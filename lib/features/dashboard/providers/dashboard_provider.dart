import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';

class MonthlySummary {
  final double totalIncome;
  final double totalExpense;
  final double net;
  final Map<String, double> categorySpending; // categoryId -> total

  const MonthlySummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.categorySpending,
  });
}

final currentMonthProvider = StateProvider<({int year, int month})>((ref) {
  final now = DateTime.now();
  return (year: now.year, month: now.month);
});

final monthlySummaryProvider = FutureProvider<MonthlySummary>((ref) async {
  final month = ref.watch(currentMonthProvider);
  final transactions = await ref
      .watch(monthlyTransactionsProvider((year: month.year, month: month.month))
          .future);

  double income = 0;
  double expense = 0;
  final categorySpending = <String, double>{};

  for (final t in transactions) {
    if (t.type == 'transfer' || t.isBalanceAdjustment) continue;
    if (t.type == 'income') {
      income += t.amount;
    } else {
      expense += t.amount;
      categorySpending[t.categoryId] =
          (categorySpending[t.categoryId] ?? 0) + t.amount;
    }
  }

  return MonthlySummary(
    totalIncome: income,
    totalExpense: expense,
    net: income - expense,
    categorySpending: categorySpending,
  );
});

final recentTransactionsProvider =
    FutureProvider<List<Transaction>>((ref) async {
  final all = await ref.watch(transactionListProvider.future);
  return all.take(5).toList();
});

class DaySummary {
  final DateTime date;
  final double income;
  final double expense;

  const DaySummary({
    required this.date,
    required this.income,
    required this.expense,
  });
}

final last7DaysSummaryProvider =
    FutureProvider<List<DaySummary>>((ref) async {
  final all = await ref.watch(transactionListProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final sevenDaysAgo = today.subtract(const Duration(days: 6));

  // Initialize 7 days
  final dayMap = <String, DaySummary>{};
  for (var i = 0; i < 7; i++) {
    final day = sevenDaysAgo.add(Duration(days: i));
    final key = '${day.year}-${day.month}-${day.day}';
    dayMap[key] = DaySummary(date: day, income: 0, expense: 0);
  }

  for (final t in all) {
    if (t.type == 'transfer' || t.isBalanceAdjustment) continue;
    final d = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
    if (d.isBefore(sevenDaysAgo) || d.isAfter(today)) continue;
    final key = '${d.year}-${d.month}-${d.day}';
    final existing = dayMap[key];
    if (existing != null) {
      dayMap[key] = DaySummary(
        date: existing.date,
        income: existing.income + (t.type == 'income' ? t.amount : 0),
        expense: existing.expense + (t.type == 'expense' ? t.amount : 0),
      );
    }
  }

  return dayMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
});
