// occurrencesBetween (upcoming-calendar-v1): every dated money event between
// two days, past and future, with a status. One engine for the Calendar and
// the List (the List keeps its old "next one per source" rule on top of it,
// see UpcomingEventsAggregator.getUpcomingEvents).
//
// Past schedule days come from the schedule itself (watermark + skipped
// dates); their actual amounts from the posted transactions (indexed by
// source). Credit card bills are worked out from the card's transactions in
// the statement cycle; nothing new is stored.

import 'package:isar_community/isar.dart';

import '../../../core/money_math/investment_math.dart';
import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../accounts/data/account.dart';
import '../../investments/data/investment.dart';
import '../../investments/domain/investment_engine.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../loans/domain/loan_engine.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../reminders/data/reminder.dart';
import '../../transactions/data/transaction.dart';
import 'event_aggregator.dart';

enum OccurrenceStatus { upcoming, needsConfirmation, done, skipped, overdue }

class CalendarOccurrence {
  final UpcomingEvent event;
  final OccurrenceStatus status;

  /// Signed amount that actually posted (done schedule days).
  final double? actual;

  /// Credit card payment due: the statement amount, when known.
  final double? cardBill;

  /// Position among this source's occurrences on or after today (0 = next).
  /// -1 for past days. Used by the List's "next one per source" rule.
  final int ordinal;

  /// A pre-vNext row (no schedule yet): the List shows only its next date.
  final bool legacy;

  const CalendarOccurrence(
    this.event,
    this.status, {
    this.actual,
    this.cardBill,
    this.ordinal = -1,
    this.legacy = false,
  });

  int get day => dayKey(event.date);

  /// Signed amount for totals: what posted, else what is scheduled.
  double? get amount => actual ?? event.amount;

  bool get isCardDue => event is CreditCardEvent && (event as CreditCardEvent).isPaymentDue;
  bool get isCardStatement =>
      event is CreditCardEvent && !(event as CreditCardEvent).isPaymentDue;

  /// Type order inside a day (design §2): reminders, EMIs, SIPs and FDs,
  /// recurring, lent and borrowed, credit cards.
  int get typeOrder => switch (event.sourceType) {
        'reminder' => 0,
        'emi' => 1,
        'sip' => 2,
        'recurring' => 3,
        'ledger' => 4,
        _ => 5,
      };
}

/// Month and day totals (design §6).
class OccurrenceTotals {
  final double out;
  final double inn;
  final double cardBills;
  const OccurrenceTotals(this.out, this.inn, this.cardBills);
  bool get isEmpty => out == 0 && inn == 0 && cardBills == 0;

  /// Skipped items, reminders without an amount and statements are left out;
  /// card payments go on their own line, never into out.
  factory OccurrenceTotals.of(Iterable<CalendarOccurrence> items) {
    var out = 0.0, inn = 0.0, card = 0.0;
    for (final o in items) {
      if (o.status == OccurrenceStatus.skipped || o.isCardStatement) continue;
      if (o.isCardDue) {
        card += o.cardBill ?? 0;
        continue;
      }
      final a = o.amount;
      if (a == null) continue;
      if (a >= 0) {
        inn += a;
      } else {
        out -= a;
      }
    }
    return OccurrenceTotals(out, inn, card);
  }
}

/// Calendar order: day, then time of day (untimed first), then type order.
int compareOccurrences(CalendarOccurrence a, CalendarOccurrence b) {
  final d = a.day.compareTo(b.day);
  if (d != 0) return d;
  int minutes(CalendarOccurrence o) => o.event.date.hour * 60 + o.event.date.minute;
  final t = minutes(a).compareTo(minutes(b));
  if (t != 0) return t;
  return a.typeOrder.compareTo(b.typeOrder);
}

class OccurrenceEngine {
  final Isar isar;
  const OccurrenceEngine(this.isar);

