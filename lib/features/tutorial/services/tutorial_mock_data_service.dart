import 'package:isar_community/isar.dart';

import '../../../features/accounts/data/account.dart';
import '../../../features/budgets/data/budget.dart';
import '../../../features/categories/data/category.dart';
import '../../../features/categories/data/category_group.dart';
import '../../../features/ledger/data/ledger.dart';
import '../../../features/recurring/data/recurring_rule.dart';
import '../../../features/transactions/data/transaction.dart';
import '../../../features/transactions/data/transaction_suggestion.dart';

class TutorialMockDataService {
  Future<void> generateMockData(Isar isar) async {
    final now = DateTime.now();

    await isar.writeTxn(() async {
      // ── Accounts ──
      final wallet = Account()
        ..name = 'Wallet'
        ..type = 'cash'
        ..icon = 'payments_outlined'
        ..colorValue = 0xFF9E9E9E
        ..initialBalance = 5000;

      final hdfc = Account()
        ..name = 'HDFC Bank'
        ..type = 'bank'
        ..icon = 'account_balance_outlined'
        ..colorValue = 0xFF2196F3
        ..initialBalance = 45000;

      await isar.accounts.putAll([wallet, hdfc]);
      final walletId = wallet.id.toString();
      final hdfcId = hdfc.id.toString();

      // ── Category Group ──
      final group = CategoryGroup()..name = 'TUTORIAL';
      final groupId = await isar.categoryGroups.put(group);

      // ── Categories ──
      final food = _cat('Food', 'restaurant', 0xFFFF5722, 'expense', groupId);
      final transport =
          _cat('Transport', 'commute', 0xFF2196F3, 'expense', groupId);
      final shopping =
          _cat('Shopping', 'shopping_bag', 0xFFE91E63, 'expense', groupId);
      final salary =
          _cat('Salary', 'account_balance_wallet', 0xFF4CAF50, 'income', groupId);
      final entertainment =
          _cat('Entertainment', 'movie', 0xFF9C27B0, 'expense', groupId);

      await isar.categorys
          .putAll([food, transport, shopping, salary, entertainment]);

      final foodId = food.id.toString();
      final transportId = transport.id.toString();
      final shoppingId = shopping.id.toString();
      final salaryId = salary.id.toString();
      final entertainmentId = entertainment.id.toString();

      // ── Transactions (10, spread over last 7 days) ──
      final txns = <Transaction>[
        _txn('Salary', 25000, 'income', salaryId, hdfcId,
            now.subtract(const Duration(days: 6))),
        _txn('Salary Advance', 20000, 'income', salaryId, hdfcId,
            now.subtract(const Duration(days: 5))),
        _txn('Monthly Bonus', 21667, 'income', salaryId, hdfcId,
            now.subtract(const Duration(days: 4))),
        _txn('Restaurant dinner', 850, 'expense', foodId, walletId,
            now.subtract(const Duration(days: 6))),
        _txn('Grocery run', 1240, 'expense', foodId, walletId,
            now.subtract(const Duration(days: 5))),
        _txn('Coffee', 120, 'expense', foodId, walletId,
            now.subtract(const Duration(days: 4))),
        _txn('Metro card recharge', 500, 'expense', transportId, walletId,
            now.subtract(const Duration(days: 3))),
        _txn('Cab ride', 380, 'expense', transportId, walletId,
            now.subtract(const Duration(days: 2))),
        _txn('T-shirt', 1800, 'expense', shoppingId, hdfcId,
            now.subtract(const Duration(days: 1))),
        _txn('Movie tickets', 650, 'expense', entertainmentId, walletId,
            now),
      ];
      await isar.transactions.putAll(txns);

      // ── Budget (1) ──
      final budget = Budget()
        ..categoryId = foodId
        ..amount = 5000
        ..periodType = BudgetPeriodType.monthly
        ..startDate = DateTime(now.year, now.month, 1)
        ..isRecurring = true
        ..updatedAt = now;
      await isar.budgets.put(budget);

      // ── Recurring Rule (1) ──
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final rule = RecurringRule()
        ..name = 'Salary'
        ..amount = 25000
        ..type = 'income'
        ..categoryId = salaryId
        ..accountId = hdfcId
        ..frequency = 'monthly'
        ..startDate = DateTime(now.year, now.month, 1)
        ..nextDueAt = nextMonth
        ..endType = 'never'
        ..createdAt = now
        ..updatedAt = now;
      await isar.recurringRules.put(rule);

      // ── Ledger Entry (1) ──
      final ledger = Ledger()
        ..uid = 'tutorial-ledger-${now.millisecondsSinceEpoch}'
        ..personName = 'Rahul'
        ..personNameLower = 'rahul'
        ..type = 'lent'
        ..originalAmount = 500
        ..accountId = walletId
        ..categoryId = shoppingId
        ..createdAt = now.subtract(const Duration(days: 3))
        ..updatedAt = now;
      await isar.ledgers.put(ledger);
    });
  }

  Future<void> clearMockData(Isar isar) async {
    await isar.writeTxn(() async {
      await isar.transactions.clear();
      await isar.accounts.clear();
      await isar.categorys.clear();
      await isar.categoryGroups.clear();
      await isar.budgets.clear();
      await isar.recurringRules.clear();
      await isar.ledgers.clear();
      await isar.transactionSuggestions.clear();
    });
  }
}

Category _cat(
    String name, String icon, int colorValue, String type, int groupId) {
  return Category()
    ..name = name
    ..icon = icon
    ..colorValue = colorValue
    ..type = type
    ..groupId = groupId;
}

Transaction _txn(
  String name,
  double amount,
  String type,
  String categoryId,
  String accountId,
  DateTime date,
) {
  final now = DateTime.now();
  return Transaction()
    ..name = name
    ..amount = amount
    ..type = type
    ..categoryId = categoryId
    ..accountId = accountId
    ..createdAt = date
    ..updatedAt = now
    ..nameLower = name.toLowerCase();
}
