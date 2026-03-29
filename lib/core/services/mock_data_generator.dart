import 'dart:math';
import 'package:isar/isar.dart';
import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/categories/data/category_group.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/tags/data/tag.dart';
import '../../features/tags/data/transaction_tag.dart';
import '../utils/color_palette.dart';

class MockDataGenerator {
  final Isar isar;

  MockDataGenerator(this.isar);

  Future<void> generate() async {
    await isar.writeTxn(() async {
      await isar.clear();
      final now = DateTime.now();

      // 0. Create Category Groups
      final gFood = CategoryGroup()..name = 'Food & Dining';
      final gTransport = CategoryGroup()..name = 'Transport';
      final gShopping = CategoryGroup()..name = 'Shopping';
      final gPersonal = CategoryGroup()..name = 'Personal';
      
      await isar.categoryGroups.putAll([gFood, gTransport, gShopping, gPersonal]);

      // 1. Create Accounts
      final cash = Account()
        ..name = 'Cash'
        ..type = 'bank'
        ..icon = 'payments'
        ..colorValue = AppColorPalette.colors[7]; // emerald

      final hdfc = Account()
        ..name = 'HDFC Bank'
        ..type = 'bank'
        ..icon = 'account_balance'
        ..colorValue = AppColorPalette.colors[1]; // indigo

      final icici = Account()
        ..name = 'ICICI Credit Card'
        ..type = 'bank'
        ..isCreditCard = true
        ..icon = 'credit_card'
        ..colorValue = AppColorPalette.colors[2] // violet
        ..creditLimit = 100000
        ..initialBalance = -5000;

      await isar.accounts.putAll([cash, hdfc, icici]);

      // 2. Create Categories
      final food = _cat('Food', 'restaurant', AppColorPalette.colors[4], 'expense')..groupId = gFood.id;
      final fastFood = _cat('Fast Food', 'lunch_dining', AppColorPalette.colors[5], 'expense')..groupId = gFood.id;
      final transport = _cat('Transport', 'directions_car', AppColorPalette.colors[0], 'expense')..groupId = gTransport.id;
      final shopping = _cat('Shopping', 'shopping_bag', AppColorPalette.colors[3], 'expense')..groupId = gShopping.id;
      final bills = _cat('Bills', 'receipt_long', AppColorPalette.colors[6], 'expense')..groupId = gPersonal.id;
      final income = _cat('Salary', 'trending_up', AppColorPalette.colors[8], 'income');
      final other = _cat('Other', 'category', AppColorPalette.colors[10], 'both');

      await isar.categorys.putAll([food, fastFood, transport, shopping, bills, income, other]);

      // 2.5 Create Tags
      final tagVacation = Tag()..name = 'vacation'..createdAt = now;
      final tagUrgent = Tag()..name = 'urgent'..createdAt = now;
      final tagReimbursable = Tag()..name = 'reimbursable'..createdAt = now;
      final tagPersonal = Tag()..name = 'personal'..createdAt = now;
      final tagWork = Tag()..name = 'work'..createdAt = now;
      final tagPending = Tag()..name = 'pending'..createdAt = now;

      final allTags = [tagVacation, tagUrgent, tagReimbursable, tagPersonal, tagWork, tagPending];
      await isar.tags.putAll(allTags);

      // 3. Create Recurring Rules
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      final rent = RecurringRule()
        ..name = 'Monthly Rent'
        ..amount = 25000
        ..type = 'expense'
        ..categoryId = bills.id.toString()
        ..accountId = hdfc.id.toString()
        ..frequency = 'monthly'
        ..startDate = lastMonth
        ..nextDueAt = DateTime(now.year, now.month + 1, 1)
        ..endType = 'never'
        ..createdAt = lastMonth
        ..updatedAt = lastMonth;

      final salary = RecurringRule()
        ..name = 'Monthly Salary'
        ..amount = 85000
        ..type = 'income'
        ..categoryId = income.id.toString()
        ..accountId = hdfc.id.toString()
        ..frequency = 'monthly'
        ..startDate = lastMonth
        ..nextDueAt = DateTime(now.year, now.month + 1, 1)
        ..endType = 'never'
        ..createdAt = lastMonth
        ..updatedAt = lastMonth;

      final netflix = RecurringRule()
        ..name = 'Netflix'
        ..amount = 649
        ..type = 'expense'
        ..categoryId = other.id.toString()
        ..accountId = icici.id.toString()
        ..frequency = 'monthly'
        ..startDate = lastMonth
        ..nextDueAt = DateTime(now.year, now.month + 1, 1)
        ..endType = 'never'
        ..createdAt = lastMonth
        ..updatedAt = lastMonth;

      await isar.recurringRules.putAll([rent, salary, netflix]);

      // 4. Create Transactions (Past 4 months)
      final List<Transaction> transactions = [];
      final random = Random();

      for (int i = 0; i < 4; i++) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        
        // Monthly Salary
        transactions.add(_tx('Salary Credit', 85000, 'income', income, hdfc, monthDate));
        
        // Monthly Rent
        transactions.add(_tx('House Rent', 25000, 'expense', bills, hdfc, monthDate.add(const Duration(days: 2))));

        // Netflix
        transactions.add(_tx('Netflix Subscription', 649, 'expense', other, icici, monthDate.add(const Duration(days: 5))));

        // Random Expenses
        for (int j = 0; j < 15; j++) {
           final day = random.nextInt(28) + 1;
           final date = DateTime(monthDate.year, monthDate.month, day);
           
           final r = random.nextDouble();
           if (r < 0.3) {
             transactions.add(_tx('Uber', (random.nextInt(400) + 100).toDouble(), 'expense', transport, icici, date));
           } else if (r < 0.6) {
             transactions.add(_tx('Swiggy', (random.nextInt(800) + 200).toDouble(), 'expense', food, cash, date));
           } else if (r < 0.8) {
             transactions.add(_tx('Amazon Shopping', (random.nextInt(3000) + 500).toDouble(), 'expense', shopping, icici, date));
           } else if (r < 0.9) {
             // ATM Withdrawal (two legs)
             final transferId1 = '${date.millisecondsSinceEpoch}_atm';
             transactions.addAll([
               Transaction()
                 ..name = ''..nameLower = ''..amount = 5000
                 ..type = 'expense'..accountId = hdfc.id.toString()
                 ..categoryId = ''..isTransfer = true..transferId = transferId1
                 ..isRecurring = false..createdAt = date..updatedAt = date,
               Transaction()
                 ..name = ''..nameLower = ''..amount = 5000
                 ..type = 'income'..accountId = cash.id.toString()
                 ..categoryId = ''..isTransfer = true..transferId = transferId1
                 ..isRecurring = false..createdAt = date..updatedAt = date,
             ]);
           } else {
             // Credit Card Payment (two legs)
             final transferId2 = '${date.millisecondsSinceEpoch}_cc';
             transactions.addAll([
               Transaction()
                 ..name = ''..nameLower = ''..amount = 15000
                 ..type = 'expense'..accountId = hdfc.id.toString()
                 ..categoryId = ''..isTransfer = true..transferId = transferId2
                 ..isRecurring = false..createdAt = date..updatedAt = date,
               Transaction()
                 ..name = ''..nameLower = ''..amount = 15000
                 ..type = 'income'..accountId = icici.id.toString()
                 ..categoryId = ''..isTransfer = true..transferId = transferId2
                 ..isRecurring = false..createdAt = date..updatedAt = date,
             ]);
           }
        }
      }

      await isar.transactions.putAll(transactions);

      // 5. Assign Tags
      final List<TransactionTag> txTags = [];
      for (final tx in transactions) {
        // 40% chance of having tags
        if (random.nextDouble() < 0.4) {
          // 1-3 tags per transaction
          final numTags = random.nextInt(3) + 1;
          final shuffled = List.from(allTags)..shuffle(random);
          for (int k = 0; k < numTags; k++) {
            txTags.add(TransactionTag()
              ..transactionId = tx.id
              ..tagId = shuffled[k].id);
          }
        }
      }
      await isar.transactionTags.putAll(txTags);
    });
  }

  Category _cat(String name, String icon, int colorValue, String type) {
    return Category()
      ..name = name
      ..icon = icon
      ..colorValue = colorValue
      ..isDefault = true
      ..type = type;
  }

  Transaction _tx(String name, double amount, String type, Category cat, Account acc, DateTime date) {
    return Transaction()
      ..name = name
      ..nameLower = name.toLowerCase()
      ..amount = amount
      ..type = type
      ..categoryId = cat.id.toString()
      ..accountId = acc.id.toString()
      ..isRecurring = false
      ..createdAt = date
      ..updatedAt = date;
  }
}
