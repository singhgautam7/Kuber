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

  group('rollover recap highlights', () {
    test('recaps cover the last completed period; all use the 48h TTL',
        () async {
      final now = DateTime(2026, 6, 3, 10, 30); // Wed
      await seed(
        categories: defaultCategories,
        txns: [
          makeTransaction(
            amount: 300,
            categoryId: '1',
            createdAt: DateTime(2026, 6, 2, 12), // yesterday
          ),
          makeTransaction(
            amount: 1000,
            categoryId: '1',
            createdAt: DateTime(2026, 5, 28, 12), // last week + last month
          ),
          makeTransaction(
            amount: 500,
            categoryId: '2',
            createdAt: DateTime(2026, 5, 15, 12), // last month
          ),
          makeTransaction(
            amount: 2000,
            categoryId: '1',
            createdAt: DateTime(2025, 7, 10, 12), // last year (2025)
          ),
        ],
      );

      await StoryGenerationService(isar).generateDue(now: now);
      final rows = await StoryRepository(isar).all();

      expect(rows.any((r) => r.storyKey == 'recap_day_2026_06_02'), isTrue);
      expect(rows.any((r) => r.storyKey == 'recap_week_2026_W22'), isTrue);
      expect(rows.any((r) => r.storyKey == 'recap_month_2026_05'), isTrue);
      expect(rows.any((r) => r.storyKey == 'recap_year_2025'), isTrue);

      for (final r in rows) {
        expect(
          r.expiresAt,
          r.generatedAt.add(const Duration(hours: 48)),
          reason: '${r.storyKey} must use the unified 48h TTL',
        );
      }
    });

    test('a recap is generated once and not refreshed (so it expires)',
        () async {
      await seed(
        categories: defaultCategories,
        txns: [
          makeTransaction(
            amount: 800,
            categoryId: '1',
            createdAt: DateTime(2026, 5, 28, 12), // last week
          ),
        ],
      );

      final service = StoryGenerationService(isar);
      await service.generateDue(now: DateTime(2026, 6, 3, 12)); // Wed
      await service.generateDue(now: DateTime(2026, 6, 4, 12)); // Thu, same week

      final weekly = (await StoryRepository(isar).all())
          .where((r) => r.storyKey == 'recap_week_2026_W22')
          .toList();
      expect(weekly.length, 1);
      // Not refreshed on the second run, so it still expires 48h after the first.
      expect(weekly.single.generatedAt, DateTime(2026, 6, 3, 12));
    });
  });

  group('recap comparisons', () {
    test('weekly compares last week vs the week before, with named ranges',
        () async {
      final now = DateTime(2026, 6, 3, 10); // Wed
      await seed(
        categories: defaultCategories,
        txns: [
          makeTransaction(
            amount: 800,
            categoryId: '1',
            createdAt: DateTime(2026, 5, 28, 12), // last week (25 to 31 May)
          ),
          makeTransaction(
            amount: 400,
            categoryId: '1',
            createdAt: DateTime(2026, 5, 20, 12), // week before (18 to 24 May)
          ),
        ],
      );

      await StoryGenerationService(isar).generateDue(now: now);
      final weekly = (await StoryRepository(isar).all())
          .firstWhere((r) => r.storyKey == 'recap_week_2026_W22');

      expect(weekly.payloadJson.contains('This Week (25 to 31 May)'), isTrue);
      expect(weekly.payloadJson.contains('Previous Week (18 to 24 May)'), isTrue);
    });

    test('monthly shows This Month and Previous Month names', () async {
      final now = DateTime(2026, 6, 3, 10); // Wed
      await seed(
        categories: defaultCategories,
        txns: [
          makeTransaction(
            amount: 5000,
            categoryId: '1',
            createdAt: DateTime(2026, 5, 15, 12), // last month (May)
          ),
          makeTransaction(
            amount: 3000,
            categoryId: '1',
            createdAt: DateTime(2026, 4, 15, 12), // month before (April)
          ),
        ],
      );

      await StoryGenerationService(isar).generateDue(now: now);
      final monthly = (await StoryRepository(isar).all())
          .firstWhere((r) => r.storyKey == 'recap_month_2026_05');

      expect(monthly.payloadJson.contains('This Month (May)'), isTrue);
      expect(monthly.payloadJson.contains('Previous Month (April)'), isTrue);
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

    test('insights are consolidated into a single story (not one per insight)',
        () async {
      // Enough varied spending to trigger insight(s).
      await seed(
        categories: defaultCategories,
        txns: [
          for (var i = 1; i <= 15; i++)
            makeTransaction(
              amount: 100.0 + i * 10,
              categoryId: i.isEven ? '1' : '2',
              createdAt: DateTime(2026, 5, i, 10),
            ),
        ],
      );

      await StoryGenerationService(isar).generateDue(now: DateTime(2026, 6, 3, 10));
      final insightRows = (await StoryRepository(isar).all())
          .where((r) => r.type == 'insights')
          .toList();
      expect(insightRows.length, lessThanOrEqualTo(1));
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
