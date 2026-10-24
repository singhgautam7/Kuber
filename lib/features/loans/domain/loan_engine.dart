// Loan record -> schedule dates, amortization and status. Pure Dart over the
// Isar models (no Flutter), shared by the EMI processor, the loan sheet /
// full screen, Upcoming events and Ask Kuber.

import '../../../core/money_math/loan_math.dart';
import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
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
int trackingDay(Loan l) => dayKey(l.createdAt);

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

List<AmortEvent> amortEventsOf(Loan l) => [
      for (final e in l.events)
        if (e.date != null)
          AmortEvent(
            dayKey(e.date!),
            switch (e.kind) {
              LoanEventKind.rateChange => AmortEventKind.rateChange,
              LoanEventKind.prepayment => AmortEventKind.prepayment,
              LoanEventKind.charge => AmortEventKind.charge,
            },
            amount: e.amount,
            newRate: e.newRate,
            adjustEmi: e.adjust == LoanAdjust.emi,
          ),
      if (l.adjustment != 0)
        AmortEvent(trackingDay(l), AmortEventKind.adjustment, amount: l.adjustment),
    ];

/// The loan's amortization, or null for "Just track the EMI".
Amortization? loanAmortization(Loan l) {
  if (!hasLoanNumbers(l)) return null;
  final running = l.startingPoint == LoanStartingPoint.outstandingToday;
  return amortize(
    principal: running ? l.outstandingAtStart! : l.principalAmount,
    rate: l.annualRate!,
    months: l.tenureMonths!,
    emiDays: loanEmiDays(l),
    kind: rateKindOf(l),
    ioMonths: l.interestOnlyMonths,
    emi: l.emiAmount > 0 ? l.emiAmount : null,
    events: amortEventsOf(l),
  );
}

/// True for transactions that are a regular EMI (not an extra payment,
/// charge or closure).
bool isEmiTransaction(Transaction t) =>
    t.occurrenceDate != null || t.name.startsWith('EMI - ');

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
    this.endDay,
    this.closed = false,
  });

  double get progress =>
      totalEmis == null || totalEmis == 0 ? 0 : (emisPaid / totalEmis!).clamp(0, 1);
}

/// Where the loan stands on [now]. [linked] = the loan's transactions.
LoanStatus loanStatus(Loan l, List<Transaction> linked, {DateTime? now}) {
  final today = todayKey(now);
  final closed = l.isCompleted || l.closedAt != null;
  final s = l.schedule;
  final next = closed || s == null ? null : nextDate(s, fromKey: today);
  final a = loanAmortization(l);
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
  return LoanStatus(
    outstanding: closed ? 0 : a.balanceOn(paidThrough, eventsThrough: today),
    emisPaid: paid + (running ? l.emisPaidBefore : 0),
    totalEmis: a.rows.length + (running ? l.emisPaidBefore : 0),
    nextDay: row == null ? null : next,
    nextAmount: row?.payment,
    nextRow: row,
    interestPaid: interest + (running ? l.interestPaidBefore : 0),
    principalPaid: principal + (running ? l.principalPaidBefore : 0),
    totalInterest: a.totalInterest + (running ? l.interestPaidBefore : 0),
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
    Loan l, int day, int decimals) {
  final a = loanAmortization(l);
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
