// RecurringService on the shared schedule: legacy mirror fields, skip / undo,
// pause / resume without back-posting, edit future only.
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/occurrence_processor.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/recurring/domain/recurring_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  late Isar isar;
  late RecurringService service;
  setUp(() async {
    isar = await openTestIsar();
    service = RecurringService(isar);
  });
  tearDown(() => closeAndCleanIsar(isar));

  Future<int> run(DateTime now) async =>
      (await OccurrenceProcessor(isar, decimals: 2, l10n: AppLocalizationsEn())
              .run(now: now))
          .recurring;

  RecurringRule rule() => RecurringRule()
    ..name = 'Rent'
    ..amount = 18000
    ..type = 'expense'
    ..categoryId = '1'
    ..accountId = '1';

  Future<RecurringRule> reload(int id) async => (await isar.recurringRules.get(id))!;

  test('create mirrors the schedule into the legacy fields', () async {
    final id = await service.create(
        rule(),
        scheduleFrom(
            start: DateTime(2026, 1, 31),
            unit: ScheduleUnit.month,
            endType: ScheduleEnd.afterCount,
            endCount: 12));
    final r = await reload(id);
    expect(r.dataVersion, 1);
    expect(r.frequency, 'monthly');
    expect(r.intervalUnit, 'month');
    expect(r.customDays, 1);
    expect(r.endType, 'occurrences');
    expect(r.endAfter, 12);
    expect(r.nextDueAt, DateTime(2026, 1, 31));
    await run(DateTime(2026, 3, 5, 9));
    final after = await reload(id);
    expect(after.executionCount, 2);
    expect(after.nextDueAt, DateTime(2026, 3, 31), reason: 'month end anchor returns');
  });

  test('skip next posts nothing for that date; undo brings it back', () async {
    final id = await service.create(
        rule(), scheduleFrom(start: DateTime(2026, 10, 1), unit: ScheduleUnit.month));
    await run(DateTime(2026, 10, 1, 9));
    var r = await reload(id);
    final skipped = await service.skip(r);
    expect(skipped, 20261101);
    expect(await run(DateTime(2026, 11, 2, 9)), 0);
    r = await reload(id);
    expect(r.nextDueAt, DateTime(2026, 12, 1));

    // Undo before the date passes.
    final id2 = await service.create(
        rule()..name = 'Gym', scheduleFrom(start: DateTime(2026, 10, 1), unit: ScheduleUnit.month));
    await run(DateTime(2026, 10, 1, 9));
    var g = await reload(id2);
    final day = await service.skip(g);
    g = await reload(id2);
    await service.undoSkip(g, day!);
    expect(await run(DateTime(2026, 11, 1, 9)), 1);
  });

  test('pause then resume never posts the paused period', () async {
    final id = await service.create(
        rule(), scheduleFrom(start: DateTime(2026, 10, 1), unit: ScheduleUnit.day));
    final r = await reload(id);
    // Pause "now" (the real clock), then a run far later posts nothing.
    await service.setPaused(r, true);
    final paused = await reload(id);
    expect(paused.isPaused, isTrue);
    final before = await isar.transactions.count();
    await run(DateTime.now().add(const Duration(days: 20)));
    expect(await isar.transactions.count(), before);
    await service.setPaused(paused, false);
    final resumed = await reload(id);
    expect(resumed.isPaused, isFalse);
    expect(dayKey(resumed.nextDueAt) >= todayKey(), isTrue,
        reason: 'no occurrence before the resume day');
  });

  test('edit future only: past rows untouched, old terms kept as a version', () async {
    final id = await service.create(
        rule(), scheduleFrom(start: DateTime(2026, 8, 1), unit: ScheduleUnit.month));
    await run(DateTime(2026, 10, 2, 9));
    final past = await isar.transactions.where().findAll();
    expect(past.map((t) => t.amount).toSet(), {18000});
    final r = await reload(id);
    await service.edit(r,
        name: 'Rent',
        amount: 20000,
        type: 'expense',
        categoryId: '1',
        accountId: '1',
        schedule: scheduleFrom(start: DateTime(2026, 8, 1), unit: ScheduleUnit.month));
    final edited = await reload(id);
    expect(edited.versions.single.amount, 18000);
    expect(await run(DateTime(2026, 11, 2, 9)), 1);
    final all = await isar.transactions.where().sortByCreatedAt().findAll();
    expect(all.map((t) => t.amount).toList(), [18000, 18000, 18000, 20000]);
  });

  test('delete removes the rule; its past transactions stay', () async {
    final id = await service.create(
        rule(), scheduleFrom(start: DateTime(2026, 10, 1), unit: ScheduleUnit.month));
    await run(DateTime(2026, 10, 2, 9));
    await service.delete(await reload(id));
    expect(await isar.recurringRules.count(), 0);
    expect(await isar.transactions.count(), 1);
    expect(await run(DateTime(2026, 12, 2, 9)), 0);
  });
}
