import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/budgets/data/budget_repository.dart';
import 'package:kuber/features/categories/providers/category_provider.dart';
import 'package:kuber/core/services/notification_service.dart';
import 'package:kuber/core/services/attachment_service.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import '../../helpers/mock_repositories.dart';

/// Tests the balance-adjustment creation logic that was moved verbatim from the
/// old EditBalanceSheet into TransactionListNotifier.addBalanceAdjustment.
/// The name / sign / type / nameLower must be identical to the legacy behavior.
void main() {
  late MockTransactionRepository mockRepo;
  late MockBudgetRepository mockBudgetRepo;
  late MockCategoryRepository mockCategoryRepo;
  late MockNotificationService mockNotification;
  late MockAttachmentService mockAttachments;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(Transaction()
      ..name = ''
      ..nameLower = ''
      ..amount = 0
      ..type = 'expense'
      ..categoryId = ''
      ..accountId = ''
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now());
    registerFallbackValue(Budget());
    registerFallbackValue(<BudgetAlert>[]);
  });

  setUp(() {
    mockRepo = MockTransactionRepository();
    mockBudgetRepo = MockBudgetRepository();
    mockCategoryRepo = MockCategoryRepository();
    mockNotification = MockNotificationService();
    mockAttachments = MockAttachmentService();

    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    when(() => mockRepo.save(any())).thenAnswer((_) async => 1);
    when(() => mockBudgetRepo.watchBudgets())
        .thenAnswer((_) => Stream.value([]));
    when(() => mockBudgetRepo.getByCategory(any())).thenAnswer((_) async => null);
    when(() => mockCategoryRepo.getAll()).thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(mockRepo),
        budgetRepositoryProvider.overrideWithValue(mockBudgetRepo),
        categoryRepositoryProvider.overrideWithValue(mockCategoryRepo),
        notificationServiceProvider.overrideWithValue(mockNotification),
        formatterProvider.overrideWithValue(AppFormatter()),
        attachmentServiceProvider.overrideWithValue(mockAttachments),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<Transaction> capturedAdjustment({
    required int accountId,
    required double diff,
    required bool isCredit,
  }) async {
    await container.read(transactionListProvider.future);
    await container.read(transactionListProvider.notifier).addBalanceAdjustment(
          accountId: accountId,
          diff: diff,
          isCredit: isCredit,
        );
    return verify(() => mockRepo.save(captureAny())).captured.single
        as Transaction;
  }

  group('addBalanceAdjustment', () {
    test('positive diff (bank) → income "Balance Adjustment"', () async {
      final t = await capturedAdjustment(
          accountId: 7, diff: 500, isCredit: false);
      expect(t.name, 'Balance Adjustment');
      expect(t.nameLower, 'balance adjustment');
      expect(t.type, 'income');
      expect(t.amount, 500);
      expect(t.accountId, '7');
      expect(t.categoryId, '');
      expect(t.isBalanceAdjustment, isTrue);
    });

    test('negative diff (bank) → expense, absolute amount', () async {
      final t = await capturedAdjustment(
          accountId: 7, diff: -200, isCredit: false);
      expect(t.type, 'expense');
      expect(t.amount, 200);
      expect(t.name, 'Balance Adjustment');
    });

    test('credit positive diff → income "Limit Spent Adjustment"', () async {
      final t = await capturedAdjustment(
          accountId: 3, diff: 300, isCredit: true);
      expect(t.name, 'Limit Spent Adjustment');
      expect(t.nameLower, 'limit spent adjustment');
      expect(t.type, 'income');
      expect(t.amount, 300);
    });

    test('credit negative diff → expense "Limit Spent Adjustment"', () async {
      final t = await capturedAdjustment(
          accountId: 3, diff: -150, isCredit: true);
      expect(t.name, 'Limit Spent Adjustment');
      expect(t.type, 'expense');
      expect(t.amount, 150);
    });
  });
}
