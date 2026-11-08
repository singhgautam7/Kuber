// November release A6 "Also test", through the real service, processor and
// backup. Expected values are worked out here by hand (closed-form EMI, plain
// sums) and written up in specs/nov-release/loan-tests.md, never read from the
// code under test.
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/occurrence_processor.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/schedule/processed_occurrence.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/helpers/transaction_filters.dart';
import 'package:kuber/l10n/app_localizations_en.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

double refEmi(double p, double annual, int n) {
  final r = annual / 1200;
  final f = math.pow(1 + r, n);
  return p * r * f / (f - 1);
}

LoanRelease part(DateTime d, double amount, {String? account, LoanAdjust adjust = LoanAdjust.tenure}) =>
    LoanRelease()
      ..date = d
      ..amount = amount
      ..accountId = account
      ..adjust = adjust;

void main() {
  late Isar isar;
  late LoanService service;
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initialiseIsarForTests();
    isar = await openTestIsar();
    service = LoanService(isar);
  });
  setUp(() => isar.writeTxn(() => isar.clear()));
  tearDownAll(() => closeAndCleanIsar(isar));

  final today = DateUtils.dateOnly(DateTime.now());
  DateTime monthsAgo(int n, [int day = 5]) => DateTime(today.year, today.month - n, day);

  Future<Loan> save(Loan l, {int? firstEmiMonthsAgo, int months = 60, bool isNew = true}) async {
    final first = monthsAgo(firstEmiMonthsAgo ?? 0);
    final s = scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: months)
      ..autoRecord = true;
    return service.save(l, s, isNew: isNew);
  }

  Loan loan({
    double principal = 500000,
    double rate = 12,
    double emi = 0,
    int months = 60,
    bool inParts = true,
    List<LoanRelease> releases = const [],
    LoanPreEmi preEmi = LoanPreEmi.none,
    LoanInterestType type = LoanInterestType.reducingBalance,
    DateTime? start,
  }) =>
      Loan()
        ..name = 'Personal'
        ..loanType = 'personal'
        ..lenderName = 'Bank'
        ..accountId = '9'
        ..principalAmount = principal
        ..emiAmount = emi
        ..mode = LoanMode.advanced
        ..interestType = type
        ..annualRate = rate
        ..tenureMonths = months
        ..loanStartDate = start
        ..releasedInParts = inParts
        ..releases = [...releases]
        ..preEmiMode = preEmi;

  Future<List<Transaction>> linked(Loan l) =>
      isar.transactions.filter().linkedRuleIdEqualTo(l.uid).findAll();
  Future<Loan> reload(Loan l) async => (await isar.loans.filter().uidEqualTo(l.uid).findFirst())!;

  test('personal loan: each part reaches Bank A on its date, never income or spending', () async {
    final l = await save(
        loan(releases: [
          part(monthsAgo(3, 1), 200000, account: '1'),
          part(monthsAgo(2, 1), 300000, account: '1'),
        ], start: monthsAgo(3, 1)),
        firstEmiMonthsAgo: -1);
    final txns = await linked(l);
    expect(txns.map((t) => t.amount).toList()..sort(), [200000, 300000]);
    for (final t in txns) {
      expect(t.accountId, '1');
      expect(t.type, 'income', reason: 'raises the balance');
      expect(t.subType, TxnSubType.loanDisbursement);
      expect(t.isBalanceAdjustment, isTrue);
      expect(t.name, 'Personal received');
      expect(t.sourceId, l.uid);
    }
    expect(txns.map((t) => dayKey(t.createdAt)).toSet(),
        {dayKey(monthsAgo(3, 1)), dayKey(monthsAgo(2, 1))});
    // Every total in the app is built on this filter.
    expect(txns.validForCalculations, isEmpty);
    // The EMI works on the outstanding on the first EMI date: all 5L released.
    final a = loanAmortization(l)!;
    expect(a.rows.first.payment, closeTo(refEmi(500000, 12, 60), 0.01));
    expect(a.openingBalance, 500000);
  });

  test('a calculated EMI uses what was released, not the sanctioned amount', () async {
    final l = await save(
        loan(principal: 1700000, rate: 9, months: 120, releases: [
          part(monthsAgo(4, 1), 1000000),
        ], start: monthsAgo(4, 1)),
        firstEmiMonthsAgo: -1, months: 120);
    final a = loanAmortization(l)!;
    expect(a.rows.first.payment, closeTo(refEmi(1000000, 9, 120), 0.01));
    final st = loanStatus(l, const []);
    expect(st.outstanding, 1000000);
    expect(st.partlyReleased, 1000000);
  });

  test('home loan paid to the builder: no account changes', () async {
    final l = await save(
        loan(releases: [part(monthsAgo(3, 1), 200000), part(monthsAgo(2, 1), 300000)],
            start: monthsAgo(3, 1)),
        firstEmiMonthsAgo: -1);
    expect(await linked(l), isEmpty);
  });

  group('a part released after EMIs started', () {
    Future<(Loan, Amortization)> released(LoanAdjust adjust) async {
      final l = await save(
          loan(principal: 600000, emi: 13000, inParts: false, start: monthsAgo(12)),
          firstEmiMonthsAgo: 12);
      await service.saveRelease(l, part(monthsAgo(1, 6), 100000, adjust: adjust), growSanctioned: true);
      return (l, loanAmortization(l)!);
    }

    test('it switches parts on and keeps the first release', () async {
      final (l, _) = await released(LoanAdjust.tenure);
      expect(l.releasedInParts, isTrue);
      expect(l.releases.map((r) => r.amount), [600000, 100000]);
      expect(l.principalAmount, 700000);
    });

    test('keep EMI: the payment stays and the end moves later', () async {
      final base = loanAmortization(await save(
          loan(principal: 600000, emi: 13000, inParts: false, start: monthsAgo(12)),
          firstEmiMonthsAgo: 12))!;
      final (_, a) = await released(LoanAdjust.tenure);
      expect(a.rows.last.day, greaterThan(base.rows.last.day));
      expect(a.rows[20].payment, 13000);
    });

    test('keep end date: the EMI rises and the end stays', () async {
      final base = loanAmortization(await save(
          loan(principal: 600000, emi: 13000, inParts: false, start: monthsAgo(12)),
          firstEmiMonthsAgo: 12))!;
      final (_, a) = await released(LoanAdjust.emi);
      expect(a.rows.last.day, base.rows.last.day);
      expect(a.rows[20].payment, greaterThan(13000));
    });
  });

  test('keep EMI on a part too big for the EMI to cover: the loan never ends', () async {
    final l = await save(
        loan(principal: 1000000, rate: 10, months: 120,
            releases: [part(monthsAgo(6, 1), 600000), part(monthsAgo(1, 1), 400000)],
            start: monthsAgo(6, 1)),
        firstEmiMonthsAgo: 3, months: 120);
    expect(loanNeverEnds(loanAmortization(l)!), isTrue);
    l.releases.last.adjust = LoanAdjust.emi;
    expect(loanNeverEnds(loanAmortization(l)!), isFalse);
  });

  group('Add to loan', () {
    test('charges added before EMIs raise the outstanding and earn interest', () async {
      final l = await save(
          loan(principal: 1000000, inParts: true, preEmi: LoanPreEmi.addToLoan, rate: 12,
              releases: [part(monthsAgo(4, 1), 1000000)], start: monthsAgo(4, 1)),
          firstEmiMonthsAgo: -1);
      final before = loanAmortization(l)!.preEmi!;
      await service.saveAddition(l,
          interest: false, date: monthsAgo(3, 1), amount: 10000, adjust: LoanAdjust.tenure);
      final after = loanAmortization(await reload(l))!.preEmi!;
      expect(after.addedCharges, 10000);
      expect(after.balance, greaterThan(before.balance + 10000), reason: 'interest on it');
      expect(after.addedInterest, greaterThan(before.addedInterest));
      expect((await linked(l)).where((t) => t.amount == 10000), isEmpty, reason: 'no money moved');
    });

    test('unpaid interest before EMIs counts as interest added', () async {
      final l = await save(
          loan(principal: 1000000, preEmi: LoanPreEmi.addToLoan,
              releases: [part(monthsAgo(4, 1), 1000000)], start: monthsAgo(4, 1)),
          firstEmiMonthsAgo: -1);
      final before = loanAmortization(l)!.preEmi!;
      await service.saveAddition(l,
          interest: true, date: monthsAgo(2, 15), amount: 5000, adjust: LoanAdjust.tenure);
      final st = loanStatus(await reload(l), const []);
      expect(st.addedInterest, greaterThan(before.addedInterest + 5000 - 1));
    });

    test('charge after EMIs start, keep EMI: outstanding up, EMI the same', () async {
      final l = await save(loan(principal: 600000, emi: 13000, inParts: false, start: monthsAgo(12)),
          firstEmiMonthsAgo: 12);
      final before = loanStatus(l, const []).outstanding!;
      await service.saveAddition(l,
          interest: false, date: today, amount: 20000, adjust: LoanAdjust.tenure);
      final st = loanStatus(await reload(l), const []);
      expect(st.outstanding, closeTo(before + 20000, 0.01));
      expect(st.addedCharges, 20000);
      expect(st.nextAmount, 13000);
    });

    test('unpaid interest after EMIs start, keep end date: EMI rises', () async {
      final l = await save(loan(principal: 600000, emi: 13000, inParts: false, start: monthsAgo(12)),
          firstEmiMonthsAgo: 12);
      await service.saveAddition(l,
          interest: true, date: today, amount: 20000, adjust: LoanAdjust.emi);
      final st = loanStatus(await reload(l), const []);
      expect(st.nextAmount, greaterThan(13000));
      expect(st.addedInterest, 20000);
    });

    test('dated in the past: Keep as is leaves recorded EMIs, Recalculate splits them again', () async {
      final l = await save(loan(principal: 600000, emi: 13000, inParts: false, start: monthsAgo(12)),
          firstEmiMonthsAgo: 12);
      l.schedule!.processedThrough = 0;
      await isar.writeTxn(() => isar.loans.put(l));
      await OccurrenceProcessor(isar, decimals: 2, l10n: AppLocalizationsEn()).run();
      final posted = (await linked(l)).where((t) => t.occurrenceDate != null).toList();
      expect(posted, isNotEmpty);
      final interestBefore = posted.fold(0.0, (s, t) => s + t.interestPart!);
      final from = dayKey(monthsAgo(11, 1));
      await service.saveAddition(l,
          interest: false, date: dayOf(from), amount: 50000, adjust: LoanAdjust.tenure);
      final kept = await linked(l);
      expect(kept.where((t) => t.occurrenceDate != null).fold(0.0, (s, t) => s + t.interestPart!),
          closeTo(interestBefore, 0.001), reason: 'Keep as is');
      final fresh = await reload(l);
      final rec = await LoanService.records(isar, l.uid);
      final p = LoanService.recalculatePreview(fresh, rec, from);
      expect(p.count, greaterThan(0));
      expect(p.newInterest, greaterThan(p.oldInterest));
      final n = await service.recalculateSplits(fresh, from);
      expect(n, p.count);
      final after = (await linked(l)).where((t) => t.occurrenceDate != null);
      expect(after.fold(0.0, (s, t) => s + t.interestPart!), greaterThan(interestBefore));
    });

    test('an older "unpaid interest" adjustment stays an unpaid interest event', () async {
      final l = loan(principal: 600000, emi: 13000, inParts: false, start: monthsAgo(12));
      await save(l, firstEmiMonthsAgo: 12);
      await service.saveAdjustment(l,
          date: monthsAgo(3), amount: 9000, reason: LoanAdjustReason.interestAdded, adjust: LoanAdjust.tenure);
      final st = loanStatus(await reload(l), const []);
      expect(st.addedInterest, 9000);
    });
  });

  group('edited pre-EMI override', () {
    Future<Loan> edited() async {
      final l = await save(
          loan(principal: 1000000, preEmi: LoanPreEmi.addToLoan,
              releases: [part(monthsAgo(5, 1), 600000), part(monthsAgo(4, 1), 200000)],
              start: monthsAgo(5, 1)),
          firstEmiMonthsAgo: -1);
      final calc = LoanService.preEmiCalculatedNow(l)!;
      l
        ..preEmiOverride = 25000
        ..preEmiCalculated = calc;
      await isar.writeTxn(() => isar.loans.put(l));
      expect(LoanService.preEmiNotice(l), isNull);
      expect(loanAmortization(l)!.openingBalance, 825000);
      return l;
    }

    test('a change to the releases brings the notice; Use goes back to Kuber', () async {
      final l = await edited();
      await service.saveRelease(l, part(monthsAgo(3, 1), 100000));
      final fresh = await reload(l);
      final now = LoanService.preEmiNotice(fresh);
      expect(now, isNotNull);
      expect(now, LoanService.preEmiCalculatedNow(fresh));
      await service.resolvePreEmiNotice(fresh, useKuber: true);
      final used = await reload(l);
      expect(used.preEmiOverride, isNull);
      expect(loanAmortization(used)!.openingBalance, 900000 + now!);
    });

    test('Keep mine holds the figure and stops asking', () async {
      final l = await edited();
      await service.saveRelease(l, part(monthsAgo(3, 1), 100000));
      await service.resolvePreEmiNotice(await reload(l), useKuber: false);
      final kept = await reload(l);
      expect(kept.preEmiOverride, 25000);
      expect(LoanService.preEmiNotice(kept), isNull);
      expect(loanAmortization(kept)!.openingBalance, 925000);
    });
  });

  group('I pay it every month', () {
    Future<Loan> paying() => save(
        loan(principal: 1000000, rate: 9.2, preEmi: LoanPreEmi.payMonthly, inParts: false,
            start: monthsAgo(3, 1), months: 120),
        firstEmiMonthsAgo: -1, months: 120);

    test('posts each due cycle from the EMI account as interest, once', () async {
      final l = await paying();
      final count = await OccurrenceProcessor.countDue(isar);
      final p = OccurrenceProcessor(isar, decimals: 2, l10n: AppLocalizationsEn());
      // Created today: earlier cycles are history, like EMIs before Kuber.
      await p.run();
      expect(count, 0);
      expect(await linked(l), isEmpty);
      l.createdAt = monthsAgo(4);
      await isar.writeTxn(() => isar.loans.put(l));
      expect(await OccurrenceProcessor.countDue(isar), greaterThan(0));
      await p.run();
      await p.run();
      final txns = await linked(l);
      final cycles = loanAmortization(l)!.preEmi!.cycles.where((c) => c.day <= dayKey(today)).toList();
      expect(txns.length, cycles.length);
      for (final t in txns) {
        expect(t.accountId, '9');
        expect(t.principalPart, 0);
        expect(t.interestPart, t.amount);
        expect(t.subType, TxnSubType.loanRepayment);
        expect(t.type, 'expense');
        expect(isEditableEmi(t), isFalse);
      }
      expect(txns.map((t) => t.amount).toList()..sort(),
          cycles.map((c) => c.interest).toList()..sort());
      expect(await isar.processedOccurrences.count(), txns.length);
    });

    test('it matches an interest-only period over a full year', () {
      // 12 cycles of daily interest = 12 monthly interest-only payments.
      final pre = preEmiLedger(
          rate: 9.2,
          mode: PreEmiInterest.paid,
          cycleDay: 5,
          firstEmiDay: 20250605,
          releases: const [(20240505, 1000000)]);
      expect(pre.cycles.length, 12);
      expect(pre.paidInterest, closeTo(12 * monthlyInterest(1000000, 9.2), 6));
      expect(pre.balance, 1000000);
    });

    test('a stored interest-only-first loan keeps its engine', () {
      final io = loan(principal: 400000, rate: 9.5, inParts: false, months: 72,
          type: LoanInterestType.interestOnlyFirst)
        ..interestOnlyMonths = 12
        ..createdAt = monthsAgo(1)
        ..schedule = (scheduleFrom(start: monthsAgo(0), endType: ScheduleEnd.afterCount, endCount: 72));
      final a = loanAmortization(io)!;
      expect(a.preEmi, isNull);
      expect(a.rows.first.interestOnly, isTrue);
      expect(a.rows.first.payment, closeTo(monthlyInterest(400000, 9.5), 0.001));
    });
  });

  group('deleting and turning off', () {
    Future<Loan> twoParts() => save(
        loan(releases: [
          part(monthsAgo(3, 1), 200000, account: '1'),
          part(monthsAgo(2, 1), 300000, account: '1'),
        ], start: monthsAgo(3, 1)),
        firstEmiMonthsAgo: -1);

    test('delete a part with its transaction', () async {
      final l = await twoParts();
      await service.deleteRelease(l, l.releases.last, deleteTransaction: true);
      expect((await linked(l)).map((t) => t.amount), [200000]);
      expect(loanAmortization(await reload(l))!.openingBalance, 200000);
    });

    test('delete a part, keep its transaction', () async {
      final l = await twoParts();
      await service.deleteRelease(l, l.releases.last, deleteTransaction: false);
      expect((await linked(l)).map((t) => t.amount).toList()..sort(), [200000, 300000]);
      expect(loanAmortization(await reload(l))!.openingBalance, 200000);
    });

    test('editing a part updates its transaction', () async {
      final l = await twoParts();
      final old = l.releases.last;
      await service.saveRelease(
          l,
          part(monthsAgo(2, 9), 350000, account: '2')..transactionId = old.transactionId,
          replace: old);
      final t = (await linked(l)).firstWhere((x) => x.id == old.transactionId);
      expect(t.amount, 350000);
      expect(t.accountId, '2');
      expect(dayKey(t.createdAt), dayKey(monthsAgo(2, 9)));
    });

    test('turning the switch off keeps the first part only', () async {
      final l = await twoParts();
      final first = l.releases.first;
      final draft = l.copy()
        ..releasedInParts = false
        ..releases = [first.copy()..amount = l.principalAmount];
      await service.save(draft, draft.schedule!);
      final txns = await linked(l);
      expect(txns.map((t) => t.amount), [500000]);
    });
  });

  group('backup', () {
    test('releases, events and override survive a round trip', () async {
      await isar.writeTxn(() => isar.categorys.put(Category()
        ..name = 'Loan EMI'
        ..icon = 'x'
        ..colorValue = 1));
      final l = await save(
          loan(principal: 1000000, preEmi: LoanPreEmi.addToLoan,
              releases: [part(monthsAgo(4, 1), 800000, account: '1')], start: monthsAgo(4, 1)),
          firstEmiMonthsAgo: -1);
      l
        ..preEmiCycleDay = 12
        ..preEmiOverride = 9000
        ..preEmiCalculated = 8000;
      await service.saveAddition(l,
          interest: false, date: monthsAgo(3), amount: 1500, adjust: LoanAdjust.emi, note: 'Insurance');
      final json = await JsonBackupService().exportJson(isar);
      expect(jsonDecode(json)['version'], 4);
      await isar.writeTxn(() => isar.clear());
      await JsonBackupService().importJson(isar, json);
      final r = await reload(l);
      expect(r.releases.single.amount, 800000);
      expect(r.releases.single.accountId, '1');
      expect(r.releases.single.transactionId, isNotNull);
      expect(r.releasedInParts, isTrue);
      expect(r.preEmiMode, LoanPreEmi.addToLoan);
      expect(r.preEmiCycleDay, 12);
      expect(r.preEmiOverride, 9000);
      expect(r.preEmiCalculated, 8000);
      expect(r.events.single.kind, LoanEventKind.chargeAdded);
      expect(r.events.single.note, 'Insurance');
      final t = (await linked(l)).single;
      expect(t.subType, TxnSubType.loanDisbursement);
      expect(t.isBalanceAdjustment, isTrue);
    });

    test('a backup from before this release restores with nothing new', () {
      final m = (loan(inParts: false)
            ..id = 1
            ..uid = 'u'
            ..billDate = 5
            ..startDate = today
            ..categoryId = '1'
            ..createdAt = today
            ..updatedAt = today)
          .toMap()
        ..remove('releases')
        ..remove('releasedInParts')
        ..remove('preEmiMode')
        ..remove('preEmiCycleDay')
        ..remove('preEmiOverride')
        ..remove('preEmiCalculated');
      final json = jsonEncode({'version': 3, 'loans': [m]});
      expect(() async => JsonBackupService().importJson(isar, json), returnsNormally);
    });
  });

  group('every interest type released in parts', () {
    for (final type in LoanInterestType.values) {
      test(type.name, () async {
        final l = loan(principal: 1000000, rate: 10, months: 120, type: type,
            releases: [
              part(monthsAgo(6, 1), 600000),
              part(monthsAgo(1, 1), 400000, adjust: LoanAdjust.emi),
            ],
            start: monthsAgo(6, 1))
          ..interestOnlyMonths = type == LoanInterestType.interestOnlyFirst ? 6 : 0;
        await save(l, firstEmiMonthsAgo: 3, months: 120);
        final a = loanAmortization(l)!;
        // 6L before the first EMI, the second part as a later event.
        expect(a.openingBalance, 600000);
        final st = loanStatus(l, const []);
        expect(st.outstanding, greaterThan(600000), reason: 'second part is in');
        expect(a.rows, isNotEmpty);
        if (type == LoanInterestType.interestOnlyFirst) {
          expect(a.rows.first.interestOnly, isTrue);
        }
        expect(a.rows.last.balance, closeTo(0, 0.01));
      });
    }
  });
}
