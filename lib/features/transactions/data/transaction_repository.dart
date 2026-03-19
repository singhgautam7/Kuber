import 'package:isar/isar.dart';

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

  Future<void> save(Transaction t) async {
    t.nameLower = t.name.toLowerCase();
    t.updatedAt = DateTime.now();
    if (t.id == Isar.autoIncrement) {
      t.createdAt = DateTime.now();
    }
    await isar.writeTxn(() => isar.transactions.put(t));
  }

  Future<void> delete(Id id) async {
    await isar.writeTxn(() => isar.transactions.delete(id));
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

  Future<List<Transaction>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return isar.transactions
        .filter()
        .createdAtBetween(start, end)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<Transaction>> getByMonth(int year, int month) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return getByDateRange(start, end);
  }
}
