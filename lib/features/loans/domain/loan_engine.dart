// Loan record -> schedule dates, amortization and status. Pure Dart over the
// Isar models (no Flutter), shared by the EMI processor, the loan sheet /
// full screen, Upcoming events and Ask Kuber.

import 'dart:math' show min;

import '../../../core/money_math/loan_math.dart';
import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/processed_occurrence.dart';
import '../../transactions/data/transaction.dart';
import '../data/loan.dart';

RateKind rateKindOf(Loan l) => switch (l.interestType) {
      LoanInterestType.reducingBalance => RateKind.reducing,
      LoanInterestType.flatRate => RateKind.flat,
      LoanInterestType.interestOnlyFirst => RateKind.interestOnlyFirst,
    };

/// True when the loan has the numbers for a principal / interest split.
bool hasLoanNumbers(Loan l) =>
    l.startingPoint != LoanStartingPoint.trackEmiOnly &&
    l.annualRate != null &&
    (l.tenureMonths ?? 0) > 0 &&
    (l.startingPoint == LoanStartingPoint.outstandingToday
        ? (l.outstandingAtStart ?? 0) > 0
        : l.principalAmount > 0);

/// The day Kuber started tracking the loan (opening values are before it).
/// With "Add past EMIs as transactions" the whole loan is tracked.
int trackingDay(Loan l) {
  final first = l.schedule?.startDate;
  return l.addPastEmis && first != null ? dayKey(first) : dayKey(l.createdAt);
}

/// Every EMI date of the loan's rule (ignoring what's posted), long enough to
/// let a rate rise extend the tenure.
List<int> loanEmiDays(Loan l, {int extra = 360}) {
  final s = l.schedule;
  if (s == null || s.startDate == null) return const [];
  final n = (l.tenureMonths ?? 0) + extra;
  final copy = s.copy()
    ..processedThrough = 0
    ..postedCount = 0
    ..skippedDates = []
    ..endType = ScheduleEnd.never
    ..paused = false;
  return upcomingOccurrences(copy, limit: n).map((o) => o.day).toList();
}

/// The loan's payouts in date order. A loan saved before releases existed (or
/// with the switch off) is one release of the full principal.
List<LoanRelease> loanReleases(Loan l) {
  if (l.releasedInParts && l.releases.isNotEmpty) {
    return [...l.releases]..sort((a, b) => a.date!.compareTo(b.date!));
  }
  return [
    LoanRelease()
      ..date = l.loanStartDate ?? l.schedule?.startDate ?? l.startDate
      ..amount = l.principalAmount
      ..accountId = l.releases.firstOrNull?.accountId
      ..transactionId = l.releases.firstOrNull?.transactionId,
  ];
}

/// Released so far (the full principal unless released in parts).
double loanReleasedTotal(Loan l) =>
    loanReleases(l).fold(0.0, (s, r) => s + r.amount);

/// Walks the first release to the first EMI instead of starting on the
/// principal. Off for every loan without the new settings, so their numbers
/// stay exact; "outstanding today" has no history to walk.
bool usesPreEmiLedger(Loan l) =>
    l.startingPoint != LoanStartingPoint.outstandingToday &&
    (l.releasedInParts || l.preEmiMode != LoanPreEmi.none);

PreEmiInterest _preEmiKind(Loan l) => switch (l.preEmiMode) {
      LoanPreEmi.none => PreEmiInterest.none,
      LoanPreEmi.payMonthly => PreEmiInterest.paid,
      LoanPreEmi.addToLoan => PreEmiInterest.added,
    };

/// Day of month pre-EMI interest is charged on.
int preEmiCycleDayOf(Loan l) =>
    l.preEmiCycleDay ?? l.schedule?.anchorDay ?? l.schedule?.startDate?.day ?? l.billDate;

