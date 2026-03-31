import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/dashboard/providers/insight_engine.dart';
import 'package:kuber/features/insights/models/insight.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import '../../helpers/test_factories.dart';

void main() {
  late AppFormatter formatter;

  setUp(() {
    formatter = AppFormatter(system: NumberSystem.indian);
  });

  InsightEngine makeEngine({
    required List transactions,
    List<Category>? categories,
  }) {
    return InsightEngine(
      allTransactions: List.from(transactions),
      categories: categories ?? [],
      currencySymbol: '₹',
      formatter: formatter,
    );
  }

  group('generate', () {
    test('returns fallback for empty transactions', () {
      final engine = makeEngine(transactions: []);
      final insights = engine.generate();
      expect(insights.length, 1);
      expect(insights.first.type, InsightType.fallbackTip);
    });

    test('returns fallback total for few transactions', () {
      // 1-2 transactions: not enough for most insights, should get fallback
      final txns = [
        makeTransaction(amount: 500, createdAt: DateTime.now()),
      ];
      final engine = makeEngine(transactions: txns);
      final insights = engine.generate();
      expect(insights.isNotEmpty, true);
      // With only 1 transaction, most insights need 3+ so we get fallback
      expect(
        insights.any((i) =>
            i.type == InsightType.fallbackTotal ||
            i.type == InsightType.fallbackTip),
        true,
      );
    });

    test('deduplicates by type keeping highest confidence', () {
      // Create enough data to trigger multiple insights
      final now = DateTime.now();
      final txns = <dynamic>[];
      for (int i = 0; i < 30; i++) {
        txns.add(makeTransaction(
          amount: 100.0 + i * 10,
          categoryId: '${(i % 3) + 1}',
          createdAt: now.subtract(Duration(days: i)),
        ));
      }
      final engine = makeEngine(
        transactions: txns,
        categories: [
          makeCategory(id: 1, name: 'Food'),
          makeCategory(id: 2, name: 'Transport'),
          makeCategory(id: 3, name: 'Shopping'),
        ],
      );
      final insights = engine.generate();

      // Check no duplicate types
      final types = insights.map((i) => i.type).toList();
      expect(types.toSet().length, types.length);
    });

    test('semantic conflict: keeps only one of spendingHighToday/spendingFasterThisWeek', () {
      // This is hard to trigger deterministically, but we can verify the logic
      // by checking the output doesn't contain both
      final now = DateTime.now();
      final txns = <dynamic>[];
      // Create 90 days of data with high spending today
      for (int i = 0; i < 90; i++) {
        txns.add(makeTransaction(
          amount: i == 0 ? 10000 : 100,
          createdAt: now.subtract(Duration(days: i)),
        ));
      }
      final engine = makeEngine(transactions: txns);
      final insights = engine.generate();
      final types = insights.map((i) => i.type).toSet();

      final hasBoth = types.contains(InsightType.spendingHighToday) &&
          types.contains(InsightType.spendingFasterThisWeek);
      expect(hasBoth, false);
    });

    test('insights are sorted by confidence descending', () {
      final now = DateTime.now();
      final txns = <dynamic>[];
      for (int i = 0; i < 60; i++) {
        txns.add(makeTransaction(
          amount: 200.0 + (i % 5) * 50,
          categoryId: '${(i % 4) + 1}',
          createdAt: now.subtract(Duration(days: i)),
        ));
      }
      final engine = makeEngine(
        transactions: txns,
        categories: [
          makeCategory(id: 1, name: 'Food'),
          makeCategory(id: 2, name: 'Transport'),
          makeCategory(id: 3, name: 'Shopping'),
          makeCategory(id: 4, name: 'Bills'),
        ],
      );
      final insights = engine.generate();

      for (int i = 0; i < insights.length - 1; i++) {
        expect(
          insights[i].confidence >= insights[i + 1].confidence,
          true,
          reason: '${insights[i].type} (${insights[i].confidence}) should be >= ${insights[i + 1].type} (${insights[i + 1].confidence})',
        );
      }
    });
  });

  group('top category', () {
    test('identifies top spending category', () {
      final now = DateTime.now();
      final txns = [
        makeTransaction(amount: 1000, categoryId: '1', createdAt: now),
        makeTransaction(amount: 500, categoryId: '1', createdAt: now),
        makeTransaction(amount: 200, categoryId: '2', createdAt: now),
        makeTransaction(amount: 100, categoryId: '2', createdAt: now),
      ];
      final engine = makeEngine(
        transactions: txns,
        categories: [
          makeCategory(id: 1, name: 'Food'),
          makeCategory(id: 2, name: 'Transport'),
        ],
      );
      final insights = engine.generate();
      final topCat = insights.where((i) => i.type == InsightType.topCategory);
      expect(topCat.isNotEmpty, true);
      expect(topCat.first.message, contains('Food'));
    });
  });

  group('category concentration', () {
    test('detects when top 3 categories dominate', () {
      final now = DateTime.now();
      final txns = <dynamic>[];
      // Create enough data with heavy concentration in 3 categories
      for (int i = 0; i < 20; i++) {
        txns.add(makeTransaction(
          amount: 1000,
          categoryId: '${(i % 3) + 1}',
          createdAt: now.subtract(Duration(days: i)),
        ));
      }
      // Add a tiny amount to a 4th category
      txns.add(makeTransaction(
        amount: 10,
        categoryId: '4',
        createdAt: now.subtract(const Duration(days: 5)),
      ));
      final engine = makeEngine(
        transactions: txns,
        categories: [
          makeCategory(id: 1, name: 'Food'),
          makeCategory(id: 2, name: 'Transport'),
          makeCategory(id: 3, name: 'Shopping'),
          makeCategory(id: 4, name: 'Other'),
        ],
      );
      final insights = engine.generate();
      final concentration =
          insights.where((i) => i.type == InsightType.categoryConcentration);
      expect(concentration.isNotEmpty, true);
      expect(concentration.first.message, contains('3 categories'));
    });
  });
}
