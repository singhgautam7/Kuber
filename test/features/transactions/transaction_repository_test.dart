import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/data/transaction_repository.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/core/utils/transfer_helpers.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  late Isar isar;
  late TransactionRepository repo;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
    repo = TransactionRepository(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  group('Transaction CRUD', () {
    test('save sets nameLower and updatedAt', () async {
      final t = makeTransaction(name: 'Grocery Run');
      final id = await repo.save(t);
      final saved = await isar.transactions.get(id);
      expect(saved, isNotNull);
      expect(saved!.nameLower, 'grocery run');
      expect(saved.updatedAt, isNotNull);
    });

    test('save sets isRecurring based on recurringRuleId', () async {
      final t = makeTransaction(recurringRuleId: 5);
      final id = await repo.save(t);
      final saved = await isar.transactions.get(id);
      expect(saved!.isRecurring, true);
    });

    test('save without recurringRuleId sets isRecurring false', () async {
      final t = makeTransaction();
      final id = await repo.save(t);
      final saved = await isar.transactions.get(id);
      expect(saved!.isRecurring, false);
    });

    test('getAll returns transactions sorted by createdAt desc', () async {
      final t1 = makeTransaction(
        name: 'First',
        createdAt: DateTime(2024, 1, 1),
      );
      final t2 = makeTransaction(
        name: 'Second',
        createdAt: DateTime(2024, 6, 1),
      );
      await repo.save(t1);
      await repo.save(t2);
      final all = await repo.getAll();
      expect(all.length, 2);
      expect(all.first.name, 'Second');
    });

    test('getById returns transaction', () async {
      final id = await repo.save(makeTransaction(name: 'Find Me'));
      final found = await repo.getById(id);
      expect(found, isNotNull);
      expect(found!.name, 'Find Me');
    });

    test('delete removes transaction', () async {
      final id = await repo.save(makeTransaction());
      await repo.delete(id);
      final found = await repo.getById(id);
      expect(found, isNull);
    });

    test('restore puts transaction back', () async {
      final t = makeTransaction(name: 'Restored');
      t.id = 999;
      t.nameLower = t.name.toLowerCase();
      await repo.restore(t);
      final found = await repo.getById(999);
      expect(found, isNotNull);
      expect(found!.name, 'Restored');
    });
  });

  group('getByDateRange', () {
    test('returns transactions within range', () async {
      // Insert directly via Isar to preserve createdAt (repo.save overwrites it for new records)
      final inRange = makeTransaction(name: 'In range', createdAt: DateTime(2024, 3, 15));
      final outRange = makeTransaction(name: 'Out of range', createdAt: DateTime(2024, 1, 1));
      await isar.writeTxn(() async {
        await isar.transactions.put(inRange);
        await isar.transactions.put(outRange);
      });
      final results = await repo.getByDateRange(
        DateTime(2024, 3, 1),
        DateTime(2024, 3, 31),
      );
      expect(results.length, 1);
      expect(results.first.name, 'In range');
    });
  });

  group('getByMonth', () {
    test('returns transactions for specific month', () async {
      final marchTxn = makeTransaction(name: 'March txn', createdAt: DateTime(2024, 3, 15));
      final aprilTxn = makeTransaction(name: 'April txn', createdAt: DateTime(2024, 4, 10));
      await isar.writeTxn(() async {
        await isar.transactions.put(marchTxn);
        await isar.transactions.put(aprilTxn);
      });
      final results = await repo.getByMonth(2024, 3);
      expect(results.length, 1);
      expect(results.first.name, 'March txn');
    });
  });

  group('getSuggestions', () {
    test('returns empty for empty query', () async {
      await repo.save(makeTransaction(name: 'Food'));
      final results = await repo.getSuggestions('');
      expect(results, isEmpty);
    });

    test('deduplicates by lowercase name', () async {
      await repo.save(makeTransaction(name: 'Groceries'));
      await repo.save(makeTransaction(name: 'groceries'));
      final results = await repo.getSuggestions('grocer');
      expect(results.length, 1);
    });

    test('limits to 5 results', () async {
      for (int i = 0; i < 10; i++) {
        await repo.save(makeTransaction(name: 'Item $i'));
      }
      final results = await repo.getSuggestions('Item');
      expect(results.length, lessThanOrEqualTo(5));
    });
  });

  group('Transfer operations', () {
    late Account fromAccount, toAccount;

    setUp(() async {
      fromAccount = makeAccount(name: 'Savings', initialBalance: 10000);
      toAccount = makeAccount(name: 'Checking', initialBalance: 0);
      await isar.writeTxn(() async {
        await isar.accounts.put(fromAccount);
        await isar.accounts.put(toAccount);
      });
    });

    test('saveTransfer creates linked pair', () async {
      final ids = await repo.saveTransfer(
        fromAccountId: fromAccount.id.toString(),
        toAccountId: toAccount.id.toString(),
        amount: 500,
        createdAt: DateTime.now(),
      );
      expect(ids.length, 2);
      final fromTxn = await isar.transactions.get(ids[0]);
      final toTxn = await isar.transactions.get(ids[1]);
      expect(fromTxn!.isTransfer, true);
      expect(toTxn!.isTransfer, true);
      expect(fromTxn.transferId, toTxn.transferId);
      expect(fromTxn.type, 'expense');
      expect(toTxn.type, 'income');
      expect(fromTxn.amount, 500);
      expect(toTxn.amount, 500);
    });

    test('saveTransfer throws on same account', () async {
      expect(
        () => repo.saveTransfer(
          fromAccountId: fromAccount.id.toString(),
          toAccountId: fromAccount.id.toString(),
          amount: 100,
          createdAt: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('saveTransfer throws on zero amount', () async {
      expect(
        () => repo.saveTransfer(
          fromAccountId: fromAccount.id.toString(),
          toAccountId: toAccount.id.toString(),
          amount: 0,
          createdAt: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('saveTransfer throws InsufficientBalanceException', () async {
      expect(
        () => repo.saveTransfer(
          fromAccountId: fromAccount.id.toString(),
          toAccountId: toAccount.id.toString(),
          amount: 99999,
          createdAt: DateTime.now(),
        ),
        throwsA(isA<InsufficientBalanceException>()),
      );
    });

    test('deleteTransferPair removes both legs', () async {
      final ids = await repo.saveTransfer(
        fromAccountId: fromAccount.id.toString(),
        toAccountId: toAccount.id.toString(),
        amount: 100,
        createdAt: DateTime.now(),
      );
      final fromTxn = await isar.transactions.get(ids[0]);
      await repo.deleteTransferPair(fromTxn!.transferId!);
      final remaining = await repo.getAll();
      expect(remaining, isEmpty);
    });
  });
}
