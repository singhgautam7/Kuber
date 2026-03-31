import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/budgets/data/budget_repository.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  late Isar isar;
  late BudgetRepository repo;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
    repo = BudgetRepository(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  group('Budget CRUD', () {
    test('saveBudget persists with alerts', () async {
      final budget = makeBudget(categoryId: '1');
      final alerts = [
        makeAlert(type: BudgetAlertType.percentage, value: 80),
        makeAlert(type: BudgetAlertType.amount, value: 4000),
      ];
      final id = await repo.saveBudget(budget, alerts);

      final saved = await isar.budgets.get(id);
      expect(saved, isNotNull);
      expect(saved!.alerts.length, 2);
      expect(saved.alerts[0].type, BudgetAlertType.percentage);
      expect(saved.alerts[0].value, 80);
      expect(saved.alerts[1].type, BudgetAlertType.amount);
    });

    test('getAll returns all budgets', () async {
      await repo.saveBudget(makeBudget(categoryId: '1'), []);
      await repo.saveBudget(makeBudget(categoryId: '2'), []);
      final all = await repo.getAll();
      expect(all.length, 2);
    });

    test('deleteBudget removes it', () async {
      final id = await repo.saveBudget(makeBudget(), []);
      await repo.deleteBudget(id);
      final all = await repo.getAll();
      expect(all, isEmpty);
    });
  });

  group('getByCategory', () {
    test('returns active budget for category', () async {
      await repo.saveBudget(
        makeBudget(categoryId: '5', isActive: true),
        [],
      );
      final found = await repo.getByCategory('5');
      expect(found, isNotNull);
      expect(found!.categoryId, '5');
    });

    test('returns null for inactive budget', () async {
      await repo.saveBudget(
        makeBudget(categoryId: '5', isActive: false),
        [],
      );
      final found = await repo.getByCategory('5');
      expect(found, isNull);
    });

    test('returns null when no budget exists', () async {
      final found = await repo.getByCategory('99');
      expect(found, isNull);
    });
  });

  group('setBudgetActive', () {
    test('toggles active state', () async {
      final id = await repo.saveBudget(makeBudget(isActive: true), []);
      await repo.setBudgetActive(id, false);
      final budget = await isar.budgets.get(id);
      expect(budget!.isActive, false);
    });
  });

  group('getAlerts', () {
    test('returns alerts for budget', () async {
      final id = await repo.saveBudget(
        makeBudget(),
        [makeAlert(value: 50), makeAlert(value: 90)],
      );
      final alerts = await repo.getAlerts(id);
      expect(alerts.length, 2);
    });

    test('returns empty for nonexistent budget', () async {
      final alerts = await repo.getAlerts(999);
      expect(alerts, isEmpty);
    });
  });

  group('calculateUsage', () {
    test('sums expenses in range for category', () async {
      // Insert transactions directly
      await isar.writeTxn(() async {
        await isar.transactions.put(makeTransaction(
          categoryId: '1',
          type: 'expense',
          amount: 200,
          createdAt: DateTime(2024, 3, 10),
        ));
        await isar.transactions.put(makeTransaction(
          categoryId: '1',
          type: 'expense',
          amount: 300,
          createdAt: DateTime(2024, 3, 20),
        ));
        // Different category
        await isar.transactions.put(makeTransaction(
          categoryId: '2',
          type: 'expense',
          amount: 1000,
          createdAt: DateTime(2024, 3, 15),
        ));
        // Income should be excluded
        await isar.transactions.put(makeTransaction(
          categoryId: '1',
          type: 'income',
          amount: 500,
          createdAt: DateTime(2024, 3, 15),
        ));
      });

      final usage = await repo.calculateUsage(
        '1',
        DateTime(2024, 3, 1),
        DateTime(2024, 3, 31),
      );
      expect(usage, 500);
    });

    test('returns 0 when no matching transactions', () async {
      final usage = await repo.calculateUsage(
        '1',
        DateTime(2024, 3, 1),
        DateTime(2024, 3, 31),
      );
      expect(usage, 0);
    });
  });

  group('evaluateBudgets', () {
    test('resets alerts on new period', () async {
      final budget = makeBudget(isActive: true, isRecurring: true);
      budget.lastEvaluatedAt = DateTime(2024, 1, 15); // Old month
      final alerts = [makeAlert(isTriggered: true)];
      final id = await repo.saveBudget(budget, alerts);

      await repo.evaluateBudgets();

      final evaluated = await isar.budgets.get(id);
      expect(evaluated!.alerts.first.isTriggered, false);
      expect(evaluated.lastEvaluatedAt, isNotNull);
    });

    test('deactivates non-recurring budget from old month', () async {
      final budget = makeBudget(
        isActive: true,
        isRecurring: false,
        startDate: DateTime(2020, 1, 1),
      );
      final id = await repo.saveBudget(budget, []);

      await repo.evaluateBudgets();

      final evaluated = await isar.budgets.get(id);
      expect(evaluated!.isActive, false);
    });

    test('skips inactive budgets', () async {
      final budget = makeBudget(isActive: false, isRecurring: true);
      budget.lastEvaluatedAt = DateTime(2020, 1, 1);
      final id = await repo.saveBudget(budget, [makeAlert(isTriggered: true)]);

      await repo.evaluateBudgets();

      final evaluated = await isar.budgets.get(id);
      // Alert should remain triggered since budget is inactive
      expect(evaluated!.alerts.first.isTriggered, true);
    });
  });
}
