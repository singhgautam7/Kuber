import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/budget.dart';
import '../data/budget_repository.dart';

final budgetListProvider = AsyncNotifierProvider<BudgetListNotifier, List<Budget>>(() {
  return BudgetListNotifier();
});

class BudgetListNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() async {
    return ref.watch(budgetRepositoryProvider).getAll();
  }

  Future<void> save(Budget budget, List<BudgetAlert> alerts) async {
    await ref.read(budgetRepositoryProvider).saveBudget(budget, alerts);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(budgetRepositoryProvider).deleteBudget(id);
    ref.invalidateSelf();
  }

  Future<void> toggleActive(int id, bool active) async {
    await ref.read(budgetRepositoryProvider).setBudgetActive(id, active);
    ref.invalidateSelf();
  }
}

final budgetByCategoryProvider = FutureProvider.family<Budget?, String>((ref, categoryId) async {
  return ref.watch(budgetRepositoryProvider).getByCategory(categoryId);
});

final budgetAlertsProvider = FutureProvider.family<List<BudgetAlert>, int>((ref, budgetId) async {
  return ref.watch(budgetRepositoryProvider).getAlerts(budgetId);
});

class BudgetProgress {
  final double spent;
  final double limit;
  final double percentage;
  final DateTime startDate;
  final DateTime endDate;
  final int daysRemaining;

  BudgetProgress({
    required this.spent,
    required this.limit,
    required this.percentage,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
  });
}

final budgetProgressProvider = FutureProvider.family<BudgetProgress, Budget>((ref, budget) async {
  final repo = ref.watch(budgetRepositoryProvider);
  
  DateTime startDate;
  DateTime endDate;
  
  if (budget.periodType == BudgetPeriodType.monthly) {
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0);
  } else if (budget.periodType == BudgetPeriodType.weekly) {
    // Current week logic
    final now = DateTime.now();
    startDate = now.subtract(Duration(days: now.weekday - 1));
    endDate = startDate.add(const Duration(days: 6));
  } else {
    startDate = budget.startDate;
    endDate = budget.endDate ?? DateTime.now();
  }
  
  final spent = await repo.calculateUsage(budget.categoryId, startDate, endDate);
  final percentage = (spent / budget.amount) * 100;
  final daysRemaining = endDate.difference(DateTime.now()).inDays + 1;
  
  return BudgetProgress(
    spent: spent,
    limit: budget.amount,
    percentage: percentage,
    startDate: startDate,
    endDate: endDate,
    daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
  );
});

final budgetSnapshotProvider = FutureProvider<List<({Budget budget, BudgetProgress progress})>>((ref) async {
  final budgets = await ref.watch(budgetListProvider.future);
  final activeBudgets = budgets.where((b) => b.isActive).toList();

  final List<({Budget budget, BudgetProgress progress})> results = [];

  for (final budget in activeBudgets) {
    final progress = await ref.watch(budgetProgressProvider(budget).future);
    results.add((budget: budget, progress: progress));
  }

  // Sort by usage DESC
  results.sort((a, b) => b.progress.percentage.compareTo(a.progress.percentage));

  // Take top 3 budgets regardless of percentage
  return results.take(3).toList();
});

final budgetVsActualProvider = FutureProvider<List<({Budget budget, BudgetProgress progress})>>((ref) async {
  final budgets = await ref.watch(budgetListProvider.future);
  final activeBudgets = budgets.where((b) => b.isActive).toList();

  final List<({Budget budget, BudgetProgress progress})> results = [];

  for (final budget in activeBudgets) {
    final progress = await ref.watch(budgetProgressProvider(budget).future);
    results.add((budget: budget, progress: progress));
  }

  // Sort by usage DESC
  results.sort((a, b) => b.progress.percentage.compareTo(a.progress.percentage));

  return results;
});
