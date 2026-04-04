import 'dart:math';
import 'package:isar/isar.dart';
import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/tags/data/tag.dart';
import '../../features/tags/data/transaction_tag.dart';
import '../../features/budgets/data/budget.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../database/seed_service.dart';

class MockDataService {
  static Future<void> generate(Isar isar) async {
    await isar.writeTxn(() async {
      // 1. Wipe database
      await isar.clear();
    });

    // 2. Re-seed defaults
    await SeedService().seedInitialData(isar);

    // 3. Fetch entities for linking
    final accounts = await isar.accounts.where().findAll();
    final categories = await isar.categorys.where().findAll();
    final tags = await isar.tags.where().findAll();

    if (accounts.isEmpty || categories.isEmpty) return;

    final cash = accounts.firstWhere((a) => a.name == 'Cash');
    final bank = accounts.firstWhere((a) => a.name == 'Bank');
    final cc = accounts.firstWhere((a) => a.name == 'Credit Card');

    final catSalary = categories.firstWhere((c) => c.name == 'Salary');
    final catRent = categories.firstWhere((c) => c.name == 'Rent');
    final catDining = categories.firstWhere((c) => c.name == 'Dining');
    final catGroceries = categories.firstWhere((c) => c.name == 'Groceries');
    final catTravel = categories.firstWhere((c) => c.name == 'Fuel' || c.name == 'Cab');
    final catShopping = categories.firstWhere((c) => c.name == 'Clothing' || c.name == 'Electronics');
    final catBills = categories.firstWhere((c) => c.name == 'Electricity' || c.name == 'Mobile');
    final catEntertain = categories.firstWhere((c) => c.name == 'Movies' || c.name == 'Streaming');

    final now = DateTime.now();
    final random = Random();

    await isar.writeTxn(() async {
      // 4. Generate Recurring Rules + History
      // 4.1 Salary Rule
      final salaryRule = RecurringRule()
        ..name = 'Monthly Salary'
        ..amount = 65000
        ..type = 'income'
        ..categoryId = catSalary.id.toString()
        ..accountId = bank.id.toString()
        ..frequency = 'monthly'
        ..startDate = DateTime(now.year, now.month - 3, 1)
        ..nextDueAt = DateTime(now.year, now.month + 1, 1)
        ..endType = 'never'
        ..createdAt = now.subtract(const Duration(days: 90))
        ..updatedAt = now;
      await isar.recurringRules.put(salaryRule);

      // Past Salary Transactions
      for (int i = 0; i < 3; i++) {
        final date = DateTime(now.year, now.month - i, 1);
        await isar.transactions.put(_tx('Monthly Salary', 65000, 'income', catSalary, bank, date, ruleId: salaryRule.id));
      }

      // 4.2 Rent Rule
      final rentRule = RecurringRule()
        ..name = 'Monthly Rent'
        ..amount = 18000
        ..type = 'expense'
        ..categoryId = catRent.id.toString()
        ..accountId = bank.id.toString()
        ..frequency = 'monthly'
        ..startDate = DateTime(now.year, now.month - 3, 5)
        ..nextDueAt = DateTime(now.year, now.month + 1, 5)
        ..endType = 'never'
        ..createdAt = now.subtract(const Duration(days: 90))
        ..updatedAt = now;
      await isar.recurringRules.put(rentRule);

      // Past Rent Transactions
      for (int i = 0; i < 3; i++) {
        final date = DateTime(now.year, now.month - i, 5);
        await isar.transactions.put(_tx('Rent Payment', 18000, 'expense', catRent, bank, date, ruleId: rentRule.id));
      }

      // 4.3 Gym Rule
      final gymRule = RecurringRule()
        ..name = 'Weekly Gym'
        ..amount = 1200
        ..type = 'expense'
        ..categoryId = categories.firstWhere((c) => c.name == 'Fitness').id.toString()
        ..accountId = bank.id.toString()
        ..frequency = 'weekly'
        ..startDate = DateTime(now.year, now.month - 1, 1)
        ..nextDueAt = now.add(const Duration(days: 4))
        ..endType = 'never'
        ..createdAt = now.subtract(const Duration(days: 30))
        ..updatedAt = now;
      await isar.recurringRules.put(gymRule);

      // 4.4 Netflix (Paused)
      final netflixRule = RecurringRule()
        ..name = 'Netflix'
        ..amount = 649
        ..type = 'expense'
        ..categoryId = catEntertain.id.toString()
        ..accountId = cc.id.toString()
        ..frequency = 'monthly'
        ..startDate = DateTime(now.year, now.month - 2, 15)
        ..nextDueAt = DateTime(now.year, now.month + 1, 15)
        ..endType = 'never'
        ..isPaused = true
        ..createdAt = now.subtract(const Duration(days: 60))
        ..updatedAt = now;
      await isar.recurringRules.put(netflixRule);

      // 5. Generate Random Transactions (90 days)
      final List<Transaction> randomTxList = [];
      for (int i = 0; i < 90; i++) {
        final date = now.subtract(Duration(days: i));
        
        // Skip dates with specific patterns (Salary/Rent) if necessary, but randomness is fine
        
        // Food/Dining (2-3 times per day)
        if (random.nextDouble() > 0.3) {
          randomTxList.add(_tx('Lunch / Dinner', (random.nextInt(8) + 1) * 100.0, 'expense', catDining, cash, _randTime(date)));
        }
        
        // Small expenses (Tea/Coffee)
        if (random.nextDouble() > 0.5) {
          randomTxList.add(_tx('Tea/Coffee', (random.nextInt(4) + 1) * 20.0, 'expense', catDining, cash, _randTime(date)));
        }
        
        // Groceries (Weekly)
        if (date.weekday == DateTime.sunday) {
          randomTxList.add(_tx('Weekly Groceries', (random.nextInt(2000) + 500).toDouble(), 'expense', catGroceries, bank, _randTime(date)));
        }

        // Travel (Occasional)
        if (random.nextDouble() > 0.8) {
          randomTxList.add(_tx('Cab / Fuel', (random.nextInt(1000) + 100).toDouble(), 'expense', catTravel, cc, _randTime(date)));
        }

        // Shopping (Monthly-ish)
        if (i % 30 == 15) {
          randomTxList.add(_tx('Monthly Shopping', (random.nextInt(4000) + 1000).toDouble(), 'expense', catShopping, cc, _randTime(date)));
        }

        // Bills (Monthly-ish)
        if (i % 30 == 10) {
          randomTxList.add(_tx('Electricity Bill', (random.nextInt(1500) + 500).toDouble(), 'expense', catBills, bank, _randTime(date)));
        }
        if (i % 30 == 20) {
          randomTxList.add(_tx('Mobile Recharge', (random.nextInt(500) + 299).toDouble(), 'expense', catBills, cc, _randTime(date)));
        }
      }

      // Save random transactions
      for (final tx in randomTxList) {
        await isar.transactions.put(tx);
        
        // Add Tags (30-40%)
        if (random.nextDouble() < 0.35 && tags.isNotEmpty) {
          final tag = tags[random.nextInt(tags.length)];
          await isar.transactionTags.put(TransactionTag()
            ..transactionId = tx.id
            ..tagId = tag.id);
        }
      }

      // 6. Generate Transfers (3-5)
      for (int i = 0; i < 4; i++) {
        final date = now.subtract(Duration(days: i * 20 + 5));
        final transferId = '${date.millisecondsSinceEpoch}_$i';
        final amount = (random.nextInt(5) + 1) * 1000.0;

        // ATM Withdrawal (Bank -> Cash)
        await isar.transactions.put(Transaction()
          ..name = 'ATM Withdrawal'
          ..nameLower = 'atm withdrawal'
          ..amount = amount
          ..type = 'expense'
          ..accountId = bank.id.toString()
          ..categoryId = ''
          ..isTransfer = true
          ..transferId = transferId
          ..createdAt = date
          ..updatedAt = date);

        await isar.transactions.put(Transaction()
          ..name = 'ATM Withdrawal'
          ..nameLower = 'atm withdrawal'
          ..amount = amount
          ..type = 'income'
          ..accountId = cash.id.toString()
          ..categoryId = ''
          ..isTransfer = true
          ..transferId = transferId
          ..createdAt = date.add(const Duration(minutes: 1))
          ..updatedAt = date);
      }

      // 7. Generate Budgets (4 cases)
      // Case 1: Under Budget (Food)
      final foodBudget = Budget()
        ..categoryId = catDining.id.toString()
        ..amount = 15000
        ..periodType = BudgetPeriodType.monthly
        ..startDate = DateTime(now.year, now.month, 1)
        ..isRecurring = true;
      await isar.budgets.put(foodBudget);

      // Case 2: Over Budget this month (Travel)
      final travelBudget = Budget()
        ..categoryId = catTravel.id.toString()
        ..amount = 5000
        ..periodType = BudgetPeriodType.monthly
        ..startDate = DateTime(now.year, now.month, 1)
        ..isRecurring = true;
      await isar.budgets.put(travelBudget);

      // Case 3: Over Budget Monthly (Shopping)
      final shoppingBudget = Budget()
        ..categoryId = catShopping.id.toString()
        ..amount = 3000
        ..periodType = BudgetPeriodType.monthly
        ..startDate = DateTime(now.year, now.month, 1)
        ..isRecurring = true;
      await isar.budgets.put(shoppingBudget);

      // Case 4: Disabled (Entertainment)
      final entertainmentBudget = Budget()
        ..categoryId = catEntertain.id.toString()
        ..amount = 2000
        ..periodType = BudgetPeriodType.monthly
        ..startDate = DateTime(now.year, now.month, 1)
        ..isRecurring = true
        ..isActive = false;
      await isar.budgets.put(entertainmentBudget);
    });
  }

  static Transaction _tx(String name, double amount, String type, Category cat, Account acc, DateTime date, {int? ruleId}) {
    return Transaction()
      ..name = name
      ..nameLower = name.toLowerCase()
      ..amount = amount
      ..type = type
      ..categoryId = cat.id.toString()
      ..accountId = acc.id.toString()
      ..linkedRuleId = ruleId?.toString()
      ..linkedRuleType = ruleId != null ? 'recurring' : null
      ..createdAt = date
      ..updatedAt = date;
  }

  static DateTime _randTime(DateTime base) {
    final rand = Random();
    return DateTime(base.year, base.month, base.day, rand.nextInt(24), rand.nextInt(60));
  }
}
