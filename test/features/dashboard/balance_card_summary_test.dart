import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kuber/features/dashboard/providers/dashboard_provider.dart';
import 'package:kuber/features/transactions/helpers/transaction_filters.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_factories.dart';

void main() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final end = DateTime(now.year, now.month + 1);
  final prevStart = DateTime(now.year, now.month - 1);
  DateTime inPrev(int d) => DateTime(now.year, now.month - 1, d, 12);
  DateTime inCur(int d) => DateTime(now.year, now.month, d, 12);

  final txns = [
    makeTransaction(type: 'income', amount: 50000, createdAt: inCur(1)),
    makeTransaction(type: 'expense', amount: 5000, categoryId: '1', createdAt: inCur(2)),
    makeTransaction(type: 'expense', amount: 3000, categoryId: '2', createdAt: inCur(2)),
    makeTransaction(type: 'expense', amount: 999, isTransfer: true, createdAt: inCur(3)),
    makeTransaction(type: 'expense', amount: 888, isBalanceAdjustment: true, createdAt: inCur(3)),
    makeTransaction(type: 'income', amount: 40000, createdAt: inPrev(1)),
    makeTransaction(type: 'expense', amount: 7000, createdAt: inPrev(15)),
    makeTransaction(type: 'expense', amount: 500, isTransfer: true, createdAt: inPrev(16)),
    makeTransaction(type: 'expense', amount: 300, isBalanceAdjustment: true, createdAt: inPrev(17)),
    makeTransaction(type: 'expense', amount: 1234, createdAt: DateTime(now.year - 1, 3, 3)),
  ];

  test('aggregateWithPrev: this month unchanged, last month equals aggregate()', () {
    final f = TxnPeriodFilter(from: start, to: end);
    final old = txns.aggregate(f);
    final r = txns.aggregateWithPrev(f, prevFrom: prevStart);
    expect(r.current.income, old.income);
    expect(r.current.expense, old.expense);
    expect(r.current.spendingByCategory, old.spendingByCategory);
    expect(r.current.txnCountByCategory, old.txnCountByCategory);
    final prev = txns.aggregate(TxnPeriodFilter(from: prevStart, to: start));
    expect(r.prevIncome, prev.income);
    expect(r.prevExpense, prev.expense);
    expect(r.prevIncome, 40000);
    expect(r.prevExpense, 7000);
    expect(r.hasEarlier, isTrue);
  });

  test('hasEarlier is false with nothing before this month (transfers ignored)', () {
    final only = [
      makeTransaction(type: 'expense', amount: 10, createdAt: inCur(1)),
      makeTransaction(type: 'expense', amount: 10, isTransfer: true, createdAt: inPrev(1)),
    ];
    final r = only.aggregateWithPrev(TxnPeriodFilter(from: start, to: end), prevFrom: prevStart);
    expect(r.hasEarlier, isFalse);
    expect(r.prevExpense, 0);
  });

  test('monthlySummaryProvider carries the previous month', () async {
    final repo = MockTransactionRepository();
    when(() => repo.getAll()).thenAnswer((_) async => txns);
    final c = ProviderContainer(overrides: [transactionRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(c.dispose);
    final s = await c.read(monthlySummaryProvider.future);
    expect(s.totalIncome, 50000);
    expect(s.totalExpense, 8000);
    expect(s.prevIncome, 40000);
    expect(s.prevExpense, 7000);
    expect(s.hasEarlier, isTrue);
  });
}
