import 'package:isar/isar.dart';

part 'budget.g.dart';

enum BudgetPeriodType {
  monthly,
  weekly,
  custom,
}

@collection
class Budget {
  Id id = Isar.autoIncrement;

  @Index()
  late String categoryId;

  late double amount;

  @enumerated
  late BudgetPeriodType periodType;

  late DateTime startDate;

  DateTime? endDate;

  late bool isRecurring;

  int? anchorDay;

  int? durationDays;

  bool isActive = true;

  DateTime? lastEvaluatedAt;

  DateTime createdAt = DateTime.now();

  late DateTime updatedAt;

  Budget() {
    updatedAt = DateTime.now();
  }
}

enum BudgetAlertType {
  percentage,
  amount,
}

@collection
class BudgetAlert {
  Id id = Isar.autoIncrement;

  @Index()
  late int budgetId;

  @enumerated
  late BudgetAlertType type;

  late double value;

  bool isTriggered = false;

  bool isNotificationEnabled = true;

  DateTime createdAt = DateTime.now();
  
  BudgetAlert();
}
