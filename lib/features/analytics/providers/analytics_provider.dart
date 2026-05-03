import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../../transactions/providers/transaction_provider.dart';

enum FilterType {
  all,
  today,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  custom,
}

class AnalyticsFilter {
  final FilterType type;
  final DateTime from;
  final DateTime to;

  AnalyticsFilter({
    required this.type,
    required this.from,
    required this.to,
  });

  AnalyticsFilter copyWith({
    FilterType? type,
    DateTime? from,
    DateTime? to,
  }) {
    return AnalyticsFilter(
      type: type ?? this.type,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

final analyticsFilterProvider = StateNotifierProvider<AnalyticsFilterNotifier, AnalyticsFilter>((ref) {
  return AnalyticsFilterNotifier(ref);
});

class AnalyticsFilterNotifier extends StateNotifier<AnalyticsFilter> {
  final Ref ref;

  AnalyticsFilterNotifier(this.ref) : super(_initialFilter()) {
    _loadSavedFilter();
  }

  static AnalyticsFilter _initialFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return AnalyticsFilter(type: FilterType.today, from: today, to: today);
  }

  Future<void> _loadSavedFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final typeIndex = prefs.getInt(PrefsKeys.analyticsFilterType);
    if (typeIndex == null || typeIndex >= FilterType.values.length) return;
    final savedType = FilterType.values[typeIndex];
    if (savedType == FilterType.custom) {
      final fromMs = prefs.getInt(PrefsKeys.analyticsFilterFrom);
      final toMs = prefs.getInt(PrefsKeys.analyticsFilterTo);
      if (fromMs != null && toMs != null) {
        state = AnalyticsFilter(
          type: FilterType.custom,
          from: DateTime.fromMillisecondsSinceEpoch(fromMs),
          to: DateTime.fromMillisecondsSinceEpoch(toMs),
        );
      }
    } else {
      setFilter(savedType);
    }
  }

  Future<void> _persist(FilterType type, DateTime from, DateTime to) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.analyticsFilterType, type.index);
    if (type == FilterType.custom) {
      await prefs.setInt(PrefsKeys.analyticsFilterFrom, from.millisecondsSinceEpoch);
      await prefs.setInt(PrefsKeys.analyticsFilterTo, to.millisecondsSinceEpoch);
    }
  }

  void setFilter(FilterType type, {DateTime? from, DateTime? to}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime newFrom = from ?? state.from;
    DateTime newTo = to ?? state.to;

    switch (type) {
      case FilterType.all:
        final transactions = ref.read(transactionListProvider).valueOrNull ?? [];
        if (transactions.isEmpty) {
          newFrom = today;
        } else {
          final sorted = List.from(transactions)..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          newFrom = sorted.first.createdAt;
        }
        newTo = today;
        break;
      case FilterType.today:
        newFrom = today;
        newTo = today;
        break;
      case FilterType.thisWeek:
        // Week = Monday -> Sunday. THIS WEEK = Monday -> Today
        final weekday = now.weekday; // 1 = Mon, 7 = Sun
        newFrom = today.subtract(Duration(days: weekday - 1));
        newTo = today;
        break;
      case FilterType.lastWeek:
        // LAST WEEK = previous Monday -> Sunday
        final weekday = now.weekday;
        newFrom = today.subtract(Duration(days: weekday + 6));
        newTo = today.subtract(Duration(days: weekday));
        break;
      case FilterType.thisMonth:
        newFrom = DateTime(now.year, now.month, 1);
        newTo = today;
        break;
      case FilterType.lastMonth:
        newFrom = DateTime(now.year, now.month - 1, 1);
        newTo = DateTime(now.year, now.month, 0); // Last day of previous month
        break;
      case FilterType.thisYear:
        newFrom = DateTime(now.year, 1, 1);
        newTo = today;
        break;
      case FilterType.custom:
        // from and to should be provided
        break;
    }

    state = AnalyticsFilter(type: type, from: newFrom, to: newTo);
    _persist(type, newFrom, newTo).ignore();
  }

  void reset() {
    setFilter(FilterType.today);
  }
}

/// Pre-computed analytics data — single O(n) pass over transactions.
/// Cached by Riverpod, recomputed only when filter or transactions change.
class AnalyticsComputed {
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final Map<String, double> dailyAverages;
  final Map<String, int> sizeDistribution;

  const AnalyticsComputed({
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.dailyAverages,
    required this.sizeDistribution,
  });
}

final analyticsComputedProvider = Provider<AnalyticsComputed?>((ref) {
  final txns = ref.watch(analyticsTransactionsProvider);
  if (txns.isEmpty) return null;

  double totalIncome = 0, totalExpense = 0;
  int smallCount = 0, mediumCount = 0, largeCount = 0;
  final Map<int, List<double>> dayAmounts = {
    1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [],
  };

  for (final t in txns) {
    if (t.type == 'income') {
      totalIncome += t.amount;
    } else {
      totalExpense += t.amount;
      // Size distribution (expense only)
      if (t.amount < 500) {
        smallCount++;
      } else if (t.amount <= 2000) {
        mediumCount++;
      } else {
        largeCount++;
      }
      // Daily averages by weekday (expense only)
      dayAmounts[t.createdAt.toLocal().weekday]!.add(t.amount);
    }
  }

  const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final dailyAverages = <String, double>{};
  for (int i = 1; i <= 7; i++) {
    final amounts = dayAmounts[i]!;
    dailyAverages[dayNames[i - 1]] = amounts.isEmpty
        ? 0.0
        : amounts.reduce((a, b) => a + b) / amounts.length;
  }

  return AnalyticsComputed(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netAmount: totalIncome - totalExpense,
    dailyAverages: dailyAverages,
    sizeDistribution: {'small': smallCount, 'medium': mediumCount, 'large': largeCount},
  );
});

final analyticsTransactionsProvider = Provider<List<Transaction>>((ref) {
  final filter = ref.watch(analyticsFilterProvider);
  final all = ref.watch(transactionListProvider).valueOrNull ?? [];
  
  final from = DateTime(filter.from.year, filter.from.month, filter.from.day);
  final to = DateTime(filter.to.year, filter.to.month, filter.to.day, 23, 59, 59);

  return all.validForCalculations.where((t) {
    final date = t.createdAt;
    return !date.isBefore(from) && !date.isAfter(to);
  }).toList();
});
