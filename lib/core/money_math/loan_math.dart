// Shared loan math for the EMI / prepayment calculators and the Loans
// feature: EMI formulas, the any-3-of-4 solver, amortization with dated
// events, and opening values for loans that started before Kuber.
//
// Pure Dart, no Flutter. Rates are annual percentages; periods are months.
// Full combination table: specs/vnext/loan-solver.md.

import 'dart:math';

enum RateKind { reducing, flat, interestOnlyFirst }

/// EMI = P·r·(1+r)^n / ((1+r)^n − 1), r = monthly rate, n = months.
/// (Moved verbatim from the EMI calculator engine; calculator goldens hold
/// it bit for bit.)
double calculateEmi(double principal, double annualRatePercent, int tenureMonths) {
  if (tenureMonths <= 0) return 0;
  final r = annualRatePercent / 100 / 12;
  if (r == 0) return principal / tenureMonths;
  final factor = pow(1 + r, tenureMonths);
  return principal * r * factor / (factor - 1);
}

/// Flat rate: interest = P × rate × years; EMI = (P + interest) ÷ months.
double flatInterest(double principal, double annualRatePercent, int months) =>
    principal * annualRatePercent / 100 * months / 12;

double flatEmi(double principal, double annualRatePercent, int months) =>
    months <= 0
        ? 0
        : (principal + flatInterest(principal, annualRatePercent, months)) /
            months;

/// One month's interest on [balance].
double monthlyInterest(double balance, double annualRatePercent) =>
    balance * annualRatePercent / 100 / 12;

/// The regular EMI (after any interest-only months).
double regularEmi(RateKind kind, double principal, double rate, int months,
    {int ioMonths = 0}) {
  switch (kind) {
    case RateKind.reducing:
      return calculateEmi(principal, rate, months);
    case RateKind.flat:
      return flatEmi(principal, rate, months);
    case RateKind.interestOnlyFirst:
      return calculateEmi(principal, rate, max(1, months - ioMonths));
  }
}

// ── Solver ──────────────────────────────────────────────────────────────

enum LoanField { principal, rate, tenure, emi }

enum LoanError {
  /// Fewer than three of principal / rate (or total payable) / tenure / EMI.
  missingInputs,
  invalidPrincipal,
  invalidTenure,
  invalidRate,

  /// EMI at or below the first month's interest: the loan never ends.
  emiTooLow,

  /// EMI × months (or the total payable) is below the principal.
  totalTooLow,
  noConvergence,
}

class LoanSolution {
  final double principal;
  final double rate;
  final int months;

  /// The EMI payments use (the user's EMI when all four were entered).
  final double emi;

  /// Interest-only monthly amount (interest-only-first loans).
  final double ioEmi;

  final LoanField? calculated;

  /// When all four numbers were entered: the EMI the rate implies, and
  /// user EMI − calculated EMI (rounded mismatch shown at >= 1 unit).
  final double? calculatedEmi;
  final double mismatch;

  final LoanError? error;

  /// First month's interest, for the "EMI doesn't cover the interest" text.
  final double firstMonthInterest;

  const LoanSolution({
    this.principal = 0,
    this.rate = 0,
    this.months = 0,
    this.emi = 0,
    this.ioEmi = 0,
    this.calculated,
    this.calculatedEmi,
    this.mismatch = 0,
    this.error,
    this.firstMonthInterest = 0,
  });

  bool get ok => error == null;
}

/// Convergence limits for the numeric rate solve: bisection on the monthly
/// rate in [0, 100% / 12], stopping when the EMI (or total) is within
/// [_solveTolerance] relative, or after [_solveMaxIterations].
const _solveMaxIterations = 200;
const _solveTolerance = 1e-12;
const _maxAnnualRate = 1200.0; // 100% a month, far above any real loan

