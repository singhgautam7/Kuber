import 'package:mocktail/mocktail.dart';
import 'package:kuber/features/transactions/data/transaction_repository.dart';
import 'package:kuber/features/budgets/data/budget_repository.dart';
import 'package:kuber/features/accounts/data/account_repository.dart';
import 'package:kuber/features/categories/data/category_repository.dart';
import 'package:kuber/features/recurring/data/recurring_repository.dart';
import 'package:kuber/features/tags/data/tag_repository.dart';
import 'package:kuber/core/services/notification_service.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockRecurringRepository extends Mock implements RecurringRepository {}

class MockTagRepository extends Mock implements TagRepository {}

class MockNotificationService extends Mock implements NotificationService {}
