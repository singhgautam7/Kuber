import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/budget.dart';
import '../data/budget_repository.dart';
import '../providers/budget_provider.dart';
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

    final progress = await ref.read(budgetProgressProvider(budget).future);
    final alerts = await ref.read(budgetAlertsProvider(budget.id).future);

    for (final alert in alerts) {
      if (alert.isTriggered) continue;

      bool shouldTrigger = false;
      if (alert.type == BudgetAlertType.percentage) {
        if (progress.percentage >= alert.value) {
          shouldTrigger = true;
        }
      } else {
        if (progress.spent >= alert.value) {
          shouldTrigger = true;
        }
      }

      if (shouldTrigger) {
        await ref.read(budgetRepositoryProvider).markAlertTriggered(alert.id);
        
        if (alert.isNotificationEnabled) {
          final categories = await ref.read(categoryListProvider.future);
          final cat = categories.firstWhere((c) => c.id.toString() == budget.categoryId);
          
          final title = 'Budget Alert: ${cat.name}';
          String body;
          if (alert.type == BudgetAlertType.percentage) {
            body = 'You have used ${alert.value.toInt()}% of your ${cat.name} budget.';
          } else {
            body = 'You have used ${ref.read(formatterProvider).formatCurrency(alert.value)} of your ${cat.name} budget.';
          }

          await ref.read(notificationServiceProvider).showBudgetAlertNotification(
            id: alert.id,
            title: title,
            body: body,
          );
        }
      }
    }
  }
}
