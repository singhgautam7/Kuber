// The launch task queue: (1) due occurrences (recurring, EMIs, SIPs), (2) FD /
// RD maturity checks, (3) automatic backup if due, last, so it includes what
// step 1 posted. One run at a time (lease on BackgroundTaskRun); the
// processed ledger is the final safety net. Each step's failure is recorded
// and never blocks the next step.
//
// Pure Dart over Isar: the Android worker isolate runs it (WorkManager), web
// and tests run it in-process.

import 'dart:io' as io show pid;
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:isar_community/isar.dart';

import '../../features/backups/services/scheduled_backup.dart';
import '../../features/accounts/data/account.dart';
import '../../features/investments/data/investment.dart';
import '../../features/investments/domain/investment_engine.dart';
import '../utils/formatters.dart';
import '../../features/notifications/data/app_notification.dart';
import '../../features/notifications/data/notification_repository.dart';
import '../../l10n/app_localizations.dart';
import '../database/vnext_migration.dart';
import '../schedule/processed_occurrence.dart';
import '../schedule/schedule_engine.dart';
import 'background_task_run.dart';
import 'occurrence_processor.dart';

typedef BackupStep = Future<(BackupOutcome, String?)> Function();
typedef MaturityNotifier = Future<void> Function(Investment investment);

class TaskRunner {
  /// A run whose heartbeat is younger than this is considered alive.
  static const lease = Duration(minutes: 2);
  static const keepRuns = 30;

  final Isar isar;
  final int decimals;
  final AppLocalizations l10n;
  final BackupStep backup;
  final MaturityNotifier? onMatured;

  TaskRunner({
    required this.isar,
    required this.decimals,
    required this.l10n,
    required this.backup,
    this.onMatured,
  });

  /// The run currently holding the lease, if any.
  static Future<BackgroundTaskRun?> activeRun(Isar isar, {DateTime? now}) async {
    final n = now ?? DateTime.now();
    final running = await isar.backgroundTaskRuns
        .filter()
        .statusEqualTo('running')
        .sortByStartedAtDesc()
        .findFirst();
    if (running == null) return null;
    if (running.ownerPid != currentPid) return null; // its process died
    return n.difference(running.heartbeatAt) < lease ? running : null;
  }

  /// This process (0 on web, where runs are in-process anyway).
  static int get currentPid => kIsWeb ? 0 : io.pid;