  /// Every occurrence from [start] to [end] (inclusive days), in source order
  /// (reminders, EMIs, SIPs, recurring, ledger, cards, FD maturity; each
  /// source chronological). Sort with [compareOccurrences] for the calendar.
  /// [sources] uses the List's source names ('sip' includes FD maturity).
  Future<List<CalendarOccurrence>> between(
    DateTime start,
    DateTime end, {
    DateTime? at,
    Set<String>? sources,
    List<Account>? accounts,
  }) async {
    final now = at ?? DateTime.now();
    final today = dayKey(now);
    final from = dayKey(start), to = dayKey(end);
    bool wanted(String t) => sources == null || sources.contains(t);
    final out = <CalendarOccurrence>[];

    if (wanted('reminder')) {
      for (final r in await isar.reminders.where().findAll()) {
        out.addAll(_reminder(r, from, to, now));
      }
    }
    if (wanted('emi')) {
      for (final l in await isar.loans.where().findAll()) {
        final s = l.schedule;
        final active = !l.isCompleted && l.closedAt == null;
        if (s == null) {
          if (active) {
            out.addAll(_legacyMonthly(l.billDate, from, to, today,
                (d) => LoanEmiEvent(l, d)));
          }
          continue;
        }
        final posted = await _posted('loan', l.uid, from, to);
        out.addAll(_schedule(s, from, to, today, active: active, posted: posted,
            build: (d) => LoanEmiEvent(l, d, emi: emiFor(l, dayKey(d), 2).amount)));
      }
    }
    final investments = wanted('sip') ? await isar.investments.where().findAll() : const <Investment>[];
    for (final i in investments) {
      final s = i.sip;
      final active = i.status == InvestmentStatus.active;
      if (s == null) {
        final day = i.sipDate;
        if (active && i.autoDebit && day != null) {
          out.addAll(_legacyMonthly(day, from, to, today, (d) => InvestmentSipEvent(i, d)));
        }
        continue;
      }
      final posted = await _posted('investment', i.uid, from, to);
      out.addAll(_schedule(s, from, to, today, active: active, posted: posted,
          build: (d) => InvestmentSipEvent(i, d,
              sip: stepUpAmount(
                  base: i.sipAmount ?? i.installment ?? 0,
                  start: s.startDate!,
                  on: d,
                  percent: i.stepUpKind == StepUpKind.percent,
                  value: i.stepUpValue))));
    }
    if (wanted('recurring')) {
      for (final r in await isar.recurringRules.where().findAll()) {
        final s = r.schedule;
        if (s == null) {
          final k = dayKey(r.nextDueAt);
          if (!r.isPaused && k >= from && k <= to) {
            out.add(CalendarOccurrence(RecurringEvent(r),
                k < today ? OccurrenceStatus.upcoming : OccurrenceStatus.upcoming,
                ordinal: k >= today ? 0 : -1, legacy: true));
          }
          continue;
        }
        final posted = await _posted('recurring', '${r.id}', from, to);
        out.addAll(_schedule(s, from, to, today,
            active: true, posted: posted, build: (d) => RecurringEvent(r, d)));
      }
    }
    if (wanted('ledger')) {
      final ledgers = await isar.ledgers.filter().expectedDateIsNotNull().findAll();
      for (final l in ledgers) {
        final k = dayKey(l.expectedDate!);
        if (k < from || k > to) continue;
        final status = l.isSettled
            ? OccurrenceStatus.done
            : k < today
                ? OccurrenceStatus.overdue
                : OccurrenceStatus.upcoming;
        out.add(CalendarOccurrence(LedgerEvent(l), status, ordinal: k >= today ? 0 : -1));
      }
    }
    if (wanted('creditCard')) {
      final cards = accounts ?? await isar.accounts.where().findAll();
      for (final a in cards) {
        if (!a.isCreditCard || a.isDisabled) continue;
        out.addAll(await _card(a, from, to, today));
      }
    }
    for (final i in investments) {
      if (i.behaviour != InvestmentBehaviour.fixedReturn || i.maturityDate == null) continue;
      final k = dayKey(i.maturityDate!);
      if (k < from || k > to) continue;
      final handled = i.maturityHandled;
      if (i.status == InvestmentStatus.closed && !handled) continue; // closed early
      out.add(CalendarOccurrence(
          InvestmentMaturityEvent(i, dayOf(k), maturityValue(i) ?? currentValue(i)),
          handled ? OccurrenceStatus.done : OccurrenceStatus.upcoming,
          ordinal: k >= today ? 0 : -1));
    }
    return out;
  }

