import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/providers/category_provider.dart';
import '../../dashboard/providers/insight_engine.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../models/insight.dart';

final smartInsightsProvider = Provider<List<KuberInsight>>((ref) {
  final transactions = ref.watch(transactionListProvider).valueOrNull;
  final categories = ref.watch(categoryListProvider).valueOrNull;
  final currency = ref.watch(currencyProvider);

  if (transactions == null || categories == null) return [];

  final engine = InsightEngine(
    allTransactions: transactions,
    categories: categories,
    currencySymbol: currency.symbol,
    formatter: ref.watch(formatterProvider),
  );

  return engine.generate();
});
