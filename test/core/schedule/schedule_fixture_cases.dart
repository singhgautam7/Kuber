// The characterization matrix shared by the legacy fixture test and the
// engine-vs-fixture test: every interval in use, anchors 1/15/28/29/30/31,
// leap and non-leap starts, every end condition, times of day.

import 'package:kuber/core/schedule/legacy_schedules.dart';

class ScheduleCase {
  final String id;
  final int count;
  final LegacyUnit unit;
  final DateTime start;
  final String endType; // never | occurrences | date
  final int? endAfter;
  final DateTime? endDate;
  const ScheduleCase(this.id, this.count, this.unit, this.start, this.endType,
      this.endAfter, this.endDate);
}

class CatchUpCase {
  final String id;
  final ScheduleCase base;
  final DateTime nextDueAt;
  final int executionCount;
  final bool isPaused;
  final DateTime now;
  const CatchUpCase(this.id, this.base, this.nextDueAt, this.executionCount,
      this.isPaused, this.now);
}

const intervals = <(int, LegacyUnit)>[
  (1, LegacyUnit.day),
  (2, LegacyUnit.day),
  (7, LegacyUnit.day),
  (10, LegacyUnit.day),
  (1, LegacyUnit.week),
  (2, LegacyUnit.week),
  (1, LegacyUnit.month),
  (2, LegacyUnit.month),
  (3, LegacyUnit.month),
  (6, LegacyUnit.month),
  (1, LegacyUnit.year),
  (2, LegacyUnit.year),
];

const anchors = [1, 15, 28, 29, 30, 31];
const sameDayDays = [1, 5, 15, 28, 29, 30, 31];

String fmtDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}'
    '${d.hour != 0 || d.minute != 0 ? 'T${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}' : ''}';

List<ScheduleCase> recurringCases() {
  final out = <ScheduleCase>[];
  final starts = <DateTime>[
    for (final y in [2024, 2025])
      for (final a in anchors) DateTime(y, 1, a),
    DateTime(2024, 2, 29),
    DateTime(2025, 3, 31),
    DateTime(2024, 8, 31),
  ];
  for (final (count, unit) in intervals) {
    final isDayWeek = unit == LegacyUnit.day || unit == LegacyUnit.week;
    for (final s in starts) {
      final variants = <DateTime>[
        s,
        // The add form's default start (DateTime.now() with a time of day)
        // only matters for day / week, where the time is carried along.
        if (isDayWeek) DateTime(s.year, s.month, s.day, 14, 35),
      ];
      for (final st in variants) {
        final base =
            '${unit.name}$count-${fmtDay(st)}'.replaceAll(':', '');
        out.add(ScheduleCase('$base-never', count, unit, st, 'never', null, null));
        out.add(ScheduleCase('$base-after5', count, unit, st, 'occurrences', 5, null));
        out.add(ScheduleCase('$base-until200d', count, unit, st, 'date', null,
            DateTime(st.year, st.month, st.day + 200)));
      }
    }
  }
  return out;
}

/// Up to 24 occurrences the old processor would post, in order, from the
/// rule's start (processor semantics: expiry checked before every post).
List<DateTime> legacyChain(ScheduleCase c, {int max = 24}) {
  final out = <DateTime>[];
  var due = c.start;
  var exec = 0;
  while (out.length < max) {
    if (legacyRecurringExpired(
        endType: c.endType,
        endAfter: c.endAfter,
        endDate: c.endDate,
        executionCount: exec,
        dueDate: due)) {
      break;
    }
    out.add(due);
    exec++;
    due = legacyRecurringNext(
        count: c.count, unit: c.unit, startDate: c.start, from: due);
  }
  return out;
}

List<CatchUpCase> catchUpCases() {
  final out = <CatchUpCase>[];
  final bases = [
    ScheduleCase('daily', 1, LegacyUnit.day, DateTime(2025, 1, 1), 'never', null, null),
    ScheduleCase('daily-1435', 1, LegacyUnit.day, DateTime(2025, 1, 1, 14, 35), 'never', null, null),
    ScheduleCase('weekly', 1, LegacyUnit.week, DateTime(2025, 1, 6), 'never', null, null),
    ScheduleCase('monthly31', 1, LegacyUnit.month, DateTime(2025, 1, 31), 'never', null, null),
    ScheduleCase('quarterly30', 3, LegacyUnit.month, DateTime(2024, 11, 30), 'never', null, null),
    ScheduleCase('yearly29feb', 1, LegacyUnit.year, DateTime(2024, 2, 29), 'never', null, null),
    ScheduleCase('monthly-after3', 1, LegacyUnit.month, DateTime(2025, 1, 15), 'occurrences', 3, null),
    ScheduleCase('monthly-until', 1, LegacyUnit.month, DateTime(2025, 1, 15), 'date', null, DateTime(2025, 4, 15)),
  ];
  // "now" at 9:00 and at 18:00 on several days after the start, paused or not.
  final nows = [
    DateTime(2025, 1, 1, 9),
    DateTime(2025, 2, 1, 9),
    DateTime(2025, 3, 31, 18),
    DateTime(2025, 7, 10, 9),
    DateTime(2027, 3, 1, 9),
  ];
  for (final b in bases) {
    for (final now in nows) {
      for (final paused in [false, true]) {
        out.add(CatchUpCase(
            '${b.id}@${fmtDay(now)}${paused ? '-paused' : ''}'.replaceAll(':', ''),
            b,
            b.start,
            0,
            paused,
            now));
      }
    }
  }
  return out;
}
