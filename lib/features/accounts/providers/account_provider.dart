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

  final transactions = await isar.transactions
      .filter()
      .accountIdEqualTo(accountId.toString())
      .findAll();

  if (account.isCreditCard) {
    // Credit utilized: starts at initial, expenses increase, income (payments) decrease
    double utilized = account.initialBalance;
    for (final t in transactions) {
      if (t.type == 'expense') {
        utilized += t.amount;
      } else {
        utilized -= t.amount;
      }
    }
    return utilized; // positive = you owe this much
  } else {
    // Regular: starts at initial, income increases, expenses decrease
    double balance = account.initialBalance;
    for (final t in transactions) {
      if (t.type == 'income') {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }
});
