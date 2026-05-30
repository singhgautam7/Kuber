import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_factories.dart';

/// Drives the real provider chain (instead of mirroring the formula) to lock
/// in the single-pass `accountBalancesProvider` that replaced the per-account
/// N+1 query. Balances = initialBalance + income - expense, including
/// transfers and adjustments, computed in one pass over the in-memory list.
void main() {
  late MockAccountRepository accountRepo;
  late MockTransactionRepository txnRepo;

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        accountRepositoryProvider.overrideWithValue(accountRepo),
        transactionRepositoryProvider.overrideWithValue(txnRepo),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    accountRepo = MockAccountRepository();
    txnRepo = MockTransactionRepository();
    when(() => accountRepo.getAll()).thenAnswer(
      (_) async => [
        makeAccount(id: 1, initialBalance: 1000),
        makeAccount(id: 2, initialBalance: 500),
      ],
    );
  });

  test('computes each balance as initial + income - expense', () async {
    when(() => txnRepo.getAll()).thenAnswer(
      (_) async => [
        makeTransaction(type: 'income', amount: 300, accountId: '1'),
        makeTransaction(type: 'expense', amount: 200, accountId: '1'),
        makeTransaction(type: 'expense', amount: 100, accountId: '2'),
      ],
    );

    final c = makeContainer();
    final balances = await c.read(accountBalancesProvider.future);

    expect(balances[1], 1100); // 1000 + 300 - 200
    expect(balances[2], 400); //  500 - 100
  });

  test('includes transfer legs and ignores deleted-account txns', () async {
    when(() => txnRepo.getAll()).thenAnswer(
      (_) async => [
        // Transfer of 250 from account 1 → account 2 (two legs).
        makeTransaction(
          type: 'expense',
          amount: 250,
          accountId: '1',
          isTransfer: true,
          transferId: 't1',
        ),
        makeTransaction(
          type: 'income',
          amount: 250,
          accountId: '2',
          isTransfer: true,
          transferId: 't1',
        ),
        // Transaction for an account that no longer exists — must be ignored.
        makeTransaction(type: 'income', amount: 9999, accountId: '99'),
      ],
    );

    final c = makeContainer();
    final balances = await c.read(accountBalancesProvider.future);

    expect(balances[1], 750); //  1000 - 250 (transfer out)
    expect(balances[2], 750); //   500 + 250 (transfer in)
    expect(balances.containsKey(99), isFalse);
  });

  test('accountBalanceProvider reads the shared map (0 for unknown)', () async {
    when(() => txnRepo.getAll()).thenAnswer(
      (_) async => [
        makeTransaction(type: 'expense', amount: 200, accountId: '1'),
      ],
    );

    final c = makeContainer();

    expect(await c.read(accountBalanceProvider(1).future), 800);
    expect(await c.read(accountBalanceProvider(2).future), 500);
    expect(await c.read(accountBalanceProvider(404).future), 0.0);
  });
}
