// Advanced history v1.2 A1/A2/A3/A5: the EMI split fix through the real
// service and Isar. Expected numbers come from the independent script
// specs/advanced-history-v1/loan_check.py (no shared code), tabled in
// specs/advanced-history-v1/loan-tests.md.
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

import '../../helpers/isar_test_helper.dart';
import 'loan_pre_emi_test.dart' show federal;

/// The script's EMI days (13th, or 5th) for EMI number [n] from [first].
int emiDay(DateTime first, int n) {
  final m = first.month - 1 + (n - 1);
  return (first.year + m ~/ 12) * 10000 + (m % 12 + 1) * 100 + first.day;
}

/// (principal, interest) per EMI number, from loan_check.py.
typedef Expect = Map<int, (double, double)>;

void main() {
  late Isar isar;
  setUpAll(() async {
    await initialiseIsarForTests();
    isar = await openTestIsar();
  });
  setUp(() => isar.writeTxn(() => isar.clear()));
  tearDownAll(() => closeAndCleanIsar(isar));
  final now = DateTime(2026, 11, 16);
  final fed1 = DateTime(2017, 11, 13);

  Future<Loan> create(Loan l) => LoanService(isar).save(l, l.schedule!, isNew: true);
  Future<Loan> reload(Loan l) async => (await isar.loans.filter().uidEqualTo(l.uid).findFirst())!;
  Future<LoanRecords> records(Loan l) => LoanService.records(isar, l.uid);
  Map<int, Transaction> byDay(LoanRecords r) => {for (final t in r.linked) t.occurrenceDate!: t};

  /// The reported home loan: all four parts, EMI 15,840, running, past EMIs on.
  Loan fedAll({bool daily = false}) => federal()
    ..emiAmount = 15840
    ..events = []
    ..alreadyRunning = true
    ..startingPoint = LoanStartingPoint.originalDetails
    ..interestMethod = daily ? LoanInterestMethod.daily : LoanInterestMethod.monthly;

  void expectSplits(LoanRecords r, DateTime first, Expect e,
      {double tol = 0.011, int? skipDay}) {
    final m = byDay(r);
    e.forEach((n, v) {
      if (emiDay(first, n) == skipDay) return;
      final t = m[emiDay(first, n)]!;
      expect(t.principalPart, closeTo(v.$1, tol), reason: 'EMI $n principal');
      expect(t.interestPart, closeTo(v.$2, tol), reason: 'EMI $n interest');
    });
  }

  group('A1 reproduce', () {
    test('path (a): first part only, parts added later: null splits survive Recalculate (root cause)',
        () async {
      final all = fedAll();
      final firstOnly = all.copy()..releases = [all.releases.first];
      var l = await create(firstOnly);
      final s = LoanService(isar);
      await s.addPastEmis(l, now: now);
      var rec = await records(l);
      // The old schedule ends on EMI 40 (14 Feb 2021): later days have no row.
      expect(loanAmortizationWith(l, noLoanRecords)!.rows.length, 40);
      expect(rec.linked.length, 109);
      expect(rec.linked.where((t) => t.principalPart == null).length, 69);
      expect(rec.linked.where((t) => t.principalPart != null).length, 40);
      // Add to loan > Money released, three times.
      for (final r in all.releases.skip(1)) {
        await s.saveRelease(l, r);
      }
      l = await reload(l);
      // The fixed Recalculate takes every unedited EMI, null splits included.
      expect(LoanService.recalculatePreview(l, rec, 0).count, 109);
      expect(await s.recalculateSplits(l, 0), 109);
      rec = await records(l);
      expect(rec.linked.where((t) => t.principalPart == null), isEmpty);
      // EMI 40 was recorded as 4,429.43 by the old schedule (script S1a).
      expectSplits(rec, fed1, {
        1: (2138.17, 13701.83),
        40: (0, 4429.43),
        41: (2880.06, 12959.94),
        109: (4841.17, 10998.83),
      });
      final st = loanStatus(l, rec.linked, now: now);
      expect(st.outstanding, closeTo(1429789.23, 0.5));
      expect(st.interestPaid, closeTo(1357743.66, 0.5));
      expect(st.principalPaid, closeTo(357405.77, 0.5));
      expect(st.totalEmis, 264);
      expect(loanSplitCheck(l, rec).count, 0);
    });

    test('path (b): all parts from the start: every past EMI has the schedule split', () async {
      final l = await create(fedAll());
      await LoanService(isar).addPastEmis(l, now: now);
      final rec = await records(l);
      expect(rec.linked.length, 109);
      expect(rec.linked.where((t) => t.principalPart == null), isEmpty);
      expectSplits(rec, fed1, {
        1: (2138.17, 13701.83),
        40: (2880.06, 12959.94),
        41: (2902.14, 12937.86),
        109: (4878.28, 10961.72),
      });
      final c = loanSplitCheck(await reload(l), rec);
      expect((c.count, c.checked, c.kept), (0, 109, 0));
      final st = loanStatus(await reload(l), rec.linked, now: now);
      expect(st.outstanding, closeTo(1424910.94, 0.5));
      expect(st.interestPaid, closeTo(1364275.94, 0.5));
      expect(st.principalPaid, closeTo(362284.06, 0.5));
      expect(st.emisPaid, 109);
      expect(st.totalEmis, 263);
    });
  });

  group('A3 fix', () {
    /// Path (a) as the user has it: EMIs 1 to 40 hand-edited to the bank's
    /// figures (here the schedule's), 41 to 109 with no split.
    Future<(Loan, Map<int, (double, double)>)> userCase() async {
      final all = fedAll();
      final s = LoanService(isar);
      var l = await create(all.copy()..releases = [all.releases.first]);
      await s.addPastEmis(l, now: now);
      for (final r in all.releases.skip(1)) {
        await s.saveRelease(l, r);
      }
      l = await reload(l);
      final want = loanAmortization(l)!;
      final rec = await records(l);
      final kept = <int, (double, double)>{};
      await isar.writeTxn(() async {
        for (final t in rec.linked) {
          final d = t.occurrenceDate!;
          if (d > emiDay(fed1, 40)) continue;
          final row = want.rowOn(d)!;
          final sp = roundedSplit(15840, row.interest, 2);
          LoanService.applyEditedSplit(t,
              amount: 15840, principal: sp.principal, interest: sp.interest);
          kept[d] = (sp.principal, sp.interest);
          await isar.transactions.put(t);
        }
      });
      return (l, kept);
    }

    test('hand-edited 1 to 40, no split 41 to 109: 69 to fix, 40 kept, totals identical', () async {
      final (l, kept) = await userCase();
      var rec = await records(l);
      final before = loanStatus(l, rec.linked, now: now);
      final c = loanSplitCheck(l, rec);
      expect((c.count, c.checked, c.kept), (69, 109, 40));
      expect(c.items.every((i) => i.missing), isTrue);
      expect((c.firstDay, c.lastDay), (emiDay(fed1, 41), emiDay(fed1, 109)));
      expect(c.totalPaid, 69 * 15840);
      expect(c.nowInterest, 0);
      // The sheet already used the schedule for them, so nothing moves.
      expect(c.outstandingAfter, closeTo(before.outstanding!, 0.5));
      expect(before.outstanding, closeTo(1424910.94, 0.5)); // script S1
      expect(before.interestPaid, closeTo(1364275.94, 0.5));

      await LoanService(isar).fixSplits(c);
      rec = await records(l);
      final after = loanStatus(l, rec.linked, now: now);
      for (final (a, b) in [
        (after.outstanding!, before.outstanding!),
        (after.interestPaid!, before.interestPaid!),
        (after.principalPaid!, before.principalPaid!),
        (after.totalInterest!, before.totalInterest!),
      ]) {
        expect(a, closeTo(b, 0.5));
      }
      expect((after.emisPaid, after.totalEmis), (before.emisPaid, before.totalEmis));
      // Every unedited EMI now has the schedule split (script S1), edited unchanged.
      expectSplits(rec, fed1, {
        41: (2902.14, 12937.86),
        109: (4878.28, 10961.72),
      });
      final m = byDay(rec);
      kept.forEach((d, v) {
        expect(m[d]!.principalPart, v.$1);
        expect(m[d]!.interestPart, v.$2);
        expect(m[d]!.splitEdited, isTrue);
      });
      expect(rec.linked.where((t) => t.principalPart == null), isEmpty);
      final again = loanSplitCheck(l, rec);
      expect((again.count, again.kept), (0, 40));
      // The amounts never move.
      expect(rec.linked.every((t) => t.amount == 15840), isTrue);
    });

    test('Undo puts every old value back', () async {
      final (l, _) = await userCase();
      final s = LoanService(isar);
      final c = loanSplitCheck(l, await records(l));
      final undo = await s.fixSplits(c);
      expect(undo.length, 69);
      expect(loanSplitCheck(l, await records(l)).count, 0);
      await s.undoSplitFix(undo);
      final rec = await records(l);
      expect(rec.linked.where((t) => t.principalPart == null).length, 69);
      expect(loanSplitCheck(l, rec).count, 69);
    });

    test('not hand-edited: the stale unedited splits are fixed too, and the outstanding moves',
        () async {
      // Path (a) untouched by the user: 40 EMIs carry the old short schedule's splits.
      final all = fedAll();
      final s = LoanService(isar);
      var l = await create(all.copy()..releases = [all.releases.first]);
      await s.addPastEmis(l, now: now);
      for (final r in all.releases.skip(1)) {
        await s.saveRelease(l, r);
      }
      l = await reload(l);
      var rec = await records(l);
      final before = loanStatus(l, rec.linked, now: now);
      // The old splits were trusted: far less owed than the loan schedule says.
      expect(before.outstanding, closeTo(686699.53, 0.5));
      final c = loanSplitCheck(l, rec);
      expect((c.count, c.kept), (109, 0));
      expect(c.outstandingAfter, closeTo(1429789.23, 0.5)); // script S1a
      await s.fixSplits(c);
      rec = await records(l);
      expect(loanStatus(l, rec.linked, now: now).outstanding, closeTo(1429789.23, 0.5));
      // Total paid never changes.
      expect(rec.linked.fold(0.0, (a, t) => a + t.amount), c.totalPaid + 0);
    });
  });

  group('A5 every kind of loan', () {
    Loan plain({
      required String uid,
      required double principal,
      required double rate,
      required int months,
      required double emi,
      required DateTime first,
      LoanInterestType type = LoanInterestType.reducingBalance,
      int io = 0,
      bool daily = false,
    }) =>
        Loan()
          ..uid = uid
          ..name = 'Loan $uid'
          ..loanType = 'personal'
          ..lenderName = 'Bank'
          ..accountId = '1'
          ..categoryId = '1'
          ..principalAmount = principal
          ..emiAmount = emi
          ..billDate = first.day
          ..startDate = first
          ..createdAt = first
          ..updatedAt = first
          ..mode = LoanMode.advanced
          ..alreadyRunning = true
          ..startingPoint = LoanStartingPoint.originalDetails
          ..annualRate = rate
          ..tenureMonths = months
          ..interestType = type
          ..interestOnlyMonths = io
          ..interestMethod = daily ? LoanInterestMethod.daily : LoanInterestMethod.monthly
          ..schedule = (scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: months)
            ..autoRecord = false);

    /// Past EMIs on, then damage the splits (null, wrong), edit the LAST one,
    /// check, fix, and compare every unedited EMI with the script.
    Future<void> run(Loan loan, int emis, DateTime first, Expect expected) async {
      final l = await create(loan);
      final s = LoanService(isar);
      await s.addPastEmis(l, now: now);
      var rec = await records(l);
      expect(rec.linked.length, emis);
      expectSplits(rec, first, expected);
      expect(loanSplitCheck(l, rec).count, 0, reason: 'created right: nothing to fix');

      final ordered = rec.linked.toList()..sort((a, b) => a.occurrenceDate!.compareTo(b.occurrenceDate!));
      final last = ordered.last;
      var damaged = 0;
      await isar.writeTxn(() async {
        for (var k = 0; k < ordered.length - 1; k++) {
          final t = ordered[k];
          if (k % 3 == 0) {
            t
              ..principalPart = null
              ..interestPart = null;
            damaged++;
          } else if (k % 5 == 0) {
            t
              ..principalPart = t.principalPart! + 500
              ..interestPart = t.interestPart! - 500;
            damaged++;
          } else {
            continue;
          }
          await isar.transactions.put(t);
        }
        LoanService.applyEditedSplit(last,
            amount: last.amount, principal: last.principalPart! + 7, interest: last.interestPart! - 7);
        await isar.transactions.put(last);
      });
      final editedP = last.principalPart, editedI = last.interestPart;
      rec = await records(l);
      final c = loanSplitCheck(l, rec);
      expect((c.count, c.kept), (damaged, 1));
      final paid = rec.linked.fold(0.0, (a, t) => a + t.amount);
      await s.fixSplits(c);
      rec = await records(l);
      expect(loanSplitCheck(l, rec).count, 0);
      expect(rec.linked.fold(0.0, (a, t) => a + t.amount), paid);
      // The edited one is untouched; the others equal the script.
      final m = byDay(rec);
      expect(m[last.occurrenceDate]!.principalPart, editedP);
      expect(m[last.occurrenceDate]!.interestPart, editedI);
      expectSplits(rec, first, expected, skipDay: last.occurrenceDate);
    }

    test('no parts, reducing, monthly (script S3)', () async {
      final first = DateTime(2020, 1, 5);
      await run(plain(uid: 's3', principal: 1200000, rate: 9, months: 180, emi: 12171, first: first),
          83, first, {
        1: (3171.00, 9000.00),
        50: (4573.03, 7597.97),
        80: (5722.10, 6448.90),
      });
    });

    test('flat rate (script S4)', () async {
      final first = DateTime(2020, 1, 5);
      await run(
          plain(
              uid: 's4',
              principal: 600000,
              rate: 10,
              months: 60,
              emi: 15000,
              first: first,
              type: LoanInterestType.flatRate),
          60,
          first,
          {1: (10000, 5000), 30: (10000, 5000), 60: (10000, 5000)});
    });

    test('interest only first six months (script S5)', () async {
      final first = DateTime(2020, 1, 5);
      await run(
          plain(
              uid: 's5',
              principal: 500000,
              rate: 12,
              months: 48,
              emi: 14638,
              first: first,
              type: LoanInterestType.interestOnlyFirst,
              io: 6),
          48,
          first,
          {1: (0, 5000), 6: (0, 5000), 7: (9638, 5000), 30: (12116.54, 2521.46), 48: (14483.46, 144.83)});
    });

    test('parts, monthly interest (script S1)', () async {
      await run(fedAll(), 109, fed1, {
        1: (2138.17, 13701.83),
        40: (2880.06, 12959.94),
        109: (4878.28, 10961.72),
      });
    });

    test('parts, daily interest (script S1 daily)', () async {
      await run(fedAll(daily: true), 109, fed1, {
        1: (1875, 13965),
        40: (2625, 13215),
        41: (3923, 11917),
        109: (4658, 11182),
      });
    });
  });

  group('A4 EMI count', () {
    test('112 of 265 style count is right: EMI 15,840 is under the 240-month EMI (script)', () async {
      // Script: 240-month EMI on 17,87,195 is 16,310.45; at 15,840 it takes 262.21 months.
      final l = await create(fedAll());
      await LoanService(isar).addPastEmis(l, now: now);
      final rec = await records(l);
      final st = loanStatus(await reload(l), rec.linked, now: now);
      expect(st.totalEmis, 263);
      expect(loanGotLonger(await reload(l), st), isTrue);
    });

    test('no explanation for a loan with no parts or one that ends on time', () async {
      final st = loanStatus(fedAll()..releasedInParts = false, const [], now: now);
      expect(loanGotLonger(fedAll()..releasedInParts = false, st), isFalse);
      final l = fedAll()..emiAmount = 16400;
      expect(loanGotLonger(l, loanStatus(l, const [], now: now)), isFalse);
    });
  });

  group('A2 a release after the loan was paid off', () {
    test('the schedule keeps applying it (script S6)', () {
      final days = [
        for (var i = 0; i < 40; i++) emiDay(DateTime(2020, 1, 5), i + 1),
      ];
      List<AmortRow> rows({bool release = true}) => amortize(
            principal: 100000,
            rate: 12,
            months: 12,
            emiDays: days,
            emi: 8885,
            events: [
              if (release) AmortEvent(20210320, AmortEventKind.release, amount: 50000),
            ],
          ).rows;
      expect(rows(release: false).length, 12);
      final r = rows();
      expect(r.length, 18);
      expect(r[11].balance, 0);
      expect((r[12].index, r[12].day), (13, 20210405));
      expect(r[12].interest, closeTo(500, 1e-6));
      expect(r[12].balance, closeTo(41615, 1e-6));
      expect(r[13].interest, closeTo(416.15, 1e-6));
      expect(r.last.payment, closeTo(7300.35, 0.01));
      expect(r.last.balance, 0);
    });
  });
}
