// Loan accuracy E1: S1 to S17 on the pure engine. Expected values come from
// the small reference calculation below (plain month-by-month loops and the
// closed-form EMI), never from the code under test.
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/money_math/loan_math.dart' show RateKind, roundedSplit;
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

// ── Reference ───────────────────────────────────────────────────────────

double refEmi(double p, double annual, int n) {
  final r = annual / 1200;
  if (r == 0) return p / n;
  final f = math.pow(1 + r, n);
  return p * r * f / (f - 1);
}

/// Month-by-month reducing balance: [(interest, principal, balance)], with
/// optional per-month overrides of (principal, interest).
List<(double, double, double)> refRows(double p, double annual, double emi,
    {int max = 600, Map<int, (double, double)> overrides = const {}}) {
  final r = annual / 1200;
  var bal = p;
  final out = <(double, double, double)>[];
  for (var m = 1; m <= max && bal > 1e-6; m++) {
    double i = bal * r, pr = emi - i;
    if (pr > bal || bal - pr < math.max(0.005, emi * 0.01)) pr = bal;
    final o = overrides[m];
    if (o != null) {
      pr = o.$1;
      i = o.$2;
    }
    bal -= pr;
    out.add((i, pr, bal));
  }
  return out;
}

// ── Fixture helpers ─────────────────────────────────────────────────────

final now = DateTime(2026, 10, 26, 12);
final todayK = dayKey(now);

/// First EMI on the 5th, [monthsAgo] months before now (month 1).
Loan loan({
  double principal = 2500000,
  double rate = 8.5,
  int months = 240,
  int monthsAgo = 0,
  LoanInterestType type = LoanInterestType.reducingBalance,
  int io = 0,
  double? emi,
  List<LoanEvent> events = const [],
}) {
  final first = DateTime(2026, 10 - monthsAgo + 1, 5);
  final created = DateTime(first.year, first.month, first.day - 3);
  final kind = switch (type) {
    LoanInterestType.reducingBalance => RateKind.reducing,
    LoanInterestType.flatRate => RateKind.flat,
    LoanInterestType.interestOnlyFirst => RateKind.interestOnlyFirst,
  };
  return Loan()
    ..uid = 'L'
    ..name = 'Home'
    ..loanType = 'home'
    ..lenderName = 'Bank'
    ..accountId = '1'
    ..categoryId = '1'
    ..principalAmount = principal
    ..emiAmount = emi ?? 0
    ..billDate = 5
    ..startDate = first
    ..createdAt = created
    ..updatedAt = created
    ..mode = LoanMode.advanced
    ..interestType = type
    ..interestOnlyMonths = io
    ..annualRate = rate
    ..tenureMonths = months
    ..events = [...events]
    ..dataVersion = 1
    ..schedule = (scheduleFrom(start: first, endType: ScheduleEnd.afterCount, endCount: months)
      ..autoRecord = true
      ..processedThrough = addDays(todayK, -1))
    ..emiAmount = emi ?? regularEmiFor(kind, principal, rate, months, io);
}

double regularEmiFor(RateKind k, double p, double rate, int n, int io) => switch (k) {
      RateKind.reducing => refEmi(p, rate, n),
      RateKind.interestOnlyFirst => refEmi(p, rate, n - io),
      RateKind.flat => (p + p * rate / 100 * n / 12) / n,
    };

int emiDay(Loan l, int month) {
  final s = l.schedule!.startDate!;
  return dayKey(DateTime(s.year, s.month + month - 1, 5));
}

Transaction emiTxn(Loan l, int month, double amount, double principal, double interest,
        {bool edited = false}) =>
    Transaction()
      ..id = month
      ..name = 'EMI - ${l.name}'
      ..amount = amount
      ..type = 'expense'
      ..categoryId = '1'
      ..accountId = '1'
      ..createdAt = dayOf(emiDay(l, month))
      ..updatedAt = dayOf(emiDay(l, month))
      ..nameLower = 'emi'
      ..linkedRuleType = 'loan'
      ..linkedRuleId = l.uid
      ..sourceType = 'loan'
      ..sourceId = l.uid
      ..subType = TxnSubType.loanRepayment
      ..occurrenceDate = emiDay(l, month)
      ..principalPart = principal
      ..interestPart = interest
      ..splitEdited = edited;

