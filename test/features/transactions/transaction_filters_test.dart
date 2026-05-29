import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/transactions/helpers/transaction_filters.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('buildTransferPairAccountIds', () {
    test('maps each transfer leg to the other leg accountId', () {
      final from = makeTransaction(
        id: 1,
        type: 'expense',
        accountId: '10',
        isTransfer: true,
        transferId: 'T1',
      );
      final to = makeTransaction(
        id: 2,
        type: 'income',
        accountId: '20',
        isTransfer: true,
        transferId: 'T1',
      );
      final normal = makeTransaction(id: 3, accountId: '30');

      final map = buildTransferPairAccountIds([from, to, normal]);

      expect(map[1], '20', reason: 'FROM leg points at TO account');
      expect(map[2], '10', reason: 'TO leg points at FROM account');
      expect(map.containsKey(3), isFalse, reason: 'non-transfers excluded');
    });

    test('ignores a transfer with a missing pair (orphan leg)', () {
      final orphan = makeTransaction(
        id: 1,
        accountId: '10',
        isTransfer: true,
        transferId: 'T1',
      );

      final map = buildTransferPairAccountIds([orphan]);

      expect(map, isEmpty);
    });

    test('keeps multiple transfers independent', () {
      final a1 = makeTransaction(id: 1, accountId: '10', isTransfer: true, transferId: 'A');
      final a2 = makeTransaction(id: 2, accountId: '20', isTransfer: true, transferId: 'A');
      final b1 = makeTransaction(id: 3, accountId: '30', isTransfer: true, transferId: 'B');
      final b2 = makeTransaction(id: 4, accountId: '40', isTransfer: true, transferId: 'B');

      final map = buildTransferPairAccountIds([a1, a2, b1, b2]);

      expect(map[1], '20');
      expect(map[2], '10');
      expect(map[3], '40');
      expect(map[4], '30');
    });
  });

  group('TransactionFilterX', () {
    test('validForCalculations drops transfers and balance adjustments', () {
      final txns = [
        makeTransaction(type: 'expense', amount: 100),
        makeTransaction(type: 'expense', amount: 50, isTransfer: true),
        makeTransaction(type: 'income', amount: 70, isBalanceAdjustment: true),
      ];
      final kept = txns.validForCalculations.toList();
      expect(kept.length, 1);
      expect(kept.single.amount, 100);
    });

    test('validForFeed keeps the expense transfer leg, drops the income leg',
        () {
      final txns = [
        makeTransaction(type: 'expense', amount: 50, isTransfer: true),
        makeTransaction(type: 'income', amount: 50, isTransfer: true),
        makeTransaction(type: 'income', amount: 70, isBalanceAdjustment: true),
        makeTransaction(type: 'expense', amount: 100),
      ];
      final kept = txns.validForFeed.toList();
      expect(kept.length, 2); // expense transfer leg + the normal expense
      expect(kept.where((t) => t.isTransfer).length, 1);
      expect(kept.any((t) => t.isBalanceAdjustment), isFalse);
    });
  });

  group('TransactionAggregateX.aggregate', () {
    test('sums income/expense/net and per-category spend', () {
      final txns = [
        makeTransaction(type: 'income', amount: 1000, categoryId: '3'),
        makeTransaction(type: 'expense', amount: 200, categoryId: '1'),
        makeTransaction(type: 'expense', amount: 50, categoryId: '1'),
        makeTransaction(type: 'expense', amount: 100, categoryId: '2'),
      ];
      final agg = txns.aggregate(const TxnPeriodFilter());

      expect(agg.income, 1000);
      expect(agg.expense, 350);
      expect(agg.net, 650);
      expect(agg.spendingByCategory['1'], 250);
      expect(agg.spendingByCategory['2'], 100);
      // Income categories never appear in spendingByCategory.
      expect(agg.spendingByCategory.containsKey('3'), isFalse);
      expect(agg.txnCountByCategory['1'], 2);
    });

    test('always excludes transfers and balance adjustments', () {
      final txns = [
        makeTransaction(type: 'expense', amount: 200, categoryId: '1'),
        makeTransaction(type: 'expense', amount: 999, isTransfer: true),
        makeTransaction(
          type: 'expense',
          amount: 999,
          isBalanceAdjustment: true,
          categoryId: '1',
        ),
      ];
      expect(txns.aggregate(const TxnPeriodFilter()).expense, 200);
    });

    test('excludeLinkedRule drops rule-linked transactions', () {
      final txns = [
        makeTransaction(type: 'expense', amount: 200, categoryId: '1'),
        makeTransaction(
          type: 'expense',
          amount: 500,
          categoryId: '1',
          linkedRuleType: 'recurring',
        ),
      ];
      expect(
        txns.aggregate(const TxnPeriodFilter(excludeLinkedRule: true)).expense,
        200,
      );
      expect(txns.aggregate(const TxnPeriodFilter()).expense, 700);
    });

    test('date window is inclusive of `from` and exclusive of `to`', () {
      final txns = [
        makeTransaction(
          type: 'expense',
          amount: 10,
          createdAt: DateTime(2026, 1, 1),
        ),
        makeTransaction(
          type: 'expense',
          amount: 20,
          createdAt: DateTime(2026, 1, 15),
        ),
        makeTransaction(
          type: 'expense',
          amount: 40,
          createdAt: DateTime(2026, 2, 1),
        ),
      ];
      final agg = txns.aggregate(
        TxnPeriodFilter(from: DateTime(2026, 1, 1), to: DateTime(2026, 2, 1)),
      );
      expect(agg.expense, 30); // Jan 1 (incl) + Jan 15; Feb 1 (excl) dropped
    });

    test('categoryId filter restricts to one category', () {
      final txns = [
        makeTransaction(type: 'expense', amount: 200, categoryId: '1'),
        makeTransaction(type: 'expense', amount: 100, categoryId: '2'),
      ];
      expect(
        txns.aggregate(const TxnPeriodFilter(categoryId: '1')).expense,
        200,
      );
    });
  });
}
