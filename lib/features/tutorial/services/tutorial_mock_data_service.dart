import 'package:isar_community/isar.dart';

import '../../../core/database/seed_service.dart';
import '../../accounts/data/account.dart';
import '../../budgets/data/budget.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../ledger/data/ledger.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../transactions/data/transaction.dart';

class TutorialMockDataService {
  static const _prefix = '[Tutorial] ';

  Future<void> generateMockData(Isar isar) async {
    await clearMockData(isar);
    await SeedService().seedInitialData(isar);

    await isar.writeTxn(() async {
      final wallet = Account()
        ..name = '${_prefix}Wallet'
        ..type = 'cash'
        ..icon = 'payments_outlined'
        ..colorValue = 0xFF9E9E9E
        ..initialBalance = 5000;
      final bank = Account()
        ..name = '${_prefix}HDFC Bank'
        ..type = 'bank'
        ..icon = 'account_balance_outlined'
        ..colorValue = 0xFF2196F3
        ..initialBalance = 45000;
      await isar.accounts.putAll([wallet, bank]);

      final group = CategoryGroup()..name = '${_prefix}TUTORIAL';
      final groupId = await isar.categoryGroups.put(group);
      final categories = [
        _cat('Food', 'restaurant', 0xFFFF5722, 'expense', groupId),
        _cat('Transport', 'directions_bus', 0xFF009688, 'expense', groupId),
        _cat('Shopping', 'checkroom', 0xFFE91E63, 'expense', groupId),
        _cat('Salary', 'account_balance_wallet', 0xFF4CAF50, 'income', groupId),
        _cat('Entertainment', 'movie', 0xFF673AB7, 'expense', groupId),
      ];
      await isar.categorys.putAll(categories);

      final food = categories[0];
      final transport = categories[1];
      final shopping = categories[2];
      final salary = categories[3];
      final entertainment = categories[4];
      final now = DateTime.now();

      final transactions = [
        _tx(
          'Salary',
          25000,
          'income',
          salary,
          bank,
          now.subtract(const Duration(days: 1)),
        ),
        _tx(
          'Freelance payout',
          20000,
          'income',
          salary,
          bank,
          now.subtract(const Duration(days: 4)),
        ),
        _tx(
          'Bonus credit',
          21667,
          'income',
          salary,
          bank,
          now.subtract(const Duration(days: 7)),
        ),
        _tx(
          'Lunch',
          240,
          'expense',
          food,
          wallet,
          now.subtract(const Duration(hours: 6)),
        ),
        _tx(
          'Metro recharge',
          500,
          'expense',
          transport,
          wallet,
          now.subtract(const Duration(days: 1, hours: 4)),
        ),
        _tx(
          'Groceries',
          1850,
          'expense',
          food,
          bank,
          now.subtract(const Duration(days: 2)),
        ),
        _tx(
          'Movie night',
          720,
          'expense',
          entertainment,
          wallet,
          now.subtract(const Duration(days: 3)),
        ),
        _tx(
          'Shirt',
          1499,
          'expense',
          shopping,
          bank,
          now.subtract(const Duration(days: 4, hours: 5)),
        ),
        _tx(
          'Cab ride',
          320,
          'expense',
          transport,
          wallet,
          now.subtract(const Duration(days: 5)),
        ),
        _tx(
          'Cafe',
          580,
          'expense',
          food,
          wallet,
          now.subtract(const Duration(days: 6)),
        ),
      ];
      await isar.transactions.putAll(transactions);

      await isar.budgets.put(
        Budget()
          ..categoryId = food.id.toString()
          ..amount = 5000
          ..periodType = BudgetPeriodType.monthly
          ..startDate = DateTime(now.year, now.month)
          ..isRecurring = true,
      );

      await isar.recurringRules.put(
        RecurringRule()
          ..name = '${_prefix}Salary'
          ..amount = 25000
          ..type = 'income'
          ..categoryId = salary.id.toString()
          ..accountId = bank.id.toString()
          ..frequency = 'monthly'
          ..startDate = DateTime(now.year, now.month, 1)
          ..nextDueAt = DateTime(now.year, now.month + 1, 1)
          ..endType = 'never'
          ..createdAt = now
          ..updatedAt = now,
      );

      await isar.ledgers.put(
        Ledger()
          ..uid = '${now.microsecondsSinceEpoch}_tutorial'
          ..personName = '${_prefix}Rahul'
          ..personNameLower = '${_prefix}rahul'.toLowerCase()
          ..type = 'lent'
          ..originalAmount = 500
          ..accountId = wallet.id.toString()
          ..categoryId = food.id.toString()
          ..createdAt = now.subtract(const Duration(days: 3))
          ..updatedAt = now,
      );
    });
  }

  Future<void> clearMockData(Isar isar) async {
    await isar.writeTxn(() async {
      final txs = await isar.transactions
          .filter()
          .nameStartsWith(_prefix, caseSensitive: false)
          .or()
          .nameEqualTo('Lunch')
          .or()
          .nameEqualTo('Metro recharge')
          .or()
          .nameEqualTo('Groceries')
          .or()
          .nameEqualTo('Movie night')
          .or()
          .nameEqualTo('Shirt')
          .or()
          .nameEqualTo('Cab ride')
          .or()
          .nameEqualTo('Cafe')
          .findAll();
      await isar.transactions.deleteAll(txs.map((e) => e.id).toList());

      final accounts = await isar.accounts
          .filter()
          .nameStartsWith(_prefix, caseSensitive: false)
          .findAll();
      await isar.accounts.deleteAll(accounts.map((e) => e.id).toList());

      final groups = await isar.categoryGroups
          .filter()
          .nameStartsWith(_prefix, caseSensitive: false)
          .findAll();
      final groupIds = groups.map((e) => e.id).toList();
      if (groupIds.isNotEmpty) {
        final cats = await isar.categorys
            .filter()
            .anyOf(groupIds, (q, id) => q.groupIdEqualTo(id))
            .findAll();
        await isar.categorys.deleteAll(cats.map((e) => e.id).toList());
        await isar.categoryGroups.deleteAll(groupIds);
      }

      final rules = await isar.recurringRules
          .filter()
          .nameStartsWith(_prefix, caseSensitive: false)
          .findAll();
      await isar.recurringRules.deleteAll(rules.map((e) => e.id).toList());

      final ledgers = await isar.ledgers
          .filter()
          .personNameStartsWith(_prefix, caseSensitive: false)
          .findAll();
      await isar.ledgers.deleteAll(ledgers.map((e) => e.id).toList());
    });
  }

  Category _cat(String name, String icon, int color, String type, int groupId) {
    return Category()
      ..name = '$_prefix$name'
      ..icon = icon
      ..colorValue = color
      ..type = type
      ..groupId = groupId
      ..isDefault = true;
  }

  Transaction _tx(
    String name,
    double amount,
    String type,
    Category cat,
    Account acc,
    DateTime date,
  ) {
    return Transaction()
      ..name = name.startsWith(_prefix) ? name : '$_prefix$name'
      ..nameLower = (name.startsWith(_prefix) ? name : '$_prefix$name')
          .toLowerCase()
      ..amount = amount
      ..type = type
      ..categoryId = cat.id.toString()
      ..accountId = acc.id.toString()
      ..createdAt = date
      ..updatedAt = date;
  }
}
