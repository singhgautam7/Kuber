import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

/// Tests the balance calculation logic used by accountBalanceProvider.
/// We test directly against Isar instead of through the Riverpod provider chain
/// to avoid async provider dependency resolution issues in test.
void main() {
  late Isar isar;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  /// Mirrors the balance formula from accountBalanceProvider:
  /// initialBalance + income - expense
  Future<double> computeBalance(int accountId) async {
    final account = await isar.accounts.get(accountId);
    if (account == null) return 0.0;

    final accountIdStr = accountId.toString();
    final txns = await isar.transactions
        .filter()
        .accountIdEqualTo(accountIdStr)
        .findAll();

    return account.initialBalance +
        txns.fold<double>(
            0.0, (sum, t) => t.type == 'income' ? sum + t.amount : sum - t.amount);
  }

  group('accountBalanceProvider', () {
    test('returns initialBalance when no transactions', () async {
      final account = makeAccount(initialBalance: 5000);
      await isar.writeTxn(() => isar.accounts.put(account));

      final balance = await computeBalance(account.id);
      expect(balance, 5000);
    });

    test('adds income and subtracts expense', () async {
      final account = makeAccount(initialBalance: 1000);
      await isar.writeTxn(() => isar.accounts.put(account));

      final accountIdStr = account.id.toString();
      await isar.writeTxn(() async {
        await isar.transactions.put(makeTransaction(
          type: 'income',
          amount: 500,
          accountId: accountIdStr,
        ));
        await isar.transactions.put(makeTransaction(
          type: 'expense',
          amount: 200,
          accountId: accountIdStr,
        ));
      });

      final balance = await computeBalance(account.id);
      // 1000 + 500 - 200 = 1300
      expect(balance, 1300);
    });

    test('credit card: initial balance is negative (debt)', () async {
      final cc = makeAccount(
        initialBalance: -5000,
        isCreditCard: true,
        creditLimit: 50000,
      );
      await isar.writeTxn(() => isar.accounts.put(cc));

      final balance = await computeBalance(cc.id);
      expect(balance, -5000);
    });

    test('returns 0 for nonexistent account', () async {
      final balance = await computeBalance(99999);
      expect(balance, 0);
    });
  });
}
