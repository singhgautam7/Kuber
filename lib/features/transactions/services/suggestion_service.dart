import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart';
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
      isar.transactionSuggestions.put(TransactionSuggestion()
        ..id = existing?.id ?? Isar.autoIncrement
        ..nameLower = key
        ..displayName = txn.name.trim()
        ..categoryId = txn.categoryId.isEmpty ? null : txn.categoryId
        ..accountId = txn.accountId.isEmpty ? null : txn.accountId
        ..amount = txn.amount
        ..createdAt = existing?.createdAt ?? DateTime.now()
        ..updatedAt = DateTime.now());
    });
  }

  Future<List<TransactionSuggestion>> search(String query) async {
    if (query.trim().isEmpty) return [];
    return isar.transactionSuggestions
        .filter()
        .nameLowerContains(query.toLowerCase().trim())
        .sortByUpdatedAtDesc()
        .limit(12)
        .findAll();
  }

  Future<void> clearAll() async {
    await isar.writeTxn(() => isar.transactionSuggestions.clear());
  }
}

final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  return SuggestionService(ref.watch(isarProvider));
});
