import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/charts/providers/home_income_expense_provider.dart';
import 'package:kuber/features/transactions/helpers/transaction_filters.dart';

import '../../helpers/test_factories.dart';

void main() {
  final now = DateTime(2026, 11, 17, 10);
  final txns = [
    makeTransaction(amount: 65000, type: 'income', createdAt: DateTime(2026, 11, 1)),
    makeTransaction(amount: 29000, createdAt: DateTime(2026, 11, 9)),
    makeTransaction(amount: 500, createdAt: DateTime(2026, 11, 10), isTransfer: true),
    makeTransaction(amount: 700, type: 'income', createdAt: DateTime(2026, 11, 10), isBalanceAdjustment: true),
    makeTransaction(amount: 41000, createdAt: DateTime(2026, 9, 3)),
    makeTransaction(amount: 70000, type: 'income', createdAt: DateTime(2026, 9, 5)),
    // After today's month: ignored.
    makeTransaction(amount: 9, createdAt: DateTime(2027, 1, 2)),
  ];

  test('current month equals aggregate() (Home balance card)', () {
    final periods = buildMonthlyPeriods(txns, now);
    final agg = txns.aggregate(TxnPeriodFilter(from: DateTime(2026, 11), to: DateTime(2026, 12)));
    expect(periods.last.values, [agg.income, agg.expense]);
    expect(periods.last.isCurrent, isTrue);
    final sep = txns.aggregate(TxnPeriodFilter(from: DateTime(2026, 9), to: DateTime(2026, 10)));
    final p = periods.firstWhere((e) => e.key == 2026 * 12 + 8);
    expect(p.values, [sep.income, sep.expense]);
  });

  test('history starts at the first month with a transaction; gaps are no data', () {
    final periods = buildMonthlyPeriods(txns, now);
    expect(periods.map((p) => p.label), ['Sep', 'Oct', 'Nov']);
    expect(periods[1].noData, isTrue);
    expect(periods[1].values, [0, 0]);
    expect(periods[0].noData, isFalse);
  });

  test('no transactions: empty', () {
    expect(buildMonthlyPeriods(const [], now), isEmpty);
  });

  test('7 days: one period per day ending today, same rules', () {
    final days = buildDailyPeriods(txns, DateTime(2026, 11, 12, 9));
    expect(days, hasLength(7));
    expect(days.last.isCurrent, isTrue);
    // 9 Nov expense 29,000; the 10 Nov transfer and balance adjustment ignored.
    final nov9 = days.firstWhere((p) => p.fullLabel.contains('9 Nov'));
    expect(nov9.values, [0, 29000]);
    final nov10 = days.firstWhere((p) => p.fullLabel.contains('10 Nov'));
    expect(nov10.noData, isTrue);
    expect(buildDailyPeriods(txns, DateTime(2026, 12, 30)), isEmpty);
  });
}
