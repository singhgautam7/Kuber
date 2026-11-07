// November release A2 / A6: the pre-EMI ledger against the real Federal Bank
// statement. Expected interest is the bank's, re-derived by hand in
// specs/nov-release/loan-tests.md with an independent script.
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';

const statementInterest = [3915, 3545, 5816, 8364, 11776, 12645, 13530, 13636, 13299];

LoanRelease release(DateTime d, double amount) => LoanRelease()
  ..date = d
  ..amount = amount;

LoanEvent extra(DateTime d, double amount) => LoanEvent()
  ..kind = LoanEventKind.prepayment
  ..date = d
  ..amount = amount;

LoanEvent chargeAdded(DateTime d, double amount) => LoanEvent()
  ..kind = LoanEventKind.chargeAdded
  ..date = d
  ..amount = amount;

Loan federal() => Loan()
  ..uid = 'federal'
  ..name = 'Home'
  ..loanType = 'home'
  ..lenderName = 'Federal Bank'
  ..accountId = '1'
  ..categoryId = '1'
  ..principalAmount = 1700000
  ..emiAmount = 15782
  ..billDate = 13
  ..startDate = DateTime(2017, 11, 13)
  ..createdAt = DateTime(2017, 1, 12)
  ..updatedAt = DateTime(2017, 1, 12)
  ..mode = LoanMode.advanced
  ..annualRate = 9.2
  ..tenureMonths = 240
  ..loanStartDate = DateTime(2017, 1, 12)
  ..releasedInParts = true
  ..preEmiMode = LoanPreEmi.addToLoan
  ..preEmiCycleDay = 12
  ..releases = [
    release(DateTime(2017, 1, 12), 500000),
    release(DateTime(2017, 3, 28), 500000),
    release(DateTime(2017, 5, 6), 500000),
    release(DateTime(2017, 6, 19), 200000),
  ]
  ..events = [
    chargeAdded(DateTime(2017, 1, 21), 1328),
    extra(DateTime(2017, 1, 23), 1328),
    extra(DateTime(2017, 3, 3), 5000),
    extra(DateTime(2017, 5, 5), 9500),
    extra(DateTime(2017, 10, 13), 12435),
  ]
  ..schedule = (scheduleFrom(
      start: DateTime(2017, 11, 13), endType: ScheduleEnd.afterCount, endCount: 240)
    ..autoRecord = false)
  ..dataVersion = 1;

void main() {
  group('Federal Bank statement', () {
    final pre = loanAmortization(federal())!.preEmi!;

    test('cycle dates are the 12th, nine of them', () {
      expect(pre.cycles.map((c) => c.day), [
        20170212, 20170312, 20170412, 20170512, 20170612, 20170712, 20170812, 20170912, 20171012,
      ]);
    });

    test('cycle 1 within 10 rupees, every later cycle within 1', () {
      expect((pre.cycles.first.interest - statementInterest.first).abs(), lessThanOrEqualTo(10));
      for (var i = 1; i < 9; i++) {
        expect((pre.cycles[i].interest - statementInterest[i]).abs(), lessThanOrEqualTo(1),
            reason: 'cycle ${i + 1}: ${pre.cycles[i].interest}');
      }
    });

    test('total and outstanding before the first EMI within 15 rupees', () {
      expect((pre.addedInterest - 86526).abs(), lessThanOrEqualTo(15));
      expect((pre.balance - 1759591).abs(), lessThanOrEqualTo(15));
      expect(pre.addedCharges, 1328);
    });

    test('the balance follows each dated change', () {
      final a = loanAmortization(federal())!;
      expect(a.balanceOn(20170120), 500000);
      expect(a.balanceOn(20170122), 501328);
      expect(a.balanceOn(20170123), 500000);
      expect(a.balanceOn(20171012), pre.balance + 12435);
      expect(a.balanceOn(20171013), pre.balance);
    });

    test('editing Interest added to 59,591 gives exactly 17,59,591', () {
      final l = federal()
        ..preEmiOverride = 59591
        ..preEmiCalculated = pre.calculatedAdded;
      final a = loanAmortization(l)!;
      expect(a.openingBalance, 1759591);
      expect(a.preEmi!.addedCharges, 1328);
      // Interest the bank charged: the edited net figure + payments - charge.
      expect(a.preEmi!.addedInterest, closeTo(86526, 0.001));
      expect(LoanService.preEmiNotice(l), isNull);
    });

    test('total cost shows the charge and the interest added', () {
      final st = loanStatus(federal(), const [], now: DateTime(2017, 10, 20));
      expect(st.addedCharges, 1328);
      expect(st.addedInterest, closeTo(86519, 1));
      expect(st.outstanding, closeTo(1759584, 1));
    });

    test('the EMI split after that keeps its monthly maths', () {
      final a = loanAmortization(federal())!;
      final first = a.rows.first;
      expect(first.day, 20171113);
      expect(first.interest, closeTo(pre.balance * 9.2 / 1200, 1e-6));
      expect(first.payment, 15782);
    });
  });

  group('cycle dates', () {
    test('the last cycle stops one month before the first EMI', () {
      expect(preEmiCycleDays(20240105, 20240405, 5), [20240205, 20240305]);
    });

    test('a broken first period charges on the next cycle date', () {
      expect(preEmiCycleDays(20240120, 20240412, 12), [20240212, 20240312]);
    });

    test('short months clamp', () {
      expect(preEmiCycleDays(20230131, 20230531, 31), [20230228, 20230331, 20230430]);
    });

    test('no full cycle before the first EMI: none', () {
      expect(preEmiCycleDays(20240105, 20240205, 5), isEmpty);
    });
  });
}
