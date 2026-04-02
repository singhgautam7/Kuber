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

/// Set this provider when a new account is created to auto-select it in picking flows.
final pendingAccountSelectionProvider = StateProvider<int?>((ref) => null);

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

  Future<int> add(Account a) async {
    final id = await ref.read(accountRepositoryProvider).save(a);
    ref.invalidateSelf();
    return id;
  }

  Future<void> delete(int id) async {
    await ref.read(accountRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

/// Computed balance for an account.
/// Unified formula: initialBalance + income - expense.
/// CC initial balance is stored as negative (debt), so negative balance = debt.
final accountBalanceProvider =
    FutureProvider.family<double, int>((ref, accountId) async {
  ref.watch(transactionListProvider);
  ref.watch(accountListProvider);
  final isar = ref.watch(isarProvider);
  final account = await isar.accounts.get(accountId);
  if (account == null) return 0.0;

  final accountIdStr = accountId.toString();
  final txns = await isar.transactions
      .filter()
      .accountIdEqualTo(accountIdStr)
      .findAll();

  return account.initialBalance +
      txns.fold<double>(0.0, (sum, t) =>
          t.type == 'income' ? sum + t.amount : sum - t.amount);
});

final accountLatestTransactionProvider =
    FutureProvider.family<Transaction?, int>((ref, accountId) async {
  ref.watch(transactionListProvider);
  final isar = ref.watch(isarProvider);
  return await isar.transactions
      .filter()
      .accountIdEqualTo(accountId.toString())
      .sortByCreatedAtDesc()
      .findFirst();
});
