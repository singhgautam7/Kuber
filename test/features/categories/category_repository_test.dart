import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kuber/features/categories/data/category_repository.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  late Isar isar;
  late CategoryRepository repo;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
    repo = CategoryRepository(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  group('CRUD', () {
    test('save and getAll', () async {
      await repo.save(makeCategory(name: 'Food'));
      await repo.save(makeCategory(name: 'Transport'));
      final all = await repo.getAll();
      expect(all.length, 2);
    });

    test('getById returns category', () async {
      final cat = makeCategory(name: 'Shopping');
      await repo.save(cat);
      final all = await repo.getAll();
      final found = await repo.getById(all.first.id);
      expect(found, isNotNull);
      expect(found!.name, 'Shopping');
    });

    test('delete removes category', () async {
      await repo.save(makeCategory(name: 'ToDelete'));
      final all = await repo.getAll();
      await repo.delete(all.first.id);
      expect(await repo.getAll(), isEmpty);
    });
  });

  group('hasTransactions', () {
    test('returns true when category has transactions', () async {
      await repo.save(makeCategory(name: 'Food'));
      final cats = await repo.getAll();
      final catId = cats.first.id;

      await isar.writeTxn(() => isar.transactions.put(
            makeTransaction(categoryId: catId.toString()),
          ));

      expect(await repo.hasTransactions(catId), true);
    });

    test('returns false when no transactions', () async {
      await repo.save(makeCategory(name: 'Empty'));
      final cats = await repo.getAll();
      expect(await repo.hasTransactions(cats.first.id), false);
    });
  });
}
