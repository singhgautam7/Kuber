import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/budgets/providers/budget_provider.dart';
import '../../helpers/test_factories.dart';

/// Helper that replicates the date/progress logic from budgetProgressProvider
/// so we can test it without the Riverpod dependency chain.
BudgetProgress computeProgress(Budget budget, double spent, {DateTime? now}) {
  final clock = now ?? DateTime.now();

  DateTime startDate;
  DateTime endDate;

  if (budget.periodType == BudgetPeriodType.monthly) {
    startDate = DateTime(clock.year, clock.month, 1);
    endDate = DateTime(clock.year, clock.month + 1, 0, 23, 59, 59, 999);
  } else if (budget.periodType == BudgetPeriodType.weekly) {
    final weekStart = clock.subtract(Duration(days: clock.weekday - 1));
    startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    endDate = DateTime(
        weekStart.year, weekStart.month, weekStart.day + 6, 23, 59, 59, 999);
  } else {
    startDate = budget.startDate;
    endDate = budget.endDate ?? clock;
  }

  final percentage = (spent / budget.amount) * 100;
  final daysRemaining = endDate.difference(clock).inDays + 1;

  return BudgetProgress(
    spent: spent,
    limit: budget.amount,
    percentage: percentage,
    startDate: startDate,
    endDate: endDate,
    daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
  );
}

void main() {
  group('Budget progress calculation', () {
    test('monthly period: starts on 1st, percentage = spent/limit*100', () {
      final now = DateTime(2024, 6, 15);
      final budget = makeBudget(
        id: 1,
        categoryId: '1',
        amount: 5000,
        periodType: BudgetPeriodType.monthly,
      );

      final progress = computeProgress(budget, 2500, now: now);

      expect(progress.spent, 2500);
      expect(progress.limit, 5000);
      expect(progress.percentage, 50);
      expect(progress.startDate, DateTime(2024, 6, 1));
      // End date should be last day of June
      expect(progress.endDate.day, 30);
      expect(progress.endDate.month, 6);
      expect(progress.daysRemaining, greaterThanOrEqualTo(1));
    });

    test('weekly period: starts on Monday', () {
      // 2024-06-12 is a Wednesday
      final now = DateTime(2024, 6, 12);
      final budget = makeBudget(
        id: 2,
        categoryId: '1',
        amount: 1000,
        periodType: BudgetPeriodType.weekly,
      );

      final progress = computeProgress(budget, 700, now: now);

      expect(progress.spent, 700);
      expect(progress.percentage, 70);
      expect(progress.startDate.weekday, DateTime.monday);
      // Start should be Monday June 10
      expect(progress.startDate, DateTime(2024, 6, 10));
    });

    test('custom period uses budget start/end dates', () {
      final start = DateTime(2024, 3, 1);
      final end = DateTime(2024, 3, 31);
      final budget = makeBudget(
        id: 3,
        categoryId: '1',
        amount: 10000,
        periodType: BudgetPeriodType.custom,
        startDate: start,
        endDate: end,
      );

      final now = DateTime(2024, 3, 15);
      final progress = computeProgress(budget, 8000, now: now);

      expect(progress.spent, 8000);
      expect(progress.percentage, 80);
      expect(progress.startDate, start);
      expect(progress.endDate, end);
    });

    test('daysRemaining clamps to 0 for past periods', () {
      final budget = makeBudget(
        id: 4,
        categoryId: '1',
        amount: 5000,
        periodType: BudgetPeriodType.custom,
        startDate: DateTime(2020, 1, 1),
        endDate: DateTime(2020, 1, 31),
      );

      final now = DateTime(2024, 6, 15);
      final progress = computeProgress(budget, 0, now: now);

      expect(progress.daysRemaining, 0);
    });

    test('percentage can exceed 100 when overspent', () {
      final budget = makeBudget(
        id: 5,
        categoryId: '1',
        amount: 1000,
        periodType: BudgetPeriodType.monthly,
      );

      final progress = computeProgress(budget, 1500);

      expect(progress.percentage, 150);
    });
  });

  group('Budget snapshot sorting', () {
    test('sorts by percentage descending and takes top 3', () {
      final progressList = [
        computeProgress(
            makeBudget(id: 1, categoryId: '1', amount: 1000), 250),
        computeProgress(
            makeBudget(id: 2, categoryId: '2', amount: 1000), 750),
        computeProgress(
            makeBudget(id: 3, categoryId: '3', amount: 1000), 500),
        computeProgress(
            makeBudget(id: 4, categoryId: '4', amount: 1000), 1000),
      ];

      // Replicate the sorting logic from budgetSnapshotProvider
      progressList.sort(
        (a, b) => b.percentage.compareTo(a.percentage),
      );
      final top3 = progressList.take(3).toList();

      expect(top3.length, 3);
      expect(top3[0].percentage, 100); // 1000/1000
      expect(top3[1].percentage, 75); // 750/1000
      expect(top3[2].percentage, 50); // 500/1000
      // The 25% one is excluded
    });
  });
}
