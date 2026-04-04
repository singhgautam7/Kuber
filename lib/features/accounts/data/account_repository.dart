import 'package:isar_community/isar.dart';

import '../../../core/database/base_repository.dart';
import 'account.dart';
import '../../transactions/data/transaction.dart';

class AccountRepository extends BaseRepository<Account> {
  AccountRepository(super.isar);

  Future<List<Account>> getAll() async {
    return isar.accounts.where().findAll();
  }

  Future<Account?> getById(Id id) async {
    return isar.accounts.get(id);
  }

  Future<Id> save(Account a) async {
    return await isar.writeTxn(() => isar.accounts.put(a));
  }

  Future<void> delete(Id id) async {
    await isar.writeTxn(() => isar.accounts.delete(id));
  }

  Future<bool> hasTransactions(int accountId) async {
    final count = await isar.transactions
        .where()
        .filter()
        .accountIdEqualTo(accountId.toString())
        .count();
    return count > 0;
  }
}
