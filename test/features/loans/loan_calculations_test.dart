import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/loans/utils/loan_calculations.dart';

import '../../helpers/test_factories.dart';

void main() {
  /// Helper to build a loan payment transaction.
  makeLoanPayment({
    required String loanUid,
    required double amount,
    String name = 'EMI — Test Loan',
  }) {
    return makeTransaction(
      name: name,
      amount: amount,
      type: 'expense',
      linkedRuleId: loanUid,
      linkedRuleType: 'loan',
    );
  }

  group('computeTotalPaid', () {
    test('sums all expense txns linked to loan', () {
      final txns = [
        makeLoanPayment(loanUid: 'uid1', amount: 15000),
        makeLoanPayment(loanUid: 'uid1', amount: 15000),
        makeLoanPayment(loanUid: 'uid1', amount: 15000),
      ];
      expect(computeTotalPaid('uid1', txns), 45000);
    });

    test('returns 0.0 when no payments', () {
      expect(computeTotalPaid('uid1', []), 0.0);
    });

    test('ignores transactions for other loans', () {
      final txns = [
        makeLoanPayment(loanUid: 'uid1', amount: 15000),
        makeLoanPayment(loanUid: 'uid2', amount: 20000),
      ];
      expect(computeTotalPaid('uid1', txns), 15000);
    });
  });

  group('computeRemaining', () {
    test('principal - totalPaid', () {
      final loan = makeLoan(uid: 'uid1', principalAmount: 500000);
      final txns = [
        makeLoanPayment(loanUid: 'uid1', amount: 100000),
      ];
      expect(computeRemaining(loan, txns), 400000);
    });

    test('can go below 0 if overpaid', () {
      final loan = makeLoan(uid: 'uid1', principalAmount: 100000);
      final txns = [
        makeLoanPayment(loanUid: 'uid1', amount: 150000),
      ];
      expect(computeRemaining(loan, txns), -50000);
    });
  });

  group('computeProgress', () {
    test('0.0 at start', () {
      final loan = makeLoan(uid: 'uid1', principalAmount: 500000);
      expect(computeProgress(loan, []), 0.0);
    });

    test('0.2 after 1,00,000 paid of 5,00,000', () {
      final loan = makeLoan(uid: 'uid1', principalAmount: 500000);
      final txns = [
        makeLoanPayment(loanUid: 'uid1', amount: 100000),
      ];
      expect(computeProgress(loan, txns), 0.2);
    });

    test('clamped to 1.0 if overpaid', () {
      final loan = makeLoan(uid: 'uid1', principalAmount: 100000);
      final txns = [
        makeLoanPayment(loanUid: 'uid1', amount: 200000),
      ];
      expect(computeProgress(loan, txns), 1.0);
    });

    test('0.0 when principalAmount is 0', () {
      final loan = makeLoan(uid: 'uid1', principalAmount: 0);
      expect(computeProgress(loan, []), 0.0);
    });
  });

  group('computeNextDueDate', () {
    test('returns date in current month if billDate not passed', () {
      final now = DateTime.now();
      // Use day 28 which is always in the future or today
      final loan = makeLoan(uid: 'uid1', billDate: 28);
      final nextDue = computeNextDueDate(loan);
      expect(nextDue, isNotNull);
      if (now.day <= 28) {
        expect(nextDue!.day, 28);
        expect(nextDue.month, now.month);
      }
    });

    test('returns next month date if billDate already passed', () {
      final now = DateTime.now();
      // Use day 1 which is usually in the past
      final loan = makeLoan(uid: 'uid1', billDate: 1);
      final nextDue = computeNextDueDate(loan);
      expect(nextDue, isNotNull);
      if (now.day > 1) {
        // Should be next month
        if (now.month == 12) {
          expect(nextDue!.month, 1);
          expect(nextDue.year, now.year + 1);
        } else {
          expect(nextDue!.month, now.month + 1);
        }
      }
    });

    test('returns null if loan isCompleted', () {
      final loan = makeLoan(uid: 'uid1', isCompleted: true);
      expect(computeNextDueDate(loan), isNull);
    });
  });

  group('totalOutstanding', () {
    test('sums remaining of non-completed loans only', () {
      final l1 = makeLoan(uid: 'uid1', principalAmount: 500000);
      final l2 = makeLoan(uid: 'uid2', principalAmount: 200000, isCompleted: true);
      final l3 = makeLoan(uid: 'uid3', principalAmount: 300000);
      final txns = [
        makeLoanPayment(loanUid: 'uid1', amount: 100000),
        makeLoanPayment(loanUid: 'uid3', amount: 50000),
      ];
      // Active remaining: (500000 - 100000) + (300000 - 50000) = 400000 + 250000 = 650000
      expect(totalOutstanding([l1, l2, l3], txns), 650000);
    });
  });

  group('totalPaidAllLoans', () {
    test('sums across all loans including completed', () {
      final l1 = makeLoan(uid: 'uid1', principalAmount: 500000);
      final l2 = makeLoan(uid: 'uid2', principalAmount: 200000, isCompleted: true);
      final txns = [
        makeLoanPayment(loanUid: 'uid1', amount: 100000),
        makeLoanPayment(loanUid: 'uid2', amount: 200000),
      ];
      expect(totalPaidAllLoans([l1, l2], txns), 300000);
    });
  });
}
