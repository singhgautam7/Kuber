import 'package:isar_community/isar.dart';

import '../../investments/data/investment.dart';
import '../../loans/data/loan.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/services/suggestion_service.dart';
import 'recurring_repository.dart';
import 'recurring_rule.dart';

class RecurringProcessor {
  final Isar isar;

  RecurringProcessor(this.isar);

  /// Processes all due recurring rules and creates missed transactions.
  /// Returns the total number of transactions created.
  Future<int> processAll() async {
    final now = DateTime.now();
    final repo = RecurringRepository(isar);
    final dueRules = await repo.getDue(now);
    final suggestionService = SuggestionService(isar);

    int totalCreated = 0;
    final createdRecurring = <Transaction>[];

    await isar.writeTxn(() async {
      for (final rule in dueRules) {
        if (RecurringRepository.isExpired(rule)) continue;

        var dueDate = rule.nextDueAt;

        // Create transactions for each missed due date
        while (dueDate.isBefore(now)) {
          // Check if rule has expired after incrementing execution count
          if (RecurringRepository.isExpired(rule)) break;

          final combinedDate = DateTime(
            dueDate.year,
            dueDate.month,
            dueDate.day,
            now.hour,
            now.minute,
            now.second,
            now.millisecond,
          );

          final t = Transaction()
            ..name = rule.name
            ..nameLower = rule.name.toLowerCase()
            ..amount = rule.amount
            ..type = rule.type
            ..categoryId = rule.categoryId
            ..accountId = rule.accountId
            ..notes = rule.notes
            ..linkedRuleId = rule.id.toString()
            ..linkedRuleType = 'recurring'
            ..createdAt = combinedDate
            ..updatedAt = DateTime.now();

          await isar.transactions.put(t);
          createdRecurring.add(t);
          totalCreated++;

          rule.executionCount++;
          dueDate = RecurringRepository.computeNextDue(rule, dueDate);

          if (RecurringRepository.isExpired(rule)) break;
        }

        rule.nextDueAt = dueDate;
        rule.updatedAt = DateTime.now();
        await isar.recurringRules.put(rule);
      }
    });

    for (final t in createdRecurring) {
      suggestionService.upsertSuggestion(t).ignore();
    }

    // Process loan auto-payments and investment SIP auto-debits
    totalCreated += await _processLoanAutoPayments(now, suggestionService);
    totalCreated += await _processInvestmentSipDebits(now, suggestionService);

    return totalCreated;
  }

  /// Creates EMI transactions for loans with autoAddTransaction on their bill date.
  Future<int> _processLoanAutoPayments(DateTime now, SuggestionService suggestionService) async {
    final today = now.day;
    final loans = await isar.loans
        .filter()
        .autoAddTransactionEqualTo(true)
        .isCompletedEqualTo(false)
        .findAll();

    int created = 0;

    for (final loan in loans) {
      if (loan.billDate != today) continue;

      // Check if an EMI transaction already exists for this loan today
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final existing = await isar.transactions
          .filter()
          .linkedRuleIdEqualTo(loan.uid)
          .linkedRuleTypeEqualTo('loan')
          .createdAtBetween(startOfDay, endOfDay, includeUpper: false)
          .findAll();

      if (existing.isNotEmpty) continue;

      final txnName = 'EMI — ${loan.name}';
      late Transaction t;
      await isar.writeTxn(() async {
        t = Transaction()
          ..name = txnName
          ..nameLower = txnName.toLowerCase()
          ..amount = loan.emiAmount
          ..type = 'expense'
          ..accountId = loan.accountId
          ..categoryId = loan.categoryId
          ..linkedRuleId = loan.uid
          ..linkedRuleType = 'loan'
          ..createdAt = now
          ..updatedAt = now;
        await isar.transactions.put(t);
      });
      suggestionService.upsertSuggestion(t).ignore();
      created++;
    }

    return created;
  }

  /// Creates SIP contribution transactions for investments with autoDebit on their SIP date.
  Future<int> _processInvestmentSipDebits(DateTime now, SuggestionService suggestionService) async {
    final today = now.day;
    final investments = await isar.investments
        .filter()
        .autoDebitEqualTo(true)
        .findAll();

    int created = 0;

    for (final inv in investments) {
      if (inv.sipDate != today) continue;
      if (inv.sipAmount == null || inv.sipAmount! <= 0) continue;
      if (inv.accountId == null) continue;

      // Check if a contribution already exists for this investment today
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final existing = await isar.transactions
          .filter()
          .linkedRuleIdEqualTo(inv.uid)
          .linkedRuleTypeEqualTo('investment')
          .createdAtBetween(startOfDay, endOfDay, includeUpper: false)
          .findAll();

      if (existing.isNotEmpty) continue;

      final txnName = 'Contribution — ${inv.name}';
      late Transaction t;
      await isar.writeTxn(() async {
        t = Transaction()
          ..name = txnName
          ..nameLower = txnName.toLowerCase()
          ..amount = inv.sipAmount!
          ..type = 'expense'
          ..accountId = inv.accountId!
          ..categoryId = inv.categoryId
          ..linkedRuleId = inv.uid
          ..linkedRuleType = 'investment'
          ..createdAt = now
          ..updatedAt = now;
        await isar.transactions.put(t);
      });
      suggestionService.upsertSuggestion(t).ignore();
      created++;
    }

    return created;
  }
}
