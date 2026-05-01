import 'package:isar_community/isar.dart';

import '../../../core/database/base_repository.dart';
import 'transaction.dart';

class TransactionRepository extends BaseRepository<Transaction> {
  TransactionRepository(super.isar);

  Future<List<Transaction>> getAll() async {
    return isar.transactions.where().sortByCreatedAtDesc().findAll();
  }

  Future<Transaction?> getById(Id id) async {
    return isar.transactions.get(id);
  }

  Future<int> save(Transaction t) async {
    t.nameLower = t.name.toLowerCase();
    t.updatedAt = DateTime.now();
    return isar.writeTxn(() => isar.transactions.put(t));
  }

  Future<void> delete(Id id) async {
    await isar.writeTxn(() => isar.transactions.delete(id));
  }

  Future<void> restore(Transaction t) async {
    t.nameLower = t.name.toLowerCase();
    await isar.writeTxn(() => isar.transactions.put(t));
  }

  Future<List<Transaction>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    final all = await isar.transactions
        .filter()
        .nameContains(query, caseSensitive: false)
        .sortByUpdatedAtDesc()
        .findAll();

    // Deduplicate: keep only most recent per lowercase name
    final seen = <String>{};
    return all.where((t) => seen.add(t.name.toLowerCase())).take(5).toList();
  }



  Future<Transaction?> findTransferPair(String transferId, int excludeId) async {
    final pair = await isar.transactions
        .filter()
        .transferIdEqualTo(transferId)
        .findAll();
    return pair.where((t) => t.id != excludeId).firstOrNull;
  }

  Future<List<int>> saveTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime createdAt,
    String? notes,
  }) async {
    if (fromAccountId == toAccountId) {
      throw ArgumentError('FROM and TO accounts must be different');
    }
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }

    final transferId = DateTime.now().millisecondsSinceEpoch.toString();

    final fromTxn = Transaction()
      ..name = ''
      ..nameLower = ''
      ..amount = amount
      ..type = 'expense'
      ..accountId = fromAccountId
      ..categoryId = ''
      ..isTransfer = true
      ..transferId = transferId
      ..notes = notes

      ..createdAt = createdAt
      ..updatedAt = DateTime.now();

    final toTxn = Transaction()
      ..name = ''
      ..nameLower = ''
      ..amount = amount
      ..type = 'income'
      ..accountId = toAccountId
      ..categoryId = ''
      ..isTransfer = true
      ..transferId = transferId
      ..notes = notes

      ..createdAt = createdAt
      ..updatedAt = DateTime.now();

    late int fromId, toId;
    await isar.writeTxn(() async {
      fromId = await isar.transactions.put(fromTxn);
      toId = await isar.transactions.put(toTxn);
    });
    return [fromId, toId];
  }

  Future<List<int>> updateTransfer({
    required int id,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime createdAt,
    String? notes,
  }) async {
    // Find existing pair
    final existing = await isar.transactions.get(id);
    if (existing == null) throw ArgumentError('Transaction not found');

    // Delete old pair
    if (existing.transferId != null) {
      await deleteTransferPair(existing.transferId!);
    } else {
      await isar.writeTxn(() => isar.transactions.delete(id));
    }

    // Create new pair
    return saveTransfer(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      createdAt: createdAt,
      notes: notes,
    );
  }

  Future<void> deleteTransferPair(String transferId) async {
    final pair = await isar.transactions
        .filter()
        .transferIdEqualTo(transferId)
        .findAll();
    await isar.writeTxn(() async {
      await isar.transactions.deleteAll(pair.map((t) => t.id).toList());
    });
  }
}
