import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tags/providers/tag_providers.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../utils/filter_utils.dart';
import '../utils/history_utils.dart';
import 'history_filter_provider.dart';

/// Everything the History screen needs to render, derived once per change to
/// the underlying data or the active filter.
class HistoryView {
  /// Filtered transactions grouped by day, newest first.
  final List<DateGroup> groups;

  /// Count of transactions matching the filter (pre-grouping).
  final int filteredCount;

  final double totalIncome;
  final double totalExpense;

  /// Transaction id → tag names, for the row indicator line.
  final Map<int, List<String>> tagNamesMap;

  /// Transaction id → paired transfer leg's accountId (O(1) row lookup).
  final Map<int, String> transferPairAccountId;

  /// Whether the user has no transactions at all (drives empty-state copy).
  final bool sourceEmpty;

  double get totalNet => totalIncome - totalExpense;

  const HistoryView({
    required this.groups,
    required this.filteredCount,
    required this.totalIncome,
    required this.totalExpense,
    required this.tagNamesMap,
    required this.transferPairAccountId,
    required this.sourceEmpty,
  });
}

/// Memoized History view-model. Because this provider is kept alive (not
/// autoDispose) and only recomputes when transactions, the filter, or tags
/// change, the heavy filter→group→tag-map pass runs once — not on every screen
/// rebuild (e.g. entering selection mode) and not again when switching back to
/// the History tab. This is what keeps the tab from stuttering on entry.
final historyViewProvider = FutureProvider<HistoryView>((ref) async {
  final transactions = await ref.watch(transactionListProvider.future);
  final filter = ref.watch(historyFilterProvider);
  final txnTagsMap = await ref.watch(transactionTagsMapProvider.future);
  final tags = await ref.watch(tagListProvider.future);

  final filtered = applyHistoryFilters(
    transactions,
    filter,
    txnTagsMap: txnTagsMap,
  );

  final summary = filtered.computeSummary(
    start: DateTime.fromMillisecondsSinceEpoch(0),
    end: DateTime(9999),
  );

  final groups = groupTransactionsByDate(filtered);

  final tagNameById = {for (final t in tags) t.id: t.name};
  final tagNamesMap = <int, List<String>>{};
  for (final entry in txnTagsMap.entries) {
    final names = entry.value
        .map((tagId) => tagNameById[tagId])
        .whereType<String>()
        .toList();
    if (names.isNotEmpty) tagNamesMap[entry.key] = names;
  }

  return HistoryView(
    groups: groups,
    filteredCount: filtered.length,
    totalIncome: summary.income,
    totalExpense: summary.expense,
    tagNamesMap: tagNamesMap,
    transferPairAccountId: buildTransferPairAccountIds(transactions),
    sourceEmpty: transactions.isEmpty,
  );
});
