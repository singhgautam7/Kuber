import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kuber/features/dashboard/providers/dashboard_provider.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import '../../helpers/mock_repositories.dart';
import '../../helpers/test_factories.dart';

void main() {
  late MockTransactionRepository mockRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
  });

  group('monthlySummaryProvider', () {
    test('computes income, expense, net and categorySpending', () async {
      final now = DateTime.now();
      final txns = [
        makeTransaction(type: 'income', amount: 50000, createdAt: now),
        makeTransaction(
          type: 'expense', amount: 5000, categoryId: '1', createdAt: now,
        ),
        makeTransaction(
          type: 'expense', amount: 3000, categoryId: '2', createdAt: now,
        ),
        makeTransaction(
          type: 'expense', amount: 2000, categoryId: '1', createdAt: now,
        ),
      ];

      when(() => mockRepo.getAll()).thenAnswer((_) async => txns);

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final summary = await container.read(monthlySummaryProvider.future);
      expect(summary.totalIncome, 50000);
      expect(summary.totalExpense, 10000);
      expect(summary.net, 40000);
      expect(summary.categorySpending['1'], 7000);
      expect(summary.categorySpending['2'], 3000);
    });

    test('skips transfers in summary', () async {
      final now = DateTime.now();
      final txns = [
        makeTransaction(type: 'expense', amount: 1000, createdAt: now),
        makeTransaction(
          type: 'expense', amount: 500, isTransfer: true,
          transferId: 'tf1', createdAt: now,
        ),
      ];

      when(() => mockRepo.getAll()).thenAnswer((_) async => txns);

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final summary = await container.read(monthlySummaryProvider.future);
      expect(summary.totalExpense, 1000);
    });

    test('skips balance adjustments', () async {
      final now = DateTime.now();
      final txns = [
        makeTransaction(type: 'expense', amount: 1000, createdAt: now),
        makeTransaction(
          type: 'expense', amount: 2000,
          isBalanceAdjustment: true, createdAt: now,
        ),
      ];

      when(() => mockRepo.getAll()).thenAnswer((_) async => txns);

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final summary = await container.read(monthlySummaryProvider.future);
      expect(summary.totalExpense, 1000);
    });
  });

  group('last7DaysSummaryProvider', () {
    test('buckets transactions into 7 days', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final txns = [
        makeTransaction(
          type: 'expense', amount: 100, createdAt: today,
        ),
        makeTransaction(
          type: 'income', amount: 500, createdAt: today,
        ),
        makeTransaction(
          type: 'expense', amount: 200,
          createdAt: today.subtract(const Duration(days: 1)),
        ),
      ];

      when(() => mockRepo.getAll()).thenAnswer((_) async => txns);

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final days = await container.read(last7DaysSummaryProvider.future);
      expect(days.length, 7);
      // Sorted by date ascending
      expect(days.first.date.isBefore(days.last.date), true);

      // Today's bucket
      final todayBucket = days.last;
      expect(todayBucket.expense, 100);
      expect(todayBucket.income, 500);
    });

    test('excludes transfers from daily bucketing', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final txns = [
        makeTransaction(type: 'expense', amount: 300, createdAt: today),
        makeTransaction(
          type: 'expense', amount: 200, isTransfer: true,
          transferId: 'tf1', createdAt: today,
        ),
      ];

      when(() => mockRepo.getAll()).thenAnswer((_) async => txns);

      final container = ProviderContainer(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final days = await container.read(last7DaysSummaryProvider.future);
      final todayBucket = days.last;
      expect(todayBucket.expense, 300);
    });
  });
}
