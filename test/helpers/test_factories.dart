import 'package:isar/isar.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/tags/data/tag.dart';
import 'package:kuber/features/ledger/data/ledger.dart';

Transaction makeTransaction({
  int? id,
  String name = 'Test Transaction',
  double amount = 100.0,
  String type = 'expense',
  String categoryId = '1',
  String accountId = '1',
  DateTime? createdAt,
  bool isTransfer = false,
  String? transferId,
  String? notes,
  String? linkedRuleId,
  String? linkedRuleType,
  bool isBalanceAdjustment = false,
}) {
  final now = DateTime.now();
  return Transaction()
    ..id = id ?? Isar.autoIncrement
    ..name = name
    ..nameLower = name.toLowerCase()
    ..amount = amount
    ..type = type
    ..categoryId = categoryId
    ..accountId = accountId
    ..createdAt = createdAt ?? now
    ..updatedAt = now
    ..isTransfer = isTransfer
    ..transferId = transferId
    ..notes = notes
    ..linkedRuleId = linkedRuleId
    ..linkedRuleType = linkedRuleType
    ..isBalanceAdjustment = isBalanceAdjustment;
}

Budget makeBudget({
  int? id,
  String categoryId = '1',
  double amount = 5000.0,
  BudgetPeriodType periodType = BudgetPeriodType.monthly,
  DateTime? startDate,
  DateTime? endDate,
  bool isRecurring = true,
  List<BudgetAlert>? alerts,
  bool isActive = true,
}) {
  return Budget()
    ..id = id ?? Isar.autoIncrement
    ..categoryId = categoryId
    ..amount = amount
    ..periodType = periodType
    ..startDate = startDate ?? DateTime.now()
    ..endDate = endDate
    ..isRecurring = isRecurring
    ..isActive = isActive
    ..alerts = alerts ?? [];
}

BudgetAlert makeAlert({
  BudgetAlertType type = BudgetAlertType.percentage,
  double value = 80.0,
  bool isTriggered = false,
  bool enableNotification = true,
}) {
  return BudgetAlert()
    ..type = type
    ..value = value
    ..isTriggered = isTriggered
    ..enableNotification = enableNotification;
}

RecurringRule makeRecurringRule({
  int? id,
  String name = 'Test Recurring',
  double amount = 500.0,
  String type = 'expense',
  String categoryId = '1',
  String accountId = '1',
  String frequency = 'monthly',
  int? customDays,
  DateTime? startDate,
  DateTime? nextDueAt,
  String endType = 'never',
  int? endAfter,
  DateTime? endDate,
  int executionCount = 0,
  bool isPaused = false,
  String? notes,
}) {
  final now = DateTime.now();
  return RecurringRule()
    ..id = id ?? Isar.autoIncrement
    ..name = name
    ..amount = amount
    ..type = type
    ..categoryId = categoryId
    ..accountId = accountId
    ..frequency = frequency
    ..customDays = customDays
    ..startDate = startDate ?? now
    ..nextDueAt = nextDueAt ?? now
    ..endType = endType
    ..endAfter = endAfter
    ..endDate = endDate
    ..executionCount = executionCount
    ..isPaused = isPaused
    ..notes = notes
    ..createdAt = now
    ..updatedAt = now;
}

Account makeAccount({
  int? id,
  String name = 'Test Account',
  String type = 'bank',
  double initialBalance = 0.0,
  bool isCreditCard = false,
  double? creditLimit,
  String? icon,
  int? colorValue,
}) {
  return Account()
    ..id = id ?? Isar.autoIncrement
    ..name = name
    ..type = type
    ..initialBalance = initialBalance
    ..isCreditCard = isCreditCard
    ..creditLimit = creditLimit
    ..icon = icon
    ..colorValue = colorValue;
}

Category makeCategory({
  int? id,
  String name = 'Test Category',
  String icon = 'category',
  int colorValue = 0xFF5C6BC0,
  String type = 'expense',
  bool isDefault = false,
  int? groupId,
}) {
  return Category()
    ..id = id ?? Isar.autoIncrement
    ..name = name
    ..icon = icon
    ..colorValue = colorValue
    ..type = type
    ..isDefault = isDefault
    ..groupId = groupId;
}

Tag makeTag({
  int? id,
  String name = 'test-tag',
  bool isEnabled = true,
  DateTime? createdAt,
}) {
  return Tag()
    ..id = id ?? Isar.autoIncrement
    ..name = name
    ..isEnabled = isEnabled
    ..createdAt = createdAt ?? DateTime.now();
}

Ledger makeLedger({
  int? id,
  String uid = 'ledger-uid-1',
  String personName = 'John Doe',
  String type = 'lent',
  double originalAmount = 5000.0,
  String accountId = '1',
  String categoryId = '1',
  String? notes,
  DateTime? expectedDate,
  bool isSettled = false,
  DateTime? createdAt,
}) {
  final now = DateTime.now();
  return Ledger()
    ..id = id ?? Isar.autoIncrement
    ..uid = uid
    ..personName = personName
    ..personNameLower = personName.toLowerCase()
    ..type = type
    ..originalAmount = originalAmount
    ..accountId = accountId
    ..categoryId = categoryId
    ..notes = notes
    ..expectedDate = expectedDate
    ..isSettled = isSettled
    ..createdAt = createdAt ?? now
    ..updatedAt = now;
}
