import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';

import 'loan_solver_table.dart';

List<int> monthlyDays(DateTime first, int n) => upcomingOccurrences(
        scheduleFrom(start: first, unit: ScheduleUnit.month),
        limit: n)
    .map((o) => o.day)
    .toList();

void main() {
  group('combination table (specs/vnext/loan-solver.md)', () {
    for (final row in loanSolverTable) {
      test(row.id, row.check);
    }
  });

  group('design demo figures', () {
    test('home loan: EMI, month 1 split', () {
      final s = solveLoan(principal: 2500000, rate: 8.5, months: 240);
      expect(s.emi.round(), 21696);
      final a = amortize(
          principal: 2500000,
          rate: 8.5,
          months: 240,
          emiDays: monthlyDays(DateTime(2017, 4, 5), 240));
      // What an EMI transaction saves: rounded parts that add up exactly.
      final split = roundedSplit(a.rows.first.payment, a.rows.first.interest, 0);
      expect(split.interest, 17708);
      expect(split.principal, 3988);
      expect(a.rows.length, 240);
      expect(a.rows.last.balance, 0);
    });

    test('flat: 5L at 9% for 5 years', () {
      expect(flatEmi(500000, 9, 60).round(), 12083);
      expect(flatInterest(500000, 9, 60), 225000);
      expect((calculateEmi(500000, 9, 60) * 60 - 500000).round(), 122751);
    });

    test('interest-only first: 4L at 9.5%, 12 months then 60', () {
      final s = solveLoan(
          principal: 400000,
          rate: 9.5,
          months: 72,
          kind: RateKind.interestOnlyFirst,
          ioMonths: 12);
      expect(s.ioEmi.round(), 3167);
      expect(s.emi.round(), 8401);
      final a = amortize(
          principal: 400000,
          rate: 9.5,
          months: 72,
          kind: RateKind.interestOnlyFirst,
          ioMonths: 12,
          emiDays: monthlyDays(DateTime(2026, 1, 1), 72));
      expect(a.rows.take(12).every((r) => r.interestOnly && r.principal == 0),
          isTrue);
      expect(a.rows[11].balance, 400000);
      expect(a.rows.last.balance, 0);
      expect(a.rows.length, 72);
    });

    test('swap: EMI 22,000 makes principal 25,35,078', () {
      final s = solveLoan(rate: 8.5, months: 240, emi: 22000);
      expect(s.principal.round(), 2535078);
      expect(s.calculated, LoanField.principal);
      expect((22000 * 240 - s.principal).round(), 2744922);
    });

    test('mismatch: EMI 21,816 is 120 more than calculated', () {
      final s = solveLoan(
          principal: 2500000, rate: 8.5, months: 240, emi: 21816);
      expect(s.mismatch.round(), 120);
      expect(s.emi, 21816);
    });

    test('run 1: 115 EMIs paid by 20 Oct 2026', () {
      final days = monthlyDays(DateTime(2017, 4, 5), 240);
      final a = amortize(
          principal: 2500000, rate: 8.5, months: 240, emiDays: days);
      final o = openingFromOriginal(a, 20261021);
      expect(o.emisPaid, 115);
      expect((o.principalPaid + o.outstanding).round(), 2500000);
    });

    test('run 2: 15,63,554 at 8.25% with EMI 21,696 has 100 EMIs left', () {
      expect(emisLeftFor(1563554, 8.25, 21696), 100);
    });
  });

  group('validation', () {
    test('EMI at or below month-1 interest is invalid', () {
      final s = solveLoan(principal: 2500000, rate: 8.5, emi: 17708);
      expect(s.error, LoanError.emiTooLow);
      expect(s.firstMonthInterest.round(), 17708);
    });

    test('0% is valid: EMI = principal / months', () {
      for (final k in RateKind.values) {
        final s = solveLoan(
            principal: 120000, rate: 0, months: 24, kind: k, ioMonths: 0);
        expect(s.ok, isTrue);
        expect(s.emi, 5000);
      }
      expect(solveLoan(principal: 120000, months: 24, emi: 5000).rate, 0);
    });

    test('needs three of four', () {
      expect(solveLoan(principal: 1, rate: 1).error, LoanError.missingInputs);
    });

    test('EMI × months below principal has no rate', () {
      expect(solveLoan(principal: 100000, months: 10, emi: 9000).error,
          LoanError.totalTooLow);
    });

    test('rate solve converges within limits across a wide grid', () {
      final rnd = Random(3);
      for (var i = 0; i < 300; i++) {
        final p = 1000 + rnd.nextDouble() * 5e7;
        final r = rnd.nextDouble() * 36;
        final n = 1 + rnd.nextInt(360);
        final emi = calculateEmi(p, r, n);
        final s = solveLoan(principal: p, months: n, emi: emi);
        expect(s.ok, isTrue, reason: '$p $r $n');
        expect((calculateEmi(p, s.rate, n) - emi).abs() / emi, lessThan(1e-9));
      }
    });
  });

  group('events', () {
    final days = monthlyDays(DateTime(2025, 1, 5), 400);

    test('prepayment, reduce tenure: same EMI, fewer EMIs, less interest', () {
      final base = amortize(
          principal: 2500000, rate: 8.5, months: 240, emiDays: days);
      final pre = amortize(
          principal: 2500000,
          rate: 8.5,
          months: 240,
          emiDays: days,
          events: [AmortEvent(20260320, AmortEventKind.prepayment, amount: 200000)]);
      expect(pre.rows.length, lessThan(base.rows.length));
      expect(pre.rows[30].payment.round(), base.rows[30].payment.round());
      expect(pre.totalInterest, lessThan(base.totalInterest));
      expect(pre.rows.last.balance, 0);
    });

    test('prepayment, reduce EMI: same end, lower EMI', () {
      final pre = amortize(
          principal: 2500000,
          rate: 8.5,
          months: 240,
          emiDays: days,
          events: [
            AmortEvent(20260320, AmortEventKind.prepayment,
                amount: 200000, adjustEmi: true)
          ]);
      expect(pre.rows.length, 240);
      expect(pre.rows[20].payment, lessThan(pre.rows[10].payment));
      expect(pre.rows.last.balance, 0);
    });

    test('rate change: adjust EMI keeps the end, adjust tenure keeps the EMI',
        () {
      final emiAdj = amortize(
          principal: 2500000,
          rate: 8.5,
          months: 240,
          emiDays: days,
          events: [
            AmortEvent(20260205, AmortEventKind.rateChange,
                newRate: 8.25, adjustEmi: true)
          ]);
      expect(emiAdj.rows.length, 240);
      expect(emiAdj.rows[20].payment, lessThan(emiAdj.rows[5].payment));
      final tenAdj = amortize(
          principal: 2500000,
          rate: 8.5,
          months: 240,
          emiDays: days,
          events: [AmortEvent(20260205, AmortEventKind.rateChange, newRate: 8.25)]);
      expect(tenAdj.rows.length, lessThan(240));
      expect(tenAdj.rows[20].payment.round(), tenAdj.rows[5].payment.round());
      expect(tenAdj.rows[20].rate, 8.25);
    });

    test('a charge never changes the outstanding amount', () {
      final base = amortize(
          principal: 500000, rate: 10, months: 60, emiDays: days);
      final ch = amortize(
          principal: 500000,
          rate: 10,
          months: 60,
          emiDays: days,
          events: [AmortEvent(20250610, AmortEventKind.charge, amount: 4000)]);
      expect(ch.balanceOn(20260101), base.balanceOn(20260101));
    });

    test('prepayment then rate change in date order', () {
      final a = amortize(
          principal: 2500000,
          rate: 8.5,
          months: 240,
          emiDays: days,
          events: [
            AmortEvent(20260205, AmortEventKind.rateChange, newRate: 8.25),
            AmortEvent(20250320, AmortEventKind.prepayment, amount: 200000),
          ]);
      expect(a.events.first.kind, AmortEventKind.prepayment);
      expect(a.rows.last.balance, 0);
    });

    test('opening adjustment shifts the balance from its date', () {
      final a = amortize(
          principal: 1000000,
          rate: 9,
          months: 120,
          emiDays: days,
          events: [AmortEvent(20260101, AmortEventKind.adjustment, amount: -5000)]);
      final b = amortize(principal: 1000000, rate: 9, months: 120, emiDays: days);
      expect((b.balanceOn(20251231) - a.balanceOn(20251231)).abs(), lessThan(1e-6));
      expect(a.balanceOn(20260201), lessThan(b.balanceOn(20260201) - 4900));
    });
  });

  test('rounded split always adds up to the payment', () {
    final rnd = Random(9);
    for (var i = 0; i < 1000; i++) {
      final pay = rnd.nextDouble() * 100000;
      final interest = rnd.nextDouble() * pay;
      for (final d in [0, 2, 3]) {
        final s = roundedSplit(pay, interest, d);
        final f = pow(10, d);
        expect(((s.principal + s.interest) * f).round(), (s.payment * f).round());
      }
    }
  });
}
