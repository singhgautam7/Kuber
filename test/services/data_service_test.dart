import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/services/data_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

import '../helpers/isar_test_helper.dart';

void main() {
  setUpAll(() async => initialiseIsarForTests());

  late Isar isar;
  setUp(() async => isar = await openTestIsar());
  tearDown(() async => closeAndCleanIsar(isar));

  String csv(List<List<String>> rows) => rows.map((r) => r.join(',')).join('\n');

  const header = [
    'date',
    'name',
    'amount',
    'type',
    'category',
    'group',
    'account',
    'notes',
    'from_account',
    'to_account',
    'tags',
    'id',
  ];

  Future<int> seedTransaction(String name, double amount) async {
    late int id;
    await isar.writeTxn(() async {
      id = await isar.transactions.put(
        Transaction()
          ..name = name
          ..nameLower = name.toLowerCase()
          ..amount = amount
          ..type = 'expense'
          ..categoryId = ''
          ..accountId = ''
          ..createdAt = DateTime(2024, 1, 1)
          ..updatedAt = DateTime(2024, 1, 1),
      );
    });
    return id;
  }

  test(
    'merge import never overwrites an existing transaction sharing the CSV id',
    () async {
      final existingId = await seedTransaction('Original', 500);

      final content = csv([
        header,
        [
          '2024-02-01',
          'Imported',
          '100',
          'expense',
          'Misc',
          'Other',
          'Cash',
          '',
          '',
          '',
          '',
          '$existingId', // deliberately collides with the existing id
        ],
      ]);

      final result = await DataService(isar).importData(content, override: false);
      expect(result.successCount, 1);

      final all = await isar.transactions.where().findAll();
      expect(all.length, 2, reason: 'original preserved + imported added');

      final original = await isar.transactions.get(existingId);
      expect(original?.name, 'Original', reason: 'existing row untouched');
      expect(all.any((t) => t.name == 'Imported'), isTrue);
    },
  );

  test('override import replaces all existing data', () async {
    await seedTransaction('Old', 999);

    final content = csv([
      header,
      [
        '2024-02-01',
        'Fresh',
        '100',
        'expense',
        'Misc',
        'Other',
        'Cash',
        '',
        '',
        '',
        '',
        '',
      ],
    ]);

    final result = await DataService(isar).importData(content, override: true);
    expect(result.successCount, 1);

    final all = await isar.transactions.where().findAll();
    expect(all.length, 1);
    expect(all.single.name, 'Fresh');
  });

  test('empty CSV does not clear existing data even with override', () async {
    await seedTransaction('Keep', 10);

    final result = await DataService(isar).importData('', override: true);
    expect(result.error, 'Empty file');

    final all = await isar.transactions.where().findAll();
    expect(all.length, 1);
    expect(all.single.name, 'Keep');
  });
}
