package com.grs.kuber

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.work.BackoffPolicy
import androidx.work.CoroutineWorker
import androidx.work.ExistingWorkPolicy
import androidx.work.ForegroundInfo
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import java.util.concurrent.TimeUnit

/**
 * Runs Kuber's launch task queue (due recurring / EMIs / SIPs, maturity
 * checks, automatic backup) as WorkManager expedited work, so it finishes
 * even if the app is closed right after opening. Unique work + KEEP means one
 * run at a time; the Dart side also holds a lease and the processed ledger
 * makes double posting impossible.
 *
 * The Dart code runs in a headless FlutterEngine (entry point backgroundMain
 * in lib/main.dart), which opens the same Isar database. On
 * Android 12+ expedited work needs no foreground service; on older versions
 * WorkManager falls back to one using [getForegroundInfo]. The visible
 * progress / failure notification is posted from Dart on the "Background
 * tasks" channel.
 */
class BackgroundTasksWorker(context: Context, params: WorkerParameters) :
    CoroutineWorker(context, params) {

    override suspend fun getForegroundInfo(): ForegroundInfo {
        val manager = applicationContext.getSystemService(Context.NOTIFICATION_SERVICE)
            as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "Background tasks", NotificationManager.IMPORTANCE_LOW)
            )
        }
        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_kuber)
            .setContentTitle("Kuber")
            .setOngoing(true)
            .setProgress(0, 0, true)
            .build()
        return ForegroundInfo(NOTIFICATION_ID, notification)
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.Main) {
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(applicationContext)
        loader.ensureInitializationComplete(applicationContext, null)
        val engine = FlutterEngine(applicationContext)
        val saf = SafBackupHandler(applicationContext)
        val finished = CompletableDeferred<Map<*, *>>()
        try {
            val messenger = engine.dartExecutor.binaryMessenger
            saf.register(messenger)
            MethodChannel(messenger, WORKER_CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "trigger" -> result.success(inputData.getString(KEY_TRIGGER) ?: "coldStart")
                    "attempt" -> result.success(runAttemptCount)
                    "finished" -> {
                        finished.complete(call.arguments as? Map<*, *> ?: emptyMap<String, Any>())
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "backgroundMain")
            )
            val outcome = withTimeoutOrNull(TimeUnit.MINUTES.toMillis(9)) { finished.await() }
            when {
                outcome == null -> if (runAttemptCount < MAX_ATTEMPTS) Result.retry() else Result.failure()
                outcome["retry"] == true && runAttemptCount < MAX_ATTEMPTS -> Result.retry()
                else -> Result.success()
            }
        } finally {
            saf.shutdown()
            engine.destroy()
        }
    }

    companion object {
        const val UNIQUE_NAME = "kuber_on_open"
        const val CHANNEL_ID = "kuber_background"
        const val NOTIFICATION_ID = 7300
        const val WORKER_CHANNEL = "com.grs.kuber/background_worker"
        const val KEY_TRIGGER = "trigger"
        const val MAX_ATTEMPTS = 3

        fun enqueue(context: Context, trigger: String) {
            val request = OneTimeWorkRequestBuilder<BackgroundTasksWorker>()
                .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)
                .setInputData(workDataOf(KEY_TRIGGER to trigger))
                .build()
            WorkManager.getInstance(context)
                .enqueueUniqueWork(UNIQUE_NAME, ExistingWorkPolicy.KEEP, request)
        }
    }
}
