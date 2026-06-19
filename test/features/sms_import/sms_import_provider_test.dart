import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/sms_import/data/sms_import_repository.dart';
import 'package:kuber/features/sms_import/data/sms_transaction.dart';
import 'package:kuber/features/sms_import/providers/sms_import_provider.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:kuber/features/tutorial/providers/tutorial_sandbox_provider.dart';

import '../../helpers/isar_test_helper.dart';

SmsTransaction _staged({
  double amount = 648.50,
  String type = 'expense',
  String sender = 'HDFCBK',
  String raw = 'INR 648.50 debited from A/c XX4521 on 05-Jun-26',
}) {
  return SmsTransaction()
    ..rawSms = raw
    ..senderId = sender
    ..rawSmsHash = '$sender|$raw'.hashCode.toString()
    ..parsedDate = DateTime(2026, 6, 5)
    ..parsedAmount = amount
    ..parsedType = type
    ..parsedMerchant = 'Swiggy'
    ..parsedAccountSuffix = '4521'
    ..reviewStatus = SmsReviewStatus.unreviewed
    ..smsDate = DateTime(2026, 6, 5)
    ..patternMatched = 'HDFC debit';
}

void main() {
  late Isar isar;
  late ProviderContainer container;

  setUpAll(initialiseIsarForTests);

  setUp(() async {
    isar = await openTestIsar();
    container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(isar),
        tutorialAwareIsarProvider.overrideWithValue(isar),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await closeAndCleanIsar(isar);
  });

  test('importSingle creates a Transaction tagged from SMS and links the row',
      () async {
    final repo = container.read(smsImportRepositoryProvider);
    final id = await repo.put(_staged());
    final sms = (await repo.getById(id))!;

    final notifier = container.read(smsImportProvider.notifier);
    await container.read(smsImportProvider.future);

    final txnId = await notifier.importSingle(
      sms,
      name: 'Swiggy',
      amount: 648.50,
      type: 'expense',
      accountId: '1',
      categoryId: '2',
      date: DateTime(2026, 6, 5),
    );

    final txns = await container.read(transactionListProvider.future);
    expect(txns.length, 1);
    expect(txns.first.importSource, 'sms');
    expect(txns.first.importedFromSms, contains('debited'));
    expect(txns.first.notes, isNull);

    final updated = await repo.getById(id);
    expect(updated!.reviewStatus, SmsReviewStatus.imported);
    expect(updated.importedTransactionId, '$txnId');
  });

  test('importBatch creates all transactions', () async {
    final repo = container.read(smsImportRepositoryProvider);
    final s1 = (await repo.getById(await repo.put(_staged(amount: 100))))!;
    final s2 = (await repo.getById(
      await repo.put(_staged(amount: 200, raw: 'INR 200 debited xyz')),
    ))!;

    final notifier = container.read(smsImportProvider.notifier);
    await container.read(smsImportProvider.future);

    await notifier.importBatch([
      SmsImportDraft(
        sms: s1,
        name: 'A',
        amount: 100,
        type: 'expense',
        accountId: '1',
        date: DateTime(2026, 6, 5),
      ),
      SmsImportDraft(
        sms: s2,
        name: 'B',
        amount: 200,
        type: 'expense',
        accountId: '1',
        date: DateTime(2026, 6, 6),
      ),
    ]);

    final txns = await container.read(transactionListProvider.future);
    expect(txns.length, 2);
  });

  test('findDuplicate flags same amount/account within +/- 1 day', () async {
    // Seed an existing manual transaction.
    final existing = Transaction()
      ..name = 'Swiggy'
      ..amount = 648.50
      ..type = 'expense'
      ..accountId = '1'
      ..categoryId = '2'
      ..createdAt = DateTime(2026, 6, 5, 13, 42)
      ..updatedAt = DateTime(2026, 6, 5)
      ..nameLower = 'swiggy';
    await container.read(transactionListProvider.notifier).add(existing);
    // Ensure the list is materialised (add() invalidates it) before reading.
    await container.read(transactionListProvider.future);

    final notifier = container.read(smsImportProvider.notifier);
    await container.read(smsImportProvider.future);

    final dup = notifier.findDuplicate(
      amount: 648.50,
      accountId: '1',
      date: DateTime(2026, 6, 5, 18, 0),
    );
    expect(dup, isNotNull);

    final noDup = notifier.findDuplicate(
      amount: 648.50,
      accountId: '1',
      date: DateTime(2026, 6, 9),
    );
    expect(noDup, isNull);
  });

  test('importing one row pre-fills the account on same-sender unreviewed rows',
      () async {
    final repo = container.read(smsImportRepositoryProvider);
    final id1 = await repo.put(_staged(raw: 'INR 100 debited from HDFC a/c 1'));
    final id2 = await repo.put(_staged(raw: 'INR 200 debited from HDFC a/c 2'));
    final id3 = await repo.put(
      _staged(sender: 'SBIINB', raw: 'Rs 50 debited from SBI a/c'),
    );
    final s1 = (await repo.getById(id1))!;

    final notifier = container.read(smsImportProvider.notifier);
    await container.read(smsImportProvider.future);

    await notifier.importSingle(
      s1,
      name: 'Swiggy',
      amount: 100,
      type: 'expense',
      accountId: '7',
      date: DateTime(2026, 6, 5),
    );

    // The other HDFC row now points at the chosen account...
    expect((await repo.getById(id2))!.suggestedAccountId, '7');
    // ...but a different sender is untouched.
    expect((await repo.getById(id3))!.suggestedAccountId, isNull);
  });

  test('insertNew skips rows with an already-staged hash', () async {
    final repo = container.read(smsImportRepositoryProvider);
    final row = _staged();
    expect(await repo.insertNew([row]), 1);
    // Same hash again -> not inserted.
    expect(await repo.insertNew([_staged()]), 0);
  });
}
