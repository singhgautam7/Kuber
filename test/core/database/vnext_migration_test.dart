import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/vnext_migration.dart';
import 'package:kuber/core/schedule/processed_occurrence.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/legacy_dataset.dart';

RecurringRule _rule({
  required DateTime start,
  required DateTime next,
  String frequency = 'monthly',
  int count = 1,
  String? unit = 'month',
  int exec = 0,
  bool paused = false,
  String endType = 'never',
}) =>
    RecurringRule()
      ..name = 'r'
      ..amount = 100
      ..type = 'expense'
      ..categoryId = '1'
      ..accountId = '1'
      ..frequency = frequency
      ..customDays = count
      ..intervalUnit = unit
      ..startDate = start
      ..nextDueAt = next
      ..executionCount = exec
      ..endType = endType
      ..isPaused = paused
      ..createdAt = start
      ..updatedAt = start;

void main() {
  setUpAll(initialiseIsarForTests);

  test('existing dataset: every record migrated, seeded, backfilled, once',
      () async {
    final isar = await openTestIsar();
    addTearDown(() => closeAndCleanIsar(isar));
    await seedLegacyDataset(isar, count: 300);
    final now = DateTime(2026, 10, 21, 9);

    final r1 = await VNextMigration.run(isar, now: now);
    expect(r1.rules, 1);
    expect(r1.loans, 1);
    expect(r1.investments, 1);
    expect(r1.snapshotTaken, isTrue);
    expect(File('${isar.directory}/${VNextMigration.snapshotName}').existsSync(), isTrue);
    // 46 rent + 47 loan days (46 EMIs + 1 extra payment) + 46 SIPs.
    expect(r1.seeded, 46 + 47 + 46);
    expect(r1.backfilled, 46 + 47 + 46 + 20);

    final rule = (await isar.recurringRules.where().findFirst())!;
    expect(rule.dataVersion, 1);
    expect(rule.schedule!.processedThrough, 20261031);
    expect(rule.schedule!.postedCount, 46);
    expect(rule.schedule!.migrationNote, 'Migrated · "monthly" → 1 month');
    expect(nextDate(rule.schedule!, fromKey: 20261021), 20261101);
    // Old fields untouched.
    expect(rule.nextDueAt, DateTime(2026, 11, 1));
    expect(rule.frequency, 'monthly');

    final loan = (await isar.loans.where().findFirst())!;
    expect(loan.mode, LoanMode.simple);
    expect(loan.startingPoint, LoanStartingPoint.originalDetails);
    expect(loan.tenureMonths, 240);
    expect(loan.schedule!.anchorDay, 5);
    // L1: nothing before the update is back-filled.
    expect(loan.schedule!.processedThrough, 20261020);
    expect(loan.billDate, 5);

    final inv = (await isar.investments.where().findFirst())!;
    expect(inv.behaviour, InvestmentBehaviour.market);
    expect(inv.snapshots.single.value, 260000);
    expect(inv.investedAmount, 230000); // unchanged
    expect(inv.sip!.anchorDay, 10);
    expect(inv.openingInvested, 0); // 46 × 5,000 = 2,30,000 linked

    final emi = await isar.transactions.filter().linkedRuleTypeEqualTo('loan').findFirst();
    expect(emi!.subType, TxnSubType.loanRepayment);
    expect(emi.sourceId, loan.uid);
    expect(emi.principalPart, isNull); // never recalculated
    final lent = await isar.transactions.filter().linkedRuleTypeEqualTo('lent').findFirst();
    expect(lent!.subType, TxnSubType.lent);
    expect(lent.sourceType, isNull);
    final plain = await isar.transactions.filter().linkedRuleTypeIsNull().findFirst();
    expect(plain!.subType, isNull);

    final r2 = await VNextMigration.run(isar, now: now);
    expect(r2.rules + r2.loans + r2.investments + r2.seeded + r2.backfilled, 0);
    expect(r2.snapshotTaken, isFalse);
    expect(await isar.processedOccurrences.count(), r1.seeded);
  });

  test('rows written before vNext (Isar null sentinels) are migrated', () async {
    final isar = await openTestIsar();
    addTearDown(() => closeAndCleanIsar(isar));
    // What an old row reads as: never-stored int = Int64 min, double = NaN.
    const nullInt = -9223372036854775808;
    final r = _rule(start: DateTime(2026, 1, 1), next: DateTime(2026, 11, 1))
      ..dataVersion = nullInt;
    final l = Loan()
      ..uid = 'z'
      ..name = 'Z'
      ..loanType = 'other'
      ..lenderName = 'B'
      ..principalAmount = 0
      ..emiAmount = 100
      ..billDate = 1
      ..startDate = DateTime(2026, 1, 1)
      ..accountId = '1'
      ..categoryId = '1'
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1)
      ..dataVersion = nullInt
      ..emisPaidBefore = nullInt
      ..adjustment = double.nan
      ..principalPaidBefore = double.nan;
    await isar.writeTxn(() async {
      await isar.recurringRules.put(r);
      await isar.loans.put(l);
    });
    final report = await VNextMigration.run(isar, now: DateTime(2026, 10, 21));
    expect(report.rules, 1);
    expect(report.loans, 1);
    final after = (await isar.loans.where().findFirst())!;
    expect(after.dataVersion, 1);
    expect(after.emisPaidBefore, 0);
    expect(after.adjustment, 0);
    expect(after.principalPaidBefore, 0);
  });

  group('verification per record', () {
    final now = DateTime(2026, 10, 21);

    test('a rule whose old dates drifted keeps the old algorithm, flagged', () {
      // Old code once produced 3 Mar from 31 Jan (overflow), off the lattice.
      final r = _rule(start: DateTime(2025, 1, 31), next: DateTime(2025, 3, 3));
      VNextMigration.migrateRule(r, now);
      expect(r.schedule!.compat, 'legacyRecurring');
      expect(r.schedule!.migrationNote, contains('Flagged · kept the old dates'));
      expect(upcomingOccurrences(r.schedule!, limit: 2).map((o) => o.day),
          [20250303, 20250403]);
    });

    test('month-end anchors are migrated and flagged as clamped', () {
      final r = _rule(start: DateTime(2026, 1, 31), next: DateTime(2026, 10, 31));
      VNextMigration.migrateRule(r, now);
      expect(r.schedule!.compat, isNull);
      expect(r.schedule!.migrationNote,
          'Migrated · "monthly" → 1 month · Flagged · day 31 falls on the last day in 5 of 12');
    });

    test('legacy biweekly reads as 2 weeks; paused stays paused', () {
      final r = _rule(
          start: DateTime(2024, 2, 2),
          next: DateTime(2024, 3, 1),
          frequency: 'biweekly',
          count: 2,
          unit: 'week',
          paused: true);
      VNextMigration.migrateRule(r, now);
      expect(r.schedule!.paused, isTrue);
      expect(r.schedule!.migrationNote,
          'Migrated · legacy "biweekly" read as 2 weeks; paused');
      expect(dueOccurrences(r.schedule!, 20261021), isEmpty);
    });

    test('a daily rule created at 14:35 is OK (approved fix R1 only)', () {
      final r = _rule(
          start: DateTime(2026, 10, 1, 14, 35),
          next: DateTime(2026, 10, 21, 14, 35),
          frequency: 'daily',
          unit: 'day');
      VNextMigration.migrateRule(r, now);
      expect(r.schedule!.compat, isNull);
      expect(dueOccurrences(r.schedule!, 20261021).map((o) => o.day), [20261021]);
    });

    test('occurrence-count end carries executionCount', () {
      final r = _rule(
          start: DateTime(2026, 1, 1),
          next: DateTime(2026, 4, 1),
          exec: 3,
          endType: 'occurrences')
        ..endAfter = 5;
      VNextMigration.migrateRule(r, now);
      expect(upcomingOccurrences(r.schedule!).map((o) => o.day), [20260401, 20260501]);
    });
  });

  test('loan without numbers tracks the EMI only (L3, no wrong outstanding)', () {
    final l = Loan()
      ..uid = 'x'
      ..name = 'Bike'
      ..loanType = 'vehicle'
      ..lenderName = 'B'
      ..principalAmount = 100000
      ..emiAmount = 5000
      ..billDate = 12
      ..startDate = DateTime(2026, 1, 1)
      ..autoAddTransaction = true
      ..accountId = '1'
      ..categoryId = '1'
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1);
    VNextMigration.migrateLoan(l, const [], DateTime(2026, 10, 21));
    expect(l.startingPoint, LoanStartingPoint.trackEmiOnly);
    expect(loanStatus(l, const [], now: DateTime(2026, 10, 21)).outstanding, isNull);
    expect(l.schedule!.startDate, DateTime(2026, 1, 12));
    expect(l.schedule!.endType, ScheduleEnd.never);
  });

  test('loan with a past end date stops (approved fix L2)', () {
    final l = Loan()
      ..uid = 'y'
      ..name = 'Old'
      ..loanType = 'personal'
      ..lenderName = 'B'
      ..principalAmount = 0
      ..emiAmount = 5000
      ..billDate = 3
      ..startDate = DateTime(2023, 1, 3)
      ..endDate = DateTime(2025, 12, 3)
      ..autoAddTransaction = true
      ..accountId = '1'
      ..categoryId = '1'
      ..createdAt = DateTime(2023, 1, 1)
      ..updatedAt = DateTime(2023, 1, 1);
    VNextMigration.migrateLoan(l, const [], DateTime(2026, 10, 21));
    expect(dueOccurrences(l.schedule!, 20261103), isEmpty);
    expect(isEnded(l.schedule!), isTrue);
  });
}