/// Any 3 of principal / rate / tenure / EMI give the 4th. [totalPayable] can
/// stand in for the rate. Exactly one of the four may be null; when none is
/// null the result carries the mismatch (the user's EMI pays, the rate
/// splits). [ioMonths] applies to [RateKind.interestOnlyFirst].
LoanSolution solveLoan({
  double? principal,
  double? rate,
  int? months,
  double? emi,
  double? totalPayable,
  RateKind kind = RateKind.reducing,
  int ioMonths = 0,
}) {
  final io = kind == RateKind.interestOnlyFirst ? max(0, ioMonths) : 0;
  if (rate == null && totalPayable != null && principal != null && months != null) {
    final r = _rateFromTotal(principal, months, totalPayable, kind, io);
    if (r == null) {
      return const LoanSolution(error: LoanError.totalTooLow);
    }
    rate = r;
    if (emi == null) {
      final s = solveLoan(
          principal: principal, rate: r, months: months, kind: kind, ioMonths: io);
      return LoanSolution(
          principal: s.principal,
          rate: s.rate,
          months: s.months,
          emi: s.emi,
          ioEmi: s.ioEmi,
          calculated: LoanField.rate,
          error: s.error,
          firstMonthInterest: s.firstMonthInterest);
    }
  }
  final unknown = [
    if (principal == null) LoanField.principal,
    if (rate == null) LoanField.rate,
    if (months == null) LoanField.tenure,
    if (emi == null) LoanField.emi,
  ];
  if (unknown.length > 1) return const LoanSolution(error: LoanError.missingInputs);
  if (principal != null && principal <= 0) {
    return const LoanSolution(error: LoanError.invalidPrincipal);
  }
  if (months != null && (months < 1 || months <= io)) {
    return const LoanSolution(error: LoanError.invalidTenure);
  }
  if (rate != null && (rate < 0 || rate > _maxAnnualRate)) {
    return const LoanSolution(error: LoanError.invalidRate);
  }
  if (emi != null && emi <= 0) {
    return const LoanSolution(error: LoanError.emiTooLow);
  }

  final field = unknown.isEmpty ? null : unknown.first;
  switch (field) {
    case LoanField.emi:
      return _finish(principal!, rate!, months!, null, kind, io, LoanField.emi);
    case LoanField.principal:
      final p = _principalFor(rate!, months!, emi!, kind, io);
      return _finish(p, rate, months, emi, kind, io, LoanField.principal);
    case LoanField.tenure:
      final p = principal!, r = rate!, e = emi!;
      final firstInterest = monthlyInterest(p, r);
      final n = _tenureFor(p, r, e, kind, io);
      if (n == null) {
        return LoanSolution(
            principal: p,
            rate: r,
            emi: e,
            calculated: LoanField.tenure,
            error: LoanError.emiTooLow,
            firstMonthInterest: firstInterest);
      }
      return _finish(p, r, n, e, kind, io, LoanField.tenure);
    case LoanField.rate:
      final p = principal!, n = months!, e = emi!;
      final r = _rateFor(p, n, e, kind, io);
      if (r == null) {
        return LoanSolution(
            principal: p,
            months: n,
            emi: e,
            calculated: LoanField.rate,
            error: (e * (n - io)) < p ? LoanError.totalTooLow : LoanError.noConvergence);
      }
      return _finish(p, r, n, e, kind, io, LoanField.rate);
    case null:
      // All four entered: the rate implies an EMI; the user's EMI is truth.
      final calc = regularEmi(kind, principal!, rate!, months!, ioMonths: io);
      final s = _finish(principal, rate, months, emi, kind, io, null);
      return LoanSolution(
          principal: s.principal,
          rate: s.rate,
          months: s.months,
          emi: s.emi,
          ioEmi: s.ioEmi,
          calculatedEmi: calc,
          mismatch: emi! - calc,
          error: s.error,
          firstMonthInterest: s.firstMonthInterest);
  }
}

LoanSolution _finish(double p, double r, int n, double? userEmi, RateKind kind,
    int io, LoanField? calculated) {
  final calc = regularEmi(kind, p, r, n, ioMonths: io);
  final e = userEmi ?? calc;
  final first = monthlyInterest(p, r);
  final ioEmi = kind == RateKind.interestOnlyFirst ? first : 0.0;
  final never = e <= first && r > 0;
  return LoanSolution(
    principal: p,
    rate: r,
    months: n,
    emi: e,
    ioEmi: ioEmi,
    calculated: calculated,
    error: never ? LoanError.emiTooLow : null,
    firstMonthInterest: first,
  );
}

double _principalFor(double rate, int months, double emi, RateKind kind, int io) {
  final r = rate / 100 / 12;
  switch (kind) {
    case RateKind.flat:
      return emi * months / (1 + rate / 100 * months / 12);
    case RateKind.reducing:
    case RateKind.interestOnlyFirst:
      final n = months - io;
      if (r == 0) return emi * n;
      final f = pow(1 + r, n);
      return emi * (f - 1) / (r * f);
  }
}

