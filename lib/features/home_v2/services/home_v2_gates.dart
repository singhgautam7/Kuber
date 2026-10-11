import 'package:isar_community/isar.dart';

import '../../accounts/data/account.dart';
import '../../budgets/data/budget.dart';
import '../../investments/data/investment.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../notes/data/kuber_note.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../reminders/data/reminder.dart';
import '../../sms_import/data/sms_import_repository.dart';
import '../../sms_import/data/sms_transaction.dart';
import '../../stories/data/insight_story.dart';
import '../../transactions/data/transaction.dart';

/// Data-gated triggers (widget-inventory.md › Inventory). Evaluates only
/// the ids still waiting ([pending]) and returns the ones whose trigger is
/// true now. Every check is an Isar `count()` or a single-property query, so
/// no transaction objects are deserialised.
class HomeV2Gates {
  const HomeV2Gates._();

  /// Collections whose changes can flip a trigger, for `watchLazy`.
  static List<IsarCollection<dynamic>> watched(Isar isar) => [
    isar.transactions,
    isar.accounts,
    isar.budgets,
    isar.kuberNotes,
    isar.loans,
    isar.investments,
    isar.recurringRules,
    isar.reminders,
    isar.ledgers,
    isar.insightStorys,
    isar.smsTransactions,
  ];

  static Future<Set<String>> evaluate(
    Isar isar,
    Set<String> pending, {
    required Set<int> seededAccountIds,
    required Future<bool> Function() smsPermission,
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    final open = <String>{};
    for (final id in pending) {
      final ok = switch (id) {
        // A generated story; the Welcome story seeded at install does not
        // count (it exists before the user has any data).
        'insight_stories' =>
          await isar.insightStorys
                  .filter()
                  .not()
                  .typeEqualTo('welcome')
                  .count() >
              0,
        'spending_stats' => await _expenseDaysIn30(isar, t) >= 7,
        'sms_import_widget' =>
          await isar.smsTransactions
                      .filter()
                      .reviewStatusEqualTo(SmsReviewStatus.unreviewed)
                      .count() >
                  0 &&
              await smsPermission(),
        'home_accounts' => await _accountsTrigger(isar, seededAccountIds),
        'seven_day_chart' => await _distinctTxnDays(isar, 3) >= 3,
        'budget_snapshot' =>
          await isar.budgets.filter().isActiveEqualTo(true).count() > 0,
        'upcoming_events_widget' => await _hasUpcoming(isar),
        'kuber_notes_widget' => await isar.kuberNotes.count() > 0,
        _ => false,
      };
      if (ok) open.add(id);
    }
    return open;
  }

  static int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  /// Distinct calendar days with an expense in the last 30 days.
  static Future<int> _expenseDaysIn30(Isar isar, DateTime now) async {
    final dates = await isar.transactions
        .filter()
        .typeEqualTo('expense')
        .isTransferEqualTo(false)
        .isBalanceAdjustmentEqualTo(false)
        .createdAtGreaterThan(now.subtract(const Duration(days: 30)))
        .createdAtProperty()
        .findAll();
    return {for (final d in dates) _dayKey(d)}.length;
  }

  /// Distinct days with an income or expense (any date). Walks newest first
  /// and stops as soon as [enough] days are found.
  static Future<int> _distinctTxnDays(Isar isar, int enough) async {
    final dates = await isar.transactions
        .filter()
        .isTransferEqualTo(false)
        .isBalanceAdjustmentEqualTo(false)
        .sortByCreatedAtDesc()
        .createdAtProperty()
        .findAll();
    final days = <int>{};
    for (final d in dates) {
      days.add(_dayKey(d));
      if (days.length >= enough) break;
    }
    return days.length;
  }

  /// An account the user or SMS import created (not seeded at install), or
  /// a non-zero balance anywhere. ponytail: "any balance is not 0" is read
  /// as "a non-zero opening balance or any transaction exists" (a single
  /// transaction moves its account off 0); computing every balance here
  /// would mean loading all transactions.
  static Future<bool> _accountsTrigger(Isar isar, Set<int> seeded) async {
    final ids = await isar.accounts.where().idProperty().findAll();
    if (ids.any((id) => !seeded.contains(id))) return true;
    if (await isar.accounts.filter().not().initialBalanceEqualTo(0).count() >
        0) {
      return true;
    }
    return await isar.transactions.count() > 0;
  }

  /// Reminder, loan with an EMI, investment with a SIP, active recurring
  /// rule, or ledger entry with a due date.
  static Future<bool> _hasUpcoming(Isar isar) async =>
      await isar.reminders.count() > 0 ||
      await isar.loans
              .filter()
              .isCompletedEqualTo(false)
              .emiAmountGreaterThan(0)
              .count() >
          0 ||
      await isar.investments.filter().autoDebitEqualTo(true).count() > 0 ||
      await isar.recurringRules.filter().isPausedEqualTo(false).count() > 0 ||
      await isar.ledgers.filter().expectedDateIsNotNull().count() > 0;
}
