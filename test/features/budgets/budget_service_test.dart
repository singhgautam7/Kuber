import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/budgets/data/budget_repository.dart';
import 'package:kuber/features/budgets/services/budget_service.dart'
    show budgetServiceProvider;
import 'package:kuber/features/categories/providers/category_provider.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/core/services/notification_service.dart';
import 'package:kuber/core/utils/formatters.dart';
import '../../helpers/mock_repositories.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/riverpod_test_helper.dart';

void main() {
  late MockBudgetRepository mockBudgetRepo;
  late MockCategoryRepository mockCategoryRepo;
  late MockNotificationService mockNotification;
  late ProviderContainer container;

  setUp(() {
    mockBudgetRepo = MockBudgetRepository();
    mockCategoryRepo = MockCategoryRepository();
    mockNotification = MockNotificationService();

    container = createTestContainer(
      overrides: [
        budgetRepositoryProvider.overrideWithValue(mockBudgetRepo),
        categoryRepositoryProvider.overrideWithValue(mockCategoryRepo),
        notificationServiceProvider.overrideWithValue(mockNotification),
        formatterProvider.overrideWithValue(AppFormatter()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(Budget());
    registerFallbackValue(<BudgetAlert>[]);
  });

  group('BudgetService.checkAlerts', () {
    test('no-op when no budget for category', () async {
      when(() => mockBudgetRepo.getByCategory('1'))
          .thenAnswer((_) async => null);

      final service = container.read(budgetServiceProvider);
      await service.checkAlerts('1');

      verifyNever(() => mockBudgetRepo.saveBudget(any(), any()));
    });

    test('no-op when budget is inactive', () async {
      final budget = makeBudget(isActive: false);
      when(() => mockBudgetRepo.getByCategory('1'))
          .thenAnswer((_) async => budget);

      final service = container.read(budgetServiceProvider);
      await service.checkAlerts('1');

      verifyNever(() => mockBudgetRepo.saveBudget(any(), any()));
    });

    test('does not trigger when below threshold', () async {
      final budget = makeBudget(
        categoryId: '1',
        amount: 5000,
        periodType: BudgetPeriodType.monthly,
        alerts: [makeAlert(type: BudgetAlertType.percentage, value: 80)],
      );
      when(() => mockBudgetRepo.getByCategory('1'))
          .thenAnswer((_) async => budget);
      when(() => mockBudgetRepo.calculateUsage(any(), any(), any()))
          .thenAnswer((_) async => 3000); // 60% < 80%

      final service = container.read(budgetServiceProvider);
      await service.checkAlerts('1');

      verifyNever(() => mockBudgetRepo.saveBudget(any(), any()));
    });

    test('triggers percentage alert when threshold crossed', () async {
      final alert = makeAlert(
        type: BudgetAlertType.percentage,
        value: 80,
        isTriggered: false,
        enableNotification: true,
      );
      final budget = makeBudget(
        categoryId: '1',
        amount: 5000,
        periodType: BudgetPeriodType.monthly,
        alerts: [alert],
      );
      budget.id = 1;

      when(() => mockBudgetRepo.getByCategory('1'))
          .thenAnswer((_) async => budget);
      when(() => mockBudgetRepo.calculateUsage(any(), any(), any()))
          .thenAnswer((_) async => 4100); // 82% > 80%

      final cat = makeCategory(id: 1, name: 'Food');
      when(() => mockCategoryRepo.getAll())
          .thenAnswer((_) async => [cat]);
      when(() => mockNotification.showBudgetAlertNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async {});
      when(() => mockBudgetRepo.saveBudget(any(), any()))
          .thenAnswer((_) async => 1);

      final service = container.read(budgetServiceProvider);
      await service.checkAlerts('1');

      verify(() => mockBudgetRepo.saveBudget(any(), any())).called(1);
      verify(() => mockNotification.showBudgetAlertNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('triggers amount alert when threshold crossed', () async {
      final alert = makeAlert(
        type: BudgetAlertType.amount,
        value: 3000,
        isTriggered: false,
        enableNotification: true,
      );
      final budget = makeBudget(
        categoryId: '1',
        amount: 5000,
        periodType: BudgetPeriodType.monthly,
        alerts: [alert],
      );
      budget.id = 1;

      when(() => mockBudgetRepo.getByCategory('1'))
          .thenAnswer((_) async => budget);
      when(() => mockBudgetRepo.calculateUsage(any(), any(), any()))
          .thenAnswer((_) async => 3500);

      final cat = makeCategory(id: 1, name: 'Food');
      when(() => mockCategoryRepo.getAll())
          .thenAnswer((_) async => [cat]);
      when(() => mockNotification.showBudgetAlertNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          )).thenAnswer((_) async {});
      when(() => mockBudgetRepo.saveBudget(any(), any()))
          .thenAnswer((_) async => 1);

      final service = container.read(budgetServiceProvider);
      await service.checkAlerts('1');

      verify(() => mockBudgetRepo.saveBudget(any(), any())).called(1);
    });

    test('notification disabled: triggers but no notification', () async {
      final alert = makeAlert(
        type: BudgetAlertType.percentage,
        value: 80,
        isTriggered: false,
        enableNotification: false,
      );
      final budget = makeBudget(
        categoryId: '1',
        amount: 5000,
        periodType: BudgetPeriodType.monthly,
        alerts: [alert],
      );
      budget.id = 1;

      when(() => mockBudgetRepo.getByCategory('1'))
          .thenAnswer((_) async => budget);
      when(() => mockBudgetRepo.calculateUsage(any(), any(), any()))
          .thenAnswer((_) async => 4500); // 90% > 80%
      when(() => mockBudgetRepo.saveBudget(any(), any()))
          .thenAnswer((_) async => 1);

      final service = container.read(budgetServiceProvider);
      await service.checkAlerts('1');

      verify(() => mockBudgetRepo.saveBudget(any(), any())).called(1);
      verifyNever(() => mockNotification.showBudgetAlertNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
          ));
    });

    test('resets alert when spending drops below threshold', () async {
      final alert = makeAlert(
        type: BudgetAlertType.percentage,
        value: 80,
        isTriggered: true, // already triggered
      );
      final budget = makeBudget(
        categoryId: '1',
        amount: 5000,
        periodType: BudgetPeriodType.monthly,
        alerts: [alert],
      );
      budget.id = 1;

      when(() => mockBudgetRepo.getByCategory('1'))
          .thenAnswer((_) async => budget);
      when(() => mockBudgetRepo.calculateUsage(any(), any(), any()))
          .thenAnswer((_) async => 2000); // 40% < 80%
      when(() => mockBudgetRepo.saveBudget(any(), any()))
          .thenAnswer((_) async => 1);

      final service = container.read(budgetServiceProvider);
      await service.checkAlerts('1');

      verify(() => mockBudgetRepo.saveBudget(any(), any())).called(1);
    });
  });

  group('BudgetService.init', () {
    test('calls evaluateBudgets', () async {
      when(() => mockBudgetRepo.evaluateBudgets())
          .thenAnswer((_) async {});

      final service = container.read(budgetServiceProvider);
      await service.init();

      verify(() => mockBudgetRepo.evaluateBudgets()).called(1);
    });
  });
}