List<AmortEvent> amortEventsOf(Loan l) => [
      for (final e in l.events)
        if (e.date != null)
          AmortEvent(
            dayKey(e.date!),
            switch (e.kind) {
              LoanEventKind.rateChange => AmortEventKind.rateChange,
              LoanEventKind.prepayment => AmortEventKind.prepayment,
              LoanEventKind.charge => AmortEventKind.charge,
              LoanEventKind.adjustment => AmortEventKind.adjustment,
              LoanEventKind.chargeAdded => AmortEventKind.chargeAdded,
            },
            amount: e.amount,
            newRate: e.newRate,
            adjustEmi: e.adjust == LoanAdjust.emi,
            interestAdded: e.kind == LoanEventKind.adjustment &&
                e.reason == LoanAdjustReason.interestAdded,
            // Update outstanding: the balance after that day's EMI.
            afterEmi: e.kind == LoanEventKind.adjustment,
          ),
      // The outstanding entered in the form, on the day it was entered.
      if (l.adjustment != 0)
        AmortEvent(dayKey(l.createdAt), AmortEventKind.adjustment, amount: l.adjustment),
    ];

/// The loan's amortization, or null for "Just track the EMI".
///
/// [linked]: the loan's transactions; recorded EMIs keep their own split
/// (an edited or out-of-date split is the truth, see [RecordedEmi]) and the
/// future is projected from the outstanding after them. [deletedDays]: EMIs
/// that were recorded and then deleted (no payment those months).
/// [recalculateFrom]: unedited recorded EMIs on or after this day are split
/// again from the outstanding (A4 "Recalculate").
Amortization? loanAmortization(Loan l,
    {List<Transaction> linked = const [],
    Set<int> deletedDays = const {},
    int? recalculateFrom,
    int decimals = 2}) {
  if (!hasLoanNumbers(l)) return null;
  final running = l.startingPoint == LoanStartingPoint.outstandingToday;
  final emiDays = loanEmiDays(l);
  var events = amortEventsOf(l);
  PreEmi? pre;
  if (usesPreEmiLedger(l) && emiDays.isNotEmpty) {
    final first = emiDays.first;
    bool before(AmortEvent e) => e.day < first || (e.day == first && !e.afterEmi);
    final all = [
      for (final r in loanReleases(l))
        // The switch off: the one release is there on the first EMI at the latest.
        l.releasedInParts ? r : (r.copy()..date = dayOf(min(dayKey(r.date!), first))),
    ];
    final releases = [
      for (final r in all)
        if (dayKey(r.date!) <= first) (dayKey(r.date!), r.amount),
    ];
    final later = [
      for (final r in all)
        if (dayKey(r.date!) > first)
          AmortEvent(dayKey(r.date!), AmortEventKind.release,
              amount: r.amount, adjustEmi: r.adjust == LoanAdjust.emi),
    ];
    pre = preEmiLedger(
      rate: l.annualRate!,
      mode: _preEmiKind(l),
      cycleDay: preEmiCycleDayOf(l),
      firstEmiDay: first,
      releases: releases,
      events: events.where(before).toList(),
      override: l.preEmiMode == LoanPreEmi.addToLoan ? l.preEmiOverride : null,
    );
    events = [...events.where((e) => !before(e)), ...later];
  } else if (running) {
    events = [
      ...events,
      for (final r in l.releases)
        AmortEvent(dayKey(r.date!), AmortEventKind.release,
            amount: r.amount, adjustEmi: r.adjust == LoanAdjust.emi),
    ];
  }
  final a = amortize(
    principal: pre?.balance ?? (running ? l.outstandingAtStart! : l.principalAmount),
    rate: pre?.rate ?? l.annualRate!,
    months: l.tenureMonths!,
    emiDays: emiDays,
    kind: rateKindOf(l),
    ioMonths: l.interestOnlyMonths,
    emi: l.emiAmount > 0 ? l.emiAmount : null,
    events: events,
    recorded: recordedEmis(linked, recalculateFrom: recalculateFrom),
    unpaid: deletedDays,
    decimals: decimals,
  );
  return pre == null ? a : Amortization(a.rows, a.events, a.openingBalance, preEmi: pre);
}

