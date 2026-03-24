import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../data/tag.dart';
import '../data/tag_repository.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TagRepository(isar);
});

final tagListProvider = StreamProvider<List<Tag>>((ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.watchTags();
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
