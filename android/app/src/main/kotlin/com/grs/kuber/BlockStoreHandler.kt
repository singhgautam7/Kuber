package com.grs.kuber

import android.content.Context
import com.google.android.gms.auth.blockstore.Blockstore
import com.google.android.gms.auth.blockstore.RetrieveBytesRequest
import com.google.android.gms.auth.blockstore.StoreBytesData
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * v7.0.0-b trial record in Google Play services Block Store, so a reinstall or
 * a device restore cannot reset the trial. Task callbacks only (they arrive on
 * the main looper, which is where MethodChannel results must complete), so
 * nothing blocks the main thread. Any failure replies null / error / false and
 * the app falls back to the local record.
 */
class BlockStoreHandler(private val context: Context) {
    companion object {
        const val CHANNEL = "com.grs.kuber/trial"
        private const val KEY = "kuber_trial"

        // Native half of the record-signing key (XOR-masked). The other half
        // lives in Dart (trial_signer.dart); the key is SHA-256 of both.
        private val A = intArrayOf(76, 119, 48, 150, 216, 81, 126, 59, 250, 132, 46, 246, 241, 72, 179, 68, 140, 126, 73, 115, 86, 215, 220, 120, 255, 250, 64, 43, 64, 145, 120, 50)
        private val B = intArrayOf(119, 236, 129, 255, 43, 227, 129, 155, 45, 22, 32, 166, 52, 232, 138, 174, 172, 201, 175, 194, 63, 150, 165, 41, 190, 121, 99, 66, 68, 27, 244, 151)
    }

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "keyPart" -> result.success(ByteArray(A.size) { (A[it] xor B[it]).toByte() })
            // Boot clock for the trial clock guard: users can't set it.
            "uptime" -> result.success(android.os.SystemClock.elapsedRealtime())
            "read" -> read(result)
            "write" -> write(call.argument<String>("data"), result)
            else -> result.notImplemented()
        }
    }

    private fun read(result: MethodChannel.Result) {
        try {
            val request = RetrieveBytesRequest.Builder().setKeys(listOf(KEY)).build()
            Blockstore.getClient(context).retrieveBytes(request)
                .addOnSuccessListener { response ->
                    val bytes = response.blockstoreDataMap[KEY]?.bytes
                    result.success(mapOf("data" to bytes?.toString(Charsets.UTF_8), "error" to false))
                }
                .addOnFailureListener { result.success(mapOf("data" to null, "error" to true)) }
        } catch (e: Exception) {
            result.success(mapOf("data" to null, "error" to true))
        }
    }

    private fun write(data: String?, result: MethodChannel.Result) {
        if (data == null) {
            result.success(false)
            return
        }
        try {
            val bytes = StoreBytesData.Builder()
                .setBytes(data.toByteArray(Charsets.UTF_8))
                .setKey(KEY)
                .setShouldBackupToCloud(true)
                .build()
            Blockstore.getClient(context).storeBytes(bytes)
                .addOnSuccessListener { result.success(true) }
                .addOnFailureListener { result.success(false) }
        } catch (e: Exception) {
            result.success(false)
        }
    }
}
