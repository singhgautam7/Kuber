// BackgroundTasks: the "anything due?" gate that decides whether a run starts
// on app open / from the worker, and the snackbar / notification texts.
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/background_task_run.dart';
import 'package:kuber/core/background/background_tasks.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  late Isar isar;
  setUp(() async => isar = await openTestIsar());
  tearDown(() => closeAndCleanIsar(isar));
  final l = AppLocalizationsEn();

  RecurringRule rule(DateTime start, {int version = 1}) => RecurringRule()
    ..name = 'Tea'
    ..amount = 20
    ..type = 'expense'
    ..categoryId = '1'
    ..accountId = '1'
    ..frequency = 'monthly'
    ..startDate = start
    ..nextDueAt = start
    ..endType = 'never'
    ..createdAt = start
    ..updatedAt = start
    ..schedule = version == 1 ? scheduleFrom(start: start) : null
    ..dataVersion = version;

  test('empty install: nothing due, no run', () async {
    expect(await BackgroundTasks.anythingDue(isar), isFalse);
  });

  test('unmigrated rows (old data, restored backup) are due', () async {
    await isar.writeTxn(() => isar.recurringRules.put(rule(DateTime(2030, 1, 1), version: 0)));
    expect(await BackgroundTasks.anythingDue(isar), isTrue);
  });

  test('an occurrence due today is due; a future one is not', () async {
    final today = DateTime.now();
    await isar.writeTxn(() =>
        isar.recurringRules.put(rule(DateTime(today.year, today.month + 1, 1))));
    expect(await BackgroundTasks.anythingDue(isar), isFalse);
    await isar.writeTxn(() => isar.recurringRules.put(rule(dayOf(todayKey()))));
    expect(await BackgroundTasks.anythingDue(isar), isTrue);
  });

  BackgroundTaskRun run() => BackgroundTaskRun()
    ..runId = 'r'
    ..trigger = 't'
    ..startedAt = DateTime(2026)
    ..heartbeatAt = DateTime(2026)
    ..status = 'done';

  test('result text: posted, failed, matured, backup', () {
    expect(BackgroundTasks.resultText(run(), l), '');
    expect(BackgroundTasks.resultText(run()..postedRecurring = 1, l), l.bgAddedOne);
    expect(
        BackgroundTasks.resultText(
            run()
              ..postedRecurring = 2
              ..postedEmis = 1
              ..postedSips = 1
              ..backupStatus = 'done',
            l),
        '${l.bgAdded(4)} · ${l.bgBackupSaved}');
    expect(
        BackgroundTasks.resultText(
            run()
              ..failedOccurrences = 2
              ..maturedCount = 1
              ..backupStatus = 'failed',
            l),
        '${l.bgFailRecurring('2')} · ${l.bgResultMatured('1')} · ${l.bgFailBackup}');
  });

  test('step text follows the step', () {
    expect(BackgroundTasks.stepText(run()..step = 'processing', l), l.bgStepStarting);
    expect(
        BackgroundTasks.stepText(
            run()
              ..step = 'processing'
              ..stepTotal = 1,
            l),
        l.bgStepProcessingOne);
    expect(
        BackgroundTasks.stepText(
            run()
              ..step = 'processing'
              ..stepTotal = 3,
            l),
        l.bgStepProcessing('3'));
    expect(BackgroundTasks.stepText(run()..step = 'maturity', l), l.bgStepMaturity);
    expect(BackgroundTasks.stepText(run()..step = 'backup', l), l.bgStepBackup);
  });

  test('worker retries only transient backup failures', () {
    expect(BackgroundTasks.shouldRetry(null), isTrue);
    expect(BackgroundTasks.shouldRetry(run()), isFalse);
    expect(
        BackgroundTasks.shouldRetry(run()
          ..backupStatus = 'failed'
          ..backupError = 'write_error'),
        isTrue);
    expect(
        BackgroundTasks.shouldRetry(run()
          ..backupStatus = 'failed'
          ..backupError = 'folder_revoked'),
        isFalse);
  });
}
