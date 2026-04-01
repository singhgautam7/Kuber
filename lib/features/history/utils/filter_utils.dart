import '../../transactions/data/transaction.dart';
import '../models/history_filter.dart';

/// Shared filter logic used by both the History screen and the export provider.
List<Transaction> applyHistoryFilters(
  List<Transaction> transactions,
  HistoryFilter filter, {
  Map<int, Set<int>>? txnTagsMap,
}) {
  var filtered = transactions;

  // Search filter
  if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
    final query = filter.searchQuery!.toLowerCase();
    filtered = filtered.where((t) => t.name.toLowerCase().contains(query)).toList();
  }

  // Type filter
  if (filter.types.isNotEmpty) {
    filtered = filtered.where((t) {
      if (t.isTransfer) return filter.types.contains('transfer');
      return filter.types.contains(t.type);
    }).toList();
  }

  // Recurring filter
  if (filter.isRecurring != null) {
    filtered = filtered.where((t) => t.isRecurring == filter.isRecurring).toList();
  }

  // Date Range
  if (filter.from != null && filter.to != null) {
    filtered = filtered.where((t) =>
        !t.createdAt.isBefore(filter.from!) &&
        t.createdAt.isBefore(filter.to!.add(const Duration(days: 1)))).toList();
  }

  // Accounts
  if (filter.accountIds.isNotEmpty) {
    filtered = filtered.where((t) =>
        filter.accountIds.contains(t.accountId)).toList();
  }

  // Categories
  if (filter.categoryIds.isNotEmpty) {
    filtered = filtered.where((t) =>
        filter.categoryIds.contains(t.categoryId)).toList();
  }

  // Tags (AND logic)
  if (filter.tagIds.isNotEmpty && txnTagsMap != null) {
    filtered = filtered.where((t) {
      final txnTags = txnTagsMap[t.id] ?? {};
      return filter.tagIds.every((tagId) => txnTags.contains(tagId));
    }).toList();
  }

  return filtered;
}
