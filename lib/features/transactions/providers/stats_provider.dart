import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../analytics/providers/analytics_provider.dart';

final burnRateProvider = FutureProvider<({double avgDaily, double projected})>((ref) async {
  final transactions = await ref.watch(transactionListProvider.future);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 0);
  final daysInMonth = monthEnd.day;
  final daysElapsed = now.day;

  final monthlyExpenses = transactions.where((t) {
    return t.type == 'expense' && !t.isTransfer && !t.isBalanceAdjustment && t.linkedRuleType == null && t.createdAt.isAfter(monthStart.subtract(const Duration(seconds: 1)));
  }).toList();

  final totalSpend = monthlyExpenses.fold<double>(0, (sum, t) => sum + t.amount);
  
  final avgDaily = daysElapsed > 0 ? totalSpend / daysElapsed : 0.0;
  final projected = avgDaily * daysInMonth;

  return (avgDaily: avgDaily, projected: projected);
});

class CategoryStat {
  final Category category;
  final double total;
  final double percentage;
  CategoryStat({required this.category, required this.total, required this.percentage});
}

final analyticsCategoryStatsProvider = FutureProvider<List<CategoryStat>>((ref) async {
  try {
    final transactions = ref.watch(analyticsTransactionsProvider);
    final categoryMap = await ref.watch(categoryMapProvider.future);
    
    final Map<int, double> totals = {};
    double overallTotal = 0;

    for (final t in transactions) {
      if (t.type != 'expense' || t.isBalanceAdjustment) continue;
      final catId = int.tryParse(t.categoryId) ?? -1;
      if (catId == -1) continue;
      totals[catId] = (totals[catId] ?? 0) + t.amount;
      overallTotal += t.amount;
    }

    final stats = totals.entries
        .where((e) => categoryMap.containsKey(e.key))
        .map((e) => CategoryStat(
              category: categoryMap[e.key]!,
              total: e.value,
              percentage: overallTotal > 0 ? (e.value / overallTotal) * 100 : 0,
            ))
        .toList();

    stats.sort((a, b) => b.total.compareTo(a.total));
    return stats;
  } catch (e, stack) {
    debugPrint('Error in analyticsCategoryStatsProvider: $e\n$stack');
    return [];
  }
});

class GroupStat {
  final String groupName;
  final double total;
  final double percentage;
  GroupStat({required this.groupName, required this.total, required this.percentage});
}

final analyticsGroupStatsProvider = FutureProvider<List<GroupStat>>((ref) async {
  try {
    final transactions = ref.watch(analyticsTransactionsProvider);
    final categoryMap = await ref.watch(categoryMapProvider.future);
    final groupList = await ref.watch(categoryGroupListProvider.future);
    final groupMap = {for (var g in groupList) g.id: g.name};
    
    final Map<String, double> totals = {};
    double overallTotal = 0;

    for (final t in transactions) {
      if (t.type != 'expense' || t.isBalanceAdjustment) continue;
      final catId = int.tryParse(t.categoryId) ?? -1;
      if (catId == -1) continue;
      final cat = categoryMap[catId];
      if (cat == null) continue;
      
      final groupName = (cat.groupId != null) ? (groupMap[cat.groupId] ?? 'Other') : 'Other';
      totals[groupName] = (totals[groupName] ?? 0) + t.amount;
      overallTotal += t.amount;
    }

    final stats = totals.entries
        .map((e) => GroupStat(
              groupName: e.key,
              total: e.value,
              percentage: overallTotal > 0 ? (e.value / overallTotal) * 100 : 0,
            ))
        .toList();

    stats.sort((a, b) => b.total.compareTo(a.total));
    return stats;
  } catch (e, stack) {
    debugPrint('Error in analyticsGroupStatsProvider: $e\n$stack');
    return [];
  }
});