/// Recorded EMIs with a split, by schedule day.
Map<int, RecordedEmi> recordedEmis(List<Transaction> linked, {int? recalculateFrom}) => {
      for (final t in linked)
        if (t.occurrenceDate != null && t.principalPart != null && t.interestPart != null)
          t.occurrenceDate!: RecordedEmi(t.amount, t.principalPart!, t.interestPart!,
              edited: t.splitEdited,
              use: recalculateFrom != null && t.occurrenceDate! >= recalculateFrom
                  ? RecordedUse.recalculate
                  : RecordedUse.auto),
    };

/// A loan's transactions and deleted EMI days, for [loanStatus] /
/// [loanAmortization].
typedef LoanRecords = ({List<Transaction> linked, Set<int> deleted});

const LoanRecords noLoanRecords = (linked: <Transaction>[], deleted: <int>{});

/// [loanAmortization] with the loan's records.
Amortization? loanAmortizationWith(Loan l, LoanRecords r, {int? recalculateFrom}) =>
    loanAmortization(l,
        linked: r.linked, deletedDays: r.deleted, recalculateFrom: recalculateFrom);

/// EMIs recorded and then deleted: ledger rows marked posted whose
/// transaction no longer exists (the ledger keeps them from being posted
/// again; their principal goes back to the outstanding).
Set<int> deletedEmiDays(Iterable<ProcessedOccurrence> ledger, Set<int> existingIds) => {
      for (final p in ledger)
        if (p.sourceType == 'loan' &&
            p.status == 'posted' &&
            p.transactionId != null &&
            !existingIds.contains(p.transactionId))
          p.occurrenceDate,
    };

/// Update outstanding (A3): 0 offers to close the loan, below 0 is refused.
enum OutstandingCheck { ok, closes, negative }

OutstandingCheck outstandingError(double v) => v < 0
    ? OutstandingCheck.negative
    : (v < 0.005 ? OutstandingCheck.closes : OutstandingCheck.ok);

const preEmiTxnPrefix = 'Pre-EMI interest - ';

/// A cycle's interest under "I pay it every month".
bool isPreEmiTransaction(Transaction t) => t.name.startsWith(preEmiTxnPrefix);

/// True for transactions that are a regular EMI (not an extra payment,
/// charge or closure).
bool isEmiTransaction(Transaction t) =>
    t.occurrenceDate != null || t.name.startsWith('EMI - ');

/// A loan EMI whose split the user can edit (A2).
bool isEditableEmi(Transaction t) =>
    t.subType == TxnSubType.loanRepayment &&
    t.sourceType == 'loan' &&
    isEmiTransaction(t) &&
    !isPreEmiTransaction(t) &&
    t.principalPart != null &&
    t.interestPart != null;

class LoanStatus {
  final double? outstanding;
  final int emisPaid;
  final int? totalEmis;
  final int? nextDay;
  final double? nextAmount;
  final AmortRow? nextRow;
  final double? interestPaid;
  final double? principalPaid;
  final double? totalInterest;

  /// Unpaid interest the bank added to the loan (part of [totalInterest]).
  final double addedInterest;

  /// Charges the bank added to the loan (not interest, not spending).
  final double addedCharges;

  /// Released so far, when that is less than the sanctioned amount.
  final double? partlyReleased;
  final int? endDay;
  final bool closed;

  const LoanStatus({
    this.outstanding,
    required this.emisPaid,
    this.totalEmis,
    this.nextDay,
    this.nextAmount,
    this.nextRow,
    this.interestPaid,
    this.principalPaid,
    this.totalInterest,
    this.addedInterest = 0,
    this.addedCharges = 0,
    this.partlyReleased,
    this.endDay,
    this.closed = false,
  });

  double get progress =>
      totalEmis == null || totalEmis == 0 ? 0 : (emisPaid / totalEmis!).clamp(0, 1);
}

