import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kuber/features/recurring/data/recurring_repository.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  late Isar isar;
  late RecurringRepository repo;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
    repo = RecurringRepository(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  group('CRUD', () {
    test('save persists rule', () async {
      final rule = makeRecurringRule(name: 'Netflix');
      await repo.save(rule);
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.name, 'Netflix');
    });

    test('save sets createdAt on new rule', () async {
      final rule = makeRecurringRule();
      await repo.save(rule);
      final all = await repo.getAll();
      expect(all.first.createdAt, isNotNull);
    });

    test('delete removes rule', () async {
      final rule = makeRecurringRule();
      await repo.save(rule);
      final all = await repo.getAll();
      await repo.delete(all.first.id);
      expect(await repo.getAll(), isEmpty);
    });
  });

  group('getActive', () {
    test('excludes paused rules', () async {
      await repo.save(makeRecurringRule(name: 'Active'));
      await repo.save(makeRecurringRule(name: 'Paused', isPaused: true));
      final active = await repo.getActive();
      expect(active.length, 1);
      expect(active.first.name, 'Active');
    });
  });

  group('getDue', () {
    test('returns rules with nextDueAt before now', () async {
      await repo.save(makeRecurringRule(
        name: 'Overdue',
        nextDueAt: DateTime.now().subtract(const Duration(days: 1)),
      ));
      await repo.save(makeRecurringRule(
        name: 'Future',
        nextDueAt: DateTime.now().add(const Duration(days: 7)),
      ));
      final due = await repo.getDue(DateTime.now());
      expect(due.length, 1);
      expect(due.first.name, 'Overdue');
    });

    test('excludes paused rules', () async {
      await repo.save(makeRecurringRule(
        name: 'Paused overdue',
        nextDueAt: DateTime.now().subtract(const Duration(days: 1)),
        isPaused: true,
      ));
      final due = await repo.getDue(DateTime.now());
      expect(due, isEmpty);
    });
  });

  group('computeNextDue', () {
    test('daily adds 1 day', () {
      final rule = makeRecurringRule(frequency: 'daily');
      final from = DateTime(2024, 3, 15);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2024, 3, 16));
    });

    test('weekly adds 7 days', () {
      final rule = makeRecurringRule(frequency: 'weekly');
      final from = DateTime(2024, 3, 15);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2024, 3, 22));
    });

    test('biweekly adds 14 days', () {
      final rule = makeRecurringRule(frequency: 'biweekly');
      final from = DateTime(2024, 3, 15);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2024, 3, 29));
    });

    test('monthly advances to next month', () {
      final rule = makeRecurringRule(frequency: 'monthly');
      final from = DateTime(2024, 3, 15);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2024, 4, 15));
    });

    test('monthly handles month overflow (Jan 31 → Feb 28)', () {
      final rule = makeRecurringRule(frequency: 'monthly');
      final from = DateTime(2024, 1, 31);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2024, 2, 29)); // 2024 is leap year
    });

    test('monthly handles month overflow (Jan 31 → Feb 28 non-leap)', () {
      final rule = makeRecurringRule(frequency: 'monthly');
      final from = DateTime(2023, 1, 31);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2023, 2, 28));
    });

    test('monthly handles December → January', () {
      final rule = makeRecurringRule(frequency: 'monthly');
      final from = DateTime(2024, 12, 15);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2025, 1, 15));
    });

    test('yearly adds 1 year', () {
      final rule = makeRecurringRule(frequency: 'yearly');
      final from = DateTime(2024, 6, 15);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2025, 6, 15));
    });

    test('yearly handles leap year (Feb 29 → Feb 28)', () {
      final rule = makeRecurringRule(frequency: 'yearly');
      final from = DateTime(2024, 2, 29);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2025, 2, 28));
    });

    test('custom uses customDays', () {
      final rule = makeRecurringRule(frequency: 'custom', customDays: 10);
      final from = DateTime(2024, 3, 15);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2024, 3, 25));
    });

    test('custom defaults to 1 day if customDays is null', () {
      final rule = makeRecurringRule(frequency: 'custom');
      final from = DateTime(2024, 3, 15);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2024, 3, 16));
    });

    test('unknown frequency defaults to daily', () {
      final rule = makeRecurringRule(frequency: 'unknown');
      final from = DateTime(2024, 3, 15);
      expect(RecurringRepository.computeNextDue(rule, from), DateTime(2024, 3, 16));
    });
  });

  group('isExpired', () {
    test('never end type is never expired', () {
      final rule = makeRecurringRule(endType: 'never');
      expect(RecurringRepository.isExpired(rule), false);
    });

    test('occurrences: expired when count >= endAfter', () {
      final rule = makeRecurringRule(
        endType: 'occurrences',
        endAfter: 3,
        executionCount: 3,
      );
      expect(RecurringRepository.isExpired(rule), true);
    });

    test('occurrences: not expired when count < endAfter', () {
      final rule = makeRecurringRule(
        endType: 'occurrences',
        endAfter: 3,
        executionCount: 2,
      );
      expect(RecurringRepository.isExpired(rule), false);
    });

    test('date: expired when now is after endDate', () {
      final rule = makeRecurringRule(
        endType: 'date',
        endDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(RecurringRepository.isExpired(rule), true);
    });

    test('date: not expired when now is before endDate', () {
      final rule = makeRecurringRule(
        endType: 'date',
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      expect(RecurringRepository.isExpired(rule), false);
    });

    test('unknown endType is never expired', () {
      final rule = makeRecurringRule(endType: 'something_else');
      expect(RecurringRepository.isExpired(rule), false);
    });
  });
}
