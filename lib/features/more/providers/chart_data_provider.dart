import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/providers/category_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/providers/stats_provider.dart';

enum ChartPeriod { oneDay, oneWeek, oneMonth, oneQuarter, oneYear }

extension ChartPeriodLabel on ChartPeriod {
  String get label => switch (this) {
        ChartPeriod.oneDay => '1D',
        ChartPeriod.oneWeek => '1W',
        ChartPeriod.oneMonth => '1M',
        ChartPeriod.oneQuarter => '1Q',
        ChartPeriod.oneYear => '1Y',
      };
}

class ChartBarBucket {
  final String label;
  final double income;
  final double expense;
  final DateTime startDate;
  final DateTime endDate;

  const ChartBarBucket({
    required this.label,
    required this.income,
    required this.expense,
    required this.startDate,
    required this.endDate,
  });
}

final selectedChartPeriodProvider =
    StateProvider<ChartPeriod>((_) => ChartPeriod.oneMonth);

final selectedChartBarIndexProvider = StateProvider<int?>((ref) => null);

final chartDataProvider =
    FutureProvider.family<List<ChartBarBucket>, ChartPeriod>(
  (ref, period) async {
    final all = await ref.watch(transactionListProvider.future);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final valid = all
        .where((t) =>
            !t.isTransfer && !t.isBalanceAdjustment && t.linkedRuleType == null)
        .toList();

    List<ChartBarBucket> buildBuckets(
        List<({DateTime start, DateTime end, String label})> slots) {
      return slots.map((s) {
        double income = 0, expense = 0;
        for (final t in valid) {
          if (t.createdAt.isBefore(s.start) || !t.createdAt.isBefore(s.end)) {
            continue;
          }
          if (t.type == 'income') {
            income += t.amount;
          } else {
            expense += t.amount;
          }
        }
        return ChartBarBucket(
          label: s.label,
          income: income,
          expense: expense,
          startDate: s.start,
          endDate: s.end,
        );
      }).toList();
    }

    switch (period) {
      case ChartPeriod.oneDay:
        final slots = List.generate(24, (h) {
          final start = DateTime(today.year, today.month, today.day, h);
          return (
            start: start,
            end: start.add(const Duration(hours: 1)),
            label: h == 0
                ? '12a'
                : h < 12
                    ? '${h}a'
                    : h == 12
                        ? '12p'
                        : '${h - 12}p',
          );
        });
        return buildBuckets(slots);

      case ChartPeriod.oneWeek:
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final slots = List.generate(7, (i) {
          final start = today.subtract(Duration(days: 6 - i));
          return (
            start: start,
            end: start.add(const Duration(days: 1)),
            label: days[start.weekday - 1],
          );
        });
        return buildBuckets(slots);

      case ChartPeriod.oneMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final slots = List.generate(daysInMonth, (i) {
          final start = monthStart.add(Duration(days: i));
          return (
            start: start,
            end: start.add(const Duration(days: 1)),
            label: '${start.day}',
          );
        });
        return buildBuckets(slots);

      case ChartPeriod.oneQuarter:
        final slots = List.generate(13, (i) {
          final start = today.subtract(Duration(days: (12 - i) * 7));
          return (
            start: start,
            end: start.add(const Duration(days: 7)),
            label: 'W${i + 1}',
          );
        });
        return buildBuckets(slots);

      case ChartPeriod.oneYear:
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final slots = List.generate(12, (i) {
          final start = DateTime(now.year, now.month - 11 + i, 1);
          final end = DateTime(now.year, now.month - 11 + i + 1, 1);
          return (
            start: start,
            end: end,
            label: months[(start.month - 1) % 12],
          );
        });
        return buildBuckets(slots);
    }
  },
);

// Category stats for a specific date range — used by the Charts detail panel.
// Uses a Dart 3 record as family key (structural equality built-in).
final chartCategoryStatsProvider = FutureProvider.family<List<CategoryStat>,
    ({DateTime from, DateTime to})>(
  (ref, range) async {
    final all = await ref.watch(transactionListProvider.future);
    final categoryMap = await ref.watch(categoryMapProvider.future);

    final Map<int, double> totals = {};
    double overallTotal = 0;

    for (final t in all) {
      if (t.type != 'expense' ||
          t.isBalanceAdjustment ||
          t.isTransfer ||
          t.linkedRuleType != null) {
        continue;
      }
      if (t.createdAt.isBefore(range.from) ||
          !t.createdAt.isBefore(range.to.add(const Duration(days: 1)))) {
        continue;
      }
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
              percentage:
                  overallTotal > 0 ? (e.value / overallTotal) * 100 : 0,
            ))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return stats;
  },
);
