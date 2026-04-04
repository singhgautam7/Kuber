import 'package:isar/isar.dart';

import '../../../core/database/base_repository.dart';
import 'ledger.dart';

class LedgerRepository extends BaseRepository<Ledger> {
  LedgerRepository(super.isar);

  Future<List<Ledger>> getAll() async {
    return isar.ledgers.where().sortByCreatedAtDesc().findAll();
  }

  Future<Ledger?> getById(Id id) async {
    return isar.ledgers.get(id);
  }

  Future<int> save(Ledger entry) async {
    entry.updatedAt = DateTime.now();
    if (entry.id == Isar.autoIncrement) {
      entry.createdAt = DateTime.now();
    }
    entry.personNameLower = entry.personName.toLowerCase();
    return isar.writeTxn(() => isar.ledgers.put(entry));
  }

  Future<void> delete(Id id) async {
    await isar.writeTxn(() => isar.ledgers.delete(id));
  }

  Future<List<String>> getDistinctPersonNames() async {
    final all = await isar.ledgers.where().findAll();
    final names = <String>{};
    for (final l in all) {
      names.add(l.personName);
    }
    return names.toList()..sort();
  }
}
