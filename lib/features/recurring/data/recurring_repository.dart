import 'package:isar_community/isar.dart';

import '../../../core/database/base_repository.dart';
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

  /// The next due date for an edited [rule] (already holding the new values).
  ///
  /// Same start date and interval as before: the stored [oldNextDueAt] is
  /// kept, so editing a name or amount never re-runs past occurrences. A
  /// changed schedule restarts from the start date, skipping occurrences
  /// before today so no back-dated catch-up transactions are created.
  static DateTime nextDueAfterEdit(
    RecurringRule rule, {
    required DateTime oldStartDate,
    required RecurrenceInterval oldInterval,
    required DateTime oldNextDueAt,
    DateTime? now,
  }) {
    if (rule.startDate == oldStartDate &&
        RecurrenceInterval.of(rule) == oldInterval) {
      return oldNextDueAt;
    }
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    var next = rule.startDate;
    while (next.isBefore(today)) {
      next = computeNextDue(rule, next);
    }
    return next;
  }

  /// Returns true if the rule has expired based on its endType.
  static bool isExpired(RecurringRule rule) {
    switch (rule.endType) {
      case 'occurrences':
        return rule.endAfter != null && rule.executionCount >= rule.endAfter!;
      case 'date':
        return rule.endDate != null &&
            DateTime.now().isAfter(rule.endDate!);
      case 'never':
      default:
        return false;
    }
  }
}
