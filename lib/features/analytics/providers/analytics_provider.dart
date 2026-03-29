import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/data/transaction.dart';
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

  AnalyticsFilterNotifier(this.ref) : super(_initialFilter());

  static AnalyticsFilter _initialFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return AnalyticsFilter(
      type: FilterType.today,
      from: today,
      to: today,
    );
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
  }

  void reset() {
    setFilter(FilterType.today);
  }
}

final analyticsTransactionsProvider = Provider<List<Transaction>>((ref) {
  final filter = ref.watch(analyticsFilterProvider);
  final all = ref.watch(transactionListProvider).valueOrNull ?? [];
  
  final from = DateTime(filter.from.year, filter.from.month, filter.from.day);
  final to = DateTime(filter.to.year, filter.to.month, filter.to.day, 23, 59, 59);

  return all.where((t) {
    if (t.isTransfer || t.isBalanceAdjustment) return false;
    final date = t.createdAt;
    return !date.isBefore(from) && !date.isAfter(to);
  }).toList();
});
