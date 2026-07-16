import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/advanced_analytics/engine/analytics_engine_adapter.dart';

void main() {
  group('Advanced analytics engine adapter', () {
    test('monthly aggregates exclude transfers and balance adjustments', () {
      final input = _input(
        transactions: [
          _txn(amount: 10000, type: 'income', date: DateTime(2026, 1, 5)),
          _txn(amount: 2500, type: 'expense', date: DateTime(2026, 1, 6)),
          _txn(
            amount: 999,
            type: 'expense',
            date: DateTime(2026, 1, 7),
            isTransfer: true,
          ),
          _txn(
            amount: 777,
            type: 'expense',
            date: DateTime(2026, 1, 8),
            isBalanceAdjustment: true,
          ),
        ],
        range: AnalyticsRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
      );

      final months = computeMonthlyAggregates(input);

      expect(months, hasLength(1));
      expect(months.single.income, 10000);
      expect(months.single.expense, 2500);
      expect(months.single.transactionCount, 2);
    });

    test(
      'financial health gives full debt score when no loans are tracked',
      () {
        final txns = <Map<String, Object?>>[];
        for (var month = 1; month <= 6; month++) {
          txns
            ..add(
              _txn(
                amount: 50000,
                type: 'income',
                date: DateTime(2026, month, 1),
              ),
            )
            ..add(
              _txn(
                amount: 30000,
                type: 'expense',
                date: DateTime(2026, month, 2),
              ),
            );
        }
        final input = _input(
          transactions: txns,
          range: AnalyticsRange(DateTime(2026, 1, 1), DateTime(2026, 6, 30)),
          accounts: [
            {'id': 1, 'name': 'Savings', 'type': 'bank', 'isCreditCard': false},
          ],
          balances: {1: 200000},
          now: DateTime(2026, 6, 30),
        );

        final score = computeFinancialHealth(input);
        final debt = score.subscores.firstWhere(
          (s) => s.type == SubscoreType.debtRatio,
        );

        expect(debt.score, 20);
        expect(debt.context['loanCount'], 0);
      },
    );

    test('trends (YoY) compares the range to the same range last year', () {
      final input = _input(
        transactions: [
          // Current window: February 2026.
          _txn(amount: 1000, type: 'expense', date: DateTime(2026, 2, 10)),
          // Same window one year earlier: February 2025.
          _txn(amount: 400, type: 'expense', date: DateTime(2025, 2, 15)),
          // Outside the current window — must be ignored.
          _txn(amount: 999, type: 'expense', date: DateTime(2026, 1, 5)),
        ],
        range: AnalyticsRange(DateTime(2026, 2, 1), DateTime(2026, 2, 28)),
      );

      final trends = computeTrends(input);

      expect(trends.mode, 'yoy');
      expect(trends.currentExpense, 1000);
      expect(trends.previousExpense, 400);
    });

    test('financial health total is a weighted (not flat) average', () {
      final txns = <Map<String, Object?>>[];
      for (var month = 1; month <= 6; month++) {
        txns
          ..add(
            _txn(amount: 50000, type: 'income', date: DateTime(2026, month, 1)),
          )
          ..add(
            _txn(amount: 30000, type: 'expense', date: DateTime(2026, month, 2)),
          );
      }
      final input = _input(
        transactions: txns,
        range: AnalyticsRange(DateTime(2026, 1, 1), DateTime(2026, 6, 30)),
        accounts: [
          {'id': 1, 'name': 'Savings', 'type': 'bank', 'isCreditCard': false},
        ],
        // Only ~1 month of expenses saved -> low emergency-fund subscore, so
        // the subscores differ and weighting is observable.
        balances: {1: 30000},
        now: DateTime(2026, 6, 30),
      );

      final score = computeFinancialHealth(input);

      // Subscores: savings 20 (w .30), expense 20 (w .20), debt 20 (w .15),
      // emergency 3 (w .15). Weighted: (.30+.20+.15 + .15*3/20) / .80 * 100 = 84.
      // A flat average would give (20+20+20+3)/4 * 5 = 79.
      expect(score.total, 84);
    });

    test('all five subscores are always emitted, budget marked N/A when none',
        () {
      final txns = <Map<String, Object?>>[];
      for (var month = 5; month <= 7; month++) {
        txns
          ..add(
            _txn(amount: 60000, type: 'income', date: DateTime(2026, month, 1)),
          )
          ..add(
            _txn(amount: 40000, type: 'expense', date: DateTime(2026, month, 2)),
          );
      }
      final score = computeFinancialHealth(
        _input(
          transactions: txns,
          range: AnalyticsRange(DateTime(2026, 5, 1), DateTime(2026, 7, 31)),
          now: DateTime(2026, 7, 31),
        ),
      );

      expect(score.subscores, hasLength(5));
      final budget = score.subscores.firstWhere(
        (s) => s.type == SubscoreType.budgetAdherence,
      );
      expect(budget.applicable, isFalse); // no budgets created
    });

    test('credit-card outstanding raises the debt ratio', () {
      final txns = <Map<String, Object?>>[];
      for (var month = 5; month <= 7; month++) {
        txns.add(
          _txn(amount: 60000, type: 'income', date: DateTime(2026, month, 1)),
        );
      }
      final score = computeFinancialHealth(
        _input(
          transactions: txns,
          range: AnalyticsRange(DateTime(2026, 5, 1), DateTime(2026, 7, 31)),
          now: DateTime(2026, 7, 31),
          accounts: [
            {'id': 2, 'name': 'Card', 'type': 'bank', 'isCreditCard': true},
          ],
          // Card owes 600000 -> 5% estimated minimum = 30000/mo. Against a
          // 60000/mo income that is a 50% debt ratio.
          balances: {2: -600000},
        ),
      );

      final debt = score.subscores.firstWhere(
        (s) => s.type == SubscoreType.debtRatio,
      );
      expect(debt.context['ccOutstanding'], 600000);
      expect(debt.metric.round(), 50);
      expect(debt.score, lessThan(20)); // credit-card debt pulls it down
    });

    test('6000 transaction monthly aggregation completes under 2 seconds', () {
      final txns = List.generate(6000, (i) {
        return _txn(
          amount: (i % 100) + 1,
          type: i.isEven ? 'expense' : 'income',
          date: DateTime(2025 + (i % 2), (i % 12) + 1, (i % 27) + 1),
          categoryId: '${(i % 8) + 1}',
          name: 'Merchant ${i % 40}',
        );
      });
      final input = _input(
        transactions: txns,
        range: AnalyticsRange(DateTime(2025, 1, 1), DateTime(2026, 12, 31)),
      );

      final sw = Stopwatch()..start();
      final months = computeMonthlyAggregates(input);
      sw.stop();

      expect(months, hasLength(24));
      expect(sw.elapsed, lessThan(const Duration(seconds: 2)));
    });
  });
}

AnalyticsInput _input({
  required List<Map<String, Object?>> transactions,
  required AnalyticsRange range,
  List<Map<String, Object?>> accounts = const [],
  Map<int, double> balances = const {},
  DateTime? now,
}) {
  return AnalyticsInput(
    transactions: transactions,
    categories: const [],
    budgets: const [],
    accounts: accounts,
    balances: balances,
    loans: const [],
    recurringRules: const [],
    range: range,
    now: now ?? DateTime(2026, 7, 12),
  );
}

Map<String, Object?> _txn({
  required double amount,
  required String type,
  required DateTime date,
  String categoryId = '1',
  String name = 'Merchant',
  bool isTransfer = false,
  bool isBalanceAdjustment = false,
}) {
  return {
    'id': 1,
    'name': name,
    'amount': amount,
    'type': type,
    'categoryId': categoryId,
    'accountId': '1',
    'linkedRuleType': null,
    'isTransfer': isTransfer,
    'isBalanceAdjustment': isBalanceAdjustment,
    'createdAt': date.toIso8601String(),
  };
}
