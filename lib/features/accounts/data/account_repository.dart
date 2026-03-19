import 'package:isar/isar.dart';

import '../../../core/database/base_repository.dart';
import 'account.dart';

class AccountRepository extends BaseRepository<Account> {
  AccountRepository(super.isar);

  Future<List<Account>> getAll() async {
    return isar.accounts.where().findAll();
  }

  Future<Account?> getById(Id id) async {
    return isar.accounts.get(id);
  }

  Future<void> save(Account a) async {
    await isar.writeTxn(() => isar.accounts.put(a));
  }

  Future<void> delete(Id id) async {
    await isar.writeTxn(() => isar.accounts.delete(id));
  }

  Future<void> seedDefaults() async {
    final count = await isar.accounts.count();
    if (count > 0) return;

    final defaults = [
      Account()
        ..name = 'Cash'
        ..type = 'cash'
        ..icon = 'payments'
        ..colorValue = 0xFF66BB6A,
      Account()
        ..name = 'Bank Account'
        ..type = 'bank'
        ..icon = 'account_balance'
        ..colorValue = 0xFF5C6BC0,
      Account()
        ..name = 'Credit Card'
        ..type = 'bank'
        ..isCreditCard = true
        ..icon = 'credit_card'
        ..colorValue = 0xFFAB47BC
        ..creditLimit = 0,
    ];

    await isar.writeTxn(() => isar.accounts.putAll(defaults));
  }
}
