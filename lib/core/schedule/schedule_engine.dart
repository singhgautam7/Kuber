// The shared schedule engine for recurring rules, loan EMIs and SIPs.
//
// Occurrences are calendar days held as yyyymmdd ints, so no time of day and
// no timezone can move one. Month and year intervals keep the anchor day and
// clamp to short months (31 Jan -> 28/29 Feb -> 31 Mar; 29 Feb yearly ->
// 28 Feb in non-leap years). Day and week intervals are plain day arithmetic.
//
// Pure Dart (no Flutter), safe on any isolate.

import 'legacy_schedules.dart';
import 'schedule.dart';

// ── Day keys ────────────────────────────────────────────────────────────

int dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

DateTime dayOf(int key) => DateTime(key ~/ 10000, key ~/ 100 % 100, key % 100);

int addDays(int key, int days) {
  final u = DateTime.utc(key ~/ 10000, key ~/ 100 % 100, key % 100 + days);
  return u.year * 10000 + u.month * 100 + u.day;
}

int todayKey([DateTime? now]) => dayKey(now ?? DateTime.now());

int daysInMonthOf(int year, int month) =>
    DateTime.utc(year, month + 1, 0).day;

/// Whole days from [a] to [b] (b - a).
int daysBetween(int a, int b) => DateTime.utc(b ~/ 10000, b ~/ 100 % 100, b % 100)
    .difference(DateTime.utc(a ~/ 10000, a ~/ 100 % 100, a % 100))
    .inDays;

// ── Construction ────────────────────────────────────────────────────────

/// A schedule whose anchor follows [start] (day of month, weekday, month).
Schedule scheduleFrom({
  required DateTime start,
  int count = 1,
  ScheduleUnit unit = ScheduleUnit.month,
  int? anchorDay,
  ScheduleEnd endType = ScheduleEnd.never,
  DateTime? endDate,
  int? endCount,
}) {
  final s = Schedule()
    ..startDate = DateTime(start.year, start.month, start.day)
    ..intervalCount = count < 1 ? 1 : count
    ..intervalUnit = unit
    ..endType = endType
    ..endDate = endDate == null
        ? null
        : DateTime(endDate.year, endDate.month, endDate.day)
    ..endCount = endCount;
  s.anchorDay = switch (unit) {
    ScheduleUnit.month || ScheduleUnit.year => anchorDay ?? start.day,
    ScheduleUnit.week => start.weekday,
    ScheduleUnit.day => null,
  };
  if (unit == ScheduleUnit.year) s.anchorMonth = start.month;
  return s;
}

/// First day on or after [from] matching a monthly [anchorDay] (clamped).
/// Used by the When component: "start 1 Nov, on the 15th -> first 15 Nov".
DateTime firstMonthlyOnOrAfter(DateTime from, int anchorDay) {
  final f = DateTime(from.year, from.month, from.day);
  for (var i = 0; i < 2; i++) {
    final m = DateTime(f.year, f.month + i, 1);
    final d = DateTime(m.year, m.month,
        anchorDay.clamp(1, daysInMonthOf(m.year, m.month)));
    if (!d.isBefore(f)) return d;
  }
  return f;
}

/// First day on or after [from] that falls on [weekday] (1 = Mon).
DateTime firstWeekdayOnOrAfter(DateTime from, int weekday) {
  final f = DateTime(from.year, from.month, from.day);
  return DateTime(f.year, f.month, f.day + (weekday - f.weekday + 7) % 7);
}

// ── Lattice ─────────────────────────────────────────────────────────────

