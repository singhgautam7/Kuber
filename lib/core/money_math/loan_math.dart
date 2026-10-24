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

enum AmortEventKind { rateChange, prepayment, charge, adjustment }

class AmortEvent {
  final int day; // yyyymmdd
  final AmortEventKind kind;
  final double amount; // prepayment principal / charge / signed adjustment
  final double? newRate;

  /// Prepayment and rate change: true = keep the end date, change the EMI;
  /// false = keep the EMI, change the tenure.
  final bool adjustEmi;

  const AmortEvent(this.day, this.kind,
      {this.amount = 0, this.newRate, this.adjustEmi = false});
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

  const AmortRow({
    required this.index,
    required this.day,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
    required this.rate,
    required this.interestOnly,
  });
}

class Amortization {
  final List<AmortRow> rows;
  final List<AmortEvent> events;
  final double openingBalance;

  const Amortization(this.rows, this.events, this.openingBalance);

  double get totalInterest => rows.fold(0.0, (s, r) => s + r.interest);
  double get totalPaid => rows.fold(0.0, (s, r) => s + r.payment);

  /// Balance after every EMI and event on or before [day]. [eventsThrough]
  /// also applies later events (up to that day) without later EMIs: today's
  /// extra payment counts before today's EMI is recorded.
  double balanceOn(int day, {int? eventsThrough}) {
    var bal = openingBalance;
    for (final r in rows) {
      if (r.day > day) break;
      bal = r.balance;
    }
    // Events after the last EMI on or before [day] but not after [day].
    final lastEmiDay = rows.where((r) => r.day <= day).lastOrNull?.day ?? 0;
    final upTo = eventsThrough ?? day;
    for (final e in events) {
      if (e.day > lastEmiDay && e.day <= upTo) {
        if (e.kind == AmortEventKind.prepayment) bal = max(0, bal - e.amount);
        if (e.kind == AmortEventKind.adjustment) bal = max(0, bal + e.amount);
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
/// shifts the balance (opening override).
///
/// [emi] is the payment the user makes in the regular phase (their EMI is
/// the truth when it differs from the rate's); null = the rate's EMI.
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
}) {
  final rows = <AmortRow>[];
  final sorted = [...events]..sort((a, b) => a.day.compareTo(b.day));
  final io = kind == RateKind.interestOnlyFirst ? ioMonths : 0;
  var bal = principal;
  var r = rate;
  var pay = emi ?? regularEmi(kind, principal, rate, months, ioMonths: io);
  // Flat: interest stays on the original principal; principal part fixed.
  final base = flatBase ?? principal;
  var flatPrincipalPart = months > 0 ? principal / months : principal;
  var ev = 0;
  // EMIs still to pay at the current payment and rate (reducing loans past
  // any interest-only months); else the original plan's remainder.
  int keepEnd(int i, int remaining) {
    final int planned = max(1, remaining - max(0, io - i)).toInt();
    if (kind == RateKind.flat || i < io || bal <= 0) return planned;
    return emisLeftFor(bal, r, pay) ?? planned;
  }

  for (var i = 0; i < emiDays.length && bal > 1e-6; i++) {
    final day = emiDays[i];
    final remaining = max(1, months - i);
    while (ev < sorted.length && sorted[ev].day <= day) {
      final e = sorted[ev++];
      switch (e.kind) {
        case AmortEventKind.charge:
          break;
        case AmortEventKind.adjustment:
          bal = max(0, bal + e.amount);
        case AmortEventKind.prepayment:
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
          final left = keepEnd(i, remaining);
          r = e.newRate ?? r;
          if (kind == RateKind.flat) {
            pay = flatPrincipalPart + monthlyInterest(base, r);
          } else if (e.adjustEmi && bal > 0) {
            pay = calculateEmi(bal, r, left);
          }
      }
    }
    if (bal <= 1e-6) break;
    final isIo = i < io;
    double interest, princ;
    if (kind == RateKind.flat) {
      interest = r == 0 ? 0 : monthlyInterest(base, r);
      princ = emi != null ? max(0, pay - interest) : flatPrincipalPart;
    } else {
      interest = monthlyInterest(bal, r);
      princ = isIo ? 0 : pay - interest;
    }
    if (princ < 0) princ = 0;
    // Final EMI: whatever is left (no dust row).
    if (princ > bal || bal - princ < 0.005) princ = bal;
    bal -= princ;
    rows.add(AmortRow(
      index: i + 1,
      day: day,
      payment: princ + interest,
      principal: princ,
      interest: interest,
      balance: bal,
      rate: r,
      interestOnly: isIo,
    ));
    // A loan that can't amortize (EMI <= interest) stops at the date list.
  }
  return Amortization(rows, sorted, principal);
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
