import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/budget.dart';
import '../data/budget_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;

final budgetServiceProvider = Provider<BudgetService>((ref) {
  return BudgetService(ref);
});

class BudgetService {
  final Ref ref;

  BudgetService(this.ref);

  Future<void> init() async {
    await ref.read(budgetRepositoryProvider).evaluateBudgets();
  }

  Future<void> checkAlerts(String categoryId) async {
    final budget = await ref.read(budgetRepositoryProvider).getByCategory(categoryId);
    if (budget == null || !budget.isActive) return;

    // Compute spent directly from repository to avoid provider deadlock
    final budgetRepo = ref.read(budgetRepositoryProvider);

    DateTime startDate;
    DateTime endDate;
    if (budget.periodType == BudgetPeriodType.monthly) {
      final now = DateTime.now();
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    } else if (budget.periodType == BudgetPeriodType.weekly) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      endDate = DateTime(weekStart.year, weekStart.month, weekStart.day + 6, 23, 59, 59, 999);
    } else {
      startDate = budget.startDate;
      endDate = budget.endDate ?? DateTime.now();
    }
    final spent = await budgetRepo.calculateUsage(budget.categoryId, startDate, endDate);

    bool statusChanged = false;

    for (int i = 0; i < budget.alerts.length; i++) {
      final alert = budget.alerts[i];

      final threshold = alert.type == BudgetAlertType.percentage
          ? budget.amount * (alert.value / 100)
          : alert.value;

      final isAboveThreshold = spent >= threshold;

      // TRIGGER logic
      if (isAboveThreshold && !alert.isTriggered) {
        alert.isTriggered = true;
        statusChanged = true;

        if (alert.enableNotification) {
          final categories = await ref.read(categoryRepositoryProvider).getAll();
          final cat = categories.where((c) => c.id.toString() == budget.categoryId).firstOrNull;
          if (cat == null) return;

          final title = 'Budget Alert';
          String body;
          if (alert.type == BudgetAlertType.percentage) {
            body = "You've reached ${alert.value.toInt()}% of your ${cat.name} budget";
          } else {
            body = "You've spent ${ref.read(formatterProvider).formatCurrency(alert.value)} in ${cat.name} category";
          }

          final notificationId = budget.id * 10 + i;
          await ref.read(notificationServiceProvider).showBudgetAlertNotification(
            id: notificationId,
            title: title,
            body: body,
          );
        }
      } 
      // RESET logic: If spending drops below threshold again
      else if (!isAboveThreshold && alert.isTriggered) {
        alert.isTriggered = false;
        statusChanged = true;
      }
    }

    if (statusChanged) {
      await ref.read(budgetRepositoryProvider).saveBudget(budget, budget.alerts);
    }
  }
}
