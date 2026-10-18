import 'package:isar_community/isar.dart';

import '../../../core/database/base_repository.dart';
import '../../transactions/data/transaction.dart';
import 'recurring_interval.dart';
import 'recurring_rule.dart';

class RecurringRepository extends BaseRepository<RecurringRule> {
  RecurringRepository(super.isar);

  Future<List<RecurringRule>> getAll() async {
    return isar.recurringRules.where().sortByCreatedAtDesc().findAll();
  }

  Future<List<RecurringRule>> getActive() async {
    return isar.recurringRules
        .filter()
        .isPausedEqualTo(false)
        .sortByNextDueAt()
        .findAll();
  }

  Future<List<RecurringRule>> getDue(DateTime now) async {
    return isar.recurringRules
        .filter()
        .isPausedEqualTo(false)
        .nextDueAtLessThan(now)
        .findAll();
  }

  Future<void> save(RecurringRule rule) async {
    rule.updatedAt = DateTime.now();
    if (rule.id == Isar.autoIncrement) {
      rule.createdAt = DateTime.now();
    }
    await isar.writeTxn(() => isar.recurringRules.put(rule));
  }

  Future<void> delete(int id) async {
    await isar.writeTxn(() => isar.recurringRules.delete(id));
  }

  /// Computes the next due date after [from] for the given [rule].
  ///
  /// Day / week: calendar-day arithmetic keeping the time of day (DST safe;
  /// identical to the old `add(Duration(days: n))` outside DST zones).
  /// Month / year: same anchor day N months on, clamped to the month length,
  /// at midnight (as before). When [from] was itself clamped (it sits on a
  /// month's last day and the start date's day is later), the start date's
  /// day is the anchor, so 31 Jan -> 28 Feb -> 31 Mar instead of sticking to
  /// the 28th, and 29 Feb yearly returns to 29 Feb in leap years.
  static DateTime computeNextDue(RecurringRule rule, DateTime from) {
    final interval = RecurrenceInterval.of(rule);
    final n = interval.count;
    switch (interval.unit) {
      case RecurrenceUnit.day:
      case RecurrenceUnit.week:
        final days = interval.unit == RecurrenceUnit.week ? n * 7 : n;
        return DateTime(from.year, from.month, from.day + days, from.hour,
            from.minute, from.second, from.millisecond, from.microsecond);
      case RecurrenceUnit.month:
      case RecurrenceUnit.year:
        final months = interval.unit == RecurrenceUnit.year ? n * 12 : n;
        final fromIsMonthEnd =
            from.day == DateTime(from.year, from.month + 1, 0).day;
        final anchor = fromIsMonthEnd && rule.startDate.day > from.day
            ? rule.startDate.day
            : from.day;
        final target = DateTime(from.year, from.month + months, 1);
        final daysInTarget = DateTime(target.year, target.month + 1, 0).day;
        return DateTime(target.year, target.month,
            anchor > daysInTarget ? daysInTarget : anchor);
    }
  }

  /// When this rule last recorded a transaction, or null if never.
  Future<DateTime?> lastRecordedAt(int ruleId) async {
    final t = await isar.transactions
        .filter()
        .linkedRuleIdEqualTo('$ruleId')
        .linkedRuleTypeEqualTo('recurring')
        .sortByCreatedAtDesc()
        .findFirst();
    return t?.createdAt;
  }

  /// The next due date for an edited [rule] (already holding the new values).
  ///
  /// Same start date and interval as before: the stored [oldNextDueAt] is
  /// kept, so editing a name or amount never re-runs past occurrences. A
  /// changed schedule restarts from the start date, skipping occurrences
  /// before today (no back-dated catch-up) and on or before the day of
  /// [lastRecordedAt] (no second transaction for a day that already ran).
  static DateTime nextDueAfterEdit(
    RecurringRule rule, {
    required DateTime oldStartDate,
    required RecurrenceInterval oldInterval,
    required DateTime oldNextDueAt,
    DateTime? lastRecordedAt,
    DateTime? now,
  }) {
    if (rule.startDate == oldStartDate &&
        RecurrenceInterval.of(rule) == oldInterval) {
      return oldNextDueAt;
    }
    final n = now ?? DateTime.now();
    var floor = DateTime(n.year, n.month, n.day);
    final last = lastRecordedAt;
    if (last != null) {
      final dayAfterLast = DateTime(last.year, last.month, last.day + 1);
      if (dayAfterLast.isAfter(floor)) floor = dayAfterLast;
    }
    var next = rule.startDate;
    while (next.isBefore(floor)) {
      next = computeNextDue(rule, next);
    }
    return next;
  }

  /// True once the rule will record nothing more: its occurrence count is
  /// used up, or (end date) [dueDate] (default: its stored nextDueAt) falls on
  /// a day after the end date. The end date is inclusive, and a rule whose
  /// end date has passed still catches up occurrences missed before it.
  static bool isExpired(RecurringRule rule, [DateTime? dueDate]) {
    switch (rule.endType) {
      case 'occurrences':
        return rule.endAfter != null && rule.executionCount >= rule.endAfter!;
      case 'date':
        final end = rule.endDate;
        if (end == null) return false;
        final due = dueDate ?? rule.nextDueAt;
        return DateTime(due.year, due.month, due.day)
            .isAfter(DateTime(end.year, end.month, end.day));
      case 'never':
      default:
        return false;
    }
  }
}