  // ── Sources ──────────────────────────────────────────────────────────────

  Iterable<CalendarOccurrence> _reminder(Reminder r, int from, int to, DateTime now) sync* {
    final today = dayKey(now);
    if (r.isCompleted) {
      final k = dayKey(r.dueAt);
      if (k >= from && k <= to) yield CalendarOccurrence(ReminderEvent(r), OccurrenceStatus.done);
      return;
    }
    var due = r.dueAt;
    var ordinal = 0;
    for (var guard = 0; guard < 400; guard++) {
      final k = dayKey(due);
      if (k > to) break;
      if (k >= from) {
        final event = guard == 0 ? ReminderEvent(r) : _RepeatReminderEvent(r, due);
        final OccurrenceStatus status;
        if (k < today) {
          status = OccurrenceStatus.overdue;
        } else if (k == today && r.amount != null && !due.isAfter(now)) {
          status = OccurrenceStatus.needsConfirmation;
        } else {
          status = OccurrenceStatus.upcoming;
        }
        yield CalendarOccurrence(event, status, ordinal: k >= today ? ordinal++ : -1);
      }
      final repeat = r.repeat;
      if (repeat == null) break;
      due = switch (repeat) {
        ReminderRepeat.daily => due.add(const Duration(days: 1)),
        ReminderRepeat.weekly => due.add(const Duration(days: 7)),
        ReminderRepeat.monthly => DateTime(due.year, due.month + 1, due.day, due.hour, due.minute),
        ReminderRepeat.yearly => DateTime(due.year + 1, due.month, due.day, due.hour, due.minute),
        _ => due.add(const Duration(days: 1)),
      };
    }
  }

  /// A shared schedule: days up to the watermark are done (or skipped), the
  /// rest come from upcomingOccurrences (end and count respected).
  Iterable<CalendarOccurrence> _schedule(
    Schedule s,
    int from,
    int to,
    int today, {
    required bool active,
    required Map<int, double> posted,
    required UpcomingEvent Function(DateTime d) build,
  }) sync* {
    if (s.startDate == null) return;
    final endKey = s.endType == ScheduleEnd.onDate && s.endDate != null ? dayKey(s.endDate!) : null;
    final skipped = s.skippedDates.toSet();
    final lastDone = s.processedThrough < to ? s.processedThrough : to;
    if (from <= lastDone) {
      for (final k in lattice(s)) {
        if (k > lastDone || (endKey != null && k > endKey)) break;
        if (k < from) continue;
        if (skipped.contains(k)) {
          yield CalendarOccurrence(build(dayOf(k)), OccurrenceStatus.skipped);
        } else {
          final e = build(dayOf(k));
          final p = posted[k];
          yield CalendarOccurrence(e, OccurrenceStatus.done,
              actual: p == null ? null : ((e.amount ?? -1) < 0 ? -p : p));
        }
      }
    }
    if (!active || s.paused) return;
    var ordinal = 0;
    for (final o in upcomingOccurrences(s,
        fromKey: from, toKey: to, limit: 100000, includeSkipped: true)) {
      final isFuture = o.day >= today;
      yield CalendarOccurrence(
        build(dayOf(o.day)),
        o.skipped ? OccurrenceStatus.skipped : OccurrenceStatus.upcoming,
        // Recurring, EMIs and SIPs record on the next run: never overdue.
        ordinal: isFuture && !o.skipped ? ordinal++ : -1,
      );
    }
  }

  /// Pre-vNext loans and SIPs (day of month only): future dates.
  Iterable<CalendarOccurrence> _legacyMonthly(
      int day, int from, int to, int today, UpcomingEvent Function(DateTime d) build) sync* {
    var ordinal = 0;
    for (final k in _monthly(day, from, to)) {
      if (k < today) continue;
      yield CalendarOccurrence(build(dayOf(k)), OccurrenceStatus.upcoming,
          ordinal: ordinal++, legacy: true);
    }
  }

