import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../transactions/data/transaction.dart';
import 'budget.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return BudgetRepository(isar);
});

class BudgetRepository {
  final Isar isar;

  BudgetRepository(this.isar);

  Future<List<Budget>> getAll() async {
    return isar.budgets.where().findAll();
  }

  Future<Budget?> getByCategory(String categoryId) async {
    return isar.budgets.filter().categoryIdEqualTo(categoryId).isActiveEqualTo(true).findFirst();
  }

  Future<Id> saveBudget(Budget budget, List<BudgetAlert> alerts) async {
    return isar.writeTxn(() async {
      final budgetId = await isar.budgets.put(budget);
      
      // Delete old alerts
      await isar.budgetAlerts.filter().budgetIdEqualTo(budgetId).deleteAll();
      
      // Add new alerts
      for (final alert in alerts) {
        alert.budgetId = budgetId;
      }
      await isar.budgetAlerts.putAll(alerts);
      
      return budgetId;
    });
  }

  Future<void> deleteBudget(int id) async {
    await isar.writeTxn(() async {
      await isar.budgets.delete(id);
      await isar.budgetAlerts.filter().budgetIdEqualTo(id).deleteAll();
    });
  }

  Future<void> setBudgetActive(int id, bool active) async {
    await isar.writeTxn(() async {
      final budget = await isar.budgets.get(id);
      if (budget != null) {
        budget.isActive = active;
        budget.updatedAt = DateTime.now();
        await isar.budgets.put(budget);
      }
    });
  }

  Future<List<BudgetAlert>> getAlerts(int budgetId) async {
    return isar.budgetAlerts.filter().budgetIdEqualTo(budgetId).findAll();
  }

  Future<double> calculateUsage(String categoryId, DateTime start, DateTime end) async {
    final txns = await isar.transactions
        .filter()
        .categoryIdEqualTo(categoryId)
        .typeEqualTo('expense')
        .createdAtBetween(start, end)
        .findAll();
    
    double total = 0.0;
    for (final tx in txns) {
      total += tx.amount;
    }
    return total;
  }

  Future<void> evaluateBudgets() async {
    await isar.writeTxn(() async {
      final budgets = await isar.budgets.where().findAll();
      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);

      for (final budget in budgets) {
        if (!budget.isActive) continue;

        // Reset alerts if new period started
        bool periodChanged = false;
        if (budget.lastEvaluatedAt == null) {
          periodChanged = true;
        } else {
          final lastEvalMonthStart = DateTime(
            budget.lastEvaluatedAt!.year,
            budget.lastEvaluatedAt!.month,
            1,
          );
          if (currentMonthStart.isAfter(lastEvalMonthStart)) {
            periodChanged = true;
          }
        }

        if (periodChanged) {
          final alerts = await isar.budgetAlerts.filter().budgetIdEqualTo(budget.id).findAll();
          for (final alert in alerts) {
            alert.isTriggered = false;
          }
          await isar.budgetAlerts.putAll(alerts);
          budget.lastEvaluatedAt = now;
        }

        // Non-recurring expiry check
        if (!budget.isRecurring && budget.startDate.isBefore(currentMonthStart)) {
          budget.isActive = false;
        }
        
        await isar.budgets.put(budget);
      }
    });
  }
  
  Future<void> markAlertTriggered(int alertId) async {
    await isar.writeTxn(() async {
      final alert = await isar.budgetAlerts.get(alertId);
      if (alert != null) {
        alert.isTriggered = true;
        await isar.budgetAlerts.put(alert);
      }
    });
  }
}
