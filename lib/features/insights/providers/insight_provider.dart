import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/insight.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../../core/utils/currency_formatter.dart';

final smartInsightsProvider = FutureProvider<List<Insight>>((ref) async {
  final transactions = await ref.watch(transactionListProvider.future);
  final budgets = await ref.watch(budgetListProvider.future);
  final categories = await ref.watch(categoryListProvider.future);

  if (transactions.isEmpty) return [];

  final List<Insight> insights = [];

  // --- 1. BUDGET RISK RULE (Tiers 1 & 2) ---
  for (final budget in budgets) {
    if (!budget.isActive) continue;
    final progress = await ref.watch(budgetProgressProvider(budget).future);
    final category = categories.firstWhereOrNull(
      (c) => c.id.toString() == budget.categoryId,
    );
    if (category == null) continue;

    if (progress.percentage >= 80) {
      insights.add(Insight(
        id: 'budget_strict_${budget.id}',
        message: progress.percentage >= 100 
            ? '🚨 You\'ve exceeded your ${category.name} budget!'
            : '⚠️ You\'ve used ${progress.percentage.toInt()}% of your ${category.name} budget',
        type: InsightType.budget,
        priority: InsightPriority.high,
      ));
    } else if (progress.percentage >= 50) {
      insights.add(Insight(
        id: 'budget_relaxed_${budget.id}',
        message: '💡 You\'ve used ${progress.percentage.toInt()}% of your ${category.name} budget',
        type: InsightType.budget,
        priority: InsightPriority.medium,
      ));
    }
  }

  // --- 2. SPENDING TREND RULE (Tiers 1 & 2) ---
  final now = DateTime.now();
  final currentMonthStart = DateTime(now.year, now.month, 1);
  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = DateTime(now.year, now.month, 0);

  double currentMonthSpend = 0;
  double lastMonthSpend = 0;

  for (final tx in transactions) {
    if (tx.type != 'expense') continue;
    if (tx.createdAt.isAfter(currentMonthStart)) {
      currentMonthSpend += tx.amount;
    } else if (tx.createdAt.isAfter(lastMonthStart) && 
               tx.createdAt.isBefore(lastMonthEnd.add(const Duration(days: 1)))) {
      lastMonthSpend += tx.amount;
    }
  }

  if (lastMonthSpend > 0) {
    final percentageChange = ((currentMonthSpend - lastMonthSpend) / lastMonthSpend) * 100;
    if (percentageChange.abs() >= 10) {
      final isIncrease = percentageChange > 0;
      insights.add(Insight(
        id: 'trend_strict',
        message: '${isIncrease ? '📈' : '📉'} Spending is ${isIncrease ? 'up' : 'down'} ${percentageChange.abs().toInt()}% vs last month',
        type: InsightType.trend,
        priority: InsightPriority.high,
      ));
    } else if (percentageChange.abs() >= 5) {
      final isIncrease = percentageChange > 0;
      insights.add(Insight(
        id: 'trend_relaxed',
        message: '💡 Spending is ${isIncrease ? 'up' : 'down'} ${percentageChange.abs().toInt()}% vs last month',
        type: InsightType.trend,
        priority: InsightPriority.medium,
      ));
    }
  }

  // --- 3. BEHAVIOR PATTERN RULE (Tiers 1 & 2) ---
  if (transactions.isNotEmpty) {
    final Map<int, double> weekdaySpend = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    double totalSpend = 0;
    int expenseCount = 0;

    for (final tx in transactions) {
      if (tx.type != 'expense') continue;
      weekdaySpend[tx.createdAt.weekday] = (weekdaySpend[tx.createdAt.weekday] ?? 0) + tx.amount;
      totalSpend += tx.amount;
      expenseCount++;
    }

    if (expenseCount > 0) {
      final averageSpend = totalSpend / 7;
      int maxDay = 1;
      double maxAmount = 0;
      weekdaySpend.forEach((day, amount) {
        if (amount > maxAmount) {
          maxAmount = amount;
          maxDay = day;
        }
      });

      final percentageAboveAvg = ((maxAmount - averageSpend) / averageSpend) * 100;
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      
      if (percentageAboveAvg >= 20) {
        insights.add(Insight(
          id: 'behavior_strict',
          message: '⚡ You spend ${percentageAboveAvg.toInt()}% more on ${days[maxDay - 1]}s',
          type: InsightType.behavior,
          priority: InsightPriority.high,
        ));
      } else if (percentageAboveAvg >= 10) {
        insights.add(Insight(
          id: 'behavior_relaxed',
          message: '💡 Most of your spending happens on ${days[maxDay - 1]}s',
          type: InsightType.behavior,
          priority: InsightPriority.medium,
        ));
      }
    }
  }

  // --- 4. FALLBACK (Tier 3) ---
  if (insights.isEmpty && transactions.isNotEmpty) {
    double totalMonthSpend = 0;
    final Map<String, double> catMap = {};
    
    for (final tx in transactions) {
      if (tx.type != 'expense' || !tx.createdAt.isAfter(currentMonthStart)) continue;
      totalMonthSpend += tx.amount;
      final cat = categories.firstWhereOrNull((c) => c.id.toString() == tx.categoryId);
      if (cat != null) {
        catMap[cat.name] = (catMap[cat.name] ?? 0) + tx.amount;
      }
    }

    if (totalMonthSpend > 0) {
      insights.add(Insight(
        id: 'fallback_total',
        message: '💡 You\'ve spent ${CurrencyFormatter.format(totalMonthSpend)} this month',
        type: InsightType.trend,
        priority: InsightPriority.low,
      ));

      if (catMap.isNotEmpty) {
        final topCat = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        insights.add(Insight(
          id: 'fallback_category',
          message: '💡 Your top category is ${topCat.first.key}',
          type: InsightType.trend,
          priority: InsightPriority.low,
        ));
      }
    }
  }

  // Sort by priority and limit to 3
  insights.sort((a, b) => a.priority.index.compareTo(b.priority.index));
  return insights.take(3).toList();
});
