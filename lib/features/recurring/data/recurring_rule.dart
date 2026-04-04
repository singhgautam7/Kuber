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

  late String frequency; // 'daily' | 'weekly' | 'biweekly' | 'monthly' | 'yearly' | 'custom'
  int? customDays; // only used when frequency == 'custom'

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
}
