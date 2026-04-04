import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ledger/utils/ledger_calculations.dart';

import '../../helpers/test_factories.dart';

void main() {
  /// Helper to build a payment transaction linked to a ledger.
  makePaymentTxn({
    required String ledgerUid,
    required double amount,
    String type = 'income',
    String linkedRuleType = 'lent',
  }) {
    return makeTransaction(
      name: 'Payment — Test',
      amount: amount,
      type: type,
      linkedRuleId: ledgerUid,
      linkedRuleType: linkedRuleType,
    );
  }

  /// Helper to build the initial transaction for a ledger.
  makeInitialTxn({
    required String ledgerUid,
    required double amount,
    String personName = 'John Doe',
    String type = 'expense',
    String linkedRuleType = 'lent',
  }) {
    return makeTransaction(
      name: 'Lent to $personName',
      amount: amount,
      type: type,
      linkedRuleId: ledgerUid,
      linkedRuleType: linkedRuleType,
    );
  }

  group('computePaid', () {
    test('sums only payment transactions, excludes initial', () {
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
        makePaymentTxn(ledgerUid: 'uid1', amount: 1000),
        makePaymentTxn(ledgerUid: 'uid1', amount: 500),
      ];
      expect(computePaid('uid1', txns), 1500);
    });

    test('returns 0 when no payments exist', () {
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
      ];
      expect(computePaid('uid1', txns), 0);
    });

    test('ignores transactions for other ledgers', () {
      final txns = [
        makePaymentTxn(ledgerUid: 'uid1', amount: 1000),
        makePaymentTxn(ledgerUid: 'uid2', amount: 2000),
      ];
      expect(computePaid('uid1', txns), 1000);
    });
  });

  group('computeRemaining', () {
    test('originalAmount - paid', () {
      final ledger = makeLedger(uid: 'uid1', originalAmount: 5000);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
        makePaymentTxn(ledgerUid: 'uid1', amount: 2000),
      ];
      expect(computeRemaining(ledger, txns), 3000);
    });

    test('can go negative if overpaid', () {
      final ledger = makeLedger(uid: 'uid1', originalAmount: 1000);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 1000),
        makePaymentTxn(ledgerUid: 'uid1', amount: 1500),
      ];
      expect(computeRemaining(ledger, txns), -500);
    });
  });

  group('computeProgress', () {
    test('0.0 when no payments', () {
      final ledger = makeLedger(uid: 'uid1', originalAmount: 5000);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
      ];
      expect(computeProgress(ledger, txns), 0.0);
    });

    test('1.0 when fully paid', () {
      final ledger = makeLedger(uid: 'uid1', originalAmount: 5000);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
        makePaymentTxn(ledgerUid: 'uid1', amount: 5000),
      ];
      expect(computeProgress(ledger, txns), 1.0);
    });

    test('0.4 when 2000 paid of 5000', () {
      final ledger = makeLedger(uid: 'uid1', originalAmount: 5000);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
        makePaymentTxn(ledgerUid: 'uid1', amount: 2000),
      ];
      expect(computeProgress(ledger, txns), 0.4);
    });

    test('clamped to 1.0 if overpaid', () {
      final ledger = makeLedger(uid: 'uid1', originalAmount: 1000);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 1000),
        makePaymentTxn(ledgerUid: 'uid1', amount: 2000),
      ];
      expect(computeProgress(ledger, txns), 1.0);
    });

    test('0.0 when originalAmount is 0', () {
      final ledger = makeLedger(uid: 'uid1', originalAmount: 0);
      expect(computeProgress(ledger, []), 0.0);
    });
  });

  group('totalToReceive', () {
    test('sums remaining of active lent ledgers only', () {
      final l1 = makeLedger(uid: 'uid1', type: 'lent', originalAmount: 5000);
      final l2 = makeLedger(uid: 'uid2', type: 'lent', originalAmount: 3000);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
        makePaymentTxn(ledgerUid: 'uid1', amount: 2000),
        makeInitialTxn(ledgerUid: 'uid2', amount: 3000),
        makePaymentTxn(ledgerUid: 'uid2', amount: 1000),
      ];
      // remaining: 3000 + 2000 = 5000
      expect(totalToReceive([l1, l2], txns), 5000);
    });

    test('excludes settled ledgers', () {
      final active = makeLedger(uid: 'uid1', type: 'lent', originalAmount: 5000);
      final settled = makeLedger(uid: 'uid2', type: 'lent', originalAmount: 3000, isSettled: true);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
      ];
      expect(totalToReceive([active, settled], txns), 5000);
    });

    test('excludes borrowed type ledgers', () {
      final lent = makeLedger(uid: 'uid1', type: 'lent', originalAmount: 5000);
      final borrowed = makeLedger(uid: 'uid2', type: 'borrowed', originalAmount: 3000);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
      ];
      expect(totalToReceive([lent, borrowed], txns), 5000);
    });
  });

  group('totalOwed', () {
    test('sums remaining of active borrowed ledgers only', () {
      final l1 = makeLedger(uid: 'uid1', type: 'borrowed', originalAmount: 4000);
      final l2 = makeLedger(uid: 'uid2', type: 'borrowed', originalAmount: 2000);
      final txns = [
        makeTransaction(
          name: 'Borrowed from Alice',
          amount: 4000,
          type: 'income',
          linkedRuleId: 'uid1',
          linkedRuleType: 'borrowed',
        ),
        makePaymentTxn(ledgerUid: 'uid1', amount: 1000, type: 'expense', linkedRuleType: 'borrowed'),
        makeTransaction(
          name: 'Borrowed from Bob',
          amount: 2000,
          type: 'income',
          linkedRuleId: 'uid2',
          linkedRuleType: 'borrowed',
        ),
      ];
      // remaining: 3000 + 2000 = 5000
      expect(totalOwed([l1, l2], txns), 5000);
    });

    test('excludes settled ledgers', () {
      final active = makeLedger(uid: 'uid1', type: 'borrowed', originalAmount: 4000);
      final settled = makeLedger(uid: 'uid2', type: 'borrowed', originalAmount: 2000, isSettled: true);
      expect(totalOwed([active, settled], []), 4000);
    });

    test('excludes lent type ledgers', () {
      final lent = makeLedger(uid: 'uid1', type: 'lent', originalAmount: 5000);
      final borrowed = makeLedger(uid: 'uid2', type: 'borrowed', originalAmount: 3000);
      expect(totalOwed([lent, borrowed], []), 3000);
    });
  });

  group('markSettled scenario', () {
    test('remaining is 0 after settling (full payment added)', () {
      final ledger = makeLedger(uid: 'uid1', originalAmount: 5000);
      final txns = [
        makeInitialTxn(ledgerUid: 'uid1', amount: 5000),
        makePaymentTxn(ledgerUid: 'uid1', amount: 3000),
        // Settling adds the remaining 2000
        makePaymentTxn(ledgerUid: 'uid1', amount: 2000),
      ];
      expect(computeRemaining(ledger, txns), 0);
      expect(computeProgress(ledger, txns), 1.0);
    });
  });
}
