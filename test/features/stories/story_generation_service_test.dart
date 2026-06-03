import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/stories/data/insight_story.dart';
import 'package:kuber/features/stories/data/story_repository.dart';
import 'package:kuber/features/stories/services/story_generation_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/ledger/data/ledger.dart';
import 'package:kuber/features/investments/data/investment.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  late Isar isar;

  setUpAll(initialiseIsarForTests);
  setUp(() async => isar = await openTestIsar());
  tearDown(() async => closeAndCleanIsar(isar));

  Future<void> seed({
    List<Transaction> txns = const [],
    List<Category> categories = const [],
    List<Loan> loans = const [],
    List<Ledger> ledgers = const [],
    List<Investment> investments = const [],
  }) async {
    await isar.writeTxn(() async {
      await isar.categorys.putAll(categories);
      await isar.transactions.putAll(txns);
      await isar.loans.putAll(loans);
      await isar.ledgers.putAll(ledgers);
      await isar.investments.putAll(investments);
    });
  }

  final defaultCategories = [
    makeCategory(id: 1, name: 'Food'),
    makeCategory(id: 2, name: 'Transport'),
  ];

  group('unified TTL + always-present recaps', () {
    test('daily, weekly, monthly and yearly recaps are all present; 48h TTL',
        () async {
      final now = DateTime(2026, 6, 3, 10, 30); // any day
      await seed(
        categories: defaultCategories,
        txns: [
          makeTransaction(
            amount: 300,
            categoryId: '1',
            createdAt: DateTime(2026, 6, 2, 12), // yesterday + this week/month/year
          ),
          makeTransaction(
            amount: 200,
            categoryId: '2',
            createdAt: DateTime(2026, 6, 2, 13),
          ),
        ],
      );

      await StoryGenerationService(isar).generateDue(now: now);
      final rows = await StoryRepository(isar).all();

      expect(rows.any((r) => r.storyKey == 'recap_day_2026_06_02'), isTrue);
      expect(rows.any((r) => r.storyKey == 'recap_week_2026_W23'), isTrue);
      expect(rows.any((r) => r.storyKey == 'recap_month_2026_06'), isTrue);
      expect(rows.any((r) => r.storyKey == 'recap_year_2026'), isTrue);

      for (final r in rows) {
        expect(
          r.expiresAt,
          r.generatedAt.add(const Duration(hours: 48)),
          reason: '${r.storyKey} must use the unified 48h TTL',
        );
      }
    });

    test('current-period recaps refresh in place (no duplicates)', () async {
      await seed(
        categories: defaultCategories,
        txns: [
          makeTransaction(
            amount: 300,
            categoryId: '1',
            createdAt: DateTime(2026, 6, 2, 12),
          ),
        ],
      );

      final service = StoryGenerationService(isar);
      await service.generateDue(now: DateTime(2026, 6, 3, 12));
      await service.generateDue(now: DateTime(2026, 6, 4, 12)); // next day, same period

      final rows = await StoryRepository(isar).all();
      expect(rows.where((r) => r.storyKey == 'recap_week_2026_W23').length, 1);
      expect(rows.where((r) => r.storyKey == 'recap_month_2026_06').length, 1);
      expect(rows.where((r) => r.storyKey == 'recap_year_2026').length, 1);
    });
  });

  group('pace comparisons', () {
    test('daily pace reports "You slowed down" below the average', () async {
      final now = DateTime(2026, 6, 3, 18); // Wed
      await seed(
        categories: defaultCategories,
        txns: [
          // Today: a small spend.
          makeTransaction(
            amount: 50,
            categoryId: '1',
            createdAt: DateTime(2026, 6, 3, 9),
          ),
          // Trailing 30 days: one big spend so the daily average is ~100.
          makeTransaction(
            amount: 3000,
            categoryId: '1',
            createdAt: DateTime(2026, 5, 20, 12),
          ),
        ],
      );

      await StoryGenerationService(isar).generateDue(now: now);
      final rows = await StoryRepository(isar).all();

      final pace = rows.firstWhere(
        (r) => r.storyKey == 'compare_day_2026_06_03',
      );
      expect(pace.type, 'recap_day');
      expect(pace.payloadJson.contains('You slowed down'), isTrue);
      expect(pace.payloadJson.contains('less'), isTrue);
    });

    test('weekly pace updates in place across days in the same week', () async {
      final txns = [
        makeTransaction(
          amount: 500,
          categoryId: '1',
          createdAt: DateTime(2026, 6, 8, 10), // this week
        ),
        makeTransaction(
          amount: 400,
          categoryId: '1',
          createdAt: DateTime(2026, 6, 1, 10), // last week, same DOW
        ),
      ];
      await seed(categories: defaultCategories, txns: txns);

      final service = StoryGenerationService(isar);
      await service.generateDue(now: DateTime(2026, 6, 8, 12)); // Mon
      await service.generateDue(now: DateTime(2026, 6, 9, 12)); // Tue, same week

      final rows = await StoryRepository(isar).all();
      final weekly = rows
          .where((r) => r.storyKey.startsWith('compare_week_'))
          .toList();
      expect(weekly.length, 1, reason: 'one pace story per week, refreshed');
      expect(weekly.single.generatedAt, DateTime(2026, 6, 9, 12));
    });

    test('pace skips generation when the prior period had no spend', () async {
      final now = DateTime(2026, 6, 3, 18); // Wed
      await seed(
        categories: defaultCategories,
        txns: [
          // This week only — no prior-week or prior-month data.
          makeTransaction(
            amount: 500,
            categoryId: '1',
            createdAt: DateTime(2026, 6, 2, 10),
          ),
        ],
      );

      await StoryGenerationService(isar).generateDue(now: now);
      final rows = await StoryRepository(isar).all();

      expect(rows.where((r) => r.storyKey.startsWith('compare_week_')), isEmpty);
      expect(rows.where((r) => r.storyKey.startsWith('compare_month_')), isEmpty);
    });
  });

  group('entity cadence dedup', () {
    test('loan / ledger / investment generate once within the window', () async {
      final now = DateTime(2026, 6, 3, 10);
      await seed(
        categories: defaultCategories,
        loans: [makeLoan(uid: 'L1', name: 'Bike Loan')],
        ledgers: [makeLedger(uid: 'G1', personName: 'Rahul')],
        investments: [
          makeInvestment(uid: 'I1', investedAmount: 1000, currentValue: 1200),
        ],
      );

      final service = StoryGenerationService(isar);
      await service.generateDue(now: now);
      await service.generateDue(now: now); // second pass, same day

      final rows = await StoryRepository(isar).all();
      expect(rows.where((r) => r.storyKey == 'loans_L1').length, 1);
      expect(rows.where((r) => r.storyKey == 'ledger_G1').length, 1);
      expect(rows.where((r) => r.storyKey.startsWith('investments_')).length, 1);
    });
  });

  group('cleanup', () {
    test('deleteOlderThan removes only rows past the retention cutoff', () async {
      final now = DateTime(2026, 6, 3, 10);
      InsightStory story(String key, DateTime expiresAt) => InsightStory()
        ..storyKey = key
        ..type = 'recap_day'
        ..generatedAt = expiresAt.subtract(const Duration(hours: 48))
        ..expiresAt = expiresAt
        ..payloadJson = '[]';

      final repo = StoryRepository(isar);
      await repo.putAll([
        story('old', now.subtract(const Duration(days: 31))),
        story('recent_tombstone', now.subtract(const Duration(days: 5))),
      ]);

      await repo.deleteOlderThan(now.subtract(const Duration(days: 30)));
      final rows = await repo.all();

      expect(rows.any((r) => r.storyKey == 'old'), isFalse);
      expect(rows.any((r) => r.storyKey == 'recent_tombstone'), isTrue);
      // Both are expired, so neither is "active".
      expect(await repo.listActive(now), isEmpty);
    });
  });
}
