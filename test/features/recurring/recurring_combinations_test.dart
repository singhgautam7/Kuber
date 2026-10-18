import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/recurring/data/recurring_interval.dart';
import 'package:kuber/features/recurring/data/recurring_processor.dart';
import 'package:kuber/features/recurring/data/recurring_repository.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

/// Start / end / interval combinations run through the real processor (it
/// reads DateTime.now(), so dates here are relative to today).
void main() {
  late Isar isar;
  late DateTime today;
  setUpAll(() async => initialiseIsarForTests());
  setUp(() async {
    isar = await openTestIsar();
    final n = DateTime.now();
    today = DateTime(n.year, n.month, n.day);
  });
  tearDown(() async => closeAndCleanIsar(isar));

  DateTime daysAgo(int d) => DateTime(today.year, today.month, today.day - d);

  RecurringRule rule(
    int count,
    RecurrenceUnit unit, {
    required DateTime start,
    DateTime? next,
    String endType = 'never',
    int? endAfter,
    DateTime? endDate,
    bool isPaused = false,
  }) =>
      makeRecurringRule(
        frequency: 'custom',
        customDays: count,
        startDate: start,
        nextDueAt: next ?? start,
        endType: endType,
        endAfter: endAfter,
        endDate: endDate,
        isPaused: isPaused,
      )..intervalUnit = unit.name;

  Future<RecurringRule> insert(RecurringRule r) async {
    await isar.writeTxn(() => isar.recurringRules.put(r));
    return r;
  }

  Future<List<DateTime>> txnDays(RecurringRule r) async {
    final txns = await isar.transactions
        .filter()
        .linkedRuleIdEqualTo('${r.id}')
        .sortByCreatedAt()
        .findAll();
    return [
      for (final t in txns)
        DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day),
    ];
  }

  Future<RecurringRule> reload(RecurringRule r) async =>
      (await isar.recurringRules.get(r.id))!;

  group('catch-up with the new intervals', () {
    test('every 2 weeks, 5 weeks overdue: 3 runs, next in 1 week', () async {
      final r = await insert(rule(2, RecurrenceUnit.week, start: daysAgo(35)));
      expect(await RecurringProcessor(isar).processAll(), 3);
      expect(await txnDays(r), [daysAgo(35), daysAgo(21), daysAgo(7)]);
      expect((await reload(r)).nextDueAt, daysAgo(-7));
    });

    test('quarterly from the 1st, 7 months overdue: 3 runs', () async {
      final start = DateTime(today.year, today.month - 7, 1);
      final r = await insert(rule(3, RecurrenceUnit.month, start: start));
      expect(await RecurringProcessor(isar).processAll(), 3);
      expect(await txnDays(r), [
        start,
        DateTime(today.year, today.month - 4, 1),
        DateTime(today.year, today.month - 1, 1),
      ]);
      expect((await reload(r)).nextDueAt,
          DateTime(today.year, today.month + 2, 1));
    });

    test('every 2 years starting today runs once, next in 2 years', () async {
      final r = await insert(rule(2, RecurrenceUnit.year, start: today));
      expect(await RecurringProcessor(isar).processAll(), 1);
      expect((await reload(r)).nextDueAt,
          DateTime(today.year + 2, today.month, today.day));
    });
  });

  group('end conditions', () {
    test('every 10 days, end after 2: stops at 2 and expires', () async {
      final r = await insert(rule(10, RecurrenceUnit.day,
          start: daysAgo(50), endType: 'occurrences', endAfter: 2));
      expect(await RecurringProcessor(isar).processAll(), 2);
      final after = await reload(r);
      expect(after.executionCount, 2);
      expect(RecurringRepository.isExpired(after), isTrue);
      expect(await RecurringProcessor(isar).processAll(), 0);
    });

    test('weekly ending in 30 days: catches up and keeps going', () async {
      final r = await insert(rule(1, RecurrenceUnit.week,
          start: daysAgo(20),
          endType: 'date',
          endDate: daysAgo(-30)));
      expect(await RecurringProcessor(isar).processAll(), 3);
      expect(RecurringRepository.isExpired(await reload(r)), isFalse);
    });

    test('end date already passed: missed occurrences before it still run',
        () async {
      final r = await insert(rule(1, RecurrenceUnit.month,
          start: daysAgo(40), endType: 'date', endDate: daysAgo(1)));
      expect(await RecurringProcessor(isar).processAll(), 2);
      expect(RecurringRepository.isExpired(await reload(r)), isTrue);
      expect(await RecurringProcessor(isar).processAll(), 0);
    });

    test('daily catch-up across the end date stops on the end day', () async {
      final r = await insert(rule(1, RecurrenceUnit.day,
          start: daysAgo(10), endType: 'date', endDate: daysAgo(5)));
      expect(await RecurringProcessor(isar).processAll(), 6);
      expect(await txnDays(r), [for (var d = 10; d >= 5; d--) daysAgo(d)]);
      final after = await reload(r);
      expect(after.nextDueAt, daysAgo(4));
      expect(RecurringRepository.isExpired(after), isTrue);
    });

    test('monthly from 31 Oct ending 31 Jan records 31 Jan', () async {
      final r = await insert(rule(1, RecurrenceUnit.month,
          start: DateTime(2025, 10, 31),
          endType: 'date',
          endDate: DateTime(2026, 1, 31)));
      expect(await RecurringProcessor(isar).processAll(), 4);
      expect(await txnDays(r), [
        DateTime(2025, 10, 31),
        DateTime(2025, 11, 30),
        DateTime(2025, 12, 31),
        DateTime(2026, 1, 31),
      ]);
      expect(RecurringRepository.isExpired(await reload(r)), isTrue);
    });

    test('occurrence on an end date of today (midnight) runs', () async {
      final r = await insert(rule(1, RecurrenceUnit.week,
          start: daysAgo(14), endType: 'date', endDate: today));
      expect(await RecurringProcessor(isar).processAll(), 3);
      expect((await txnDays(r)).last, today);
      expect(RecurringRepository.isExpired(await reload(r)), isTrue);
    });

    test('future start date: nothing runs yet', () async {
      await insert(rule(3, RecurrenceUnit.month, start: daysAgo(-10)));
      expect(await RecurringProcessor(isar).processAll(), 0);
    });

    test('paused overdue quarterly rule: nothing runs', () async {
      await insert(rule(3, RecurrenceUnit.month,
          start: daysAgo(200), isPaused: true));
      expect(await RecurringProcessor(isar).processAll(), 0);
    });
  });

  group('edits', () {
    /// What the edit screen does: capture the old schedule, apply new values,
    /// recompute nextDueAt, save.
    Future<RecurringRule> edit(
        RecurringRule stale, void Function(RecurringRule) change) async {
      // The edit screen gets the rule fresh from the provider.
      final r = await reload(stale);
      final oldStart = r.startDate;
      final oldInterval = RecurrenceInterval.of(r);
      final oldNext = r.nextDueAt;
      change(r);
      r.nextDueAt = RecurringRepository.nextDueAfterEdit(
        r,
        oldStartDate: oldStart,
        oldInterval: oldInterval,
        oldNextDueAt: oldNext,
        lastRecordedAt: await RecurringRepository(isar).lastRecordedAt(r.id),
      );
      await RecurringRepository(isar).save(r);
      return r;
    }

    test('schedule change on a day the rule already ran: no duplicate',
        () async {
      // Weekly from 14 days ago: runs on -14, -7 and today.
      final r = await insert(rule(1, RecurrenceUnit.week, start: daysAgo(14)));
      expect(await RecurringProcessor(isar).processAll(), 3);

      // Every 2 weeks from the same start also lands on today.
      final e = await edit(r, (r) => r.customDays = 2);
      expect(e.nextDueAt, daysAgo(-14));
      expect(await RecurringProcessor(isar).processAll(), 0);
      expect((await txnDays(r)).where((d) => d == today).length, 1);
    });

    test('re-picking today as start on a rule that ran today: no duplicate',
        () async {
      final r = await insert(rule(1, RecurrenceUnit.month,
          start: DateTime.now())); // created today, start keeps the time
      expect(await RecurringProcessor(isar).processAll(), 1);
      // The date picker returns midnight, so the start "changes".
      final e = await edit(r, (r) => r.startDate = today);
      expect(e.nextDueAt.isAfter(today), isTrue);
      expect(await RecurringProcessor(isar).processAll(), 0);
    });

    test('switch to a schedule with a past occurrence: no catch-up', () async {
      final r = await insert(rule(1, RecurrenceUnit.month,
          start: DateTime(today.year, today.month - 5, 1),
          next: DateTime(today.year, today.month + 1, 1)));
      final e = await edit(r, (r) => r
        ..customDays = 10
        ..intervalUnit = 'day');
      expect(e.nextDueAt.isBefore(today), isFalse);
      expect(await RecurringProcessor(isar).processAll(),
          e.nextDueAt == today ? 1 : 0);
    });

    test('ending a rule after N it already reached: nothing more runs',
        () async {
      final r = await insert(rule(1, RecurrenceUnit.week, start: daysAgo(14)));
      expect(await RecurringProcessor(isar).processAll(), 3);
      final e = await edit(r, (r) => r
        ..endType = 'occurrences'
        ..endAfter = 3);
      expect(RecurringRepository.isExpired(e), isTrue);
      expect(await RecurringProcessor(isar).processAll(), 0);
    });

    test('editing a paused rule keeps it paused and idle', () async {
      final r = await insert(rule(1, RecurrenceUnit.month,
          start: daysAgo(90), next: daysAgo(-5), isPaused: true));
      await edit(r, (r) => r.customDays = 3);
      expect((await reload(r)).isPaused, isTrue);
      expect(await RecurringProcessor(isar).processAll(), 0);
    });
  });
}
