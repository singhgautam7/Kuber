import 'package:isar_community/isar.dart';

import '../../../core/utils/monthly_recurrence.dart';
import '../../accounts/data/account.dart';
import '../../investments/data/investment.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../reminders/data/reminder.dart';

/// One upcoming money event, normalized across the 6 sources. Read-only,
/// one-directional aggregation — sources never know this exists.
sealed class UpcomingEvent {
  DateTime get date;
  String get title;

  /// Signed amount: negative = outgoing, positive = incoming. null = none.
  double? get amount;

  /// 'reminder' | 'emi' | 'sip' | 'recurring' | 'ledger' | 'creditCard'
  String get sourceType;

  String get sourceId;
}

class ReminderEvent implements UpcomingEvent {
  final Reminder reminder;
  const ReminderEvent(this.reminder);

  @override
  DateTime get date => reminder.dueAt;
  @override
  String get title => reminder.title;
  @override
  double? get amount => reminder.amount == null
      ? null
      : (reminder.transactionType == 'income'
          ? reminder.amount
          : -reminder.amount!);
  @override
  String get sourceType => 'reminder';
  @override
  String get sourceId => '${reminder.id}';
}

class LoanEmiEvent implements UpcomingEvent {
  final Loan loan;
  @override
  final DateTime date;
  const LoanEmiEvent(this.loan, this.date);

  @override
  String get title => loan.name;
  @override
  double? get amount => -loan.emiAmount;
  @override
  String get sourceType => 'emi';
  @override
  String get sourceId => '${loan.id}';
}

class InvestmentSipEvent implements UpcomingEvent {
  final Investment investment;
  @override
  final DateTime date;
  const InvestmentSipEvent(this.investment, this.date);

  @override
  String get title => investment.name;
  @override
  double? get amount =>
      investment.sipAmount == null ? null : -investment.sipAmount!;
  @override
  String get sourceType => 'sip';
  @override
  String get sourceId => '${investment.id}';
}

class RecurringEvent implements UpcomingEvent {
  final RecurringRule rule;
  const RecurringEvent(this.rule);

  @override
  DateTime get date => rule.nextDueAt;
  @override
  String get title => rule.name;
  @override
  double? get amount =>
      rule.type == 'income' ? rule.amount : -rule.amount;
  @override
  String get sourceType => 'recurring';
  @override
  String get sourceId => '${rule.id}';
}

class LedgerEvent implements UpcomingEvent {
  final Ledger ledger;
  const LedgerEvent(this.ledger);

  @override
  DateTime get date => ledger.expectedDate!;
  @override
  String get title => ledger.type == 'lent'
      ? '${ledger.personName} owes you'
      : 'Repay ${ledger.personName}';
  @override
  double? get amount => ledger.type == 'lent'
      ? ledger.originalAmount
      : -ledger.originalAmount;
  @override
  String get sourceType => 'ledger';
  @override
  String get sourceId => '${ledger.id}';
}

/// A credit-card billing-cycle event: either the statement generating
/// ([isPaymentDue] == false) or the payment falling due ([isPaymentDue] ==
/// true). One card can emit up to two per window. Amount is intentionally null
/// (see [amount]).
class CreditCardEvent implements UpcomingEvent {
  final Account account;
  @override
  final DateTime date;
  final bool isPaymentDue;

  const CreditCardEvent(this.account, this.date, {required this.isPaymentDue});

  @override
  String get title => isPaymentDue
      ? 'Payment due · ${account.name}'
      : 'Bill generated · ${account.name}';

  /// Always null: the outstanding balance would require summing the card's
  /// transactions, which is too costly for this live-refiring aggregator.
  @override
  double? get amount => null;

  @override
  String get sourceType => 'creditCard';
  @override
  String get sourceId => '${account.id}:${isPaymentDue ? 'due' : 'bill'}';

  /// A payment-due event within the next 3 days. Bill-generation events are
  /// never flagged urgent.
  bool get isUrgent {
    if (!isPaymentDue) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final days = d.difference(today).inDays;
    return days >= 0 && days <= 3;
  }
}

/// Queries all 6 sources and returns a chronologically merged, typed list
/// capped to `[now, now + window]`.
class UpcomingEventsAggregator {
  final Isar isar;

  const UpcomingEventsAggregator(this.isar);

  Future<List<UpcomingEvent>> getUpcomingEvents({
    required Duration window,
    Set<String>? sourceFilters,
  }) async {
    final now = DateTime.now();
    final end = now.add(window);
    bool wanted(String type) =>
        sourceFilters == null || sourceFilters.contains(type);
    bool inWindow(DateTime d) => !d.isBefore(now) && !d.isAfter(end);

    final events = <UpcomingEvent>[];

    if (wanted('reminder')) {
      final reminders = await isar.reminders
          .filter()
          .not()
          .statusEqualTo(ReminderStatus.completed)
          .findAll();
      events.addAll(reminders
          .where((r) => inWindow(r.dueAt))
          .map(ReminderEvent.new));
    }

    if (wanted('emi')) {
      final loans =
          await isar.loans.filter().isCompletedEqualTo(false).findAll();
      for (final loan in loans) {
        final next = nextMonthlyOccurrence(loan.billDate, now);
        if (inWindow(next)) events.add(LoanEmiEvent(loan, next));
      }
    }

    if (wanted('sip')) {
      final investments =
          await isar.investments.filter().autoDebitEqualTo(true).findAll();
      for (final inv in investments) {
        final day = inv.sipDate;
        if (day == null) continue;
        final next = nextMonthlyOccurrence(day, now);
        if (inWindow(next)) events.add(InvestmentSipEvent(inv, next));
      }
    }

    if (wanted('recurring')) {
      final rules = await isar.recurringRules
          .filter()
          .isPausedEqualTo(false)
          .findAll();
      events.addAll(rules
          .where((r) => inWindow(r.nextDueAt))
          .map(RecurringEvent.new));
    }

    if (wanted('ledger')) {
      final ledgers = await isar.ledgers
          .filter()
          .isSettledEqualTo(false)
          .expectedDateIsNotNull()
          .findAll();
      events.addAll(ledgers
          .where((l) => inWindow(l.expectedDate!))
          .map(LedgerEvent.new));
    }

    if (wanted('creditCard')) {
      // Small table (a handful of rows): load once and filter in memory.
      final accounts = await isar.accounts.where().findAll();
      for (final a in accounts) {
        if (!a.isCreditCard || a.isDisabled) continue;
        final billDay = a.billGenerationDay;
        if (billDay != null) {
          final next = nextMonthlyOccurrence(billDay, now);
          if (inWindow(next)) {
            events.add(CreditCardEvent(a, next, isPaymentDue: false));
          }
        }
        final dueDay = a.paymentDueDay;
        if (dueDay != null) {
          final next = nextMonthlyOccurrence(dueDay, now);
          if (inWindow(next)) {
            events.add(CreditCardEvent(a, next, isPaymentDue: true));
          }
        }
      }
    }

    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }
}
