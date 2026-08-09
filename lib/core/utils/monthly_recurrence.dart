// Shared day-of-month recurrence helpers used by monthly schedules
// (loan EMIs, investment SIPs, credit-card billing).
//
// Pure Dart, no Flutter dependency, so it is safe to use from engines,
// services and providers alike.

/// Last calendar day of [month] (1-12) in [year]. Uses Dart's day-0
/// normalization: `DateTime(y, m + 1, 0)` resolves to the last day of month m.
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Next occurrence of a monthly [day] (1-31), on or after the day component of
/// [from] (defaults to now). Returns midnight of the resolved date.
///
/// If [day] exceeds the target month's length it CLAMPS to the last day of that
/// month — so the 31st resolves to Feb 28/29, Apr 30, etc., never overflowing
/// into the following month.
DateTime nextMonthlyOccurrence(int day, [DateTime? from]) {
  final now = from ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  DateTime candidateFor(int year, int month) =>
      DateTime(year, month, day.clamp(1, daysInMonth(year, month)));

  var candidate = candidateFor(now.year, now.month);
  if (candidate.isBefore(today)) {
    // Roll into next month; DateTime normalizes month 13 -> Jan of next year.
    final next = DateTime(now.year, now.month + 1, 1);
    candidate = candidateFor(next.year, next.month);
  }
  return candidate;
}

/// English ordinal for a day-of-month, e.g. 1 -> "1st", 22 -> "22nd", 20 ->
/// "20th". Used in "{ordinal} of every month" labels.
String ordinalDay(int day) {
  if (day >= 11 && day <= 13) return '${day}th';
  return switch (day % 10) {
    1 => '${day}st',
    2 => '${day}nd',
    3 => '${day}rd',
    _ => '${day}th',
  };
}
