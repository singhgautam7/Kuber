// A deterministic "existing user" ledger as the pre-vNext app would have
// stored it: ~6k transactions with transfers, balance adjustments, and
// transactions linked to recurring rules, a loan, a SIP and Lend / Borrow.
// Fixed dates (2023-01-01 .. 2026-10-15) so goldens never depend on today.

import 'dart:math';

import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/seed_service.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

Future<void> seedLegacyDataset(Isar isar, {int count = 6000}) async {
  await SeedService().seedInitialData(isar);
  final rnd = Random(42);
  final start = DateTime(2023, 1, 1);
  const spanDays = 1383; // to 2026-10-15

  await isar.writeTxn(() async {
    await isar.accounts.putAll([
      Account()
        ..name = 'HDFC Bank'
        ..type = 'bank'
        ..initialBalance = 125000.5,
      Account()
        ..name = 'Amex'
        ..type = 'credit_card'
        ..isCreditCard = true
        ..initialBalance = -1500,
    ]);
  });
  final accounts = await isar.accounts.where().findAll();
  final categories = await isar.categorys.where().findAll();
  final expenseCats = categories.where((c) => c.type != 'income').toList();
  final incomeCats = categories.where((c) => c.type != 'expense').toList();

  final now = DateTime(2026, 10, 15);
  final rule = RecurringRule()
    ..name = 'Rent'
    ..amount = 18000
    ..type = 'expense'
    ..categoryId = '${expenseCats.first.id}'
    ..accountId = '${accounts.first.id}'
    ..frequency = 'monthly'
    ..customDays = 1
    ..intervalUnit = 'month'
    ..startDate = DateTime(2023, 1, 1)
    ..nextDueAt = DateTime(2026, 11, 1)
    ..executionCount = 46
    ..endType = 'never'
    ..createdAt = DateTime(2023, 1, 1)
    ..updatedAt = now;
  final loan = Loan()
    ..uid = 'loan-legacy-1'
    ..name = 'Home loan'
    ..loanType = 'home'
    ..lenderName = 'HDFC'
    ..principalAmount = 2500000
    ..emiAmount = 21696
    ..interestRate = 8.5
    ..billDate = 5
    ..startDate = DateTime(2023, 1, 5)
    ..endDate = DateTime(2042, 12, 5)
    ..autoAddTransaction = true
    ..accountId = '${accounts.first.id}'
    ..categoryId = '${expenseCats.last.id}'
    ..createdAt = DateTime(2023, 1, 1)
    ..updatedAt = now;
  final inv = Investment()
    ..uid = 'inv-legacy-1'
    ..name = 'Nifty 50 Index Fund'
    ..investmentType = 'mutual_fund'
    ..currentValue = 260000
    ..investedAmount = 230000
    ..autoDebit = true
    ..sipAmount = 5000
    ..sipDate = 10
    ..accountId = '${accounts.first.id}'
    ..categoryId = '${expenseCats.last.id}'
    ..createdAt = DateTime(2023, 1, 1)
    ..updatedAt = now;
  await isar.writeTxn(() async {
    await isar.recurringRules.put(rule);
    await isar.loans.put(loan);
    await isar.investments.put(inv);
  });

  final txns = <Transaction>[];
  Transaction tx(String name, double amount, String type, DateTime at,
          {String? account, String? category}) =>
      Transaction()
        ..name = name
        ..nameLower = name.toLowerCase()
        ..amount = amount
        ..type = type
        ..categoryId = category ??
            '${(type == 'income' ? incomeCats : expenseCats)[rnd.nextInt((type == 'income' ? incomeCats : expenseCats).length)].id}'
        ..accountId = account ?? '${accounts[rnd.nextInt(accounts.length)].id}'
        ..createdAt = at
        ..updatedAt = at;

  for (var i = 0; i < count; i++) {
    final at = start.add(Duration(
        days: rnd.nextInt(spanDays), minutes: rnd.nextInt(24 * 60)));
    final roll = rnd.nextInt(100);
    final amount = rnd.nextBool()
        ? (rnd.nextInt(5000) + 10).toDouble()
        : (rnd.nextInt(500000) + 100) / 100;
    if (roll < 4) {
      final id = 'tr-$i';
      final from = accounts[rnd.nextInt(accounts.length)];
      final to = accounts.firstWhere((a) => a.id != from.id);
      txns
        ..add(tx('Transfer', amount, 'expense', at, account: '${from.id}')
          ..isTransfer = true
          ..transferId = id)
        ..add(tx('Transfer', amount, 'income', at, account: '${to.id}')
          ..isTransfer = true
          ..transferId = id);
    } else if (roll < 5) {
      txns.add(tx('Balance adjustment', amount, rnd.nextBool() ? 'income' : 'expense', at)
        ..isBalanceAdjustment = true);
    } else if (roll < 20) {
      txns.add(tx('Salary', amount * 10, 'income', at));
    } else {
      txns.add(tx('Spend $i', amount, 'expense', at));
    }
  }
  // Linked rows, as the old processors and flows created them.
  for (var m = 0; m < 46; m++) {
    final due = DateTime(2023, 1 + m, 1, 9, 30);
    txns.add(tx('Rent', 18000, 'expense', due,
        account: rule.accountId, category: rule.categoryId)
      ..linkedRuleId = '${rule.id}'
      ..linkedRuleType = 'recurring');
    final emi = DateTime(2023, 1 + m, 5, 10, 2);
    txns.add(tx('EMI - Home loan', 21696, 'expense', emi,
        account: loan.accountId, category: loan.categoryId)
      ..linkedRuleId = loan.uid
      ..linkedRuleType = 'loan');
    final sip = DateTime(2023, 1 + m, 10, 11, 0);
    txns.add(tx('Contribution - ${inv.name}', 5000, 'expense', sip,
        account: inv.accountId, category: inv.categoryId)
      ..linkedRuleId = inv.uid
      ..linkedRuleType = 'investment');
  }
  txns.add(tx('Extra Payment - Home loan', 200000, 'expense',
      DateTime(2025, 3, 20, 12), account: loan.accountId, category: loan.categoryId)
    ..linkedRuleId = loan.uid
    ..linkedRuleType = 'loan');
  for (var i = 0; i < 10; i++) {
    txns.add(tx('Lent to Ravi', 1000.0 + i, 'expense', DateTime(2024, 6, i + 1))
      ..linkedRuleId = 'ledger-$i'
      ..linkedRuleType = 'lent');
    txns.add(tx('Borrowed from Asha', 700.0 + i, 'income', DateTime(2024, 7, i + 1))
      ..linkedRuleId = 'ledger-b$i'
      ..linkedRuleType = 'borrowed');
  }
  await isar.writeTxn(() => isar.transactions.putAll(txns));
}
