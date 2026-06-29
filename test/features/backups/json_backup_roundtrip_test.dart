import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/ask_kuber/data/ask_kuber_message.dart';
import 'package:kuber/features/sms_import/data/sms_transaction.dart';
import 'package:kuber/features/sms_import/data/sms_account_mapping.dart';
import 'package:kuber/features/tools/saved/data/saved_calculation.dart';
import 'package:kuber/features/tools/saved/data/calculator_recent_use.dart';

import '../../helpers/isar_test_helper.dart';

/// Guards that the newly-added Isar collections (and the recently-changed
/// Account fields) survive a JSON backup export → import round trip.
void main() {
  late Isar isar;
  final service = JsonBackupService();

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  test('account isDisabled + last4Digits round-trip', () async {
    final now = DateTime.now();
    await isar.writeTxn(() async {
      await isar.accounts.put(Account()
        ..name = 'HDFC'
        ..type = 'bank'
        ..last4Digits = '1234'
        ..isDisabled = true);
      await isar.savedCalculations.put(SavedCalculation()
        ..tool = 'emi-calculator'
        ..name = 'Home loan'
        ..inputsJson = '{"principal":"2500000"}'
        ..summary = '₹25L @ 8.5%'
        ..savedAt = now
        ..updatedAt = now);
      await isar.calculatorRecentUses.put(CalculatorRecentUse()
        ..calculatorType = 'emi-calculator'
        ..lastUsed = now
        ..useCount = 3);
      await isar.askKuberMessages.put(AskKuberMessage()
        ..text = 'hello'
        ..isUser = true
        ..time = now);
      await isar.smsAccountMappings.put(SmsAccountMapping()
        ..senderId = 'HDFCBK'
        ..accountId = '1'
        ..usageCount = 5
        ..lastUsed = now);
      await isar.smsTransactions.put(SmsTransaction()
        ..rawSms = 'debited 500'
        ..senderId = 'HDFCBK'
        ..rawSmsHash = 'abc'
        ..parsedDate = now
        ..parsedAmount = 500
        ..parsedType = 'expense'
        ..reviewStatus = 'unreviewed'
        ..smsDate = now);
    });

    final json = await service.exportJson(isar);
    final result = await service.importJson(isar, json);
    expect(result.error, isNull);

    final account = (await isar.accounts.where().findAll()).single;
    expect(account.isDisabled, isTrue);
    expect(account.last4Digits, '1234');

    expect((await isar.savedCalculations.where().findAll()).single.name,
        'Home loan');
    expect((await isar.calculatorRecentUses.where().findAll()).single.useCount,
        3);
    expect((await isar.askKuberMessages.where().findAll()).single.text,
        'hello');
    expect((await isar.smsAccountMappings.where().findAll()).single.usageCount,
        5);
    expect((await isar.smsTransactions.where().findAll()).single.parsedAmount,
        500);
  });
}
