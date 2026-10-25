import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/occurrence_processor.dart';
import 'package:kuber/core/money_math/loan_math.dart' show emisLeftFor;
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../../helpers/isar_test_helper.dart';

// End-to-end data check for loans (the Reddit case: a home loan running
// since years before Kuber, interest counted as the expense), through the
// real save, background processor and loan service.
void main() {
  late Isar isar;
  setUpAll(() async {
    await initialiseIsarForTests();
    isar = await openTestIsar();
  });
  setUp(() => isar.writeTxn(() => isar.clear()));
  tearDownAll(() => closeAndCleanIsar(isar));

  final today = DateUtils.dateOnly(DateTime.now());
  final todayK = dayKey(today);

  OccurrenceProcessor processor() =>
      OccurrenceProcessor(isar, decimals: 2, l10n: AppLocalizationsEn());

  Future<List<Transaction>> linked(Loan l) =>
      isar.transactions.filter().linkedRuleIdEqualTo(l.uid).findAll();

  Future<Loan> reload(Loan l) async => (await isar.loans.filter().uidEqualTo(l.uid).findFirst())!;

  Future<Loan> create({
    required LoanStartingPoint start,
    double principal = 3000000,
    double rate = 8.5,
    int months = 240,
    double emi = 0,
    bool onlyInterest = true,
    double? outstanding,
    double paidPrincipal = 0,
    double paidInterest = 0,
  }) async {
    // First EMI on the 5th, 117 months ago.
    final first = DateTime(today.year, today.month - 117, 5);
    final numbers = start != LoanStartingPoint.trackEmiOnly;
    final l = Loan()
      ..name = 'Home Loan SBI'
      ..loanType = 'home'
      ..lenderName = 'SBI'
      ..accountId = '1'
      ..principalAmount = numbers ? principal : 0
      ..emiAmount = emi > 0 ? emi : calculateEmiFor(principal, rate, months)
      ..mode = numbers ? LoanMode.advanced : LoanMode.simple
      ..alreadyRunning = true
      ..startingPoint = start
      ..annualRate = numbers ? rate : null
      ..tenureMonths = numbers ? months : null
      ..countOnlyInterest = numbers && onlyInterest
      ..countOnlyInterestFrom = numbers && onlyInterest ? today : null
      ..outstandingAtStart = outstanding
      ..principalPaidBefore = paidPrincipal
      ..interestPaidBefore = paidInterest;
    final schedule = start == LoanStartingPoint.outstandingToday
        ? scheduleFrom(
            start: dayOf(nextDate(scheduleFrom(start: first), fromKey: todayK)!),
            endType: ScheduleEnd.afterCount,
            endCount: emisLeftFor(outstanding!, rate, l.emiAmount))
        : scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: months);
    schedule.autoRecord = true;
    if (start == LoanStartingPoint.outstandingToday) l.tenureMonths = schedule.endCount;
    return LoanService(isar).save(l, schedule, isNew: true);
  }

  void expectPrincipalAddsUp(Loan l, LoanStatus st, double principal) {
    expect(st.principalPaid! + st.outstanding!, closeTo(principal, 1),
        reason: 'principal paid + outstanding = principal');
  }

  test('running since years ago: opening values, nothing back-filled', () async {
    final l = await create(start: LoanStartingPoint.originalDetails);
    expect(await linked(l), isEmpty, reason: 'no past EMIs are created');
    final st = loanStatus(l, const []);
    final before = upcomingOccurrences(l.schedule!.copy()..processedThrough = 0,
            toKey: addDays(todayK, -1), limit: 1000)
        .length;
    expect(st.emisPaid, before);
    expect(st.totalEmis, 240);
    expectPrincipalAddsUp(l, st, 3000000);
    expect(st.interestPaid! + st.principalPaid!, closeTo(before * l.emiAmount, before * 0.01 + 1));
  });

  test('EMIs post once, split adds up, only interest counts as spending', () async {
    var l = await create(start: LoanStartingPoint.originalDetails);
    final later = today.add(const Duration(days: 75));
    final r1 = await processor().run(now: DateTime(later.year, later.month, later.day, 10));
    final r2 = await processor().run(now: DateTime(later.year, later.month, later.day, 18));
    expect(r2.posted, 0, reason: 'a second run posts nothing');
    final txns = await linked(l);
    expect(txns.length, r1.emis);
    expect(txns.length, inInclusiveRange(2, 3));
    for (final t in txns) {
      expect(t.subType, TxnSubType.loanRepayment);
      expect(t.principalPart! + t.interestPart!, closeTo(t.amount, 0.001));
      expect(t.occurrenceDate! >= todayK, isTrue, reason: 'nothing before today');
      expect(t.spendInterestOnly, isTrue);
      expect(t.spendAmount, t.interestPart);
    }
    l = await reload(l);
    final st = loanStatus(l, txns, now: later);
    expectPrincipalAddsUp(l, st, 3000000);
    // The stored split matches the schedule.
    final a = loanAmortization(l)!;
    for (final t in txns) {
      expect(t.interestPart, closeTo(a.rowOn(t.occurrenceDate!)!.interest, 0.01));
    }
  });

  test('extra payment toward principal, then a rate change, then closing', () async {
    var l = await create(start: LoanStartingPoint.originalDetails);
    final service = LoanService(isar);
    final base = loanStatus(l, const []);

    await service.recordExtraPayment(l,
        amount: 200000,
        towardPrincipal: true,
        reduce: LoanAdjust.tenure,
        charge: 1000,
        accountId: '1',
        date: today);
    l = await reload(l);
    final afterExtra = loanStatus(l, await linked(l));
    expect(afterExtra.outstanding, closeTo(base.outstanding! - 200000, 1));
    expect(afterExtra.totalEmis! < base.totalEmis!, isTrue, reason: 'reduce tenure ends sooner');
    expectPrincipalAddsUp(l, afterExtra, 3000000);
    final extra = await linked(l);
    expect(extra.where((t) => t.principalPart == 200000).length, 1);
    expect(extra.where((t) => t.amount == 1000 && t.subType == null).length, 1,
        reason: 'the charge is a plain expense, not a repayment');

    final emiBefore = emiFor(l, nextDate(l.schedule!, fromKey: addDays(todayK, 1))!, 2).amount;
    await service.changeRate(l, newRate: 9.5, from: today, adjust: LoanAdjust.emi);
    l = await reload(l);
    final next = nextDate(l.schedule!, fromKey: addDays(todayK, 1))!;
    expect(emiFor(l, next, 2).amount > emiBefore, isTrue, reason: 'higher rate, higher EMI');

    final later = dayOf(next);
    await processor().run(now: DateTime(later.year, later.month, later.day, 12));
    final posted = (await linked(l)).where((t) => t.occurrenceDate == next).single;
    expect(posted.amount, closeTo(emiFor(l, next, 2).amount, 0.001));
    expect(posted.principalPart! + posted.interestPart!, closeTo(posted.amount, 0.001));
    l = await reload(l);
    expectPrincipalAddsUp(l, loanStatus(l, await linked(l), now: later), 3000000);

    await service.close(l);
    l = await reload(l);
    final count = (await linked(l)).length;
    final much = later.add(const Duration(days: 120));
    await processor().run(now: DateTime(much.year, much.month, much.day, 12));
    expect((await linked(l)).length, count, reason: 'a closed loan posts nothing');
  });

  test('close, then re-open: nothing posts while closed or back-fills', () async {
    var l = await create(start: LoanStartingPoint.originalDetails);
    final service = LoanService(isar);
    final endBefore = lastDate(l.schedule!);
    await service.close(l);
    l = await reload(l);
    expect(loanStatus(l, const []).closed, isTrue);
    // Three months pass while closed.
    final later = today.add(const Duration(days: 92));
    await processor().run(now: DateTime(later.year, later.month, later.day, 9));
    expect(await linked(l), isEmpty, reason: 'a closed loan posts nothing');
    await service.reopen(l, now: later);
    l = await reload(l);
    expect(loanStatus(l, const [], now: later).closed, isFalse);
    expect(l.closedAt, isNull);
    expect(l.isCompleted, isFalse);
    expect(lastDate(l.schedule!), endBefore, reason: 'end date does not move');
    // The next run (same day) posts nothing from the closed months.
    await processor().run(now: DateTime(later.year, later.month, later.day, 12));
    final txns = await linked(l);
    expect(txns.where((t) => t.occurrenceDate! < dayKey(later)), isEmpty);
    // Next month's EMI posts as usual.
    final next = nextDate(l.schedule!, fromKey: dayKey(later))!;
    final nd = dayOf(next);
    await processor().run(now: DateTime(nd.year, nd.month, nd.day, 9));
    expect((await linked(l)).where((t) => t.occurrenceDate == next), hasLength(1));
  });

  test('editing a running loan keeps its history and never double-posts', () async {
    var l = await create(start: LoanStartingPoint.originalDetails);
    final later = today.add(const Duration(days: 75));
    await processor().run(now: DateTime(later.year, later.month, later.day, 9));
    l = await reload(l);
    final before = await linked(l);
    expect(before, isNotEmpty);
    // Edit: new name and lender, same schedule; then a rate edit that changes the EMI.
    l
      ..name = 'Home Loan HDFC'
      ..lenderName = 'HDFC';
    await LoanService(isar).save(l, l.schedule!.copy());
    l = await reload(l);
    await processor().run(now: DateTime(later.year, later.month, later.day, 18));
    final after = await linked(l);
    expect(after.length, before.length, reason: 'editing posts nothing again');
    expect(after.map((t) => t.amount).toList(), before.map((t) => t.amount).toList(),
        reason: 'posted EMIs are never rewritten');
    expectPrincipalAddsUp(l, loanStatus(l, after, now: later), 3000000);
    // Next due date posts exactly once.
    final next = nextDate(l.schedule!, fromKey: addDays(dayKey(later), 1))!;
    final nd = dayOf(next);
    await processor().run(now: DateTime(nd.year, nd.month, nd.day, 9));
    await processor().run(now: DateTime(nd.year, nd.month, nd.day, 21));
    expect((await linked(l)).where((t) => t.occurrenceDate == next), hasLength(1));
  });

  test('flat rate: every posted EMI is the same and its split adds up', () async {
    final first = DateTime(today.year, today.month, 5);
    final flatEmi = (500000 + 500000 * 0.09 * 5) / 60; // 5L at 9% flat, 5 years
    final l = await LoanService(isar).save(
        Loan()
          ..name = 'Bike loan'
          ..loanType = 'vehicle'
          ..lenderName = 'Bajaj'
          ..accountId = '1'
          ..principalAmount = 500000
          ..emiAmount = flatEmi
          ..mode = LoanMode.advanced
          ..interestType = LoanInterestType.flatRate
          ..startingPoint = LoanStartingPoint.originalDetails
          ..annualRate = 9
          ..tenureMonths = 60,
        scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: 60)..autoRecord = true,
        isNew: true);
    final later = today.add(const Duration(days: 100));
    await processor().run(now: DateTime(later.year, later.month, later.day, 9));
    final txns = await linked(l);
    expect(txns.length, inInclusiveRange(3, 4));
    for (final t in txns) {
      expect(t.amount, closeTo(flatEmi, 0.01));
      expect(t.principalPart! + t.interestPart!, closeTo(t.amount, 0.001));
      expect(t.interestPart, closeTo(500000 * 0.09 / 12, 0.01), reason: 'flat interest is the same each month');
    }
  });

  test('"outstanding today" keeps the past totals and counts from the balance', () async {
    final l = await create(
        start: LoanStartingPoint.outstandingToday,
        emi: 26035,
        outstanding: 2132774,
        paidPrincipal: 867226,
        paidInterest: 2178869);
    final st = loanStatus(l, const []);
    expect(st.outstanding, closeTo(2132774, 1));
    expect(st.principalPaid, closeTo(867226, 1));
    expect(st.interestPaid, closeTo(2178869, 1));
    expect(st.principalPaid! + st.outstanding!, closeTo(3000000, 1));
  });

  test('"just track the EMI" posts the EMI with no split', () async {
    final l = await create(start: LoanStartingPoint.trackEmiOnly, emi: 26035);
    final later = today.add(const Duration(days: 40));
    await processor().run(now: DateTime(later.year, later.month, later.day, 12));
    final txns = await linked(l);
    expect(txns, isNotEmpty);
    for (final t in txns) {
      expect(t.amount, 26035);
      expect(t.principalPart, isNull);
      expect(t.spendInterestOnly, isFalse);
      expect(t.spendAmount, 26035);
    }
  });
}

double calculateEmiFor(double p, double rate, int months) {
  final r = rate / 1200;
  final f = (1 + r) * 1;
  var pow = 1.0;
  for (var i = 0; i < months; i++) {
    pow *= f;
  }
  return p * r * pow / (pow - 1);
}
