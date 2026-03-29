import 'package:flutter/foundation.dart';
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

  Stream<List<Budget>> watchBudgets() {
    return isar.budgets.where().watch(fireImmediately: true);
  }

  Future<Id> saveBudget(Budget budget, List<BudgetAlert> alerts) async {
    return isar.writeTxn(() async {
      debugPrint('BUDGET_REPO: Writing budget ${budget.id} with ${alerts.length} alerts');
      budget.alerts = alerts;
      final id = await isar.budgets.put(budget);
      
      final saved = await isar.budgets.get(id);
      debugPrint('BUDGET_REPO: Successfully saved budget. ID: $id. Alerts in DB: ${saved?.alerts.length}');
      
      return id;
    });
  }

  Future<void> deleteBudget(int id) async {
    await isar.writeTxn(() async {
      await isar.budgets.delete(id);
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
    final budget = await isar.budgets.get(budgetId);
    return budget?.alerts ?? [];
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
          for (final alert in budget.alerts) {
            alert.isTriggered = false;
          }
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
}
