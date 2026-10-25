import 'package:isar_community/isar.dart';

import 'occurrences.dart';

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

  /// The EMI due then (interest-only months, rate changes and prepayments
  /// applied); defaults to the loan's EMI.
  final double? emi;
  const LoanEmiEvent(this.loan, this.date, {this.emi});

  @override
  String get title => loan.name;
  @override
  double? get amount => -(emi ?? loan.emiAmount);
  @override
  String get sourceType => 'emi';
  @override
  String get sourceId => '${loan.id}';
}

class InvestmentSipEvent implements UpcomingEvent {
  final Investment investment;
  @override
  final DateTime date;

  /// The installment due then (yearly step-up applied).
  final double? sip;
  const InvestmentSipEvent(this.investment, this.date, {this.sip});

  @override
  String get title => investment.name;
  @override
  double? get amount {
    final v = sip ?? investment.sipAmount;
    return v == null ? null : -v;
  }
  @override
  String get sourceType => 'sip';
  @override
  String get sourceId => '${investment.id}';
}

class RecurringEvent implements UpcomingEvent {
  final RecurringRule rule;
  final DateTime? next;
  const RecurringEvent(this.rule, [this.next]);

  @override
  DateTime get date => next ?? rule.nextDueAt;
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

/// FD maturity (decision 3): under the SIPs filter and dot, counted as In.
class InvestmentMaturityEvent implements UpcomingEvent {
  final Investment investment;
  @override
  final DateTime date;
  final double? value;
  const InvestmentMaturityEvent(this.investment, this.date, this.value);

  @override
  String get title => investment.name;
  @override
  double? get amount => value;
  @override
  String get sourceType => 'sip';
  @override
  String get sourceId => '${investment.id}:maturity';
}

/// The List view and the home widgets: the next event per source within
/// `[now, now + window]` (the rule from before the calendar), built on
/// [OccurrenceEngine] so both views read one engine. FD maturity is new
/// (upcoming-calendar-v1) and is merged in after the old ordering.
class UpcomingEventsAggregator {
  final Isar isar;

  const UpcomingEventsAggregator(this.isar);

  Future<List<UpcomingEvent>> getUpcomingEvents({
    required Duration window,
    Set<String>? sourceFilters,
    // Pre-loaded accounts, to avoid a duplicate read when the caller (e.g.
    // widget sync) already has them. Null = load here.
    List<Account>? accounts,
    // Tests pin the clock; the app passes nothing.
    DateTime? at,
  }) async {
    final now = at ?? DateTime.now();
    final end = now.add(window);
    bool inWindow(DateTime d) => !d.isBefore(now) && !d.isAfter(end);

    final all = await OccurrenceEngine(isar).between(
      DateTime(now.year, now.month, now.day),
      end,
      at: now,
      sources: sourceFilters,
      accounts: accounts,
    );
    final events = <UpcomingEvent>[];
    final maturities = <UpcomingEvent>[];
    final taken = <String>{}; // sources that already have their next event
    for (final o in all) {
      if (o.ordinal < 0) continue; // before today
      final e = o.event;
      final key = '${e.runtimeType}:${e.sourceId}';
      switch (e) {
        case InvestmentMaturityEvent():
          if (o.status != OccurrenceStatus.done && inWindow(e.date)) maturities.add(e);
        case ReminderEvent(:final reminder):
          // The reminder's own due date only, never its later repeats.
          if (e.date == reminder.dueAt &&
              o.status != OccurrenceStatus.done &&
              inWindow(e.date)) {
            events.add(e);
          }
        case LedgerEvent():
          if (o.status != OccurrenceStatus.done && inWindow(e.date)) events.add(e);
        case CreditCardEvent():
        case LoanEmiEvent():
        case InvestmentSipEvent():
        case RecurringEvent():
          if (taken.contains(key) || o.status == OccurrenceStatus.skipped) continue;
          // Old rows and cards: only their next date counts. Schedules: the
          // first one inside the window.
          if (o.legacy || e is CreditCardEvent) taken.add(key);
          if (inWindow(e.date)) {
            events.add(e);
            taken.add(key);
          }
      }
    }
    events.sort((a, b) => a.date.compareTo(b.date));
    for (final m in maturities) {
      var at = events.length;
      while (at > 0 && events[at - 1].date.isAfter(m.date)) {
        at--;
      }
      events.insert(at, m);
    }
    return events;
  }
}
