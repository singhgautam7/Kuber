import 'package:isar/isar.dart';

import '../../../core/database/base_repository.dart';
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
  static DateTime computeNextDue(RecurringRule rule, DateTime from) {
    switch (rule.frequency) {
      case 'daily':
        return from.add(const Duration(days: 1));
      case 'weekly':
        return from.add(const Duration(days: 7));
      case 'biweekly':
        return from.add(const Duration(days: 14));
      case 'monthly':
        final nextMonth = DateTime(from.year, from.month + 1, 1);
        final daysInNextMonth =
            DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
        final day = from.day > daysInNextMonth ? daysInNextMonth : from.day;
        return DateTime(nextMonth.year, nextMonth.month, day);
      case 'yearly':
        final nextYear = from.year + 1;
        // Handle Feb 29 edge case
        final daysInFeb = DateTime(nextYear, 3, 0).day;
        final day =
            (from.month == 2 && from.day > daysInFeb) ? daysInFeb : from.day;
        return DateTime(nextYear, from.month, day);
      case 'custom':
        final days = rule.customDays ?? 1;
        return from.add(Duration(days: days));
      default:
        return from.add(const Duration(days: 1));
    }
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
