import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/database/isar_service.dart';
import '../data/tag.dart';
import '../data/tag_repository.dart';
import '../data/transaction_tag.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TagRepository(isar);
});

final tagListProvider = StreamProvider<List<Tag>>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.watchTags();
});

/// Cached tag-id → name map. Consumers that need to display tag names for
/// transactions (Home recent card, History rows, etc.) can watch this
/// derived provider instead of rebuilding the map inline on every rebuild.
final tagNameByIdProvider = Provider<Map<int, String>>((ref) {
  final tags = ref.watch(tagListProvider).valueOrNull ?? const <Tag>[];
  return {for (final t in tags) t.id: t.name};
});

final transactionTagsProvider = StreamProvider.family<List<Tag>, int>((ref, transactionId) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.watchTagsForTransaction(transactionId);
});

// A provider for currently selected tags in the state (e.g. for Add Transaction or Filters)
// This will be used by the UI to keep track of a temporary list before saving.
final selectedTagsProvider = StateProvider.autoDispose<List<Tag>>((ref) => []);

final transactionTagsMapProvider = StreamProvider<Map<int, Set<int>>>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.watchTransactionTagsMap();
});

final tagRecentTransactionProvider =
    FutureProvider.family<Transaction?, int>((ref, tagId) async {
  // Watch transactionListProvider to re-compute when transactions change
  ref.watch(transactionListProvider);
  final isar = ref.watch(isarProvider);

  final junctions = await isar.transactionTags
      .filter()
      .tagIdEqualTo(tagId)
      .findAll();

  if (junctions.isEmpty) return null;

  final txIds = junctions.map((j) => j.transactionId).toList();

  // Fetch all transactions for these IDs and sort in-memory
  final txns = await isar.transactions.getAll(txIds);
  final validTxns = txns.whereType<Transaction>().toList();
  
  if (validTxns.isEmpty) return null;
  
  validTxns.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return validTxns.first;
});

/// The earliest transaction tagged with [tagId] (for the tag's "First Used"
/// row), or null when the tag has never been used.
final tagFirstTransactionProvider =
    FutureProvider.family<Transaction?, int>((ref, tagId) async {
  ref.watch(transactionListProvider);
  final isar = ref.watch(isarProvider);

  final junctions =
      await isar.transactionTags.filter().tagIdEqualTo(tagId).findAll();
  if (junctions.isEmpty) return null;

  final txIds = junctions.map((j) => j.transactionId).toList();
  final txns = await isar.transactions.getAll(txIds);
  final validTxns = txns.whereType<Transaction>().toList();
  if (validTxns.isEmpty) return null;

  validTxns.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return validTxns.first;
});

final tagTransactionCountProvider = StreamProvider.family<int, int>((ref, tagId) {
  final isar = ref.watch(isarProvider);
  return isar.transactionTags
      .filter()
      .tagIdEqualTo(tagId)
      .watch(fireImmediately: true)
      .map((records) => records.length);
});
