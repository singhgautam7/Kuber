import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/schedule/legacy_schedules.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';

import 'schedule_fixture_cases.dart';

Schedule _fromCase(ScheduleCase c) => scheduleFrom(
      start: c.start,
      count: c.count,
      unit: ScheduleUnit.values.byName(c.unit.name),
      endType: switch (c.endType) {
        'occurrences' => ScheduleEnd.afterCount,
        'date' => ScheduleEnd.onDate,
        _ => ScheduleEnd.never,
      },
      endCount: c.endAfter,
      endDate: c.endDate,
    );

String _k(int key) => fmtDay(dayOf(key));

void main() {
  final fixtures = jsonDecode(
          File('test/fixtures/schedules/recurring_chains.json').readAsStringSync())
      as Map<String, dynamic>;

  test('engine reproduces every recorded recurring chain (dates)', () {
    for (final c in recurringCases()) {
      final expected = (fixtures[c.id] as List)
          .cast<String>()
          // Approved fix R1: occurrences are calendar days. The old chains
          // carried the creation time of day; the dates themselves are equal.
          .map((d) => d.split('T').first)
          .toList();
      final actual = upcomingOccurrences(_fromCase(c), limit: 24)
          .map((o) => _k(o.day))
          .toList();
      expect(actual, expected, reason: c.id);
    }
  });

  test('approved fix R1: a 14:35 start posts on its day, no time kept', () {
    final s = scheduleFrom(
        start: DateTime(2025, 1, 15, 14, 35), unit: ScheduleUnit.day);
    // Old: due only once the clock passed 14:35 on 15 Jan.
    expect(dueOccurrences(s, 20250115).map((o) => o.day), [20250115]);
  });

  test('approved fix R2: resume does not post the paused period', () {
    final s = scheduleFrom(start: DateTime(2025, 1, 1), unit: ScheduleUnit.day);
    pause(s, DateTime(2025, 1, 1));
    expect(dueOccurrences(s, 20250301), isEmpty);
    resume(s, DateTime(2025, 3, 1, 9));
    expect(dueOccurrences(s, 20250301).map((o) => o.day), [20250301]);
    // Old behaviour, for the record: the catch-up fixture posts everything.
    final old = legacyRecurringCatchUp(
        count: 1,
        unit: LegacyUnit.day,
        startDate: DateTime(2025, 1, 1),
        nextDueAt: DateTime(2025, 1, 1),
        endType: 'never',
        executionCount: 0,
        isPaused: false,
        now: DateTime(2025, 3, 1, 9));
    expect(old.posted.length, 60);
  });

  test('month-end anchors clamp and return (31 Jan, 29 Feb yearly)', () {
    final m = scheduleFrom(start: DateTime(2026, 1, 31));
    expect(upcomingOccurrences(m, limit: 4).map((o) => o.day),
        [20260131, 20260228, 20260331, 20260430]);
    final y = scheduleFrom(start: DateTime(2024, 2, 29), unit: ScheduleUnit.year);
    expect(upcomingOccurrences(y, limit: 5).map((o) => o.day),
        [20240229, 20250228, 20260228, 20270228, 20280229]);
  });

  test('anchor helpers: start 1 Nov on the 15th, weekly on Saturday', () {
    expect(firstMonthlyOnOrAfter(DateTime(2026, 11, 1), 15), DateTime(2026, 11, 15));
    expect(firstMonthlyOnOrAfter(DateTime(2026, 11, 20), 15), DateTime(2026, 12, 15));
    expect(firstMonthlyOnOrAfter(DateTime(2027, 2, 1), 31), DateTime(2027, 2, 28));
    expect(firstWeekdayOnOrAfter(DateTime(2026, 10, 21), DateTime.saturday),
        DateTime(2026, 10, 24));
  });

  test('watermark, posting and processing twice post nothing', () {
    final s = scheduleFrom(start: DateTime(2025, 1, 1), unit: ScheduleUnit.week);
    final due = dueOccurrences(s, 20250131);
    expect(due.map((o) => o.day), [20250101, 20250108, 20250115, 20250122, 20250129]);
    for (final o in due) {
      markPosted(s, o.day);
    }
    expect(dueOccurrences(s, 20250131), isEmpty);
    expect(s.postedCount, 5);
  });

  test('afterCount end counts posted occurrences; skips do not use a slot', () {
    final s = scheduleFrom(
        start: DateTime(2025, 1, 1),
        endType: ScheduleEnd.afterCount,
        endCount: 3);
    expect(skipNext(s, now: DateTime(2025, 1, 1)), 20250101);
    final due = dueOccurrences(s, 20250601);
    expect(due.map((o) => '${o.day}${o.skipped ? 's' : ''}'),
        ['20250101s', '20250201', '20250301', '20250401']);
    expect(totalOccurrences(s), 3);
  });

  test('edit future only keeps the watermark and never back-fills', () {
    final old = scheduleFrom(start: DateTime(2025, 1, 5));
    markPosted(old, 20250105);
    final edited = scheduleFrom(start: DateTime(2025, 1, 1)); // moved earlier
    final next = editFutureOnly(old, edited, now: DateTime(2025, 3, 10));
    expect(dueOccurrences(next, 20250310), isEmpty);
    expect(nextDate(next, fromKey: 20250310), 20250401);
    expect(next.postedCount, 1);
  });

  test('legacy compat lattice chains the old algorithm from legacyNextDue', () {
    final s = scheduleFrom(start: DateTime(2025, 1, 31))
      ..compat = 'legacyRecurring'
      ..legacyNextDue = DateTime(2025, 3, 3); // drifted by old code
    expect(upcomingOccurrences(s, limit: 3).map((o) => o.day),
        [20250303, 20250403, 20250503]);
  });

  group('generated properties', () {
    final rnd = Random(7);
    for (var i = 0; i < 400; i++) {
      final unit = ScheduleUnit.values[rnd.nextInt(4)];
      final count = 1 + rnd.nextInt(unit == ScheduleUnit.day ? 40 : 6);
      final start = DateTime(1999 + rnd.nextInt(40), 1 + rnd.nextInt(12),
          1 + rnd.nextInt(31));
      final s = scheduleFrom(start: start, count: count, unit: unit);
      test('#$i ${unit.name}$count from $start', () {
        final occ = upcomingOccurrences(s, limit: 60).map((o) => o.day).toList();
        expect(occ.first, dayKey(s.startDate!));
        for (var k = 1; k < occ.length; k++) {
          expect(occ[k] > occ[k - 1], isTrue, reason: 'strictly increasing');
        }
        // No gaps / duplicates against a brute-force day walk.
        final walk = <int>[];
        var d = occ.first;
        final anchor = s.anchorDay;
        while (walk.length < occ.length) {
          final dd = dayOf(d);
          final ok = switch (unit) {
            ScheduleUnit.day => daysBetween(occ.first, d) % count == 0,
            ScheduleUnit.week => daysBetween(occ.first, d) % (7 * count) == 0,
            ScheduleUnit.month => ((dd.year * 12 + dd.month) -
                            (s.startDate!.year * 12 + s.startDate!.month)) %
                        count ==
                    0 &&
                dd.day == anchor!.clamp(1, daysInMonthOf(dd.year, dd.month)),
            ScheduleUnit.year => (dd.year - s.startDate!.year) % count == 0 &&
                dd.month == s.anchorMonth &&
                dd.day == anchor!.clamp(1, daysInMonthOf(dd.year, dd.month)),
          };
          if (ok) walk.add(d);
          d = addDays(d, 1);
        }
        expect(occ, walk);
        // End date respected (inclusive) and processing twice posts nothing.
        final endKey = occ[occ.length ~/ 2];
        final bounded = s.copy()
          ..endType = ScheduleEnd.onDate
          ..endDate = dayOf(endKey);
        final due = dueOccurrences(bounded, 99991231);
        expect(due.last.day, endKey);
        for (final o in due) {
          markPosted(bounded, o.day);
        }
        expect(dueOccurrences(bounded, 99991231), isEmpty);
        expect(isEnded(bounded), isTrue);
      });
    }
  });

  test('catch-up after a 5-year gap posts each occurrence once', () {
    final s = scheduleFrom(start: DateTime(2020, 1, 31));
    final due = dueOccurrences(s, 20250131);
    expect(due.length, 61);
    expect(due.map((o) => o.day).toSet().length, 61);
    for (final o in due) {
      markPosted(s, o.day);
    }
    expect(dueOccurrences(s, 20250131), isEmpty);
  });

  test('timezone safe: day keys never move with DST or offsets', () {
    // Day arithmetic is done in UTC, so a 1-day step is always one day.
    var d = 20250301;
    for (var i = 0; i < 400; i++) {
      final n = addDays(d, 1);
      expect(daysBetween(d, n), 1);
      d = n;
    }
  });
}
