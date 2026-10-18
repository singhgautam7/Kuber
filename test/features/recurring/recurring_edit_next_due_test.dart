import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/recurring/data/recurring_interval.dart';
import 'package:kuber/features/recurring/data/recurring_processor.dart';
import 'package:kuber/features/recurring/data/recurring_repository.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

/// Editing a rule used to reset nextDueAt to the start date, so the next app
/// open created a catch-up transaction for every occurrence since then.
void main() {
  final now = DateTime(2026, 10, 18, 22);
  final start = DateTime(2026, 1, 5);
  final storedNext = DateTime(2026, 11, 5);

  RecurringRule monthlyRule() => makeRecurringRule(
        frequency: 'monthly',
        customDays: 1,
        startDate: start,
        nextDueAt: storedNext,
      )..intervalUnit = 'month';

  DateTime afterEdit(RecurringRule edited) =>
      RecurringRepository.nextDueAfterEdit(
        edited,
        oldStartDate: start,
        oldInterval: const RecurrenceInterval(1, RecurrenceUnit.month),
        oldNextDueAt: storedNext,
        now: now,
      );

  test('name / amount edit keeps the stored next date', () {
    final edited = monthlyRule()
      ..name = 'Renamed'
      ..amount = 999;
    expect(afterEdit(edited), storedNext);
  });

  test('interval change restarts from the start date, never in the past', () {
    final quarterly = monthlyRule()..customDays = 3;
    // 5 Jan, 5 Apr, 5 Jul, 5 Oct are past; next is 5 Jan 2027.
    expect(afterEdit(quarterly), DateTime(2027, 1, 5));

    final weekly = monthlyRule()..intervalUnit = 'week';
    final next = afterEdit(weekly);
    expect(next.isBefore(DateTime(2026, 10, 18)), isFalse);
    expect(next.difference(DateTime(2026, 10, 18)).inDays, lessThan(7));
    expect(next.weekday, start.weekday);
  });

  test('a new future start date is used as is', () {
    final moved = monthlyRule()..startDate = DateTime(2026, 12, 1);
    expect(afterEdit(moved), DateTime(2026, 12, 1));
  });

  test('a schedule landing on today keeps today', () {
    final daily = monthlyRule()
      ..intervalUnit = 'day'
      ..startDate = DateTime(2026, 10, 10);
    expect(afterEdit(daily), DateTime(2026, 10, 18));
  });

  group('with the processor', () {
    late Isar isar;
    setUpAll(() async => initialiseIsarForTests());
    setUp(() async => isar = await openTestIsar());
    tearDown(() async => closeAndCleanIsar(isar));

    test('editing an old rule creates no catch-up transactions', () async {
      final today = DateTime.now();
      final oldStart = DateTime(today.year - 1, today.month, 1);
      final future = DateTime(today.year, today.month + 1, 1);
      final rule = makeRecurringRule(
        frequency: 'monthly',
        startDate: oldStart,
        nextDueAt: future,
      );
      await isar.writeTxn(() => isar.recurringRules.put(rule));

      // What the edit screen does: capture, mutate, recompute, save.
      final oldInterval = RecurrenceInterval.of(rule);
      final oldNext = rule.nextDueAt;
      rule
        ..name = 'Rent (edited)'
        ..customDays = 1
        ..intervalUnit = 'month';
      rule.nextDueAt = RecurringRepository.nextDueAfterEdit(
        rule,
        oldStartDate: oldStart,
        oldInterval: oldInterval,
        oldNextDueAt: oldNext,
      );
      await RecurringRepository(isar).save(rule);

      expect(rule.nextDueAt, future);
      expect(await RecurringProcessor(isar).processAll(), 0);
      expect(await isar.transactions.count(), 0);
    });
  });
}
