import 'package:isar/isar.dart';

import '../../../core/database/base_repository.dart';
import '../../../core/utils/transfer_helpers.dart';
import '../../accounts/data/account.dart';
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
    t.isRecurring = t.recurringRuleId != null;
    if (t.id == Isar.autoIncrement) {
      t.createdAt = DateTime.now();
    }
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

  Future<int> saveTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime createdAt,
    String? notes,
    bool fromIsCreditCard = false,
  }) async {
    if (fromAccountId == toAccountId) {
      throw ArgumentError('FROM and TO accounts must be different');
    }
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }

    // Check balance for non-credit-card FROM accounts
    if (!fromIsCreditCard) {
      final balance = await _computeBalance(fromAccountId);
      if (balance < amount) {
        throw InsufficientBalanceException(
          available: balance,
          required_: amount,
        );
      }
    }

    final t = Transaction()
      ..name = ''
      ..nameLower = ''
      ..amount = amount
      ..type = 'transfer'
      ..categoryId = ''
      ..accountId = fromAccountId
      ..fromAccountId = fromAccountId
      ..toAccountId = toAccountId
      ..notes = notes
      ..isRecurring = false
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();

    return isar.writeTxn(() => isar.transactions.put(t));
  }

  Future<int> updateTransfer({
    required int id,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime createdAt,
    String? notes,
    bool fromIsCreditCard = false,
  }) async {
    if (fromAccountId == toAccountId) {
      throw ArgumentError('FROM and TO accounts must be different');
    }
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }

    final existing = await isar.transactions.get(id);
    if (existing == null) {
      throw ArgumentError('Transaction not found');
    }

    // Check balance for non-credit-card FROM accounts (exclude current transfer amount)
    if (!fromIsCreditCard) {
      final balance = await _computeBalance(fromAccountId, excludeTransactionId: id);
      if (balance < amount) {
        throw InsufficientBalanceException(
          available: balance,
          required_: amount,
        );
      }
    }

    existing
      ..name = ''
      ..nameLower = ''
      ..amount = amount
      ..type = 'transfer'
      ..categoryId = ''
      ..accountId = fromAccountId
      ..fromAccountId = fromAccountId
      ..toAccountId = toAccountId
      ..notes = notes
      ..isRecurring = false
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();

    return isar.writeTxn(() => isar.transactions.put(existing));
  }

  Future<double> _computeBalance(String accountId, {int? excludeTransactionId}) async {
    final accountObj = await isar.accounts.get(int.parse(accountId));
    if (accountObj == null) return 0.0;

    final regularTxns = await isar.transactions
        .filter()
        .accountIdEqualTo(accountId)
        .not()
        .typeEqualTo('transfer')
        .findAll();

    final transferTxns = await isar.transactions
        .filter()
        .typeEqualTo('transfer')
        .group((q) => q
            .fromAccountIdEqualTo(accountId)
            .or()
            .toAccountIdEqualTo(accountId))
        .findAll();

    double balance = accountObj.initialBalance;

    for (final t in regularTxns) {
      if (excludeTransactionId != null && t.id == excludeTransactionId) continue;
      balance += t.type == 'income' ? t.amount : -t.amount;
    }

    for (final t in transferTxns) {
      if (excludeTransactionId != null && t.id == excludeTransactionId) continue;
      if (t.fromAccountId == accountId) balance -= t.amount;
      if (t.toAccountId == accountId) balance += t.amount;
    }

    return accountObj.isCreditCard ? -balance : balance;
  }
}
