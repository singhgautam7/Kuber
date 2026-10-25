import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/background_task_run.dart';
import 'package:kuber/core/background/task_runner.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/backups/services/scheduled_backup.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  late Isar isar;
  setUp(() async {
    isar = await openTestIsar();
    final start = DateTime(2026, 10, 15);
    await isar.writeTxn(() => isar.recurringRules.put(RecurringRule()
      ..name = 'Tea'
      ..amount = 20
      ..type = 'expense'
      ..categoryId = '1'
      ..accountId = '1'
      ..frequency = 'daily'
      ..startDate = start
      ..nextDueAt = start
      ..endType = 'never'
      ..createdAt = start
      ..updatedAt = start
      ..schedule = scheduleFrom(start: start, unit: ScheduleUnit.day)
      ..dataVersion = 1));
  });
  tearDown(() => closeAndCleanIsar(isar));

  TaskRunner runner(BackupStep backup) => TaskRunner(
      isar: isar, decimals: 0, l10n: AppLocalizationsEn(), backup: backup);

  test('processing commits before the backup reads', () async {
    int? seenAtBackup;
    final steps = <String>[];
    final r = await runner(() async {
      seenAtBackup = await isar.transactions.count();
      return (BackupOutcome.done, null);
    }).run(
        trigger: 'coldStart',
        now: DateTime(2026, 10, 21, 9),
        onUpdate: (r) {
          if (steps.isEmpty || steps.last != r.step) steps.add(r.step);
        });
    expect(seenAtBackup, 7);
    expect(steps, ['processing', 'maturity', 'backup', 'done']);
    expect(r!.status, 'done');
    expect(r.postedRecurring, 7);
    expect(r.backupStatus, 'done');
  });

  test('a backup failure never blocks processing', () async {
    final r = await runner(() async => throw Exception('disk'))
        .run(trigger: 'coldStart', now: DateTime(2026, 10, 21, 9));
    expect(r!.postedRecurring, 7);
    expect(r.backupStatus, 'failed');
    expect(r.status, 'failed');
    expect(await isar.transactions.count(), 7);
  });

  test('lease: a live run blocks a second one; overlapping runs post once',
      () async {
    final now = DateTime(2026, 10, 21, 9);
    final results = await Future.wait([
      runner(() async => (BackupOutcome.notDue, null))
          .run(trigger: 'coldStart', now: now),
      runner(() async => (BackupOutcome.notDue, null))
          .run(trigger: 'resume', now: now),
    ]);
    expect(results.where((r) => r != null).length, greaterThanOrEqualTo(1));
    expect(await isar.transactions.count(), 7);
  });

  test('a worker killed mid-run: its stale lease is taken over, no duplicates',
      () async {
    final dead = DateTime(2026, 10, 21, 8);
    await isar.writeTxn(() => isar.backgroundTaskRuns.put(BackgroundTaskRun()
      ..runId = 'dead'
      ..trigger = 'coldStart'
      ..startedAt = dead
      ..heartbeatAt = dead
      ..ownerPid = TaskRunner.currentPid
      ..status = 'running'));
    // A live lease (this process, heartbeat now) blocks.
    final blocked = await runner(() async => (BackupOutcome.notDue, null))
        .run(trigger: 'retry', now: dead.add(const Duration(seconds: 30)));
    expect(blocked, isNull);
    // Two minutes later the lease is stale: the new run takes over.
    final r = await runner(() async => (BackupOutcome.notDue, null))
        .run(trigger: 'retry', now: dead.add(const Duration(minutes: 5)));
    expect(r, isNotNull);
    final old = await isar.backgroundTaskRuns.filter().runIdEqualTo('dead').findFirst();
    expect(old!.status, 'failed');
    expect(await isar.transactions.count(), 7);
  });

  test('a run left by a killed process is taken over at once', () async {
    final t = DateTime.now();
    await isar.writeTxn(() => isar.backgroundTaskRuns.put(BackgroundTaskRun()
      ..runId = 'killed'
      ..trigger = 'coldStart'
      ..startedAt = t
      ..heartbeatAt = t
      ..ownerPid = TaskRunner.currentPid + 1
      ..status = 'running'));
    expect(await TaskRunner.activeRun(isar), isNull);
    final r = await runner(() async => (BackupOutcome.notDue, null)).run(trigger: 'retry');
    expect(r, isNotNull);
    final old = await isar.backgroundTaskRuns.filter().runIdEqualTo('killed').findFirst();
    expect(old!.status, 'failed');
  });
}