/// Every date the schedule's rule produces, ascending, ignoring the
/// watermark, skips and ends. Infinite; callers stop it.
Iterable<int> lattice(Schedule s) sync* {
  final start = s.startDate;
  if (start == null) return;
  if (s.compat == 'legacyRecurring' && s.legacyNextDue != null) {
    yield* _legacyLattice(s);
    return;
  }
  final startKey = dayKey(start);
  final n = s.intervalCount < 1 ? 1 : s.intervalCount;
  switch (s.intervalUnit) {
    case ScheduleUnit.day:
    case ScheduleUnit.week:
      final step = s.intervalUnit == ScheduleUnit.week ? 7 * n : n;
      for (var k = 0;; k++) {
        yield addDays(startKey, k * step);
      }
    case ScheduleUnit.month:
      final anchor = s.anchorDay ?? start.day;
      final base = start.year * 12 + start.month - 1;
      for (var k = 0;; k++) {
        final idx = base + k * n;
        final y = idx ~/ 12, m = idx % 12 + 1;
        final key = y * 10000 + m * 100 + anchor.clamp(1, daysInMonthOf(y, m));
        if (key >= startKey) yield key;
      }
    case ScheduleUnit.year:
      final anchor = s.anchorDay ?? start.day;
      final month = s.anchorMonth ?? start.month;
      for (var k = 0;; k++) {
        final y = start.year + k * n;
        final key =
            y * 10000 + month * 100 + anchor.clamp(1, daysInMonthOf(y, month));
        if (key >= startKey) yield key;
      }
  }
}

Iterable<int> _legacyLattice(Schedule s) sync* {
  final unit = LegacyUnit.values.byName(s.intervalUnit.name);
  var d = s.legacyNextDue!;
  while (true) {
    yield dayKey(d);
    d = legacyRecurringNext(
        count: s.intervalCount, unit: unit, startDate: s.startDate!, from: d);
  }
}

// ── Queries ─────────────────────────────────────────────────────────────

class Occurrence {
  final int day;
  final bool skipped;
  const Occurrence(this.day, {this.skipped = false});
  @override
  String toString() => skipped ? '$day(skipped)' : '$day';
}

/// Occurrences after the watermark, in order: skipped ones are returned only
/// when [includeSkipped]. Respects the end date and the afterCount end
/// (counting occurrences after [Schedule.postedCount]). Stops after [limit]
/// items or past [toKey].
List<Occurrence> upcomingOccurrences(
  Schedule s, {
  int? fromKey,
  int? toKey,
  int limit = 24,
  bool includeSkipped = false,
}) {
  final out = <Occurrence>[];
  if (s.startDate == null || limit <= 0) return out;
  final endKey = s.endType == ScheduleEnd.onDate && s.endDate != null
      ? dayKey(s.endDate!)
      : null;
  var remaining = s.endType == ScheduleEnd.afterCount
      ? (s.endCount ?? 0) - s.postedCount
      : -1;
  if (s.endType == ScheduleEnd.afterCount && remaining <= 0) return out;
  final skipped = s.skippedDates.toSet();
  for (final key in lattice(s)) {
    if (endKey != null && key > endKey) break;
    if (toKey != null && key > toKey) break;
    if (key <= s.processedThrough) continue;
    final isSkipped = skipped.contains(key);
    if (!isSkipped && remaining >= 0) {
      if (remaining == 0) break;
    }
    final visible = fromKey == null || key >= fromKey;
    if (isSkipped) {
      if (includeSkipped && visible) out.add(Occurrence(key, skipped: true));
    } else {
      if (visible) out.add(Occurrence(key));
      if (remaining > 0) remaining--;
    }
    if (out.length >= limit) break;
  }
  return out;
}

/// Next [n] upcoming dates on or after [fromKey] (default: today).
List<int> nextDates(Schedule s, {int n = 3, int? fromKey}) =>
    upcomingOccurrences(s, fromKey: fromKey ?? todayKey(), limit: n)
        .map((o) => o.day)
        .toList();

/// The next date on or after [fromKey] (default today), or null when ended.
int? nextDate(Schedule s, {int? fromKey}) {
  final l = nextDates(s, n: 1, fromKey: fromKey);
  return l.isEmpty ? null : l.first;
}

