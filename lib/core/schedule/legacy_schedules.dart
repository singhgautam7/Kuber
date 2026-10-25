// The schedule rules Kuber used before the shared schedule engine, kept
// verbatim so migration can compare old and new dates per record and so a
// record whose dates would move (outside an approved fix) keeps the old rule.
// Characterization fixtures in test/fixtures/schedules/ were recorded from
// this code. Pure Dart. Do not "fix" anything here.

enum LegacyUnit { day, week, month, year }

/// Old `RecurringRepository.computeNextDue`, minus the RecurringRule type.
DateTime legacyRecurringNext({
  required int count,
  required LegacyUnit unit,
  required DateTime startDate,
  required DateTime from,
}) {
  final n = count < 1 ? 1 : count;
  switch (unit) {
    case LegacyUnit.day:
    case LegacyUnit.week:
      final days = unit == LegacyUnit.week ? n * 7 : n;
      return DateTime(from.year, from.month, from.day + days, from.hour,
          from.minute, from.second, from.millisecond, from.microsecond);
    case LegacyUnit.month:
    case LegacyUnit.year:
      final months = unit == LegacyUnit.year ? n * 12 : n;
      final fromIsMonthEnd =
          from.day == DateTime(from.year, from.month + 1, 0).day;
      final anchor = fromIsMonthEnd && startDate.day > from.day
          ? startDate.day
          : from.day;
      final target = DateTime(from.year, from.month + months, 1);
      final daysInTarget = DateTime(target.year, target.month + 1, 0).day;
      return DateTime(target.year, target.month,
          anchor > daysInTarget ? daysInTarget : anchor);
  }
}

/// Old `RecurrenceInterval.legacy` (pre-interval `frequency` strings).
(int, LegacyUnit) legacyFrequency(String frequency, int? customDays) =>
    switch (frequency) {
      'daily' => (1, LegacyUnit.day),
      'weekly' => (1, LegacyUnit.week),
      'biweekly' => (2, LegacyUnit.week),
      'monthly' => (1, LegacyUnit.month),
      'quarterly' => (3, LegacyUnit.month),
      'half_yearly' => (6, LegacyUnit.month),
      'yearly' => (1, LegacyUnit.year),
      'custom' => ((customDays ?? 1) < 1 ? 1 : (customDays ?? 1), LegacyUnit.day),
      _ => (1, LegacyUnit.day),
    };

/// Old `RecurringRepository.isExpired`.
bool legacyRecurringExpired({
  required String endType,
  int? endAfter,
  DateTime? endDate,
  required int executionCount,
  required DateTime dueDate,
}) {
  switch (endType) {
    case 'occurrences':
      return endAfter != null && executionCount >= endAfter;
    case 'date':
      if (endDate == null) return false;
      return DateTime(dueDate.year, dueDate.month, dueDate.day)
          .isAfter(DateTime(endDate.year, endDate.month, endDate.day));
    default:
      return false;
  }
}

/// The occurrence dates the old `RecurringProcessor` loop would post for a
/// rule at [now] (paused rules post nothing), and the resulting nextDueAt.
({List<DateTime> posted, DateTime nextDueAt, int executionCount})
    legacyRecurringCatchUp({
  required int count,
  required LegacyUnit unit,
  required DateTime startDate,
  required DateTime nextDueAt,
  required String endType,
  int? endAfter,
  DateTime? endDate,
  required int executionCount,
  required bool isPaused,
  required DateTime now,
}) {
  var exec = executionCount;
  final posted = <DateTime>[];
  if (isPaused || !nextDueAt.isBefore(now)) {
    return (posted: posted, nextDueAt: nextDueAt, executionCount: exec);
  }
  bool expired(DateTime d) => legacyRecurringExpired(
      endType: endType,
      endAfter: endAfter,
      endDate: endDate,
      executionCount: exec,
      dueDate: d);
  if (expired(nextDueAt)) {
    return (posted: posted, nextDueAt: nextDueAt, executionCount: exec);
  }
  var due = nextDueAt;
  while (due.isBefore(now)) {
    if (expired(due)) break;
    posted.add(due);
    exec++;
    due = legacyRecurringNext(
        count: count, unit: unit, startDate: startDate, from: due);
    if (expired(due)) break;
  }
  return (posted: posted, nextDueAt: due, executionCount: exec);
}

/// Old loan EMI / SIP rule: posted only on a day whose day-of-month equals
/// [day], when the app was cold-started that day. No catch-up, no start or
/// end check. Returns the days in [from, to] (inclusive) that qualify.
List<DateTime> legacySameDayPostings(int day, DateTime from, DateTime to) {
  final out = <DateTime>[];
  var d = DateTime(from.year, from.month, from.day);
  final end = DateTime(to.year, to.month, to.day);
  while (!d.isAfter(end)) {
    if (d.day == day) out.add(d);
    d = DateTime(d.year, d.month, d.day + 1);
  }
  return out;
}