int? _tenureFor(double p, double rate, double emi, RateKind kind, int io) {
  final r = rate / 100 / 12;
  switch (kind) {
    case RateKind.flat:
      final principalPart = emi - p * r;
      if (principalPart <= 0) return null;
      return (p / principalPart - 1e-9).ceil();
    case RateKind.reducing:
    case RateKind.interestOnlyFirst:
      if (r == 0) return io + (p / emi - 1e-9).ceil();
      if (emi <= p * r) return null;
      final n = -log(1 - p * r / emi) / log(1 + r);
      return io + (n - 1e-9).ceil();
  }
}

/// Monthly-rate bisection. Returns the annual rate, or null when no
/// non-negative rate fits.
double? _bisectAnnual(double Function(double annual) f, double target) {
  // f is increasing in the rate.
  if (f(0) > target * (1 + _solveTolerance)) return null;
  if ((f(0) - target).abs() <= target * _solveTolerance) return 0;
  var lo = 0.0, hi = _maxAnnualRate;
  if (f(hi) < target) return null;
  for (var i = 0; i < _solveMaxIterations; i++) {
    final mid = (lo + hi) / 2;
    final v = f(mid);
    if ((v - target).abs() <= target * _solveTolerance || hi - lo < 1e-13) {
      return mid;
    }
    if (v < target) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return null;
}

double? _rateFor(double p, int n, double emi, RateKind kind, int io) {
  switch (kind) {
    case RateKind.flat:
      final interest = emi * n - p;
      if (interest < -1e-9) return null;
      return max(0, interest) / p / (n / 12) * 100;
    case RateKind.reducing:
    case RateKind.interestOnlyFirst:
      return _bisectAnnual((a) => calculateEmi(p, a, n - io), emi);
  }
}

double? _rateFromTotal(double p, int n, double total, RateKind kind, int io) {
  switch (kind) {
    case RateKind.flat:
      if (total < p - 1e-9) return null;
      return max(0, total - p) / p / (n / 12) * 100;
    case RateKind.reducing:
      return _bisectAnnual((a) => calculateEmi(p, a, n) * n, total);
    case RateKind.interestOnlyFirst:
      return _bisectAnnual(
          (a) => io * monthlyInterest(p, a) + calculateEmi(p, a, n - io) * (n - io),
          total);
  }
}

// ── Amortization ────────────────────────────────────────────────────────

enum AmortEventKind { rateChange, prepayment, charge, adjustment, release, chargeAdded }

class AmortEvent {
  final int day; // yyyymmdd
  final AmortEventKind kind;
  final double amount; // prepayment principal / charge / signed adjustment
  final double? newRate;

  /// Prepayment, rate change and adjustment: true = keep the end date,
  /// change the EMI; false = keep the EMI, change the tenure.
  final bool adjustEmi;

  /// Adjustment: unpaid interest the bank added to the loan. It raises the
  /// outstanding and counts toward total interest.
  final bool interestAdded;

  /// Applies after an EMI on the same day ("outstanding on this date" is the
  /// balance after that day's EMI). Update outstanding uses this; every other
  /// event applies before the EMI on its day, as before.
  final bool afterEmi;

  const AmortEvent(this.day, this.kind,
      {this.amount = 0,
      this.newRate,
      this.adjustEmi = false,
      this.interestAdded = false,
      this.afterEmi = false});
}

/// How a recorded EMI transaction takes part in the amortization.
enum RecordedUse {
  /// Its split is used when the user edited it or it differs from the
  /// calculation; equal to the rounded calculation it is the calculation.
  auto,

  /// Its amount is kept; the month's interest is calculated again from the
  /// outstanding and principal takes the rest (recalculate past splits).
  recalculate,
}

/// An EMI the user actually paid (a linked transaction), by schedule day.
class RecordedEmi {
  final double payment;
  final double principal;
  final double interest;
  final bool edited;
  final RecordedUse use;

  const RecordedEmi(this.payment, this.principal, this.interest,
      {this.edited = false, this.use = RecordedUse.auto});
}

class AmortRow {
  final int index; // 1-based EMI number
  final int day; // yyyymmdd
  final double payment;
  final double principal;
  final double interest;
  final double balance; // after this EMI
  final double rate;
  final bool interestOnly;

  /// Taken from a recorded transaction (its own split, not calculated).
  final bool recorded;

  /// The user changed this EMI's split.
  final bool edited;

  const AmortRow({
    required this.index,
    required this.day,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
    required this.rate,
    required this.interestOnly,
    this.recorded = false,
    this.edited = false,
  });

  /// A schedule marker with no EMI (events before the first EMI).
  const AmortRow.marker(this.day)
      : index = 0,
        payment = 0,
        principal = 0,
        interest = 0,
        balance = 0,
        rate = 0,
        interestOnly = false,
        recorded = false,
        edited = false;

  /// A pre-EMI interest cycle, for the schedule's year view and charts.
  AmortRow.cycle(PreEmiCycle c)
      : index = 0,
        day = c.day,
        payment = 0,
        principal = 0,
        interest = c.interest,
        balance = c.balance,
        rate = c.rate,
        interestOnly = true,
        recorded = false,
        edited = false;
}

class Amortization {
  final List<AmortRow> rows;
  final List<AmortEvent> events;
  final double openingBalance;

  /// Before the first EMI, for loans released in parts or with pre-EMI
  /// interest. Its events are not in [events].
  final PreEmi? preEmi;

  const Amortization(this.rows, this.events, this.openingBalance, {this.preEmi});

  double get totalInterest => rows.fold(0.0, (s, r) => s + r.interest);

  /// [totalInterest] plus the pre-EMI interest paid or added.
  double get allInterest =>
      totalInterest + (preEmi?.paidInterest ?? 0) + (preEmi?.addedInterest ?? 0);

  /// Unpaid interest the bank added to the loan (adjustments, pre-EMI).
  double get addedInterest =>
      events
          .where((e) => e.kind == AmortEventKind.adjustment && e.interestAdded)
          .fold(0.0, (s, e) => s + e.amount) +
      (preEmi?.addedInterest ?? 0);

  /// Charges the bank added to the loan (no money left any account).
  double get addedCharges =>
      events
          .where((e) => e.kind == AmortEventKind.chargeAdded)
          .fold(0.0, (s, e) => s + e.amount) +
      (preEmi?.addedCharges ?? 0);
  double get totalPaid => rows.fold(0.0, (s, r) => s + r.payment);

  /// Balance after every EMI and event on or before [day]. [eventsThrough]
  /// also applies later events (up to that day) without later EMIs: today's
  /// extra payment counts before today's EMI is recorded.
  double balanceOn(int day, {int? eventsThrough}) {
    final pre = preEmi;
    final upToDay = eventsThrough ?? day;
    if (pre != null && upToDay < pre.firstEmiDay) return pre.balanceOn(upToDay);
    var bal = openingBalance;
    for (final r in rows) {
      if (r.day > day) break;
      bal = r.balance;
    }
    // Events after the last EMI on or before [day] but not after [day].
    final lastEmiDay = rows.where((r) => r.day <= day).lastOrNull?.day ?? 0;
    final upTo = eventsThrough ?? day;
    for (final e in events) {
      if ((e.day > lastEmiDay || (e.afterEmi && e.day == lastEmiDay)) && e.day <= upTo) {
        if (e.kind == AmortEventKind.prepayment) bal = max(0, bal - e.amount);
        if (e.kind == AmortEventKind.adjustment ||
            e.kind == AmortEventKind.release ||
            e.kind == AmortEventKind.chargeAdded) {
          bal = max(0, bal + e.amount);
        }
      }
    }
    return bal;
  }

  AmortRow? rowOn(int day) => rows.where((r) => r.day == day).firstOrNull;
}

/// Amortizes month by month over [emiDays] (the schedule's payment dates,
/// ascending; extra dates let a loan run longer after a rate rise). Events
/// apply in date order before the first EMI on or after their date:
/// a prepayment reduces the balance (then tenure or EMI), a rate change sets
/// the rate (then EMI or tenure), a charge changes nothing, an adjustment
/// shifts the balance (opening override, Update outstanding).
///
/// [emi] is the payment the user makes in the regular phase (their EMI is
/// the truth when it differs from the rate's); null = the rate's EMI.
///
/// [recorded]: EMIs actually paid, by day. Their split is the truth (see
/// [RecordedUse]); only the future is projected, from the outstanding after
/// them. [unpaid]: recorded EMIs the user deleted; nothing is paid that
/// month, so their principal stays owed. [decimals]: the currency's minor
/// units, to tell a recorded split from the rounded calculation.
///
/// [dailyInterest] (reducing loans only): each EMI's interest is the days
/// since the last EMI at rate / 365 on that day's balance, rounded to the
/// rupee, the way most Indian banks charge it. The EMI itself stays the monthly formula; only
/// the split moves. Off: rate / 12 every month, as before.
Amortization amortize({
  required double principal,
  required double rate,
  required int months,
  required List<int> emiDays,
  RateKind kind = RateKind.reducing,
  int ioMonths = 0,
  double? emi,
  List<AmortEvent> events = const [],
  double? flatBase,
  Map<int, RecordedEmi> recorded = const {},
  Set<int> unpaid = const {},
  int decimals = 2,
  bool dailyInterest = false,
}) {
  final rows = <AmortRow>[];

  // By day; on the same day, after-EMI events last.
  final sorted = [...events]
    ..sort((a, b) => a.day != b.day
        ? a.day.compareTo(b.day)
        : (a.afterEmi ? 1 : 0).compareTo(b.afterEmi ? 1 : 0));
  final io = kind == RateKind.interestOnlyFirst ? ioMonths : 0;
  var bal = principal;
  var r = rate;
  final planEmi = regularEmi(kind, principal, rate, months, ioMonths: io);
  var pay = emi ?? planEmi;
  // The user's EMI is the plan's EMI rounded to the rupee (as banks quote
  // it): the last planned EMI takes the residue, so the tenure stays. Any
  // prepayment, adjustment or rate change ends this.
  var bankRounded = emi != null && (emi - planEmi).abs() <= 1;
  // Flat: interest stays on the original principal; principal part fixed.
  var base = flatBase ?? principal;
  var flatPrincipalPart = months > 0 ? principal / months : principal;
  var ev = 0;
  final daily = dailyInterest && kind == RateKind.reducing;
  // Daily: interest owed since [accFrom], banked as the balance or rate
  // changes between EMIs. The first period starts a month before EMI 1.
  var accFrom = emiDays.isEmpty ? 0 : monthBefore(emiDays.first);
  var accFromN = _dayNumber(accFrom); // kept: one day count per period
  var accrued = 0.0;
  void accrue(int to) {
    if (!daily || to <= accFrom) return;
    final toN = _dayNumber(to);
    accrued += bal * r / 100 / 365 * (toN - accFromN);
    accFrom = to;
    accFromN = toN;
  }
  // EMIs still to pay at the current payment and rate (reducing loans past
  // any interest-only months); else the original plan's remainder.
  int keepEnd(int i, int remaining) {
    final int planned = max(1, remaining - max(0, io - i)).toInt();
    if (kind == RateKind.flat || i < io || bal <= 0) return planned;
    return emisLeftFor(bal, r, pay) ?? planned;
  }

  void apply(AmortEvent e, int i, int remaining) {
    if (e.kind != AmortEventKind.charge) accrue(e.day);
    switch (e.kind) {
      case AmortEventKind.charge:
        break;
      case AmortEventKind.adjustment:
      case AmortEventKind.release:
      case AmortEventKind.chargeAdded:
        bankRounded = false;
        final left = keepEnd(i, remaining);
        bal = max(0, bal + e.amount);
        // A later release is more principal, so flat interest follows it.
        if (e.kind == AmortEventKind.release) base += e.amount;
        if (e.adjustEmi && bal > 0) {
          if (kind == RateKind.flat) {
            flatPrincipalPart = bal / remaining;
            pay = flatPrincipalPart + monthlyInterest(base, r);
          } else {
            pay = calculateEmi(bal, r, left);
          }
        }
      case AmortEventKind.prepayment:
        bankRounded = false;
        // "Adjust EMI" keeps the current end date: the EMIs left at the
        // current payment (an earlier reduce-tenure prepayment moved it).
        final left = keepEnd(i, remaining);
        bal = max(0, bal - e.amount);
        if (e.adjustEmi && bal > 0) {
          if (kind == RateKind.flat) {
            flatPrincipalPart = bal / remaining;
            pay = flatPrincipalPart + monthlyInterest(base, r);
          } else {
            pay = calculateEmi(bal, r, left);
          }
        }
      case AmortEventKind.rateChange:
        bankRounded = false;
        final left = keepEnd(i, remaining);
        r = e.newRate ?? r;
        if (kind == RateKind.flat) {
          pay = flatPrincipalPart + monthlyInterest(base, r);
        } else if (e.adjustEmi && bal > 0) {
          pay = calculateEmi(bal, r, left);
        }
    }
  }

  for (var i = 0; i < emiDays.length && bal > 1e-6; i++) {
    final day = emiDays[i];
    final remaining = max(1, months - i);
    while (ev < sorted.length &&
        (sorted[ev].day < day || (sorted[ev].day == day && !sorted[ev].afterEmi))) {
      apply(sorted[ev++], i, remaining);
    }
    if (bal <= 1e-6) break;
    if (unpaid.contains(day)) {
      // Deleted by the user: no payment this month (and, as with monthly
      // interest, none charged for it).
      bankRounded = false;
      accrued = 0;
      accFrom = day;
      accFromN = _dayNumber(day);
      while (ev < sorted.length && sorted[ev].day <= day) {
        apply(sorted[ev++], i + 1, max(1, months - i - 1));
      }
      continue;
    }
    final isIo = i < io;
    double interest, princ;
    if (kind == RateKind.flat) {
      interest = r == 0 ? 0 : monthlyInterest(base, r);
      princ = emi != null ? max(0, pay - interest) : flatPrincipalPart;
    } else if (daily) {
      accrue(day);
      // Rounded to the rupee per period, as banks charge it (and as the
      // pre-EMI cycles are).
      interest = accrued.roundToDouble();
      accrued = 0;
      princ = pay - interest;
    } else {
      interest = monthlyInterest(bal, r);
      princ = isIo ? 0 : pay - interest;
    }
    if (princ < 0) princ = 0;
    // Final EMI: whatever is left. A residue under 1% of the EMI also goes
    // into this payment, instead of a tiny extra one.
    if (princ > bal ||
        bal - princ < max(0.005, pay * 0.01) ||
        (bankRounded && i == months - 1)) {
      princ = bal;
    }
    var payment = princ + interest;
    var fromRecord = false, edited = false;
    final rec = recorded[day];
    if (rec != null) {
      edited = rec.edited;
      if (rec.use == RecordedUse.recalculate && !rec.edited) {
        // The amount paid stays; this month's interest on what is owed now.
        interest = min(rec.payment, interest);
        princ = min(bal, rec.payment - interest);
        payment = rec.payment;
        fromRecord = true;
      } else {
        final calc = roundedSplit(payment, interest, decimals);
        final same = !rec.edited &&
            (calc.principal - rec.principal).abs() < 1e-9 &&
            (calc.interest - rec.interest).abs() < 1e-9;
        if (!same) {
          princ = min(bal, rec.principal);
          interest = rec.interest;
          payment = rec.payment;
          fromRecord = true;
        }
      }
      if (fromRecord) bankRounded = false;
    }
    bal -= princ;
    rows.add(AmortRow(
      index: i + 1,
      day: day,
      payment: payment,
      principal: princ,
      interest: interest,
      balance: bal,
      rate: r,
      interestOnly: isIo,
      recorded: fromRecord,
      edited: edited,
    ));
    // After-EMI events on this day (Update outstanding).
    while (ev < sorted.length && sorted[ev].day <= day) {
      apply(sorted[ev++], i + 1, max(1, months - i - 1));
    }
    // A loan that can't amortize (EMI <= interest) stops at the date list.
  }
  return Amortization(rows, sorted, principal);
}

// ── Before the first EMI ────────────────────────────────────────────────

enum PreEmiInterest { none, paid, added }

/// One pre-EMI interest cycle: charged on [day], for [from] to the day before.
class PreEmiCycle {
  final int from;
  final int day;
  final double interest;

  /// Outstanding after the charge.
  final double balance;
  final double rate;
  const PreEmiCycle(this.from, this.day, this.interest, this.balance, this.rate);
}

/// The loan from its first release to its first EMI.
class PreEmi {
  final int firstEmiDay;
  final PreEmiInterest mode;
  final List<PreEmiCycle> cycles;

  /// Outstanding the EMIs start on (the user's figure included).
  final double balance;

  /// Rate on the first EMI date (a rate change can fall before it).
  final double rate;

  /// Released before the first EMI.
  final double released;

  /// What the period added to [released] by Kuber's own count: interest added
  /// + charges added - payments.
  final double calculatedAdded;

  /// The user's figure minus [calculatedAdded]; applied on the first EMI date.
  final double overrideDelta;

  final double paidInterest;
  final double addedInterest;
  final double addedCharges;

  /// (day, balance from that day), ascending.
  final List<(int, double)> _steps;

  const PreEmi({
    required this.firstEmiDay,
    required this.mode,
    required this.cycles,
    required this.balance,
    required this.rate,
    required this.released,
    required this.calculatedAdded,
    required this.overrideDelta,
    required this.paidInterest,
    required this.addedInterest,
    required this.addedCharges,
    required List<(int, double)> steps,
  }) : _steps = steps;

  double balanceOn(int day) {
    var bal = 0.0;
    for (final (d, b) in _steps) {
      if (d > day) break;
      bal = b;
    }
    return bal;
  }
}

/// Month after [day], on its day of month (clamped to short months).
int _nextMonthOn(int day, int anchor) {
  final int y = day ~/ 10000, m = day ~/ 100 % 100;
  final int ny = m == 12 ? y + 1 : y, nm = m == 12 ? 1 : m + 1;
  final last = DateTime.utc(ny, nm + 1, 0).day;
  return ny * 10000 + nm * 100 + min<int>(anchor, last);
}

/// The same day a month earlier (clamped: 31 Mar -> 28 or 29 Feb).
int monthBefore(int day) {
  final y = day ~/ 10000, m = day ~/ 100 % 100, d = day % 100;
  final py = m == 1 ? y - 1 : y, pm = m == 1 ? 12 : m - 1;
  final last = DateTime.utc(py, pm + 1, 0).day;
  return py * 10000 + pm * 100 + min(d, last);
}

int _gapDays(int a, int b) => _dayNumber(b) - _dayNumber(a);

/// Days since 1 Mar 0000 for a yyyymmdd key (civil calendar, integer maths:
/// no DateTime per call, as daily interest asks for it every EMI).
int _dayNumber(int ymd) {
  var y = ymd ~/ 10000;
  final m = ymd ~/ 100 % 100, d = ymd % 100;
  if (m <= 2) y -= 1;
  final era = y ~/ 400, yoe = y - era * 400;
  final doy = (153 * (m > 2 ? m - 3 : m + 9) + 2) ~/ 5 + d - 1;
  return era * 146097 + yoe * 365 + yoe ~/ 4 - yoe ~/ 100 + doy;
}

/// Dates pre-EMI interest is charged on: every [cycleDay] after [firstRelease]
/// whose following month still ends on or before the first EMI (that last
/// stretch of interest is in the first EMI itself).
List<int> preEmiCycleDays(int firstRelease, int firstEmiDay, int cycleDay) {
  final out = <int>[];
  final int y = firstRelease ~/ 10000, m = firstRelease ~/ 100 % 100;
  final last = DateTime.utc(y, m + 1, 0).day;
  int c = y * 10000 + m * 100 + min<int>(cycleDay, last);
  if (c <= firstRelease) c = _nextMonthOn(c, cycleDay);
  while (_nextMonthOn(c, cycleDay) <= firstEmiDay) {
    out.add(c);
    c = _nextMonthOn(c, cycleDay);
  }
  return out;
}

/// Walks the loan from its first release to the first EMI. Interest builds
/// daily on that day's outstanding at rate / 365; each cycle's sum is rounded
/// to the rupee and charged on the cycle date, then [PreEmiInterest.added]
/// earns interest from that date. An event counts from its own date.
/// [releases]: (day, amount), on or before [firstEmiDay]. [events]: those
/// before the first EMI. [override]: the user's total added to the released
/// amount, applied on the first EMI date.
PreEmi preEmiLedger({
  required double rate,
  required PreEmiInterest mode,
  required int cycleDay,
  required int firstEmiDay,
  required List<(int, double)> releases,
  List<AmortEvent> events = const [],
  double? override,
}) {
  final changes = <(int, double, AmortEvent?)>[
    for (final r in releases) (r.$1, r.$2, null),
    for (final e in events) (e.day, 0.0, e),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  final firstDay = changes.isEmpty ? firstEmiDay : changes.first.$1;
  final due = mode == PreEmiInterest.none
      ? const <int>[]
      : preEmiCycleDays(releases.isEmpty ? firstDay : releases.first.$1, firstEmiDay, cycleDay);
  final steps = <(int, double)>[];
  final cycles = <PreEmiCycle>[];
  var bal = 0.0, r = rate, accrued = 0.0;
  var released = 0.0, addedCharges = 0.0, addedAdj = 0.0, paid = 0.0, addedCycles = 0.0;
  var last = firstDay, from = firstDay;
  void accrue(int to) {
    if (to > last) accrued += bal * r / 100 / 365 * _gapDays(last, to);
    last = to;
  }

  var ci = 0;
  for (final c in changes) {
    while (ci < due.length && due[ci] <= c.$1) {
      accrue(due[ci]);
      final charged = accrued.roundToDouble();
      accrued = 0;
      if (mode == PreEmiInterest.added) {
        bal += charged;
        addedCycles += charged;
        steps.add((due[ci], bal));
      } else {
        paid += charged;
      }
      cycles.add(PreEmiCycle(from, due[ci], charged, bal, r));
      from = due[ci];
      ci++;
    }
    accrue(c.$1);
    final e = c.$3;
    if (e == null) {
      bal += c.$2;
      released += c.$2;
    } else {
      switch (e.kind) {
        case AmortEventKind.prepayment:
          bal = max(0, bal - e.amount);
        case AmortEventKind.chargeAdded:
          bal += e.amount;
          addedCharges += e.amount;
        case AmortEventKind.adjustment:
          bal = max(0, bal + e.amount);
          if (e.interestAdded) addedAdj += e.amount;
        case AmortEventKind.rateChange:
          r = e.newRate ?? r;
        case AmortEventKind.release:
        case AmortEventKind.charge:
          break;
      }
    }
    steps.add((c.$1, bal));
  }
  while (ci < due.length) {
    accrue(due[ci]);
    final charged = accrued.roundToDouble();
    accrued = 0;
    if (mode == PreEmiInterest.added) {
      bal += charged;
      addedCycles += charged;
      steps.add((due[ci], bal));
    } else {
      paid += charged;
    }
    cycles.add(PreEmiCycle(from, due[ci], charged, bal, r));
    from = due[ci];
    ci++;
  }
  final calculated = bal - released;
  final delta = override == null ? 0.0 : override - calculated;
  return PreEmi(
    firstEmiDay: firstEmiDay,
    mode: mode,
    cycles: cycles,
    balance: bal + delta,
    rate: r,
    released: released,
    calculatedAdded: calculated,
    overrideDelta: delta,
    paidInterest: paid,
    addedInterest: addedCycles + addedAdj + delta,
    addedCharges: addedCharges,
    steps: steps,
  );
}

// ── Opening values ──────────────────────────────────────────────────────

class OpeningValues {
  final int emisPaid;
  final double principalPaid;
  final double interestPaid;
  final double outstanding;
  const OpeningValues(
      this.emisPaid, this.principalPaid, this.interestPaid, this.outstanding);
}

/// "I know the original loan details": what was paid before [trackingDay].
OpeningValues openingFromOriginal(Amortization a, int trackingDay) {
  var n = 0;
  var p = 0.0, i = 0.0;
  for (final r in a.rows) {
    if (r.day >= trackingDay) break;
    n++;
    p += r.principal;
    i += r.interest;
  }
  return OpeningValues(n, p, i, a.balanceOn(trackingDay - 1));
}

/// "I know what's outstanding today": EMIs left at the EMI and rate.
int? emisLeftFor(double outstanding, double rate, double emi,
    {RateKind kind = RateKind.reducing}) {
  if (outstanding <= 0) return 0;
  final s = solveLoan(principal: outstanding, rate: rate, emi: emi, kind: kind);
  return s.ok ? s.months : null;
}

/// The adjustment when the user overrides the calculated outstanding.
double outstandingAdjustment(double calculated, double entered) =>
    entered - calculated;

/// Splits an EMI into principal and interest rounded to [decimals]; the two
/// parts always add up to the rounded payment exactly.
({double principal, double interest, double payment}) roundedSplit(
    double payment, double interest, int decimals) {
  final f = pow(10, decimals).toDouble();
  final pay = (payment * f).round() / f;
  final i = min(pay, (interest * f).round() / f);
  final p = ((pay * f).round() - (i * f).round()) / f;
  return (principal: p, interest: i, payment: pay);
}