/// Where the loan stands on [now]. [linked] = the loan's transactions,
/// [deletedDays] = its recorded EMIs that were deleted.
LoanStatus loanStatus(Loan l, List<Transaction> linked,
    {DateTime? now, Set<int> deletedDays = const {}}) {
  final today = todayKey(now);
  final closed = l.isCompleted || l.closedAt != null;
  final s = l.schedule;
  final next = closed || s == null ? null : nextDate(s, fromKey: today);
  final a = loanAmortization(l, linked: linked, deletedDays: deletedDays);
  if (a == null) {
    final posted = linked.where(isEmiTransaction).length;
    return LoanStatus(
      emisPaid: l.emisPaidBefore + posted,
      totalEmis: s == null ? null : _totalEmis(l, s),
      nextDay: next,
      nextAmount: next == null ? null : l.emiAmount,
      endDay: s == null ? null : lastDate(s),
      closed: closed,
    );
  }
  // Today's EMI counts as paid once it has been recorded (watermark),
  // so "next EMI today" and the paid count agree.
  final paidThrough =
      s != null && s.processedThrough < today ? addDays(today, -1) : today;
  var paid = 0;
  var interest = 0.0, principal = 0.0;
  for (final r in a.rows) {
    if (r.day > paidThrough) break;
    paid++;
    interest += r.interest;
    principal += r.principal;
  }
  // Extra payments toward principal made up to today are principal paid.
  for (final e in a.events) {
    if (e.kind == AmortEventKind.prepayment && e.day <= today) principal += e.amount;
  }
  final running = l.startingPoint == LoanStartingPoint.outstandingToday;
  final row = next == null ? null : a.rowOn(next);
  final pre = a.preEmi;
  var prePaid = 0.0;
  if (pre != null && pre.mode == PreEmiInterest.paid) {
    for (final c in pre.cycles) {
      if (c.day <= today) prePaid += c.interest;
    }
  }
  final released = l.releasedInParts && !running ? loanReleasedTotal(l) : null;
  return LoanStatus(
    outstanding: closed ? 0 : a.balanceOn(paidThrough, eventsThrough: today),
    emisPaid: paid + (running ? l.emisPaidBefore : 0),
    totalEmis: a.rows.length + (running ? l.emisPaidBefore : 0),
    nextDay: row == null ? null : next,
    nextAmount: row?.payment,
    nextRow: row,
    interestPaid: interest + prePaid + (running ? l.interestPaidBefore : 0),
    principalPaid: principal + (running ? l.principalPaidBefore : 0),
    totalInterest: a.totalInterest +
        a.addedInterest +
        (pre?.paidInterest ?? 0) +
        (running ? l.interestPaidBefore : 0),
    addedInterest: a.addedInterest,
    addedCharges: a.addedCharges,
    partlyReleased:
        released != null && released < l.principalAmount - 0.005 ? released : null,
    endDay: a.rows.isEmpty ? null : a.rows.last.day,
    closed: closed,
  );
}

int? _totalEmis(Loan l, Schedule s) {
  final t = totalOccurrences(s);
  if (t == null) return null;
  return t + l.emisPaidBefore;
}

/// The EMI to post on [day]: amount and split (null split for loans without
/// numbers). [decimals] = the currency's minor units.
({double amount, double? principal, double? interest}) emiFor(
    Loan l, int day, int decimals,
    {List<Transaction> linked = const [], Set<int> deletedDays = const {}}) {
  final a = loanAmortization(l,
      linked: linked, deletedDays: deletedDays, decimals: decimals);
  final row = a?.rowOn(day);
  if (row == null) {
    return (amount: l.emiAmount, principal: null, interest: null);
  }
  final s = roundedSplit(row.payment, row.interest, decimals);
  return (amount: s.payment, principal: s.principal, interest: s.interest);
}

/// True when the loan is paid off once [day]'s EMI is posted (call after
/// the schedule was marked posted).
bool paidOffAfter(Loan l, int day) {
  final a = loanAmortization(l);
  if (a != null) {
    final last = a.rows.isEmpty ? null : a.rows.last.day;
    return last != null && day >= last;
  }
  final s = l.schedule;
  return s != null && s.endType != ScheduleEnd.never && isEnded(s);
}
