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

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'amount': amount,
    'periodType': periodType.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isRecurring': isRecurring,
    'anchorDay': anchorDay,
    'durationDays': durationDays,
    'isActive': isActive,
    'lastEvaluatedAt': lastEvaluatedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'alerts': alerts.map((a) => a.toMap()).toList(),
  };
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

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'value': value,
    'isTriggered': isTriggered,
    'enableNotification': enableNotification,
    'createdAt': createdAt.toIso8601String(),
  };
}
