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
import '../../helpers/test_factories.dart';

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
    when(() => mockBudgetRepo.watchBudgets())
        .thenAnswer((_) => Stream.value([]));
    when(() => mockCategoryRepo.getAll()).thenAnswer((_) async => []);
    when(() => mockAttachments.deleteAllForTransaction(any()))
        .thenAnswer((_) async {});

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

  tearDown(() {
    container.dispose();
  });

  group('TransactionListNotifier', () {
    test('build calls getAll', () async {
      final txns = [makeTransaction(name: 'Test')];
      when(() => mockRepo.getAll()).thenAnswer((_) async => txns);

      final result = await container.read(transactionListProvider.future);
      expect(result.length, 1);
      expect(result.first.name, 'Test');
      verify(() => mockRepo.getAll()).called(1);
    });

    test('add saves and invalidates', () async {
      when(() => mockRepo.save(any())).thenAnswer((_) async => 1);
      when(() => mockBudgetRepo.getByCategory(any()))
          .thenAnswer((_) async => null);

      // Wait for initial build
      await container.read(transactionListProvider.future);

      final t = makeTransaction(name: 'New', type: 'expense', categoryId: '1');
      final id = await container
          .read(transactionListProvider.notifier)
          .add(t);
      expect(id, 1);
      verify(() => mockRepo.save(any())).called(1);
    });

    test('delete calls deleteTransferPair for transfers', () async {
      final transfer = makeTransaction(
        id: 5,
        isTransfer: true,
        transferId: 'tf123',
      );
      when(() => mockRepo.getById(5)).thenAnswer((_) async => transfer);
      when(() => mockRepo.findTransferPair('tf123', 5))
          .thenAnswer((_) async => null);
      when(() => mockRepo.deleteTransferPair('tf123'))
          .thenAnswer((_) async {});

      // Wait for initial build
      await container.read(transactionListProvider.future);

      await container.read(transactionListProvider.notifier).delete(5);
      verify(() => mockRepo.deleteTransferPair('tf123')).called(1);
      verifyNever(() => mockRepo.delete(5));
    });

    test('delete calls delete for non-transfer', () async {
      final normal = makeTransaction(id: 5, isTransfer: false);
      when(() => mockRepo.getById(5)).thenAnswer((_) async => normal);
      when(() => mockRepo.delete(5)).thenAnswer((_) async {});
      when(() => mockBudgetRepo.getByCategory(any()))
          .thenAnswer((_) async => null);

      await container.read(transactionListProvider.future);

      await container.read(transactionListProvider.notifier).delete(5);
      verify(() => mockRepo.delete(5)).called(1);
    });
  });
}
