import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_service.dart';
import '../data/category.dart';
import '../data/category_group.dart';
import '../data/category_group_repository.dart';
import '../data/category_repository.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../budgets/providers/budget_provider.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(isarProvider));
});

final categoryGroupRepositoryProvider = Provider<CategoryGroupRepository>((
  ref,
) {
  return CategoryGroupRepository(ref.watch(isarProvider));
});

final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, List<Category>>(
      CategoryListNotifier.new,
    );

class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  @override
  FutureOr<List<Category>> build() {
    return ref.watch(categoryRepositoryProvider).getAll();
  }

  Future<void> add(Category c) async {
    await ref.read(categoryRepositoryProvider).save(c);
    ref.invalidateSelf();
    ref.invalidate(budgetListProvider);
    ref.invalidate(transactionListProvider);
  }

  Future<void> delete(int id) async {
    await ref.read(categoryRepositoryProvider).delete(id);
    ref.invalidateSelf();
    ref.invalidate(budgetListProvider);
    ref.invalidate(transactionListProvider);
  }
}

final categoryGroupListProvider =
    AsyncNotifierProvider<CategoryGroupListNotifier, List<CategoryGroup>>(
      CategoryGroupListNotifier.new,
    );

class CategoryGroupListNotifier extends AsyncNotifier<List<CategoryGroup>> {
  @override
  FutureOr<List<CategoryGroup>> build() {
    return ref.watch(categoryGroupRepositoryProvider).getAll();
  }

  Future<Id> add(CategoryGroup g) async {
    final id = await ref.read(categoryGroupRepositoryProvider).save(g);
    ref.invalidateSelf();
    return id;
  }

  Future<void> delete(int id) async {
    await ref.read(categoryGroupRepositoryProvider).delete(id);
    ref.invalidateSelf();
    ref.invalidate(categoryListProvider);
  }
}

/// Used to signal Add Transaction screen to auto-select a newly created category
final pendingCategorySelectionProvider = StateProvider<int?>((ref) => null);

/// Provides a map of category id -> Category for quick lookup
final categoryMapProvider = FutureProvider<Map<int, Category>>((ref) async {
  final categories = await ref.watch(categoryListProvider.future);
  return {for (final c in categories) c.id: c};
});

final categoryRecentTransactionProvider =
    FutureProvider.family<Transaction?, int>((ref, categoryId) async {
      // Watch transactionListProvider to re-compute when transactions change
      ref.watch(transactionListProvider);
      final isar = ref.watch(isarProvider);
      final categoryIdStr = categoryId.toString();

      return await isar.transactions
          .filter()
          .categoryIdEqualTo(categoryIdStr)
          .sortByCreatedAtDesc()
          .findFirst();
    });

// Alias for backward compatibility during hot-reload
final categoryLatestTransactionProvider = categoryRecentTransactionProvider;

class CategoryStats {
  final int id;
  final int transactionCount;
  final double totalSpent;

  CategoryStats({
    required this.id,
    required this.transactionCount,
    required this.totalSpent,
  });

  factory CategoryStats.empty(int id) =>
      CategoryStats(id: id, transactionCount: 0, totalSpent: 0);
}

final categoryStatsProvider = FutureProvider<Map<int, CategoryStats>>((
  ref,
) async {
  // Re-fetch when transactions change
  ref.watch(transactionListProvider);
  final isar = ref.watch(isarProvider);

  final txns = await isar.transactions.where().findAll();

  Map<int, int> counts = {};
  Map<int, double> spent = {};

  for (final t in txns) {
    if (t.isTransfer || t.linkedRuleType != null) continue;
    final catId = int.tryParse(t.categoryId) ?? -1;
    if (catId == -1) continue;

    counts[catId] = (counts[catId] ?? 0) + 1;
    if (t.type == 'expense') {
      spent[catId] = (spent[catId] ?? 0) + t.amount;
    }
  }

  final stats = <int, CategoryStats>{};
  for (final catId in counts.keys) {
    stats[catId] = CategoryStats(
      id: catId,
      transactionCount: counts[catId] ?? 0,
      totalSpent: spent[catId] ?? 0,
    );
  }
  return stats;
});

class CategoryKpiDto {
  final int totalCategories;
  final int totalGroups;
  final int unusedCategories;
  final String topExpenseCategory;

  CategoryKpiDto({
    required this.totalCategories,
    required this.totalGroups,
    required this.unusedCategories,
    required this.topExpenseCategory,
  });
}

final categoryKpiProvider = FutureProvider<CategoryKpiDto>((ref) async {
  final categories = await ref.watch(categoryListProvider.future);
  final groups = await ref.watch(categoryGroupListProvider.future);
  final stats = await ref.watch(categoryStatsProvider.future);

  int unused = 0;
  Category? topExpenseCategory;
  double maxExpense = 0;

  for (final c in categories) {
    final s = stats[c.id];
    if (s == null || s.transactionCount == 0) {
      unused++;
    }
    if (s != null && s.totalSpent > maxExpense) {
      maxExpense = s.totalSpent;
      topExpenseCategory = c;
    }
  }

  return CategoryKpiDto(
    totalCategories: categories.length,
    totalGroups: groups.length,
    unusedCategories: unused,
    topExpenseCategory: topExpenseCategory?.name ?? 'None',
  );
});
