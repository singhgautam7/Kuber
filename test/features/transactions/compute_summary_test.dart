import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/transactions/helpers/transaction_filters.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('computeSummary', () {
    test('defaults exclude transfers and balance adjustments', () {
      final start = DateTime(2026, 5);
      final end = DateTime(2026, 6);
      final txns = [
        makeTransaction(
          amount: 1000,
          type: 'income',
          createdAt: DateTime(2026, 5, 1),
        ),
        makeTransaction(
          amount: 300,
          type: 'expense',
          createdAt: DateTime(2026, 5, 2),
        ),
        makeTransaction(
          amount: 700,
          type: 'expense',
          isTransfer: true,
          createdAt: DateTime(2026, 5, 3),
        ),
        makeTransaction(
          amount: 200,
          type: 'income',
          isBalanceAdjustment: true,
          createdAt: DateTime(2026, 5, 4),
        ),
      ];

      final summary = txns.computeSummary(start: start, end: end);

      expect(summary.income, 1000);
      expect(summary.expense, 300);
      expect(summary.net, 700);
    });

    test('can include linked rules and filter by account and category', () {
      final start = DateTime(2026, 5);
      final end = DateTime(2026, 6);
      final txns = [
        makeTransaction(
          amount: 100,
          type: 'expense',
          accountId: 'a',
          categoryId: 'food',
          linkedRuleType: 'recurring',
          createdAt: DateTime(2026, 5, 1),
        ),
        makeTransaction(
          amount: 200,
          type: 'expense',
          accountId: 'b',
          categoryId: 'food',
          createdAt: DateTime(2026, 5, 1),
        ),
        makeTransaction(
          amount: 300,
          type: 'expense',
          accountId: 'a',
          categoryId: 'rent',
          createdAt: DateTime(2026, 5, 1),
        ),
      ];

      final summary = txns.computeSummary(
        start: start,
        end: end,
        excludeLinkedRules: false,
        accountIds: {'a'},
        categoryIds: {'food'},
      );

      expect(summary.expense, 100);
      expect(summary.spendingByCategory, {'food': 100});
      expect(summary.txnCountByCategory, {'food': 1});
    });

    test('excludeLinkedRules drops rule-backed transactions', () {
      final txns = [
        makeTransaction(
          amount: 100,
          type: 'expense',
          linkedRuleType: 'investment',
          createdAt: DateTime(2026, 5, 1),
        ),
        makeTransaction(
          amount: 50,
          type: 'expense',
          createdAt: DateTime(2026, 5, 1),
        ),
      ];

      final summary = txns.computeSummary(
        start: DateTime(2026, 5),
        end: DateTime(2026, 6),
        excludeLinkedRules: true,
      );

      expect(summary.expense, 50);
    });
  });
}
