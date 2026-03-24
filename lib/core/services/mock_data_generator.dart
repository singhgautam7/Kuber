import 'dart:math';
import 'package:isar/isar.dart';
import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/transactions/data/transaction.dart';
import '../utils/color_palette.dart';

class MockDataGenerator {
  final Isar isar;

  MockDataGenerator(this.isar);

  Future<void> generate() async {
    await isar.writeTxn(() async {
      await isar.clear();

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
        ..creditLimit = 100000;

      await isar.accounts.putAll([cash, hdfc, icici]);

      // 2. Create Categories
      final food = _cat('Food', 'restaurant', AppColorPalette.colors[4], 'expense');
      final transport = _cat('Transport', 'directions_car', AppColorPalette.colors[0], 'expense');
      final shopping = _cat('Shopping', 'shopping_bag', AppColorPalette.colors[3], 'expense');
      final bills = _cat('Bills', 'receipt_long', AppColorPalette.colors[5], 'expense');
      final income = _cat('Salary', 'trending_up', AppColorPalette.colors[8], 'income');
      final other = _cat('Other', 'category', AppColorPalette.colors[10], 'both');

      await isar.categorys.putAll([food, transport, shopping, bills, income, other]);

      // 3. Create Recurring Rules
      final now = DateTime.now();
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
             // A transfer
             transactions.add(Transaction()
                ..name = 'ATM Withdrawal'
                ..nameLower = 'atm withdrawal'
                ..amount = 5000
                ..type = 'transfer'
                ..categoryId = other.id.toString()
                ..accountId = hdfc.id.toString()
                ..fromAccountId = hdfc.id.toString()
                ..toAccountId = cash.id.toString()
                ..createdAt = date
                ..updatedAt = date);
           } else {
             // Credit Card Payment
             transactions.add(Transaction()
                ..name = 'CC Bill Payment'
                ..nameLower = 'cc bill payment'
                ..amount = 15000
                ..type = 'transfer'
                ..categoryId = other.id.toString()
                ..accountId = hdfc.id.toString()
                ..fromAccountId = hdfc.id.toString()
                ..toAccountId = icici.id.toString()
                ..createdAt = date
                ..updatedAt = date);
           }
        }
      }

      await isar.transactions.putAll(transactions);
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
      ..createdAt = date
      ..updatedAt = date;
  }
}
