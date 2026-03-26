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
      return all.where((t) => t.type != 'transfer').toList();
    case AnalyticsPeriod.today:
      from = DateTime(now.year, now.month, now.day);
      to = from.add(const Duration(days: 1));
      break;
    case AnalyticsPeriod.week:
      from = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      to = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      break;
    case AnalyticsPeriod.month:
      from = DateTime(now.year, now.month, 1);
      to = DateTime(now.year, now.month + 1, 1);
      break;
    case AnalyticsPeriod.lastMonth:
      from = DateTime(now.year, now.month - 1, 1);
      to = DateTime(now.year, now.month, 1);
      break;
    case AnalyticsPeriod.threeMonths:
      from = DateTime(now.year, now.month - 2, 1);
      to = DateTime(now.year, now.month + 1, 1);
      break;
    case AnalyticsPeriod.year:
      from = DateTime(now.year, 1, 1);
      to = DateTime(now.year + 1, 1, 1);
      break;
    case AnalyticsPeriod.custom:
      final range = ref.watch(customDateRangeProvider);
      if (range == null) return all.where((t) => t.type != 'transfer').toList();
      from = range.start;
      to = range.end.add(const Duration(days: 1));
      break;
  }

  return all.where((t) {
    if (t.type == 'transfer') return false;
    final localCreated = t.createdAt.toLocal();
    final isAfterStart = from == null || !localCreated.isBefore(from);
    final isBeforeEnd = to == null || localCreated.isBefore(to);
    return isAfterStart && isBeforeEnd;
  }).toList();
});