/// Occurrences due on or before [today] that have not been posted yet:
/// after the watermark, not skipped, within the end. Paused schedules have
/// nothing due. Skipped dates up to today are returned with `skipped: true`
/// so the processor can record and pass them.
List<Occurrence> dueOccurrences(Schedule s, int today, {int limit = 100000}) {
  if (s.paused || s.startDate == null) return const [];
  return upcomingOccurrences(s,
      toKey: today, limit: limit, includeSkipped: true);
}

/// True when the schedule will never produce another occurrence.
bool isEnded(Schedule s) =>
    s.startDate != null && upcomingOccurrences(s, limit: 1).isEmpty;

/// Total occurrences the schedule has in all (afterCount or a date end), or
/// null when it never ends.
int? totalOccurrences(Schedule s) {
  switch (s.endType) {
    case ScheduleEnd.never:
      return null;
    case ScheduleEnd.afterCount:
      return s.endCount;
    case ScheduleEnd.onDate:
      final copy = s.copy()
        ..processedThrough = 0
        ..postedCount = 0
        ..skippedDates = [];
      return upcomingOccurrences(copy, limit: 100000).length;
  }
}

/// The last occurrence, or null when the schedule never ends.
int? lastDate(Schedule s) {
  if (s.endType == ScheduleEnd.never) return null;
  final all = upcomingOccurrences(s, limit: 100000);
  return all.isEmpty ? null : all.last.day;
}

// ── Mutations (pure; caller persists) ───────────────────────────────────

/// Marks one occurrence as posted: moves the watermark and the count.
void markPosted(Schedule s, int day) {
  if (day > s.processedThrough) s.processedThrough = day;
  s.postedCount++;
}

/// Passes a skipped occurrence (no transaction, no count).
void markSkipped(Schedule s, int day) {
  if (day > s.processedThrough) s.processedThrough = day;
  if (!s.skippedDates.contains(day)) s.skippedDates = [...s.skippedDates, day];
}

void pause(Schedule s, DateTime now) {
  s.paused = true;
  s.pausedOn = DateTime(now.year, now.month, now.day);
}

/// Resumes from today: occurrences that fell inside the pause are not posted;
/// today's occurrence still is.
void resume(Schedule s, DateTime now) {
  s.paused = false;
  s.pausedOn = null;
  final yesterday = addDays(dayKey(now), -1);
  if (yesterday > s.processedThrough) s.processedThrough = yesterday;
}

/// Adds the next upcoming occurrence (on or after today) to the skipped
/// dates. Returns it, or null when there is none.
int? skipNext(Schedule s, {DateTime? now}) {
  final next = nextDate(s, fromKey: todayKey(now));
  if (next == null) return null;
  s.skippedDates = [...s.skippedDates, next];
  return next;
}

/// Undo for [skipNext].
void unskip(Schedule s, int day) {
  s.skippedDates = s.skippedDates.where((d) => d != day).toList();
}

/// Applies an edited schedule from now on: the new rule keeps the old
/// watermark (never earlier than yesterday) and posted count, so nothing in
/// the past is posted again or back-filled.
Schedule editFutureOnly(Schedule old, Schedule edited, {DateTime? now}) {
  final yesterday = addDays(todayKey(now), -1);
  return edited.copy()
    ..processedThrough = old.processedThrough > yesterday
        ? old.processedThrough
        : yesterday
    ..postedCount = old.postedCount
    ..skippedDates =
        old.skippedDates.where((d) => d > yesterday).toList()
    ..paused = old.paused
    ..pausedOn = old.pausedOn
    ..compat = null
    ..legacyNextDue = null;
}

/// Multiplier from one occurrence to a monthly amount. A day-based month is
/// 30 days, a week-based month 52 / 12 weeks (approved: matches the design's
/// "i" sheet and the pre-vNext estimate).
double monthlyFactor(int count, ScheduleUnit unit) {
  final n = count < 1 ? 1 : count;
  return switch (unit) {
    ScheduleUnit.day => 30 / n,
    ScheduleUnit.week => 52 / 12 / n,
    ScheduleUnit.month => 1 / n,
    ScheduleUnit.year => 1 / 12 / n,
  };
}
