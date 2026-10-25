// Recurring rule writes on the shared schedule: new, edit (future only),
// pause / resume, skip next, delete. Writes the old schedule fields too
// (frequency, customDays, intervalUnit, nextDueAt, executionCount, isPaused,
// end fields) so pre-vNext readers (forecast, Home card, backups read by an
// older build) keep seeing the same meaning.

import 'package:isar_community/isar.dart';

import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../data/recurring_interval.dart';
import '../data/recurring_rule.dart';

class RecurringService {
  final Isar isar;
  RecurringService(this.isar);

  /// Copies the schedule into the legacy fields.
  static void mirror(RecurringRule r) {
    final s = r.schedule!;
    final interval = RecurrenceInterval(
        s.intervalCount, RecurrenceUnit.values.byName(s.intervalUnit.name));
    r
      ..frequency = interval.presetKey
      ..customDays = s.intervalCount
      ..intervalUnit = s.intervalUnit.name
      ..startDate = s.startDate!
      ..endType = switch (s.endType) {
        ScheduleEnd.never => 'never',
        ScheduleEnd.onDate => 'date',
        ScheduleEnd.afterCount => 'occurrences',
      }
      ..endAfter = s.endType == ScheduleEnd.afterCount ? s.endCount : null
      ..endDate = s.endType == ScheduleEnd.onDate ? s.endDate : null
      ..isPaused = s.paused
      ..executionCount = s.postedCount
      ..nextDueAt = _next(s);
  }

  static DateTime _next(Schedule s) {
    for (final day in lattice(s)) {
      if (day > s.processedThrough) return dayOf(day);
    }
    return DateTime(9999, 12, 31);
  }

  Future<int> save(RecurringRule r) async {
    final now = DateTime.now();
    r.updatedAt = now;
    if (r.id == Isar.autoIncrement) r.createdAt = now;
    r.dataVersion = 1;
    mirror(r);
    return isar.writeTxn(() => isar.recurringRules.put(r));
  }

  /// A new rule starting on its schedule's start (a past start catches up).
  Future<int> create(RecurringRule r, Schedule schedule) {
    r.schedule = schedule;
    return save(r);
  }

  /// Applies edits. When the amount, account, category or schedule changed
  /// on a rule that has run, the previous terms are kept as a version and the
  /// new schedule starts from the next occurrence (edit future only). Past
  /// transactions are never touched.
  Future<void> edit(
    RecurringRule r, {
    required String name,
    required double amount,
    required String type,
    required String categoryId,
    required String accountId,
    String? notes,
    required Schedule schedule,
  }) async {
    final old = r.schedule!;
    final termsChanged = amount != r.amount ||
        categoryId != r.categoryId ||
        accountId != r.accountId ||
        !sameRule(old, schedule);
    if (termsChanged && old.postedCount > 0) {
      r.versions = [
        ...r.versions,
        RuleVersion()
          ..effectiveFrom = old.startDate
          ..amount = r.amount
          ..categoryId = r.categoryId
          ..accountId = r.accountId
          ..intervalCount = old.intervalCount
          ..intervalUnit = old.intervalUnit
          ..anchorDay = old.anchorDay,
      ];
    }
    r
      ..name = name
      ..amount = amount
      ..type = type
      ..categoryId = categoryId
      ..accountId = accountId
      ..notes = notes
      ..schedule = sameRule(old, schedule)
          ? (old.copy()
            ..endType = schedule.endType
            ..endDate = schedule.endDate
            ..endCount = schedule.endCount)
          : editFutureOnly(old, schedule);
    await save(r);
  }

  /// Same dates (start, interval, anchor), whatever the end.
  static bool sameRule(Schedule a, Schedule b) =>
      a.startDate == b.startDate &&
      a.intervalCount == b.intervalCount &&
      a.intervalUnit == b.intervalUnit &&
      a.anchorDay == b.anchorDay &&
      a.anchorMonth == b.anchorMonth;

  Future<void> setPaused(RecurringRule r, bool paused) async {
    final s = r.schedule!;
    paused ? pause(s, DateTime.now()) : resume(s, DateTime.now());
    await save(r);
  }

  /// Skips the next occurrence; returns it (yyyymmdd) for the snackbar / Undo.
  Future<int?> skip(RecurringRule r) async {
    final day = skipNext(r.schedule!);
    await save(r);
    return day;
  }

  Future<void> undoSkip(RecurringRule r, int day) async {
    unskip(r.schedule!, day);
    await save(r);
  }

  Future<void> delete(RecurringRule r) =>
      isar.writeTxn(() => isar.recurringRules.delete(r.id));
}
