import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_service.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/account.dart';
import '../data/account_repository.dart';

/// Set to true from AppScaffold to trigger the account form sheet on the Accounts tab.
final triggerAddAccountProvider = StateProvider<bool>((ref) => false);

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(isarProvider));
});

final accountListProvider =
    AsyncNotifierProvider<AccountListNotifier, List<Account>>(
  AccountListNotifier.new,
);

class AccountListNotifier extends AsyncNotifier<List<Account>> {
  @override
  FutureOr<List<Account>> build() {
    return ref.watch(accountRepositoryProvider).getAll();
  }

  Future<void> add(Account a) async {
    await ref.read(accountRepositoryProvider).save(a);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(accountRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

/// Computed balance for an account.
/// Regular accounts: initialBalance + income - expenses (available balance).
/// Credit cards: initialBalance + expenses - income (credit utilized).
final accountBalanceProvider =
    FutureProvider.family<double, int>((ref, accountId) async {
  // Watch these so balance recomputes when transactions or accounts change
  ref.watch(transactionListProvider);
  ref.watch(accountListProvider);
  final isar = ref.watch(isarProvider);
  final account = await isar.accounts.get(accountId);
  if (account == null) return 0.0;

  final accountIdStr = accountId.toString();

  // Regular income/expense
  final regularTxns = await isar.transactions
      .filter()
      .accountIdEqualTo(accountIdStr)
      .not()
      .typeEqualTo('transfer')
      .findAll();

  // Transfers involving this account
  final transferTxns = await isar.transactions
      .filter()
      .typeEqualTo('transfer')
      .group((q) => q
          .fromAccountIdEqualTo(accountIdStr)
          .or()
          .toAccountIdEqualTo(accountIdStr))
      .findAll();

  double balance = account.initialBalance +
      regularTxns.fold<double>(0.0, (sum, t) =>
          t.type == 'income' ? sum + t.amount : sum - t.amount);

  for (final t in transferTxns) {
    if (t.fromAccountId == accountIdStr) balance -= t.amount;
    if (t.toAccountId == accountIdStr) balance += t.amount;
  }

  final isCreditCard = account.isCreditCard;
  return isCreditCard ? -balance : balance;
});

final accountLatestTransactionProvider =
    FutureProvider.family<Transaction?, int>((ref, accountId) async {
  ref.watch(transactionListProvider);
  final isar = ref.watch(isarProvider);
  final accountIdStr = accountId.toString();

  return await isar.transactions
      .filter()
      .group((q) => q
          .accountIdEqualTo(accountIdStr)
          .or()
          .fromAccountIdEqualTo(accountIdStr)
          .or()
          .toAccountIdEqualTo(accountIdStr))
      .sortByCreatedAtDesc()
      .findFirst();
});
