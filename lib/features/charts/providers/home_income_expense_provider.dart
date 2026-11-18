import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/expressive_chart/chart_model.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';

/// Home chart period: exactly the last 7 days, 6 months or 12 months (user
/// decision 2026-11-18: no older periods scroll in on Home).
enum HomeChartRange {
  days7(7),
  months6(6),
  months12(12);

  const HomeChartRange(this.window);

  /// Slots in view.
  final int window;
}

/// Selected period for the Home income / expense chart (default 6M).
final homeChartRangeProvider =
    StateProvider<HomeChartRange>((ref) => HomeChartRange.months6);

/// Bar / Line for the Home chart.
final homeChartModeProvider =
    StateProvider<ExpressiveChartMode>((ref) => ExpressiveChartMode.bar);

/// Monthly totals for the whole history, oldest first, from the first month
/// with a transaction to the current month. One pass over the loaded list.
final monthlyChartPeriodsProvider = Provider<List<ExpressivePeriod>>((ref) {
  final txns =
      ref.watch(transactionListProvider).valueOrNull ?? const <Transaction>[];
  return buildMonthlyPeriods(txns, DateTime.now());
});

/// Daily totals for the last 7 days (today last). One pass over the loaded
/// list, same rules as [buildMonthlyPeriods].
final dailyChartPeriodsProvider = Provider<List<ExpressivePeriod>>((ref) {
  final txns =
      ref.watch(transactionListProvider).valueOrNull ?? const <Transaction>[];
  return buildDailyPeriods(txns, DateTime.now());
});

List<ExpressivePeriod> buildDailyPeriods(
    Iterable<Transaction> txns, DateTime now, {int days = 7}) {
  final today = DateTime(now.year, now.month, now.day);
  final start = today.subtract(Duration(days: days - 1));
  int idxOf(DateTime d) => DateTime(d.year, d.month, d.day).difference(start).inHours ~/ 24;
  final income = List<double>.filled(days, 0);
  final expense = List<double>.filled(days, 0);
  final has = List<bool>.filled(days, false);
  var any = false;
  for (final t in txns) {
    if (t.isTransfer || t.isBalanceAdjustment) continue;
    final isIncome = t.type == 'income';
    if (!isIncome && t.type != 'expense') continue;
    if (t.createdAt.isBefore(start)) continue;
    final i = idxOf(t.createdAt);
    if (i < 0 || i >= days) continue;
    any = true;
    has[i] = true;
    if (isIncome) {
      income[i] += t.amount;
    } else {
      expense[i] += t.amount;
    }
  }
  if (!any) return const [];
  final short = DateFormat('EEE');
  final full = DateFormat('EEE, d MMM');
  return [
    for (var i = 0; i < days; i++)
      () {
        final day = DateTime(start.year, start.month, start.day + i);
        return ExpressivePeriod(
          key: day.year * 10000 + day.month * 100 + day.day,
          label: short.format(day),
          fullLabel: full.format(day),
          values: [income[i], expense[i]],
          noData: !has[i],
          isCurrent: i == days - 1,
        );
      }(),
  ];
}

/// Same rules as `monthlySummaryProvider` (`aggregate()`): transfers and
/// balance adjustments are dropped, income and expense sum `amount`. A month
/// with no income or expense transaction at all is `noData`.
List<ExpressivePeriod> buildMonthlyPeriods(
    Iterable<Transaction> txns, DateTime now) {
  int idxOf(DateTime d) => d.year * 12 + d.month - 1;
  final nowIdx = idxOf(now);
  final income = <int, double>{};
  final expense = <int, double>{};
  final has = <int>{};
  var first = nowIdx;
  for (final t in txns) {
    if (t.isTransfer || t.isBalanceAdjustment) continue;
    final isIncome = t.type == 'income';
    if (!isIncome && t.type != 'expense') continue;
    final i = idxOf(t.createdAt);
    if (i > nowIdx) continue;
    if (i < first) first = i;
    has.add(i);
    if (isIncome) {
      income[i] = (income[i] ?? 0) + t.amount;
    } else {
      expense[i] = (expense[i] ?? 0) + t.amount;
    }
  }
  if (has.isEmpty) return const [];
  final short = DateFormat('MMM');
  final full = DateFormat('MMMM yyyy');
  return [
    for (var i = first; i <= nowIdx; i++)
      () {
        final month = DateTime(i ~/ 12, i % 12 + 1);
        final exp = expense[i] ?? 0;
        final cur = i == nowIdx;
        return ExpressivePeriod(
          key: i,
          label: short.format(month),
          fullLabel: full.format(month),
          values: [income[i] ?? 0, exp],
          noData: !has.contains(i),
          isCurrent: cur,
        );
      }(),
  ];
}
