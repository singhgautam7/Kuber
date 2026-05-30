import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../tutorial/providers/tutorial_sandbox_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/account.dart';
import '../data/account_repository.dart';

/// Set to true from AppScaffold to trigger the account form sheet on the Accounts tab.
final triggerAddAccountProvider = StateProvider<bool>((ref) => false);

/// Set this provider when a new account is created to auto-select it in picking flows.
final pendingAccountSelectionProvider = StateProvider<int?>((ref) => null);

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(tutorialAwareIsarProvider));
});

final accountListProvider =
    AsyncNotifierProvider<AccountListNotifier, List<Account>>(
      AccountListNotifier.new,
    );

class AccountListNotifier extends AsyncNotifier<List<Account>> {
  @override
  FutureOr<List<Account>> build() {
    ref.keepAlive();
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

/// Provides a map of account id -> Account for quick lookup
final accountMapProvider = FutureProvider<Map<int, Account>>((ref) async {
  final accounts = await ref.watch(accountListProvider.future);
  return {for (final a in accounts) a.id: a};
});

/// All account balances computed in a single pass over the in-memory
/// transaction list. Formula per account: initialBalance + income - expense
/// (transfers and balance adjustments included — they move real money between
/// accounts). CC initial balance is stored negative, so a negative balance is
/// debt. Computing every balance at once avoids an N+1 query per account.
final accountBalancesProvider = FutureProvider<Map<int, double>>((ref) async {
  final accounts = await ref.watch(accountListProvider.future);
  final txns = await ref.watch(transactionListProvider.future);

  final balances = <int, double>{
    for (final a in accounts) a.id: a.initialBalance,
  };

  for (final t in txns) {
    final accId = int.tryParse(t.accountId);
    if (accId == null) continue;
    final current = balances[accId];
    if (current == null) continue; // transaction for a removed account
    balances[accId] = t.type == 'income'
        ? current + t.amount
        : current - t.amount;
  }

  return balances;
});

/// Computed balance for a single account (reads the shared single-pass map).
final accountBalanceProvider = FutureProvider.family<double, int>((
  ref,
  accountId,
) async {
  final balances = await ref.watch(accountBalancesProvider.future);
  return balances[accountId] ?? 0.0;
});

final accountLatestTransactionProvider =
    FutureProvider.family<Transaction?, int>((ref, accountId) async {
      ref.watch(transactionListProvider);
      final isar = ref.watch(tutorialAwareIsarProvider);
      return await isar.transactions
          .filter()
          .accountIdEqualTo(accountId.toString())
          .sortByCreatedAtDesc()
          .findFirst();
    });
