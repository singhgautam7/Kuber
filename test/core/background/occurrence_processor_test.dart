import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/occurrence_processor.dart';
import 'package:kuber/core/database/vnext_migration.dart';
import 'package:kuber/core/schedule/processed_occurrence.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../../helpers/isar_test_helper.dart';

OccurrenceProcessor _p(Isar isar) =>
    OccurrenceProcessor(isar, decimals: 0, l10n: AppLocalizationsEn());

Future<RecurringRule> _rule(Isar isar, DateTime start,
    {ScheduleUnit unit = ScheduleUnit.day}) async {
  final r = RecurringRule()
    ..name = 'Milk'
    ..amount = 60
    ..type = 'expense'
    ..categoryId = '1'
    ..accountId = '1'
    ..frequency = 'daily'
    ..customDays = 1
    ..intervalUnit = unit.name
    ..startDate = start
    ..nextDueAt = start
    ..endType = 'never'
    ..createdAt = start
    ..updatedAt = start
    ..schedule = scheduleFrom(start: start, unit: unit)
    ..dataVersion = 1;
  await isar.writeTxn(() => isar.recurringRules.put(r));
  return r;
}

void main() {
  setUpAll(initialiseIsarForTests);
  late Isar isar;
  setUp(() async => isar = await openTestIsar());
  tearDown(() => closeAndCleanIsar(isar));

  test('posts each due occurrence once; processing twice posts nothing', () async {
    await _rule(isar, DateTime(2026, 10, 1));
    final s1 = await _p(isar).run(now: DateTime(2026, 10, 21, 8));
    expect(s1.recurring, 21);
    final s2 = await _p(isar).run(now: DateTime(2026, 10, 21, 20));
    expect(s2.posted, 0);
    expect(await isar.transactions.count(), 21);
    final r = (await isar.recurringRules.where().findFirst())!;
    expect(r.executionCount, 21);
    expect(r.nextDueAt, DateTime(2026, 10, 22));
    final t = (await isar.transactions.where().sortByCreatedAt().findFirst())!;
    expect(t.sourceType, 'recurring');
    expect(t.linkedRuleType, 'recurring');
    expect(t.occurrenceDate, 20261001);
    expect(t.createdAt.hour, 8);
  });

  test('overlapping runs (two at once) post nothing twice', () async {
    await _rule(isar, DateTime(2026, 9, 1));
    final now = DateTime(2026, 10, 21, 9);
    final results = await Future.wait([_p(isar).run(now: now), _p(isar).run(now: now)]);
    expect(results[0].posted + results[1].posted, 51);
    expect(await isar.transactions.count(), 51);
    expect(await isar.processedOccurrences.count(), 51);
  });

  test('a run that was killed and resumes from a stale watermark adds nothing',
      () async {
    final r = await _rule(isar, DateTime(2026, 10, 1));
    await _p(isar).run(now: DateTime(2026, 10, 10, 9));
    // Simulate the worst case: the rule row lost its watermark (e.g. a stale
    // copy written back) but the ledger rows survived.
    final stale = (await isar.recurringRules.get(r.id))!;
    stale.schedule = scheduleFrom(start: DateTime(2026, 10, 1), unit: ScheduleUnit.day);
    await isar.writeTxn(() => isar.recurringRules.put(stale));
    final s = await _p(isar).run(now: DateTime(2026, 10, 12, 9));
    expect(s.recurring, 2); // only 11 and 12 Oct
    expect(await isar.transactions.count(), 12);
  });

  test('skipped dates are recorded, not posted', () async {
    final r = await _rule(isar, DateTime(2026, 10, 1));
    final row = (await isar.recurringRules.get(r.id))!;
    row.schedule!.skippedDates = [20261003];
    await isar.writeTxn(() => isar.recurringRules.put(row));
    final s = await _p(isar).run(now: DateTime(2026, 10, 5, 9));
    expect(s.recurring, 4);
    final key = ProcessedOccurrence.keyOf('recurring', '${r.id}', 20261003);
    expect((await isar.processedOccurrences.getByKey(key))!.status, 'skipped');
  });

  test('loan EMI: split saved, count-only-interest flag, closes when paid',
      () async {
    final l = Loan()
      ..uid = 'L1'
      ..name = 'Car'
      ..loanType = 'vehicle'
      ..lenderName = 'B'
      ..principalAmount = 120000
      ..emiAmount = 0
      ..billDate = 5
      ..startDate = DateTime(2026, 1, 5)
      ..accountId = '1'
      ..categoryId = '2'
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1)
      ..dataVersion = 1
      ..annualRate = 12
      ..tenureMonths = 12
      ..startingPoint = LoanStartingPoint.originalDetails
      ..countOnlyInterest = true
      ..countOnlyInterestFrom = DateTime(2026, 6, 1)
      ..schedule = scheduleFrom(
          start: DateTime(2026, 1, 5),
          endType: ScheduleEnd.afterCount,
          endCount: 12);
    await isar.writeTxn(() => isar.loans.put(l));
    final s = await _p(isar).run(now: DateTime(2027, 1, 10, 9));
    expect(s.emis, 12);
    final txns = await isar.transactions.where().sortByCreatedAt().findAll();
    for (final t in txns) {
      expect(t.subType, TxnSubType.loanRepayment);
      expect(t.principalPart! + t.interestPart!, t.amount);
    }
    expect(txns.first.spendInterestOnly, isFalse); // before the effective date
    expect(txns.last.spendInterestOnly, isTrue);
    expect(txns.last.spendAmount, txns.last.interestPart);
    final principal = txns.fold(0.0, (a, t) => a + t.principalPart!);
    expect(principal, closeTo(120000, 12));
    final after = (await isar.loans.where().findFirst())!;
    expect(after.isCompleted, isTrue);
    expect(s.paidOffLoans, ['Car']);
  });

  test('SIP with step-up adds to Invested (S2)', () async {
    final i = Investment()
      ..uid = 'I1'
      ..name = 'Index'
      ..investmentType = 'mutual_fund'
      ..investedAmount = 1000
      ..sipAmount = 1000
      ..accountId = '1'
      ..categoryId = '3'
      ..createdAt = DateTime(2025, 1, 1)
      ..updatedAt = DateTime(2025, 1, 1)
      ..dataVersion = 1
      ..stepUpValue = 10
      ..sip = scheduleFrom(start: DateTime(2025, 11, 10));
    await isar.writeTxn(() => isar.investments.put(i));
    final s = await _p(isar).run(now: DateTime(2026, 12, 10, 9));
    expect(s.sips, 14);
    final txns = await isar.transactions.where().sortByCreatedAt().findAll();
    expect(txns.first.amount, 1000);
    expect(txns.last.amount, 1100); // stepped up on 10 Nov 2026
    final after = (await isar.investments.where().findFirst())!;
    expect(after.investedAmount, 1000 + txns.fold(0.0, (a, t) => a + t.amount));
  });

  test('migrated data: first run after the migration posts nothing old',
      () async {
    final loan = Loan()
      ..uid = 'old'
      ..name = 'Home'
      ..loanType = 'home'
      ..lenderName = 'H'
      ..principalAmount = 0
      ..emiAmount = 21696
      ..billDate = 5
      ..startDate = DateTime(2020, 1, 5)
      ..autoAddTransaction = true
      ..accountId = '1'
      ..categoryId = '2'
      ..createdAt = DateTime(2020, 1, 1)
      ..updatedAt = DateTime(2020, 1, 1);
    await isar.writeTxn(() => isar.loans.put(loan));
    await VNextMigration.run(isar, now: DateTime(2026, 10, 21));
    final s = await _p(isar).run(now: DateTime(2026, 10, 21, 9));
    expect(s.posted, 0); // no back-fill of the years before the update
    final s2 = await _p(isar).run(now: DateTime(2026, 11, 5, 9));
    expect(s2.emis, 1);
  });

  test('a failing source does not block the others', () async {
    await _rule(isar, DateTime(2026, 10, 20));
    final bad = Investment()
      ..uid = 'bad'
      ..name = 'Bad'
      ..investmentType = 'stocks'
      ..sipAmount = 100
      ..accountId = '1'
      ..categoryId = '3'
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1)
      ..dataVersion = 1
      ..sip = (Schedule()..intervalCount = 1); // no start date: nothing due
    await isar.writeTxn(() => isar.investments.put(bad));
    final s = await _p(isar).run(now: DateTime(2026, 10, 21, 9));
    expect(s.recurring, 2);
    expect(s.failed, 0);
  });
}
