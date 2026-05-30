import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/providers/stats_provider.dart';
import 'package:kuber/features/analytics/providers/analytics_provider.dart';
import 'package:kuber/features/categories/providers/category_provider.dart';
import 'package:kuber/features/categories/data/category_group.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_factories.dart';

/// Characterization tests for the analytics aggregation providers, which had
/// no coverage. They pin the current behaviour (per-category / per-group
/// expense totals, exclusions, percentages, sort order) so the planned
/// refactor onto the shared `aggregate()` helper can be made safely.
void main() {
  // Categories: Food + Snacks live in "Essentials" (group 100); Travel in
  // "Lifestyle" (group 200); Salary is income (no group).
  final food = makeCategory(id: 1, name: 'Food', type: 'expense', groupId: 100);
  final travel =
      makeCategory(id: 2, name: 'Travel', type: 'expense', groupId: 200);
  final salary = makeCategory(id: 3, name: 'Salary', type: 'income');
  final snacks =
      makeCategory(id: 4, name: 'Snacks', type: 'expense', groupId: 100);
  final categoryMap = {1: food, 2: travel, 3: salary, 4: snacks};

  final groups = [
    CategoryGroup()
      ..id = 100
      ..name = 'Essentials',
    CategoryGroup()
      ..id = 200
      ..name = 'Lifestyle',
  ];

  late MockCategoryGroupRepository groupRepo;

  setUp(() {
    groupRepo = MockCategoryGroupRepository();
    when(() => groupRepo.getAll()).thenAnswer((_) async => groups);
  });

  ProviderContainer makeContainer(List<Transaction> txns) {
    final c = ProviderContainer(
      overrides: [
        analyticsTransactionsProvider.overrideWithValue(txns),
        categoryMapProvider.overrideWith((ref) async => categoryMap),
        categoryGroupRepositoryProvider.overrideWithValue(groupRepo),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('analyticsCategoryStatsProvider', () {
    test('sums expenses per category, sorted descending', () async {
      final c = makeContainer([
        makeTransaction(type: 'expense', amount: 100, categoryId: '1'),
        makeTransaction(type: 'expense', amount: 50, categoryId: '1'),
        makeTransaction(type: 'expense', amount: 200, categoryId: '2'),
      ]);

      final stats = await c.read(analyticsCategoryStatsProvider.future);

      expect(stats.length, 2);
      expect(stats[0].category.id, 2); // Travel 200 first
      expect(stats[0].total, 200);
      expect(stats[1].category.id, 1); // Food 150 second
      expect(stats[1].total, 150);
      // Percentages are relative to total expense (350).
      expect(stats[0].percentage, closeTo(200 / 350 * 100, 0.01));
      expect(stats[1].percentage, closeTo(150 / 350 * 100, 0.01));
    });

    test('excludes income and balance adjustments', () async {
      final c = makeContainer([
        makeTransaction(type: 'expense', amount: 100, categoryId: '1'),
        makeTransaction(type: 'income', amount: 999, categoryId: '3'),
        makeTransaction(
          type: 'expense',
          amount: 70,
          categoryId: '1',
          isBalanceAdjustment: true,
        ),
      ]);

      final stats = await c.read(analyticsCategoryStatsProvider.future);

      expect(stats.length, 1);
      expect(stats.single.category.id, 1);
      expect(stats.single.total, 100);
    });

    test('returns empty when there are no expenses', () async {
      final c = makeContainer([
        makeTransaction(type: 'income', amount: 100, categoryId: '3'),
      ]);
      expect(await c.read(analyticsCategoryStatsProvider.future), isEmpty);
    });
  });

  group('analyticsGroupStatsProvider', () {
    test('rolls category expenses up into their groups', () async {
      final c = makeContainer([
        makeTransaction(type: 'expense', amount: 100, categoryId: '1'), // Ess
        makeTransaction(type: 'expense', amount: 50, categoryId: '4'), // Ess
        makeTransaction(type: 'expense', amount: 200, categoryId: '2'), // Life
        makeTransaction(type: 'income', amount: 999, categoryId: '3'),
      ]);

      final stats = await c.read(analyticsGroupStatsProvider.future);

      expect(stats.length, 2);
      expect(stats[0].groupName, 'Lifestyle'); // 200
      expect(stats[0].total, 200);
      expect(stats[1].groupName, 'Essentials'); // 100 + 50
      expect(stats[1].total, 150);
      expect(stats[0].percentage, closeTo(200 / 350 * 100, 0.01));
    });
  });
}
