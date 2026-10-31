// Loan accuracy E2: a Overdraft account with 50,000 owed and a
// 1,00,000 limit. Transfer 20,000 out of it to the bank, repay 10,000.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/mock_repositories.dart';
import '../../helpers/test_factories.dart';

void main() {
  Account odAccount() => makeAccount(id: 3, name: 'HDFC OD', type: 'overdraft', initialBalance: -50000, creditLimit: 100000);

  final txns = [
    // Loan money received: a transfer, never income.
    makeTransaction(id: 1, type: 'expense', amount: 20000, accountId: '3', isTransfer: true, transferId: 't1'),
    makeTransaction(id: 2, type: 'income', amount: 20000, accountId: '1', isTransfer: true, transferId: 't1'),
    // Repay 10,000 from the bank.
    makeTransaction(id: 3, type: 'expense', amount: 10000, accountId: '1', isTransfer: true, transferId: 't2'),
    makeTransaction(id: 4, type: 'income', amount: 10000, accountId: '3', isTransfer: true, transferId: 't2'),
  ];

  test('balance, Available and net worth', () async {
    final accountRepo = MockAccountRepository();
    final txnRepo = MockTransactionRepository();
    when(() => accountRepo.getAll()).thenAnswer(
        (_) async => [makeAccount(id: 1, name: 'Federal Bank', initialBalance: 200000), odAccount()]);
    when(() => txnRepo.getAll()).thenAnswer((_) async => txns);
    final c = ProviderContainer(overrides: [
      accountRepositoryProvider.overrideWithValue(accountRepo),
      transactionRepositoryProvider.overrideWithValue(txnRepo),
    ]);
    addTearDown(c.dispose);
    final b = await c.read(accountBalancesProvider.future);
    expect(b[3], -60000); // owed: 50,000 + 20,000 - 10,000
    expect(b[1], 210000);
    final od = odAccount();
    expect(od.isOverdraft, isTrue);
    expect(od.isLiability, isTrue);
    expect(od.isCreditCard, isFalse);
    expect(od.creditLimit! + b[3]!, 40000); // Available
    // Net worth: a negative balance is debt, a positive one an asset.
    var assets = 0.0, debt = 0.0;
    for (final v in b.values) {
      if (v > 0) assets += v;
      if (v < 0) debt -= v;
    }
    expect(assets - debt, 150000);
    // Nothing here is income: both incoming legs are transfers.
    expect(txns.where((t) => t.type == 'income' && !t.isTransfer), isEmpty);
  });

  test('backup and restore keep the type and the limit', () async {
    await initialiseIsarForTests();
    final isar = await openTestIsar();
    addTearDown(() => closeAndCleanIsar(isar));
    await isar.writeTxn(() => isar.accounts.put(odAccount()..id = Isar.autoIncrement));
    final json = await JsonBackupService().exportJson(isar);
    await isar.writeTxn(() => isar.clear());
    expect((await JsonBackupService().importJson(isar, json)).error, isNull);
    final a = (await isar.accounts.where().findAll()).single;
    expect(a.type, 'overdraft');
    expect(a.isOverdraft, isTrue);
    expect(a.initialBalance, -50000);
    expect(a.creditLimit, 100000);
  });
}
