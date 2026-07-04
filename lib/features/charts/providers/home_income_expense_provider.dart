import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../transactions/data/transaction.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../widgets/income_expense_chart_model.dart';

/// Home compact chart range: last 7 days, last 4 weeks, or last 6 months.
enum HomeChartRange { days7, weeks4, months6 }

/// Persisted-per-session selected range for the Home income/expense chart.
final homeChartRangeProvider =
    StateProvider<HomeChartRange>((ref) => HomeChartRange.months6);

/// Income/expense points for the selected Home range. Each point carries its
/// date/date-range so the tooltip can label it.
final homeIncomeExpenseProvider =
    Provider<List<IncomeExpensePoint>>((ref) {
  final txns =
      ref.watch(transactionListProvider).valueOrNull ?? const <Transaction>[];
  final range = ref.watch(homeChartRangeProvider);
  final valid = txns.validForCalculations.toList();

  switch (range) {
    case HomeChartRange.days7:
      return _dayBuckets(valid, 7);
    case HomeChartRange.weeks4:
      return _weekBuckets(valid, 4);
    case HomeChartRange.months6:
      return _monthBuckets(valid, 6);
  }
});

List<IncomeExpensePoint> _dayBuckets(List<Transaction> txns, int count) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final days = [for (var i = count - 1; i >= 0; i--) today.subtract(Duration(days: i))];
  final income = List.filled(count, 0.0);
  final expense = List.filled(count, 0.0);
  for (final t in txns) {
    final d = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
    final idx = d.difference(days.first).inDays;
    if (idx < 0 || idx >= count) continue;
    if (t.type == 'income') {
      income[idx] += t.amount;
    } else {
      expense[idx] += t.amount;
    }
  }
  return [
    for (var i = 0; i < count; i++)
      IncomeExpensePoint(
        label: DateFormat('d/M').format(days[i]),
        income: income[i],
        expense: expense[i],
        date: days[i],
        endDate: days[i],
      ),
  ];
}

List<IncomeExpensePoint> _weekBuckets(List<Transaction> txns, int count) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
  final starts = [
    for (var i = count - 1; i >= 0; i--)
      thisWeekStart.subtract(Duration(days: i * 7)),
  ];
  final income = List.filled(count, 0.0);
  final expense = List.filled(count, 0.0);
  for (final t in txns) {
    final diff = t.createdAt.difference(starts.first).inDays;
    if (diff < 0) continue;
    final idx = diff ~/ 7;
    if (idx >= count) continue;
    if (t.type == 'income') {
      income[idx] += t.amount;
    } else {
      expense[idx] += t.amount;
    }
  }
  return [
    for (var i = 0; i < count; i++)
      IncomeExpensePoint(
        label: DateFormat('d MMM').format(starts[i]),
        income: income[i],
        expense: expense[i],
        date: starts[i],
        endDate: starts[i].add(const Duration(days: 6)),
      ),
  ];
}

List<IncomeExpensePoint> _monthBuckets(List<Transaction> txns, int count) {
  final now = DateTime.now();
  final months = [
    for (var i = count - 1; i >= 0; i--) DateTime(now.year, now.month - i, 1),
  ];
  final income = List.filled(count, 0.0);
  final expense = List.filled(count, 0.0);
  final first = months.first;
  for (final t in txns) {
    final idx =
        (t.createdAt.year - first.year) * 12 + t.createdAt.month - first.month;
    if (idx < 0 || idx >= count) continue;
    if (t.type == 'income') {
      income[idx] += t.amount;
    } else {
      expense[idx] += t.amount;
    }
  }
  return [
    for (var i = 0; i < count; i++)
      IncomeExpensePoint(
        label: DateFormat('MMM').format(months[i]),
        income: income[i],
        expense: expense[i],
        date: months[i],
        endDate: DateTime(months[i].year, months[i].month + 1, 0),
      ),
  ];
}
