import 'dart:convert';
import 'dart:math';
import 'package:isar_community/isar.dart';
import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/tags/data/tag.dart';
import '../../features/tags/data/transaction_tag.dart';
import '../../features/budgets/data/budget.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/investments/data/investment.dart';
import '../../features/ledger/data/ledger.dart';
import '../../features/loans/data/loan.dart';
import '../../features/notes/data/kuber_note.dart';
import '../../features/notifications/data/app_notification.dart';
import '../../features/reminders/data/reminder.dart';
import '../../features/tools/bill_splitter/data/bill.dart';
import '../../features/tools/bill_splitter/data/person.dart';
import '../../features/tools/saved/data/calculator_recent_use.dart';
import '../../features/kuber_cards/data/card_vault_service.dart';
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

      // 8. Extra accounts + credit card billing, so account lists, the net
      // worth split and CC utilisation all have something to show.
      cc
        ..creditLimit = 100000
        ..last4Digits = '4321'
        ..billGenerationDay = 20
        ..paymentDueDay = 8;
      await isar.accounts.put(cc);
      final savings = Account()
        ..name = 'HDFC Savings'
        ..type = 'bank'
        ..icon = 'account_balance_outlined'
        ..colorValue = 0xFF1E88E5
        ..initialBalance = 125000
        ..last4Digits = '8890';
      final wallet = Account()
        ..name = 'Paytm Wallet'
        ..type = 'wallet'
        ..icon = 'account_balance_wallet_outlined'
        ..colorValue = 0xFF00ACC1
        ..initialBalance = 1500;
      final oldCard = Account()
        ..name = 'Old Debit Card'
        ..type = 'bank'
        ..icon = 'credit_card_outlined'
        ..colorValue = 0xFF757575
        ..isDisabled = true;
      await isar.accounts.putAll([savings, wallet, oldCard]);

      String uid(String tag) => '${tag}_${now.microsecondsSinceEpoch}';
      final catLoan = categories.firstWhere((c) => c.name == 'Loan EMI');
      final catLedger = categories.firstWhere((c) => c.name == 'Lent / Borrow');
      final catInvest = categories.firstWhere((c) => c.name == 'Investment');

      // 9. Loans: two active (with EMI history), one completed.
      Future<void> loan(
        String name,
        String type,
        String lender,
        double principal,
        double emi,
        double rate,
        int billDay,
        int monthsPaid, {
        bool completed = false,
      }) async {
        final id = uid('loan_$name');
        await isar.loans.put(Loan()
          ..uid = id
          ..name = name
          ..loanType = type
          ..lenderName = lender
          ..principalAmount = principal
          ..emiAmount = emi
          ..rateType = 'floating'
          ..interestRate = rate
          ..billDate = billDay
          ..startDate = DateTime(now.year, now.month - monthsPaid, billDay)
          ..accountId = savings.id.toString()
          ..categoryId = catLoan.id.toString()
          ..isCompleted = completed
          ..createdAt = now.subtract(Duration(days: 30 * monthsPaid))
          ..updatedAt = now);
        for (var i = 1; i <= monthsPaid; i++) {
          final date = DateTime(now.year, now.month - monthsPaid + i, billDay);
          if (date.isAfter(now)) break;
          await isar.transactions.put(Transaction()
            ..name = 'EMI - $name'
            ..nameLower = 'emi - ${name.toLowerCase()}'
            ..amount = emi
            ..type = 'expense'
            ..accountId = savings.id.toString()
            ..categoryId = catLoan.id.toString()
            ..linkedRuleId = id
            ..linkedRuleType = 'loan'
            ..createdAt = date
            ..updatedAt = date);
        }
      }

      await loan('Home Loan', 'home', 'HDFC Bank', 2500000, 24500, 8.5, 10, 6);
      await loan('Maruti Brezza', 'vehicle', 'SBI', 650000, 11200, 9.1, 7, 4);
      await loan('Laptop EMI', 'personal', 'Bajaj Finserv', 60000, 5000, 0, 15,
          12,
          completed: true);

      // 10. Lent / Borrow: active, partly repaid and settled entries.
      Future<void> ledger(
        String person,
        String type,
        double amount,
        int daysAgo, {
        double repaid = 0,
        bool settled = false,
        int? dueInDays,
      }) async {
        final id = uid('ledger_$person$type');
        final created = now.subtract(Duration(days: daysAgo));
        await isar.ledgers.put(Ledger()
          ..uid = id
          ..personName = person
          ..personNameLower = person.toLowerCase()
          ..type = type
          ..originalAmount = amount
          ..accountId = bank.id.toString()
          ..categoryId = catLedger.id.toString()
          ..expectedDate =
              dueInDays == null ? null : now.add(Duration(days: dueInDays))
          ..isSettled = settled
          ..createdAt = created
          ..updatedAt = now);
        final lent = type == 'lent';
        await isar.transactions.put(Transaction()
          ..name = lent ? 'Lent to $person' : 'Borrowed from $person'
          ..nameLower =
              (lent ? 'lent to $person' : 'borrowed from $person').toLowerCase()
          ..amount = amount
          ..type = lent ? 'expense' : 'income'
          ..accountId = bank.id.toString()
          ..categoryId = catLedger.id.toString()
          ..linkedRuleId = id
          ..linkedRuleType = type
          ..createdAt = created
          ..updatedAt = created);
        final back = settled ? amount : repaid;
        if (back > 0) {
          final date = created.add(Duration(days: daysAgo ~/ 2));
          await isar.transactions.put(Transaction()
            ..name = 'Payment - $person'
            ..nameLower = 'payment - ${person.toLowerCase()}'
            ..amount = back
            ..type = lent ? 'income' : 'expense'
            ..accountId = bank.id.toString()
            ..categoryId = catLedger.id.toString()
            ..linkedRuleId = id
            ..linkedRuleType = type
            ..createdAt = date
            ..updatedAt = date);
        }
      }

      await ledger('Rahul', 'lent', 2800, 25, repaid: 800, dueInDays: 5);
      await ledger('Priya', 'lent', 2400, 9, dueInDays: 20);
      await ledger('Amit', 'borrowed', 1200, 17, dueInDays: 2);
      await ledger('Neha', 'lent', 1500, 60, settled: true);
      await ledger('Karan', 'borrowed', 5000, 45, settled: true);

      // 11. Investments across types (SIP with contributions, lump sums).
      Future<void> invest(
        String name,
        String type,
        double invested,
        double current, {
        double? sip,
        int sipMonths = 0,
      }) async {
        final id = uid('inv_$name');
        await isar.investments.put(Investment()
          ..uid = id
          ..name = name
          ..investmentType = type
          ..investedAmount = invested
          ..currentValue = current
          ..autoDebit = sip != null
          ..sipAmount = sip
          ..sipDate = sip == null ? null : 5
          ..accountId = savings.id.toString()
          ..categoryId = catInvest.id.toString()
          ..createdAt = now.subtract(const Duration(days: 200))
          ..updatedAt = now);
        for (var i = 0; i < sipMonths; i++) {
          final date = DateTime(now.year, now.month - i, 5);
          if (date.isAfter(now)) continue;
          await isar.transactions.put(Transaction()
            ..name = 'Contribution - $name'
            ..nameLower = 'contribution - ${name.toLowerCase()}'
            ..amount = sip!
            ..type = 'expense'
            ..accountId = savings.id.toString()
            ..categoryId = catInvest.id.toString()
            ..linkedRuleId = id
            ..linkedRuleType = 'investment'
            ..createdAt = date
            ..updatedAt = date);
        }
      }

      await invest('Nifty 50 Index Fund', 'sip', 151600, 184000,
          sip: 5000, sipMonths: 3);
      await invest('Parag Parikh Flexi Cap', 'mutual_fund', 96700, 112400);
      await invest('Sovereign Gold Bond', 'gold', 66100, 82000);
      await invest('Reliance Industries', 'stocks', 66900, 64800);
      await invest('Bitcoin', 'crypto', 25000, 31200);
      await invest('SBI Fixed Deposit', 'fd', 100000, 107100);

      // 12. Reminders: overdue, today, upcoming, repeating and completed.
      await isar.reminders.putAll([
        Reminder()
          ..title = 'Credit card bill'
          ..dueAt = now.subtract(const Duration(days: 1))
          ..amount = 18400
          ..transactionType = 'expense'
          ..repeat = ReminderRepeat.monthly
          ..status = ReminderStatus.pending
          ..createdAt = now.subtract(const Duration(days: 30))
          ..updatedAt = now,
        Reminder()
          ..title = 'Collect from Rahul'
          ..dueAt = DateTime(now.year, now.month, now.day, 18)
          ..amount = 1200
          ..transactionType = 'income'
          ..status = ReminderStatus.pending
          ..createdAt = now
          ..updatedAt = now,
        Reminder()
          ..title = 'Renew bike insurance'
          ..notes = 'Policy number in the glovebox.'
          ..dueAt = now.add(const Duration(days: 3))
          ..amount = 2850
          ..transactionType = 'expense'
          ..repeat = ReminderRepeat.yearly
          ..status = ReminderStatus.pending
          ..createdAt = now
          ..updatedAt = now,
        Reminder()
          ..title = 'Pay maid'
          ..dueAt = now.add(const Duration(days: 12))
          ..amount = 4000
          ..transactionType = 'expense'
          ..repeat = ReminderRepeat.monthly
          ..status = ReminderStatus.pending
          ..createdAt = now
          ..updatedAt = now,
        Reminder()
          ..title = 'Submit rent receipts'
          ..dueAt = now.subtract(const Duration(days: 6))
          ..status = ReminderStatus.completed
          ..completedAt = now.subtract(const Duration(days: 5))
          ..createdAt = now.subtract(const Duration(days: 10))
          ..updatedAt = now,
      ]);

      // 13. Notes (Quill delta JSON), one pinned, one read-only.
      String delta(String text) => jsonEncode([
            {'insert': '$text\n'},
          ]);
      await isar.kuberNotes.putAll([
        KuberNote()
          ..title = 'Goa trip split'
          ..content = delta('Hotel 12400 + cab 2100 = 14500\nSplit / 4 = 3625 each')
          ..categoryId = catTravel.id.toString()
          ..pinned = true
          ..createdAt = now.subtract(const Duration(days: 2))
          ..updatedAt = now,
        KuberNote()
          ..title = 'Weekly list'
          ..content = delta('Milk 60, eggs 90, atta 420, veggies 300')
          ..categoryId = catGroceries.id.toString()
          ..createdAt = now.subtract(const Duration(days: 1))
          ..updatedAt = now.subtract(const Duration(days: 1)),
        KuberNote()
          ..title = 'Diwali gifts'
          ..content = delta('Mom 2500, Riya 1200, office 3000')
          ..isReadOnly = true
          ..createdAt = now.subtract(const Duration(days: 9))
          ..updatedAt = now.subtract(const Duration(days: 9)),
      ]);

      // 14. Bill splitter: people and two bills (one archived).
      await isar.persons.putAll([
        for (final n in ['Rahul', 'Priya', 'Amit', 'Neha'])
          Person()
            ..name = n
            ..createdAt = now.subtract(const Duration(days: 40)),
      ]);
      BillParticipant part(String n, double share) => BillParticipant()
        ..personName = n
        ..share = share;
      await isar.bills.putAll([
        Bill()
          ..name = 'Dinner at Toit'
          ..totalAmount = 4800
          ..paidByPersonName = 'Rahul'
          ..splitType = 'equal'
          ..participants = [
            part('Rahul', 1600),
            part('Priya', 1600),
            part('Amit', 1600),
          ]
          ..createdAt = now.subtract(const Duration(days: 3)),
        Bill()
          ..name = 'Goa villa'
          ..totalAmount = 24000
          ..paidByPersonName = 'Neha'
          ..splitType = 'equal'
          ..participants = [
            part('Neha', 6000),
            part('Rahul', 6000),
            part('Priya', 6000),
            part('Amit', 6000),
          ]
          ..createdAt = now.subtract(const Duration(days: 50))
          ..isArchived = true
          ..archivedAt = now.subtract(const Duration(days: 20)),
      ]);

      // 15. Recently used calculators and a few notifications.
      await isar.calculatorRecentUses.putAll([
        for (final (i, key) in [
          'emi-calculator',
          'sip-calculator',
          'fd-rd-calculator',
          'inflation-calculator',
        ].indexed)
          CalculatorRecentUse()
            ..calculatorType = key
            ..lastUsed = now.subtract(Duration(hours: i * 7))
            ..useCount = 6 - i,
      ]);
      await isar.appNotifications.putAll([
        AppNotification()
          ..type = NotificationType.budgetAlert
          ..title = 'Groceries budget exceeded'
          ..body = 'You have spent more than your Groceries budget this month.'
          ..createdAt = now.subtract(const Duration(hours: 5)),
        AppNotification()
          ..type = NotificationType.loanEmi
          ..title = 'EMI due tomorrow'
          ..body = 'Maruti Brezza EMI of ₹11,200 is due tomorrow.'
          ..createdAt = now.subtract(const Duration(days: 1)),
        AppNotification()
          ..type = NotificationType.recurringTransaction
          ..title = 'Monthly Salary added'
          ..body = 'Your recurring income was recorded.'
          ..createdAt = now.subtract(const Duration(days: 6))
          ..readAt = now.subtract(const Duration(days: 5)),
      ]);
    });

    // 16. Kuber Cards: a vault with PIN 0000 (4 digits, named in the confirm
    // sheet) and a few cards. Outside the transaction above: the vault
    // service runs its own writes.
    final vault = CardVaultService(isar);
    final key = await vault.setupVault(pin: mockCardsPin, pinLength: 4);
    for (final card in [
      CardInput(
        nickname: 'HDFC Millennia',
        number: '4532015112830366',
        cardholder: 'RAHUL SHARMA',
        expiry: '08/29',
        cardType: 'credit',
        network: 'visa',
        bankIcon: 'bank/hdfc',
        // Gradient cards store a CardPalette.gradients index, solids an ARGB.
        colorValue: 0,
        isGradient: true,
        customFields: [CardCustomField(label: 'CVV', value: '123')],
      ),
      CardInput(
        nickname: 'SBI Salary',
        number: '6521234567891234',
        cardholder: 'RAHUL SHARMA',
        expiry: '11/28',
        cardType: 'debit',
        network: 'rupay',
        bankIcon: 'bank/sbi',
        colorValue: 0xFF0EA5E9,
      ),
      CardInput(
        nickname: 'ICICI Amazon Pay',
        number: '5555555555554444',
        cardholder: 'RAHUL SHARMA',
        expiry: '03/30',
        cardType: 'credit',
        network: 'mastercard',
        bankIcon: 'bank/icici',
        colorValue: 5,
        isGradient: true,
      ),
      CardInput(
        nickname: 'Axis Forex',
        number: '4111111111111111',
        cardholder: 'RAHUL SHARMA',
        expiry: '06/27',
        cardType: 'forex',
        network: 'visa',
        bankIcon: 'bank/axis',
        colorValue: 0xFF7C3AED,
      ),
    ]) {
      await vault.saveCard(key: key, input: card);
    }
  }

  /// The Kuber Cards PIN of the mock vault.
  static const String mockCardsPin = '0000';

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
    final now = DateTime.now();
    final isToday = base.year == now.year &&
        base.month == now.month &&
        base.day == now.day;
    final maxHour = isToday ? now.hour : 23;
    final hour = rand.nextInt(maxHour + 1);
    final maxMinute = (isToday && hour == now.hour) ? now.minute : 59;
    final minute = rand.nextInt(maxMinute + 1);
    return DateTime(base.year, base.month, base.day, hour, minute);
  }
}
