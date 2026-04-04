import 'package:isar_community/isar.dart';

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

  List<BudgetAlert> alerts = [];

  Budget() {
    updatedAt = DateTime.now();
  }
}

enum BudgetAlertType {
  percentage,
  amount,
}

@embedded
class BudgetAlert {
  @enumerated
  late BudgetAlertType type;

  late double value;

  bool isTriggered = false;

  bool enableNotification = true;

  DateTime createdAt = DateTime.now();
  
  BudgetAlert();
}
