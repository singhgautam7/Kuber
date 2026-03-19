import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';

enum AnalyticsPeriod { week, month, threeMonths, year }

final analyticsTransactionsProvider =
    Provider.family<List<Transaction>, AnalyticsPeriod>((ref, period) {
  final all = ref.watch(transactionListProvider).valueOrNull ?? [];
  final now = DateTime.now();
  DateTime from;
  switch (period) {
    case AnalyticsPeriod.week:
      from = now.subtract(const Duration(days: 7));
    case AnalyticsPeriod.month:
      from = DateTime(now.year, now.month, 1);
    case AnalyticsPeriod.threeMonths:
      from = DateTime(now.year, now.month - 2, 1);
    case AnalyticsPeriod.year:
      from = DateTime(now.year, 1, 1);
  }
  return all.where((t) => t.createdAt.isAfter(from)).toList();
});
