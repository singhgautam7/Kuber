import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kuber/features/accounts/data/account_repository.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  late Isar isar;
  late AccountRepository repo;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
    repo = AccountRepository(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  group('CRUD', () {
    test('save and getAll', () async {
      await repo.save(makeAccount(name: 'Cash'));
      await repo.save(makeAccount(name: 'Bank'));
      final all = await repo.getAll();
      expect(all.length, 2);
    });

    test('getById returns account', () async {
      await repo.save(makeAccount(name: 'Find Me'));
      final all = await repo.getAll();
      final found = await repo.getById(all.first.id);
      expect(found, isNotNull);
      expect(found!.name, 'Find Me');
    });

    test('delete removes account', () async {
      await repo.save(makeAccount(name: 'Delete Me'));
      final all = await repo.getAll();
      await repo.delete(all.first.id);
      expect(await repo.getAll(), isEmpty);
    });
  });

  group('hasTransactions', () {
    test('returns true when account has transactions', () async {
      await repo.save(makeAccount(name: 'Cash'));
      final accounts = await repo.getAll();
      final accountId = accounts.first.id;

      await isar.writeTxn(() => isar.transactions.put(
            makeTransaction(accountId: accountId.toString()),
          ));

      expect(await repo.hasTransactions(accountId), true);
    });

    test('returns false when no transactions', () async {
      await repo.save(makeAccount(name: 'Empty'));
      final accounts = await repo.getAll();
      expect(await repo.hasTransactions(accounts.first.id), false);
    });
  });

  group('seedDefaults', () {
    test('creates Cash, Bank Account, and Credit Card', () async {
      await repo.seedDefaults();
      final all = await repo.getAll();
      expect(all.length, 3);

      final names = all.map((a) => a.name).toSet();
      expect(names, contains('Cash'));
      expect(names, contains('Bank Account'));
      expect(names, contains('Credit Card'));
    });

    test('Credit Card has correct properties', () async {
      await repo.seedDefaults();
      final all = await repo.getAll();
      final cc = all.firstWhere((a) => a.name == 'Credit Card');
      expect(cc.isCreditCard, true);
      expect(cc.creditLimit, 0);
    });

    test('is idempotent', () async {
      await repo.seedDefaults();
      await repo.seedDefaults();
      final all = await repo.getAll();
      expect(all.length, 3);
    });
  });
}