/// What the processor records for months 1..[n] (rounded reference split).
List<Transaction> recorded(Loan l, int n, List<(double, double, double)> ref, double emi) => [
      for (var m = 1; m <= n; m++)
        (() {
          final sp = roundedSplit(ref[m - 1].$1 + ref[m - 1].$2, ref[m - 1].$1, 2);
          return emiTxn(l, m, sp.payment, sp.principal, sp.interest);
        })(),
    ];

LoanEvent adjustmentEvent(DateTime d, double amount,
        {LoanAdjust adjust = LoanAdjust.tenure,
        LoanAdjustReason reason = LoanAdjustReason.matchBank}) =>
    LoanEvent()
      ..kind = LoanEventKind.adjustment
      ..date = d
      ..amount = amount
      ..adjust = adjust
      ..reason = reason;

void main() {
  const tol = 1e-6;
  final emi = refEmi(2500000, 8.5, 240);
  final ref = refRows(2500000, 8.5, emi);

  test('S1 25 lakh at 8.5% for 20 years matches the closed form', () {
    final l = loan(monthsAgo: 6);
    final st = loanStatus(l, const [], now: now);
    // After 6 EMIs: P(1+r)^k - EMI((1+r)^k - 1) / r.
    final r = 8.5 / 1200, f = math.pow(1 + r, 6);
    expect(st.outstanding, closeTo(2500000 * f - emi * (f - 1) / r, tol));
    expect(st.emisPaid, 6);
    expect(st.totalEmis, 240);
    expect(st.totalInterest, closeTo(emi * 240 - 2500000, 1e-4));
    expect(st.nextRow!.interest, closeTo(ref[6].$1, tol));
  });

  group('A2 edited EMI splits', () {
    final l = loan(monthsAgo: 6);
    final base = recorded(l, 6, ref, emi);

    test('S2 month 5 principal up by 100: outstanding 100 lower from month 5', () {
      final m5 = base[4];
      final edited = [
        ...base.take(4),
        emiTxn(l, 5, m5.amount, m5.principalPart! + 100, m5.interestPart! - 100, edited: true),
        // Month 6 was recorded before the edit: it keeps its own split.
        base[5],
      ];
      final before = loanAmortization(l, linked: base)!;
      final after = loanAmortization(l, linked: edited)!;
      for (var m = 1; m <= 4; m++) {
        expect(after.rows[m - 1].balance, before.rows[m - 1].balance, reason: 'month $m');
      }
      // Unedited EMIs count at their exact value (rounding only): 0.01.
      expect(after.rows[4].balance, closeTo(before.rows[4].balance - 100, 0.01));
      expect(after.rows[4].edited, isTrue);
      // Month 6 recorded: same principal as recorded, so still 100 lower.
      expect(after.rows[5].principal, closeTo(base[5].principalPart!, tol));
      expect(loanStatus(l, edited, now: now).outstanding,
          closeTo(loanStatus(l, base, now: now).outstanding! - 100, 0.02));
      // Month 7 (the next EMI) is projected from the new outstanding.
      final out6 = after.rows[5].balance;
      expect(after.rows[6].interest, closeTo(out6 * 8.5 / 1200, tol));
    });

    test('S2 future: editing the latest EMI projects the next one from it', () {
      final l5 = loan(monthsAgo: 5);
      final b5 = recorded(l5, 5, ref, emi);
      final m5 = b5[4];
      final edited = [
        ...b5.take(4),
        emiTxn(l5, 5, m5.amount, m5.principalPart! + 100, m5.interestPart! - 100, edited: true),
      ];
      final a = loanAmortization(l5, linked: edited)!;
      final bal5 = 2500000 - [for (final t in edited) t.principalPart!].reduce((x, y) => x + y);
      expect(a.rows[4].balance, closeTo(bal5, 0.05));
      expect(a.rows[5].interest, closeTo(a.rows[4].balance * 8.5 / 1200, 1e-9));
      expect(a.rows[5].principal, closeTo(emi - a.rows[4].balance * 8.5 / 1200, 1e-9));
    });

    test('S3 month 5 interest edited: principal fills itself, outstanding moves the same', () {
      final m5 = base[4];
      final t = emiTxn(l, 5, m5.amount, m5.principalPart!, m5.interestPart!);
      LoanService.applyEditedSplit(t,
          amount: m5.amount, principal: m5.amount - (m5.interestPart! - 250), interest: m5.interestPart! - 250);
      expect(t.principalPart! + t.interestPart!, closeTo(m5.amount, 1e-9));
      expect(t.splitEdited, isTrue);
      final st = loanStatus(l, [...base.take(4), t, base[5]], now: now);
      expect(st.outstanding, closeTo(loanStatus(l, base, now: now).outstanding! - 250, 0.02));
    });

    test('S4 month 5 EMI amount changed: interest stays, principal absorbs', () {
      final m5 = base[4];
      final t = emiTxn(l, 5, m5.amount, m5.principalPart!, m5.interestPart!);
      LoanService.applyEditedSplit(t,
          amount: m5.amount + 1000, principal: m5.principalPart! + 1000, interest: m5.interestPart!);
      expect(t.interestPart, m5.interestPart);
      final st = loanStatus(l, [...base.take(4), t, base[5]], now: now);
      expect(st.outstanding, closeTo(loanStatus(l, base, now: now).outstanding! - 1000, 0.02));
    });

    test('S5 deleting the edited EMI returns its principal', () {
      final m5 = base[4];
      final edited = emiTxn(l, 5, m5.amount, m5.principalPart! + 100, m5.interestPart! - 100, edited: true);
      final withEdit = [...base.take(4), edited, base[5]];
      final without = [...base.take(4), base[5]];
      final s2 = loanStatus(l, withEdit, now: now);
      final s5 = loanStatus(l, without, now: now, deletedDays: {emiDay(l, 5)});
      expect(s5.outstanding, closeTo(s2.outstanding! + edited.principalPart!, 1e-4));
      expect(s5.emisPaid, 5);
    });

    test('S13 count only interest uses the edited interest', () {
      final t = emiTxn(l, 5, base[4].amount, base[4].principalPart!, base[4].interestPart!)
        ..spendInterestOnly = true;
      LoanService.applyEditedSplit(t,
          amount: t.amount, principal: t.amount - 9000, interest: 9000);
      expect(t.spendAmount, 9000);
    });
  });

  group('A3 Update outstanding', () {
    test('S6 today, Match bank statement, Keep EMI: end moves, EMI same', () {
      final l = loan(monthsAgo: 12);
      final before = loanStatus(l, const [], now: now);
      const target = 2300000.0;
      l.events = [adjustmentEvent(dayOf(todayK), target - before.outstanding!)];
      final st = loanStatus(l, const [], now: now);
      expect(st.outstanding, closeTo(target, 1e-6));
      expect(st.nextAmount, closeTo(emi, 1e-6));
      // Reference: keep paying the same EMI on the new balance.
      final rows = refRows(target, 8.5, emi);
      expect(st.totalEmis, 12 + rows.length);
      final remaining = rows.fold(0.0, (s, r) => s + r.$1);
      final a = loanAmortization(l)!;
      final projected = a.rows.where((r) => r.day > todayK).fold(0.0, (s, r) => s + r.interest);
      expect(projected, closeTo(remaining, 1e-4));
      expect(st.endDay, isNot(before.endDay));
    });

    test('S7 today, Keep end date: EMI changes, end date same', () {
      final l = loan(monthsAgo: 12);
      final before = loanStatus(l, const [], now: now);
      const target = 2300000.0;
      l.events = [adjustmentEvent(dayOf(todayK), target - before.outstanding!, adjust: LoanAdjust.emi)];
      final st = loanStatus(l, const [], now: now);
      expect(st.outstanding, closeTo(target, 1e-6));
      expect(st.endDay, before.endDay);
      expect(st.nextAmount, closeTo(refEmi(target, 8.5, 228), 1e-6));
    });

    test('S8 the reported case: 9 months of interest added, principal paid in between', () {
      // Disbursed 30 lakh; first EMI 9 months later. The bank added 9 months
      // of interest; he paid 50,000 toward principal in month 3.
      const p = 3000000.0, rate = 9.0;
      final l = loan(principal: p, rate: rate, months: 240, monthsAgo: 4);
      final first = dayOf(emiDay(l, 1));
      final r = rate / 1200;
      var bal = p, added = 0.0;
      for (var m = 1; m <= 9; m++) {
        if (m == 4) bal -= 50000; // paid in month 3, before month 4's interest
        final i = bal * r;
        added += i;
        bal += i; // capitalised
      }
      l.events = [
        LoanEvent()
          ..kind = LoanEventKind.prepayment
          ..date = DateTime(first.year, first.month - 6, 20)
          ..amount = 50000
          ..adjust = LoanAdjust.tenure,
        adjustmentEvent(DateTime(first.year, first.month, 1), added,
            reason: LoanAdjustReason.interestAdded),
      ];
      // Expected: from the capitalised balance, 4 regular EMIs.
      final start = p - 50000 + added;
      final rows = refRows(start, rate, l.emiAmount);
      final st = loanStatus(l, const [], now: now);
      expect(st.outstanding, closeTo(rows[3].$3, 1e-4));
      expect(st.addedInterest, closeTo(added, 1e-6));
      final all = refRows(start, rate, l.emiAmount);
      expect(st.totalInterest, closeTo(all.fold(0.0, (s, x) => s + x.$1) + added, 1e-3));
      expect(st.principalPaid, closeTo(50000 + rows.take(4).fold(0.0, (s, x) => s + x.$2), 1e-4));
    });

    test('dated on an EMI day: the outstanding that day is exactly the figure entered', () {
      final l = loan(monthsAgo: 12);
      final day = emiDay(l, 6);
      final kuber = loanAmortization(l)!.balanceOn(day); // after that EMI
      l.events = [adjustmentEvent(dayOf(day), 10000)];
      final a = loanAmortization(l)!;
      expect(a.balanceOn(day), closeTo(kuber + 10000, 1e-9));
      // Month 6 itself is unchanged; month 7 pays interest on the new figure.
      expect(a.rows[5].interest, closeTo(ref[5].$1, 1e-6));
      expect(a.rows[6].interest, closeTo((kuber + 10000) * 8.5 / 1200, 1e-6));
    });

    test('S17 an adjustment to 0 ends the loan; a negative outstanding is rejected', () {
      final l = loan(monthsAgo: 12);
      final before = loanStatus(l, const [], now: now);
      l.events = [adjustmentEvent(dayOf(todayK), -before.outstanding!)];
      final st = loanStatus(l, const [], now: now);
      expect(st.outstanding, 0);
      expect(st.nextRow, isNull);
      expect(outstandingError(0), OutstandingCheck.closes);
      expect(outstandingError(-1), OutstandingCheck.negative);
      expect(outstandingError(1500), OutstandingCheck.ok);
    });
  });

  group('A4 adjustments in the past', () {
    final l = loan(monthsAgo: 30);
    final base = recorded(l, 30, ref, emi);
    final adjDay = DateTime(2024, 10, 10); // after month 6 (5 Oct 2024)

    test('S10 Keep as is: recorded EMIs unchanged, only the projection moves', () {
      final la = l.copy()..events = [adjustmentEvent(adjDay, 40000)];
      final a = loanAmortization(la, linked: base)!;
      for (var m = 1; m <= 30; m++) {
        // Before the adjustment they equal the calculation (rounding only);
        // after it they differ from it and are taken as recorded.
        final t = m <= 6 ? 0.006 : 1e-9;
        expect(a.rows[m - 1].principal, closeTo(base[m - 1].principalPart!, t));
        expect(a.rows[m - 1].interest, closeTo(base[m - 1].interestPart!, t));
      }
      final paid = base.fold(0.0, (s, t) => s + t.principalPart!);
      final st = loanStatus(la, base, now: now);
      expect(st.outstanding, closeTo(2500000 - paid + 40000, 0.05));
      expect(st.nextRow!.interest, closeTo(st.outstanding! * 8.5 / 1200, 1e-4));
    });

    test('S9 Recalculate: unedited later EMIs split again, the edited one untouched', () {
      final la = l.copy()..events = [adjustmentEvent(adjDay, 40000)];
      // Month 12 was edited to match the bank.
      final m12 = base[11];
      final linked = [
        for (final t in base)
          t.id == 12
              ? emiTxn(l, 12, m12.amount, m12.principalPart! - 300, m12.interestPart! + 300, edited: true)
              : t,
      ];
      final a = loanAmortization(la, linked: linked, recalculateFrom: dayKey(adjDay))!;
      // Reference: months 1-6 recorded, then +40,000, then interest on the
      // balance each month, month 12 as edited.
      var bal = 2500000.0;
      for (var m = 1; m <= 6; m++) {
        bal -= base[m - 1].principalPart!;
      }
      bal += 40000;
      for (var m = 7; m <= 30; m++) {
        final row = a.rows[m - 1];
        if (m == 12) {
          expect(row.principal, closeTo(m12.principalPart! - 300, 1e-9));
          bal -= m12.principalPart! - 300;
          continue;
        }
        final i = bal * 8.5 / 1200;
        // Months 1-6 count at their exact value: 3 paise at most.
        expect(row.interest, closeTo(i, 1e-3), reason: 'month $m');
        expect(row.principal, closeTo(base[m - 1].amount - i, 1e-3));
        bal -= base[m - 1].amount - i;
      }
      final p = LoanService.recalculatePreview(la, (linked: linked, deleted: <int>{}), dayKey(adjDay));
      expect(p.count, 23); // 24 later EMIs, one edited
      expect(p.newInterest, greaterThan(p.oldInterest));
    });
  });

  test('S11 extra payment before the first EMI and inside an interest-only period', () {
    final before = loan(monthsAgo: -2); // first EMI in 3 months
    before.events = [
      LoanEvent()
        ..kind = LoanEventKind.prepayment
        ..date = dayOf(todayK)
        ..amount = 100000
        ..adjust = LoanAdjust.tenure,
    ];
    expect(loanStatus(before, const [], now: now).outstanding, closeTo(2400000, 1e-9));

    final io = loan(type: LoanInterestType.interestOnlyFirst, io: 12, monthsAgo: 4);
    io.events = [
      LoanEvent()
        ..kind = LoanEventKind.prepayment
        ..date = dayOf(todayK)
        ..amount = 100000
        ..adjust = LoanAdjust.emi,
    ];
    final st = loanStatus(io, const [], now: now);
    expect(st.outstanding, closeTo(2400000, 1e-9));
    expect(st.nextRow!.interest, closeTo(2400000 * 8.5 / 1200, 1e-9));
    expect(st.nextRow!.principal, 0);
  });

  test('S12 rate change after an edited EMI: new rate from the edited outstanding', () {
    final l = loan(monthsAgo: 6);
    final base = recorded(l, 6, ref, emi);
    final m6 = base[5];
    final linked = [
      ...base.take(5),
      emiTxn(l, 6, m6.amount, m6.principalPart! + 5000 , m6.interestPart!, edited: true),
    ];
    l.events = [
      LoanEvent()
        ..kind = LoanEventKind.rateChange
        ..date = dayOf(todayK)
        ..newRate = 9.4
        ..adjust = LoanAdjust.tenure,
    ];
    final st = loanStatus(l, linked, now: now);
    final bal = 2500000 - linked.fold(0.0, (s, t) => s + t.principalPart!);
    expect(st.outstanding, closeTo(bal, 0.05));
    expect(st.nextRow!.interest, closeTo(st.outstanding! * 9.4 / 1200, 1e-9));
  });

  test('S14 flat rate with an edit and an adjustment', () {
    const p = 500000.0, rate = 10.0;
    final l = loan(principal: p, rate: rate, months: 36, monthsAgo: 4, type: LoanInterestType.flatRate);
    final interest = p * rate / 1200, part = p / 36;
    final linked = [
      for (var m = 1; m <= 4; m++)
        m == 3
            ? emiTxn(l, m, l.emiAmount, part + 500, interest - 500, edited: true)
            : emiTxn(l, m, l.emiAmount, double.parse(part.toStringAsFixed(2)),
                double.parse(interest.toStringAsFixed(2))),
    ];
    l.events = [adjustmentEvent(dayOf(todayK), 10000)];
    final st = loanStatus(l, linked, now: now);
    final paid = linked.fold(0.0, (s, t) => s + t.principalPart!);
    expect(st.outstanding, closeTo(p - paid + 10000, 0.01));
    // Flat: the month's interest stays on the original principal.
    expect(st.nextRow!.interest, closeTo(interest, 1e-9));
    expect(st.nextRow!.principal, closeTo(l.emiAmount - interest, 1e-9));
  });

  test('S15 interest-only first, adjustment during the interest-only months', () {
    final l = loan(type: LoanInterestType.interestOnlyFirst, io: 12, monthsAgo: 4);
    l.events = [adjustmentEvent(dayOf(todayK), 75000)];
    final st = loanStatus(l, const [], now: now);
    expect(st.outstanding, closeTo(2575000, 1e-9));
    expect(st.nextRow!.interest, closeTo(2575000 * 8.5 / 1200, 1e-9));
    expect(st.nextRow!.principal, 0);
  });

  test('S16 0% loan: interest edited away from 0, outstanding still right', () {
    final l = loan(principal: 120000, rate: 0, months: 24, monthsAgo: 3);
    final linked = [
      emiTxn(l, 1, 5000, 5000, 0),
      emiTxn(l, 2, 5000, 4800, 200, edited: true),
      emiTxn(l, 3, 5000, 5000, 0),
    ];
    final st = loanStatus(l, linked, now: now);
    expect(st.outstanding, closeTo(120000 - 14800, 1e-9));
    expect(st.interestPaid, closeTo(200, 1e-9));
  });
}
