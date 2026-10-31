// Starts the launch task queue (task_runner.dart) the right way per platform:
// Android -> WorkManager expedited unique work (BackgroundTasksWorker.kt),
// which runs `backgroundMain` in a headless engine, so the queue finishes even
// if the app is closed right after opening. Web / desktop / tests -> in
// process. The UI follows progress through the BackgroundTaskRun rows
// (Isar watchers), never through this class.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';

import '../../features/backups/services/saf_backup_store.dart';
import '../../features/backups/services/scheduled_backup.dart';
import '../../features/investments/data/investment.dart';
import '../../features/loans/data/loan.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../l10n/app_localizations.dart';
import '../schedule/schedule_engine.dart';
import '../services/notification_service.dart';
import '../utils/formatters.dart';
import 'background_task_run.dart';
import 'occurrence_processor.dart';
import 'task_runner.dart';

class BackgroundTasks {
  static const _channel = MethodChannel('com.grs.kuber/background_tasks');

  static bool get _useWorker => !kIsWeb && Platform.isAndroid;

  /// Something to do right now? Indexed queries only (about 1 ms).
  static Future<bool> anythingDue(Isar isar) async {
    // Unmigrated rows (demo data, pre-vNext flows): the run migrates them.
    if (await isar.recurringRules.filter().dataVersionLessThan(1).count() > 0 ||
        await isar.loans.filter().dataVersionLessThan(1).count() > 0 ||
        await isar.investments.filter().dataVersionLessThan(1).count() > 0) {
      return true;
    }
    if (await OccurrenceProcessor.countDue(isar) > 0) return true;
    final today = todayKey();
    final matured = await isar.investments
        .filter()
        .behaviourEqualTo(InvestmentBehaviour.fixedReturn)
        .statusEqualTo(InvestmentStatus.active)
        .maturityHandledEqualTo(false)
        .maturityDateIsNotNull()
        .findAll();
    if (matured.any((i) => dayKey(i.maturityDate!) <= today)) return true;
    return ScheduledBackup.isDueNow(isar);
  }

  /// Set by the app: follows a run that was just started or queued, so its
  /// progress and result reach the in-app reporter whoever started it (app
  /// open, resume, Retry from the failure notification, the dev screen).
  static void Function(DateTime since)? onStarted;

  /// Starts a run when something is due (or [force], for Retry). Returns
  /// true when a run was started or queued.
  static Future<bool> start(Isar isar, AppLocalizations l10n,
      {required String trigger, bool force = false}) async {
    final since = DateTime.now();
    if (!force && !await anythingDue(isar)) return false;
    if (await TaskRunner.activeRun(isar) != null) {
      onStarted?.call(since);
      return true;
    }
    if (_useWorker) {
      try {
        await _channel.invokeMethod('enqueue', {'trigger': trigger});
        onStarted?.call(since);
        return true;
      } catch (e) {
        debugPrint('Kuber: WorkManager enqueue failed, running in-process: $e');
      }
    }
    unawaited(runQueue(isar, l10n, trigger: trigger));
    onStarted?.call(since);
    return true;
  }

  /// Runs the queue in this isolate. [notify] posts the Background tasks
  /// notification (worker runs; the in-app snackbar covers in-process runs).
  static Future<BackgroundTaskRun?> runQueue(Isar isar, AppLocalizations l10n,
      {required String trigger, bool notify = false}) async {
    final notifications = NotificationService();
    String? lastText;
    final runner = TaskRunner(
      isar: isar,
      decimals: AppFormatter.current.currency.decimals,
      l10n: l10n,
      backup: () => ScheduledBackup.runIfDue(isar, SafBackupStore()),
    );
    final run = await runner.run(
      trigger: trigger,
      onUpdate: notify
          ? (r) {
              if (r.status != 'running') return;
              final text = stepText(r, l10n);
              if (text == lastText) return;
              lastText = text;
              notifications.showBackgroundProgress(
                channelName: l10n.bgChannelName,
                channelDescription: l10n.bgChannelDesc,
                title: l10n.bgNotifTitle,
                body: text,
                done: r.stepDone,
                total: r.stepTotal,
              );
            }
          : null,
    );
    if (notify && run != null) {
      if (run.status == 'done') {
        await notifications.clearBackground();
      } else {
        final backupFailed = run.backupStatus == 'failed';
        await notifications.showBackgroundFailure(
          channelName: l10n.bgChannelName,
          channelDescription: l10n.bgChannelDesc,
          title: l10n.bgNotifFailedTitle,
          body: resultText(run, l10n),
          retryLabel: l10n.bgRetry,
          payload: backupFailed ? 'background:backup' : 'background:recurring',
        );
      }
    }
    return run;
  }

  static int _posted(BackgroundTaskRun r) => r.postedRecurring + r.postedEmis + r.postedSips;

  /// "Adding 2 recurring transactions…", "Backing up…".
  static String stepText(BackgroundTaskRun r, AppLocalizations l10n) {
    switch (r.step) {
      case 'processing':
        final n = r.stepTotal;
        if (n <= 0) return l10n.bgStepStarting;
        return n == 1 ? l10n.bgStepProcessingOne : l10n.bgStepProcessing('$n');
      case 'maturity':
        return l10n.bgStepMaturity;
      case 'backup':
        return l10n.bgStepBackup;
    }
    return l10n.bgStepStarting;
  }

  /// "Added 3 transactions · Backup saved", "Backup failed", or '' when
  /// nothing happened.
  static String resultText(BackgroundTaskRun r, AppLocalizations l10n) {
    final parts = <String>[];
    final posted = _posted(r);
    if (posted == 1) parts.add(l10n.bgAddedOne);
    if (posted > 1) parts.add(l10n.bgAdded(posted));
    if (r.failedOccurrences == 1) parts.add(l10n.bgFailRecurringOne);
    if (r.failedOccurrences > 1) parts.add(l10n.bgFailRecurring('${r.failedOccurrences}'));
    if (r.maturedCount > 0) parts.add(l10n.bgResultMatured('${r.maturedCount}'));
    if (r.backupStatus == 'done') parts.add(l10n.bgBackupSaved);
    if (r.backupStatus == 'failed') parts.add(l10n.bgFailBackup);
    return parts.join(' · ');
  }

  /// Whether a WorkManager retry is worth it (transient backup failure).
  static bool shouldRetry(BackgroundTaskRun? r) =>
      r == null ||
      (r.backupStatus == 'failed' && ScheduledBackup.isTransient(r.backupError));
}
