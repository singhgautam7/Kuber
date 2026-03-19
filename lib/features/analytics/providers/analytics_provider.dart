import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';

enum AnalyticsPeriod { all, today, week, month, lastMonth, threeMonths, year, custom }

final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final analyticsTransactionsProvider =
    Provider.family<List<Transaction>, AnalyticsPeriod>((ref, period) {
  final all = ref.watch(transactionListProvider).valueOrNull ?? [];
  final now = DateTime.now();
  DateTime? from;
  DateTime? to;
  switch (period) {
    case AnalyticsPeriod.all:
      return all;
    case AnalyticsPeriod.today:
      from = DateTime(now.year, now.month, now.day);
    case AnalyticsPeriod.week:
      from = now.subtract(const Duration(days: 7));
    case AnalyticsPeriod.month:
      from = DateTime(now.year, now.month, 1);
    case AnalyticsPeriod.lastMonth:
      from = DateTime(now.year, now.month - 1, 1);
      to = DateTime(now.year, now.month, 1);
    case AnalyticsPeriod.threeMonths:
      from = DateTime(now.year, now.month - 2, 1);
    case AnalyticsPeriod.year:
      from = DateTime(now.year, 1, 1);
    case AnalyticsPeriod.custom:
      final range = ref.watch(customDateRangeProvider);
      if (range == null) return all;
      from = range.start;
      to = range.end.add(const Duration(days: 1));
  }
  return all.where((t) {
    if (from != null && t.createdAt.isBefore(from)) return false;
    if (to != null && !t.createdAt.isBefore(to)) return false;
    return true;
  }).toList();
});