  /// Day [day] of every month from [from] to [to], clamped to short months.
  static Iterable<int> _monthly(int day, int from, int to) sync* {
    var y = from ~/ 10000, m = from ~/ 100 % 100;
    while (true) {
      final k = y * 10000 + m * 100 + day.clamp(1, daysInMonthOf(y, m));
      if (k > to) return;
      if (k >= from) yield k;
      m++;
      if (m > 12) {
        m = 1;
        y++;
      }
    }
  }

  /// Posted amounts by occurrence day for one source (indexed query).
  Future<Map<int, double>> _posted(String type, String id, int from, int to) async {
    final rows = await isar.transactions
        .where()
        .sourceTypeSourceIdEqualTo(type, id)
        .filter()
        .occurrenceDateBetween(from, to)
        .findAll();
    return {for (final t in rows) t.occurrenceDate!: t.amount};
  }

  /// Statement and payment-due days. The bill is the card's spending in the
  /// cycle that ends on the statement day (known once that day has come).
  /// Done when payments into the card since the statement cover it; Overdue
  /// after the due day otherwise; neutral when the amount is not known.
  Future<List<CalendarOccurrence>> _card(Account a, int from, int to, int today) async {
    final out = <CalendarOccurrence>[];
    final billDay = a.billGenerationDay, dueDay = a.paymentDueDay;
    if (billDay != null) {
      var ordinal = 0;
      for (final k in _monthly(billDay, from, to)) {
        out.add(CalendarOccurrence(
            CreditCardEvent(a, dayOf(k), isPaymentDue: false),
            k < today ? OccurrenceStatus.done : OccurrenceStatus.upcoming,
            ordinal: k >= today ? ordinal++ : -1));
      }
    }
    if (dueDay == null) return out;
    final dues = _monthly(dueDay, from, to).toList();
    if (dues.isEmpty) return out;
    List<Transaction> txns = const [];
    if (billDay != null) {
      final first = dayOf(dues.first).subtract(const Duration(days: 70));
      txns = await isar.transactions
          .where()
          .accountIdEqualTo('${a.id}')
          .filter()
          .createdAtGreaterThan(first)
          .findAll();
    }
    var ordinal = 0;
    for (final due in dues) {
      double? bill;
      var paid = 0.0;
      if (billDay != null) {
        final statement = _statementBefore(billDay, due);
        final prev = _statementBefore(billDay, statement);
        if (statement <= today) {
          var spent = 0.0;
          for (final t in txns) {
            final k = dayKey(t.createdAt);
            if (k > prev && k <= statement && !t.isTransfer) {
              spent += t.type == 'expense' ? t.amount : -t.amount;
            }
            if (k > statement && t.type == 'income' && t.isTransfer) paid += t.amount;
          }
          if (spent > 0) bill = spent;
        }
      }
      final OccurrenceStatus status;
      if (bill != null && paid + 0.005 >= bill) {
        status = OccurrenceStatus.done;
      } else if (bill != null && due < today) {
        status = OccurrenceStatus.overdue;
      } else {
        status = OccurrenceStatus.upcoming;
      }
      out.add(CalendarOccurrence(CreditCardEvent(a, dayOf(due), isPaymentDue: true), status,
          cardBill: bill, ordinal: due >= today ? ordinal++ : -1));
    }
    return out;
  }

  /// The last statement day strictly before [key].
  static int _statementBefore(int billDay, int key) {
    var y = key ~/ 10000, m = key ~/ 100 % 100;
    for (var i = 0; i < 3; i++) {
      final k = y * 10000 + m * 100 + billDay.clamp(1, daysInMonthOf(y, m));
      if (k < key) return k;
      m--;
      if (m < 1) {
        m = 12;
        y--;
      }
    }
    return key;
  }
}

/// A later repeat of a repeating reminder (the row itself holds only the next
/// due date). Opens the same reminder.
class _RepeatReminderEvent extends ReminderEvent {
  @override
  final DateTime date;
  const _RepeatReminderEvent(super.reminder, this.date);
}
