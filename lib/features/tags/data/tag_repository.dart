import 'package:isar_community/isar.dart';
import 'tag.dart';
import 'transaction_tag.dart';

class TagRepository {
  final Isar isar;

  TagRepository(this.isar);

  // --- Tag Operations ---

  /// Get all tags, sorted alphabetically by name.
  Future<List<Tag>> getAllTags() async {
    return isar.tags.where().sortByName().findAll();
  }

  /// Watch all tags for changes.
  Stream<List<Tag>> watchTags() {
    return isar.tags.where().sortByName().watch(fireImmediately: true);
  }

  /// Create or update a tag.
  Future<int> saveTag(Tag tag) async {
    // Always normalize name before saving
    tag.name = Tag.normalize(tag.name);
    
    return isar.writeTxn(() async {
      return isar.tags.put(tag);
    });
  }

  /// Find a tag by name (already normalized).
  Future<Tag?> findByName(String name) async {
    final normalized = Tag.normalize(name);
    return isar.tags.where().nameEqualTo(normalized).findFirst();
  }

  /// Toggle tag enabled status.
  Future<void> setTagEnabled(int tagId, bool enabled) async {
    await isar.writeTxn(() async {
      final tag = await isar.tags.get(tagId);
      if (tag != null) {
        tag.isEnabled = enabled;
        await isar.tags.put(tag);
      }
    });
  }

  // --- Transaction-Tag Relationship Operations ---

  /// Get all tags assigned to a specific transaction.
  Future<List<Tag>> getTagsForTransaction(int transactionId) async {
    final junctionRecords = await isar.transactionTags
        .where()
        .transactionIdEqualTo(transactionId)
        .findAll();
    
    if (junctionRecords.isEmpty) return [];
    
    final tagIds = junctionRecords.map((r) => r.tagId).toList();
    return isar.tags.getAll(tagIds).then((tags) => tags.whereType<Tag>().toList());
  }

  /// Watch tags for a specific transaction.
  Stream<List<Tag>> watchTagsForTransaction(int transactionId) {
    return isar.transactionTags
        .where()
        .transactionIdEqualTo(transactionId)
        .watch(fireImmediately: true)
        .asyncMap((_) => getTagsForTransaction(transactionId));
  }

  /// Update tags for a transaction (sync logic).
  Future<void> updateTransactionTags(int transactionId, List<int> tagIds) async {
    await isar.writeTxn(() async {
      // 1. Remove existing relations
      await isar.transactionTags
          .where()
          .transactionIdEqualTo(transactionId)
          .deleteAll();

      // 2. Add new relations
      final newRelations = tagIds.map((tagId) => TransactionTag()
        ..transactionId = transactionId
        ..tagId = tagId).toList();

      await isar.transactionTags.putAll(newRelations);
    });
  }

  /// Find transactions that have ALL of the specified tags (AND logic).
  Future<List<int>> findTransactionIdsWithTags(List<int> tagIds) async {
    if (tagIds.isEmpty) return [];

    // This is a bit complex in Isar without joins.
    // We'll intersect the transaction IDs for each tag.
    
    Set<int>? resultSet;

    for (final tagId in tagIds) {
      final txIds = await isar.transactionTags
          .where()
          .tagIdEqualTo(tagId)
          .findAll()
          .then((records) => records.map((r) => r.transactionId).toSet());
      
      if (resultSet == null) {
        resultSet = txIds;
      } else {
        resultSet = resultSet.intersection(txIds);
      }
      
      if (resultSet.isEmpty) break;
    }

    return resultSet?.toList() ?? [];
  }

  /// Watch all transaction-tag relationships.
  Stream<Map<int, Set<int>>> watchTransactionTagsMap() {
    return isar.transactionTags.where().watch(fireImmediately: true).asyncMap((records) {
      final map = <int, Set<int>>{};
      for (final r in records) {
        map.putIfAbsent(r.transactionId, () => {}).add(r.tagId);
      }
      return map;
    });
  }

  /// Delete a tag and all its relationships.
  Future<void> deleteTag(int tagId) async {
    await isar.writeTxn(() async {
      await isar.tags.delete(tagId);
      // Also delete junction records
      await isar.transactionTags.where().tagIdEqualTo(tagId).deleteAll();
    });
  }
}
