import 'package:isar_community/isar.dart';

part 'recurring_rule.g.dart';

@collection
class RecurringRule {
  Id id = Isar.autoIncrement;

  late String name;
  late double amount;
  late String type; // 'income' | 'expense'

  late String categoryId;
  late String accountId;

  String? notes;

  // Preset key, kept for CSV / backups: 'daily' | 'weekly' | 'monthly' |
  // 'quarterly' | 'half_yearly' | 'yearly' | 'custom' (legacy: 'biweekly').
  // The schedule comes from RecurrenceInterval.of(rule), not this string.
  late String frequency;

  /// Interval count ("every N units"). Legacy rules (intervalUnit == null)
  /// only set it for frequency == 'custom', where the unit was days. The
  /// field keeps its original name so old databases and backups read as-is.
  int? customDays;

  /// 'day' | 'week' | 'month' | 'year'. Null on rules saved before intervals
  /// existed; RecurrenceInterval.legacy maps those (migration 10 backfills).
  String? intervalUnit;

  late DateTime startDate;

  @Index()
  late DateTime nextDueAt;

  int executionCount = 0;

  late String endType; // 'never' | 'occurrences' | 'date'
  int? endAfter; // number of occurrences (when endType == 'occurrences')
  DateTime? endDate; // end date (when endType == 'date')

  bool isPaused = false;

  late DateTime createdAt;
  late DateTime updatedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'amount': amount,
    'type': type,
    'categoryId': categoryId,
    'accountId': accountId,
    'notes': notes,
    'frequency': frequency,
    'customDays': customDays,
    'intervalUnit': intervalUnit,
    'startDate': startDate.toIso8601String(),
    'nextDueAt': nextDueAt.toIso8601String(),
    'executionCount': executionCount,
    'endType': endType,
    'endAfter': endAfter,
    'endDate': endDate?.toIso8601String(),
    'isPaused': isPaused,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
