import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../tutorial/providers/tutorial_sandbox_provider.dart';
import '../data/transaction.dart';
import '../data/transaction_suggestion.dart';

class SuggestionService {
  final Isar isar;
  SuggestionService(this.isar);

  Future<void> upsertSuggestion(Transaction txn) async {
    if (txn.isTransfer || txn.name.trim().isEmpty) return;
    final key = txn.name.toLowerCase().trim();
    final existing = await isar.transactionSuggestions
        .where()
        .nameLowerEqualTo(key)
        .findFirst();
    await isar.writeTxn(() async {
      // Must be awaited: without it the put can flush after the txn commits, so
      // back-to-back upserts of the same name both observe `existing == null`
      // and insert duplicate rows — violating the unique `nameLower` index.
      await isar.transactionSuggestions.put(
        TransactionSuggestion()
          ..id = existing?.id ?? Isar.autoIncrement
          ..nameLower = key
          ..displayName = txn.name.trim()
          ..categoryId = txn.categoryId.isEmpty ? null : txn.categoryId
          ..accountId = txn.accountId.isEmpty ? null : txn.accountId
          ..amount = txn.amount
          ..type = txn.type
          ..createdAt = existing?.createdAt ?? DateTime.now()
          ..updatedAt = DateTime.now(),
      );
    });
  }

  /// Rebuilds the suggestion table from every transaction. Batched with
  /// event-loop yields so a large dataset (migration backfill, JSON restore,
  /// mock-data generation) doesn't block the UI isolate. Transfers and empty
  /// names are skipped inside [upsertSuggestion].
  Future<void> rebuildAll({int batchSize = 50}) async {
    final all = await isar.transactions.where().findAll();
    for (int i = 0; i < all.length; i += batchSize) {
      for (final txn in all.skip(i).take(batchSize)) {
        await upsertSuggestion(txn);
      }
      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<List<TransactionSuggestion>> search(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    // Fetch all substring matches — index can't help with contains, so the
    // scan cost is the same regardless of how many rows come back.
    final results = await isar.transactionSuggestions
        .filter()
        .nameLowerContains(q)
        .sortByUpdatedAtDesc()
        .findAll();

    // 3-tier relevance: exact (0) > prefix (1) > contains (2).
    // Within each tier keep recency order from the Isar sort above.
    int score(String name) {
      if (name == q) return 0;
      if (name.startsWith(q)) return 1;
      return 2;
    }

    results.sort((a, b) => score(a.nameLower).compareTo(score(b.nameLower)));

    return results.take(15).toList();
  }

  Future<void> clearAll() async {
    await isar.writeTxn(() => isar.transactionSuggestions.clear());
  }
}

final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  return SuggestionService(ref.watch(tutorialAwareIsarProvider));
});
