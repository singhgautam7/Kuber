// Proves lib/core/schedule/legacy_schedules.dart is a faithful copy of the
// pre-vNext RecurringRepository rules: the same matrix run through the real
// RecurringRepository.computeNextDue / isExpired on RecurringRule objects.

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/schedule/legacy_schedules.dart';
import 'package:kuber/features/recurring/data/recurring_repository.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';

import 'schedule_fixture_cases.dart';

RecurringRule _rule(ScheduleCase c) => RecurringRule()
  ..name = 'r'
  ..amount = 1
  ..type = 'expense'
  ..categoryId = '1'
  ..accountId = '1'
  ..frequency = 'custom'
  ..customDays = c.count
  ..intervalUnit = c.unit.name
  ..startDate = c.start
  ..nextDueAt = c.start
  ..endType = c.endType
  ..endAfter = c.endAfter
  ..endDate = c.endDate
  ..createdAt = c.start
  ..updatedAt = c.start;

void main() {
  test('legacy copy == RecurringRepository on the whole matrix', () {
    for (final c in recurringCases()) {
      final rule = _rule(c);
      final real = <DateTime>[];
      var due = c.start;
      while (real.length < 24) {
        rule.executionCount = real.length;
        if (RecurringRepository.isExpired(rule, due)) break;
        real.add(due);
        due = RecurringRepository.computeNextDue(rule, due);
      }
      expect(legacyChain(c).map(fmtDay).toList(), real.map(fmtDay).toList(),
          reason: c.id);
    }
  });

  test('legacy frequency mapping == RecurrenceInterval.legacy', () {
    for (final f in [
      'daily', 'weekly', 'biweekly', 'monthly', 'quarterly', 'half_yearly',
      'yearly', 'custom', 'bogus'
    ]) {
      for (final cd in [null, 0, 1, 10]) {
        final rule = RecurringRule()
          ..frequency = f
          ..customDays = cd
          ..intervalUnit = null;
        final (count, unit) = legacyFrequency(f, cd);
        final next = RecurringRepository.computeNextDue(
            rule..startDate = DateTime(2025, 1, 31), DateTime(2025, 1, 31));
        expect(
            legacyRecurringNext(
                count: count,
                unit: unit,
                startDate: DateTime(2025, 1, 31),
                from: DateTime(2025, 1, 31)),
            next,
            reason: '$f/$cd');
      }
    }
  });
}
