// The vNext link fields on a transaction (sub type, source, occurrence, EMI
// split, count-only-interest) survive a backup round trip, and posted amounts
// follow the currency's minor units.
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/occurrence_processor.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  late Isar isar;
  setUp(() async => isar = await openTestIsar());
  tearDown(() => closeAndCleanIsar(isar));

  final start = DateTime(2026, 6, 5);

  Future<void> seed({double sip = 1234.5678, double principal = 1000000}) =>
      isar.writeTxn(() async {
        await isar.loans.put(Loan()
          ..uid = 'L1'
          ..name = 'Home'
          ..loanType = 'home'
          ..lenderName = 'SBI'
          ..principalAmount = principal
          ..emiAmount = 12133.0
          ..mode = LoanMode.advanced
          ..annualRate = 8.5
          ..tenureMonths = 120
          ..countOnlyInterest = true
          ..billDate = 5
          ..startDate = start
          ..autoAddTransaction = true
          ..accountId = '1'
          ..categoryId = '1'
          ..createdAt = start
          ..updatedAt = start
          ..dataVersion = 1
          ..schedule = (scheduleFrom(start: start)..autoRecord = true));
        await isar.investments.put(Investment()
          ..uid = 'I1'
          ..name = 'Index'
          ..investmentType = 'mutual_fund'
          ..sipAmount = sip
          ..accountId = '1'
          ..categoryId = '1'
          ..createdAt = start
          ..updatedAt = start
          ..dataVersion = 1
          ..sip = scheduleFrom(start: start));
      });

  Future<void> post(int decimals) =>
      OccurrenceProcessor(isar, decimals: decimals, l10n: AppLocalizationsEn())
          .run(now: DateTime(2026, 8, 6, 9));

  test('link fields round-trip through a backup unchanged', () async {
    await seed();
    await post(2);
    final before = await isar.transactions.where().sortByCreatedAt().findAll();
    expect(before.length, 6);
    String sig(Transaction t) =>
        '${t.name}|${t.amount}|${t.subType}|${t.sourceType}|${t.sourceId}|${t.occurrenceDate}|'
        '${t.linkedRuleType}|${t.linkedRuleId}|${t.principalPart}|${t.interestPart}|'
        '${t.spendInterestOnly}|${t.spendAmount}';
    final json = await JsonBackupService().exportJson(isar);
    final r = await JsonBackupService().importJson(isar, json);
    expect(r.error, isNull);
    final after = await isar.transactions.where().sortByCreatedAt().findAll();
    expect(after.map(sig).toList(), before.map(sig).toList());
    final emi = after.firstWhere((t) => t.sourceType == 'loan');
    expect(emi.subType, TxnSubType.loanRepayment);
    expect(emi.spendInterestOnly, isTrue);
    expect(emi.spendAmount, emi.interestPart);
    // The processed ledger comes back too, so a restore posts nothing twice.
    final again = await OccurrenceProcessor(isar, decimals: 2, l10n: AppLocalizationsEn())
        .run(now: DateTime(2026, 8, 6, 20));
    expect(again.posted, 0);
  });

  for (final (code, decimals) in [('JPY', 0), ('INR', 2), ('KWD', 3)]) {
    test('$code: SIP and EMI split round to $decimals decimals', () async {
      await seed();
      await post(decimals);
      final txns = await isar.transactions.where().findAll();
      final f = [1, 10, 100, 1000][decimals];
      bool rounded(double v) => ((v * f).roundToDouble() - v * f).abs() < 1e-6;
      for (final t in txns) {
        expect(rounded(t.amount), isTrue, reason: '${t.name} ${t.amount}');
        if (t.principalPart != null) {
          expect(rounded(t.principalPart!), isTrue, reason: '${t.principalPart}');
          expect(rounded(t.interestPart!), isTrue, reason: '${t.interestPart}');
          expect(t.principalPart! + t.interestPart!, closeTo(t.amount, 1e-6));
        }
      }
    });
  }
}