  /// Runs the queue. Returns null when another run holds the lease.
  Future<BackgroundTaskRun?> run({
    required String trigger,
    DateTime? now,
    void Function(BackgroundTaskRun run)? onUpdate,
  }) async {
    BackgroundTaskRun? run;
    await isar.writeTxn(() async {
      if (await activeRun(isar, now: now) != null) return;
      // A run whose worker died mid-way: mark it failed so it doesn't hang.
      final stale = await isar.backgroundTaskRuns
          .filter()
          .statusEqualTo('running')
          .findAll();
      for (final s in stale) {
        s
          ..status = 'failed'
          ..finishedAt = DateTime.now()
          ..log = [...s.log, 'Stopped before finishing; resumed by a new run'];
      }
      await isar.backgroundTaskRuns.putAll(stale);
      final t = DateTime.now();
      run = BackgroundTaskRun()
        ..runId = '${t.microsecondsSinceEpoch}-${Random().nextInt(1 << 20)}'
        ..trigger = trigger
        ..startedAt = t
        ..heartbeatAt = t
        ..ownerPid = currentPid
        ..status = 'running'
        ..step = 'processing';
      await isar.backgroundTaskRuns.put(run!);
    });
    final r = run;
    if (r == null) return null;

    Future<void> save() async {
      r.heartbeatAt = DateTime.now();
      await isar.writeTxn(() => isar.backgroundTaskRuns.put(r));
      onUpdate?.call(r);
    }

    // 0. Rows written by a pre-vNext code path (demo data, old flows) are
    // migrated first; idempotent and quick when there is nothing to do.
    try {
      await VNextMigration.run(isar, now: now);
    } catch (e) {
      r.log = [...r.log, 'Migration failed: $e'];
    }

    // 1. Due occurrences.
    try {
      final summary = await OccurrenceProcessor(isar,
              decimals: decimals, l10n: l10n, runId: r.runId)
          .run(
        now: now,
        onProgress: (done, total, busy) async {
          r
            ..stepDone = done
            ..stepTotal = total
            ..busySourceKeys = busy.toList();
          await save();
        },
      );
      r
        ..postedRecurring = summary.recurring
        ..postedEmis = summary.emis
        ..postedSips = summary.sips
        ..failedOccurrences = summary.failed
        ..busySourceKeys = []
        ..log = [
          ...r.log,
          'Posted ${summary.recurring} recurring, ${summary.emis} EMIs, '
              '${summary.sips} SIPs',
          ...summary.log,
          for (final name in summary.paidOffLoans) 'Paid off: $name',
        ];
    } catch (e) {
      r
        ..failedOccurrences += 1
        ..log = [...r.log, 'Processing failed: $e'];
    }

    // 2. Maturity checks.
    r
      ..step = 'maturity'
      ..stepDone = 0
      ..stepTotal = 0;
    await save();
    try {
      r.maturedCount = await _maturity(now ?? DateTime.now());
    } catch (e) {
      r.log = [...r.log, 'Maturity check failed: $e'];
    }

    // 3. Backup, after processing has committed.
    r.step = 'backup';
    r.backupStatus = 'running';
    await save();
    try {
      final (outcome, error) = await backup();
      r.backupStatus = outcome.name;
      r.backupError = error;
      if (outcome == BackupOutcome.notDue) r.backupStatus = 'notDue';
      if (outcome == BackupOutcome.failed) r.log = [...r.log, 'Backup failed: $error'];
    } catch (e) {
      r
        ..backupStatus = 'failed'
        ..backupError = 'unknown'
        ..log = [...r.log, 'Backup failed: $e'];
    }

    r
      ..step = 'done'
      ..status = r.failedOccurrences > 0 || r.backupStatus == 'failed'
          ? 'failed'
          : 'done'
      ..finishedAt = DateTime.now();
    await save();
    await _prune();
    return r;
  }

  Future<int> _maturity(DateTime now) async {
    final today = dayKey(now);
    final due = (await isar.investments
            .filter()
            .behaviourEqualTo(InvestmentBehaviour.fixedReturn)
            .statusEqualTo(InvestmentStatus.active)
            .maturityHandledEqualTo(false)
            .maturityDateIsNotNull()
            .findAll())
        .where((i) => dayKey(i.maturityDate!) <= today)
        .toList();
    var n = 0;
    for (final inv in due) {
      final key =
          ProcessedOccurrence.keyOf('maturity', inv.uid, dayKey(inv.maturityDate!));
      var fresh = false;
      await isar.writeTxn(() async {
        if (await isar.processedOccurrences.getByKey(key) != null) return;
        await isar.processedOccurrences.put(ProcessedOccurrence()
          ..key = key
          ..sourceType = 'maturity'
          ..sourceId = inv.uid
          ..occurrenceDate = dayKey(inv.maturityDate!)
          ..status = 'posted'
          ..createdAt = DateTime.now());
        fresh = true;
      });
      if (!fresh) continue;
      n++;
      final account = inv.accountId == null
          ? null
          : await isar.accounts.get(int.tryParse(inv.accountId!) ?? -1);
      final amount = maturityValue(inv) ?? currentValue(inv);
      await NotificationRepository(isar).add(
        type: NotificationType.general,
        title: l10n.msInvNotifTitle(AppFormatter.amountToken(amount)),
        body: l10n.msInvNotifBody(account?.name ?? inv.name),
        payload: 'investment:${inv.uid}',
      );
      await onMatured?.call(inv);
    }
    return n;
  }

  Future<void> _prune() async {
    final all = await isar.backgroundTaskRuns.where().sortByStartedAtDesc().findAll();
    if (all.length <= keepRuns) return;
    await isar.writeTxn(() => isar.backgroundTaskRuns
        .deleteAll(all.skip(keepRuns).map((r) => r.id).toList()));
  }
}
