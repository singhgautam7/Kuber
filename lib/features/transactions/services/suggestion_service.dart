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

  /// Rebuilds the suggestion table from every transaction. One suggestion per
  /// distinct (lower-cased) name, the most recent transaction winning. Computes
  /// the deduped set in memory then writes it with chunked bulk `putAll` — far
  /// faster than a query + write transaction per transaction on a large restore
  /// — yielding the event loop between chunks so the UI stays responsive.
  /// Transfers and empty names are skipped.
  Future<void> rebuildAll({int batchSize = 500}) async {
    final all = await isar.transactions.where().findAll();

    // Dedup to one suggestion per lower-cased name (most recent wins, since
    // findAll() is id-ascending and later writes overwrite the map entry).
    final byName = <String, TransactionSuggestion>{};
    final now = DateTime.now();
    for (final txn in all) {
      if (txn.isTransfer || txn.name.trim().isEmpty) continue;
      final key = txn.name.toLowerCase().trim();
      byName[key] = TransactionSuggestion()
        ..nameLower = key
        ..displayName = txn.name.trim()
        ..categoryId = txn.categoryId.isEmpty ? null : txn.categoryId
        ..accountId = txn.accountId.isEmpty ? null : txn.accountId
        ..amount = txn.amount
        ..type = txn.type
        ..createdAt = now
        ..updatedAt = now;
    }

    // Replace the whole derived table (a fresh rebuild), then bulk-insert in
    // chunks — far faster than a query + write per transaction, and yielding
    // the event loop between chunks keeps the UI responsive. Clearing first
    // means every row is a fresh insert, so the unique nameLower index can
    // never collide regardless of any pre-existing rows.
    await isar.writeTxn(() => isar.transactionSuggestions.clear());
    final suggestions = byName.values.toList();
    for (var start = 0; start < suggestions.length; start += batchSize) {
      final end = start + batchSize < suggestions.length
          ? start + batchSize
          : suggestions.length;
      await isar.writeTxn(
        () => isar.transactionSuggestions.putAll(suggestions.sublist(start, end)),
      );
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
