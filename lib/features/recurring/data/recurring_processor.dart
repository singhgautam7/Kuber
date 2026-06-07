import 'package:isar_community/isar.dart';
import 'package:kuber/core/utils/locale_font.dart' show AppLocale;
import 'package:kuber/l10n/app_localizations.dart' show lookupAppLocalizations;

import '../../investments/data/investment.dart';
import '../../loans/data/loan.dart';
import '../../notifications/data/app_notification.dart';
import '../../notifications/data/notification_repository.dart';
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
    final notificationRepo = NotificationRepository(isar);

    int totalCreated = 0;
    final createdRecurring = <Transaction>[];
    // Collected per (ruleId) so each rule produces at most one notification
    // for this run, regardless of how many missed dates it covers.
    final recurringNotifications = <int, _PendingNotification>{};

    await isar.writeTxn(() async {
      for (final rule in dueRules) {
        if (RecurringRepository.isExpired(rule)) continue;

        var dueDate = rule.nextDueAt;
        int created = 0;

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
          created++;

          rule.executionCount++;
          dueDate = RecurringRepository.computeNextDue(rule, dueDate);

          if (RecurringRepository.isExpired(rule)) break;
        }

        if (created > 0) {
          final l = lookupAppLocalizations(AppLocale.current);
          recurringNotifications[rule.id] = _PendingNotification(
            title: l.notifNewRecurring(created),
            body: l.notifRecurringBody(rule.name),
            payload: 'recurring:${rule.id}',
          );
        }

        rule.nextDueAt = dueDate;
        rule.updatedAt = DateTime.now();
        await isar.recurringRules.put(rule);
      }
    });

    for (final t in createdRecurring) {
      suggestionService.upsertSuggestion(t).ignore();
    }

    // In-app notifications only — see plan §2. No OS notification for the
    // batched on-open processing run.
    for (final n in recurringNotifications.values) {
      await notificationRepo.add(
        type: NotificationType.recurringTransaction,
        title: n.title,
        body: n.body,
        payload: n.payload,
      );
    }

    // Process loan auto-payments and investment SIP auto-debits
    totalCreated += await _processLoanAutoPayments(
        now, suggestionService, notificationRepo);
    totalCreated += await _processInvestmentSipDebits(
        now, suggestionService, notificationRepo);

    return totalCreated;
  }

  /// Creates EMI transactions for loans with autoAddTransaction on their bill date.
  Future<int> _processLoanAutoPayments(
    DateTime now,
    SuggestionService suggestionService,
    NotificationRepository notificationRepo,
  ) async {
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

      final txnName = 'EMI - ${loan.name}';
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

      final l = lookupAppLocalizations(AppLocale.current);
      await notificationRepo.add(
        type: NotificationType.loanEmi,
        title: l.notifLoanEmiTitle,
        body: l.notifLoanEmiBody(loan.name),
        payload: 'loan:${loan.uid}',
      );
      created++;
    }

    return created;
  }

  /// Creates SIP contribution transactions for investments with autoDebit on their SIP date.
  Future<int> _processInvestmentSipDebits(
    DateTime now,
    SuggestionService suggestionService,
    NotificationRepository notificationRepo,
  ) async {
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

      final txnName = 'Contribution - ${inv.name}';
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

      // Investment SIP debits are surfaced under the recurring-transaction
      // type since there's no dedicated investment notification channel.
      final l = lookupAppLocalizations(AppLocale.current);
      await notificationRepo.add(
        type: NotificationType.recurringTransaction,
        title: l.notifInvestmentTitle,
        body: l.notifInvestmentBody(inv.name),
        payload: 'investment:${inv.uid}',
      );
      created++;
    }

    return created;
  }
}

class _PendingNotification {
  final String title;
  final String body;
  final String payload;
  _PendingNotification(
      {required this.title, required this.body, required this.payload});
}
