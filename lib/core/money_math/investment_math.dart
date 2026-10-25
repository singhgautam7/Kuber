// Shared investment math: fixed-return accrual and maturity (through the
// calculators' FD / RD / PPF engines), XIRR, gains, proportional withdrawals
// and step-up SIPs. Pure Dart, no Flutter.

import 'dart:math';

import '../../features/tools/engine/fd_rd_engine.dart';
import '../../features/tools/engine/ppf_engine.dart';

// ── Fixed return ────────────────────────────────────────────────────────

/// FD maturity for a tenure in months. Whole years go through the FD
/// calculator's engine, so the feature and the calculator agree exactly.
double fdMaturity(double principal, double rate, int months,
    CompoundingFrequency freq) {
  if (months % 12 == 0) return computeFd(principal, rate, months ~/ 12, freq).maturity;
  final f = freq.perYear;
  return principal * pow(1 + rate / 100 / f, f * months / 12);
}

/// RD maturity: [installment] at the start of each month, compounded monthly
/// (the RD calculator's model). Whole years use its engine.
double rdMaturity(double installment, double rate, int months) {
  if (months % 12 == 0) return computeRd(installment, rate, months ~/ 12).maturity;
  final r = rate / 100 / 12;
  var bal = 0.0;
  for (var m = 0; m < months; m++) {
    bal = (bal + installment) * (1 + r);
  }
  return bal;
}

/// PPF maturity for [years] (15 + extensions) through the PPF engine.
double ppfMaturity(double yearlyDeposit, double rate, int years) =>
    computePpf(yearlyDeposit, years, ratePercent: rate).maturity;

/// Years between two dates as the design's accrual uses them (days / 365.25).
double yearsBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays /
    365.25;

/// FD value on [at], including interest earned but not yet paid: compounding
/// carried to the day. Cumulative only; payout FDs stay at the principal.
/// Capped at maturity.
double fdValueOn({
  required double principal,
  required double rate,
  required CompoundingFrequency freq,
  required DateTime start,
  required int tenureMonths,
  required DateTime at,
  bool cumulative = true,
}) {
  if (!cumulative) return principal;
  if (at.isBefore(start)) return principal;
  final maturityDate = DateTime(start.year, start.month + tenureMonths, start.day);
  if (!at.isBefore(maturityDate)) {
    return fdMaturity(principal, rate, tenureMonths, freq);
  }
  final f = freq.perYear;
  return principal * pow(1 + rate / 100 / f, f * yearsBetween(start, at));
}

/// RD value on [at]: installments made so far, compounded monthly to [at].
double rdValueOn({
  required double installment,
  required double rate,
  required DateTime start,
  required int tenureMonths,
  required DateTime at,
}) {
  if (at.isBefore(start)) return 0;
  var months = (at.year - start.year) * 12 + at.month - start.month;
  if (at.day >= start.day) months++;
  months = months.clamp(0, tenureMonths);
  if (months >= tenureMonths) return rdMaturity(installment, rate, tenureMonths);
  return rdMaturity(installment, rate, months);
}

/// Interest paid out each period for a payout FD.
double fdPayoutAmount(double principal, double rate, int periodsPerYear) =>
    principal * rate / 100 / periodsPerYear;

/// Premature FD withdrawal: interest at (rate − penalty) for the time held.
({double rateAfterPenalty, double received, double interestEarned})
    fdPrematureWithdrawal({
  required double principal,
  required double rate,
  required double penaltyRate,
  required CompoundingFrequency freq,
  required DateTime start,
  required DateTime at,
}) {
  final r = max(0.0, rate - penaltyRate);
  final f = freq.perYear;
  final value = principal * pow(1 + r / 100 / f, f * yearsBetween(start, at));
  return (rateAfterPenalty: r, received: value, interestEarned: value - principal);
}

// ── Gains and withdrawals ───────────────────────────────────────────────

double absoluteGain(double value, double invested) => value - invested;

double percentGain(double value, double invested) =>
    invested == 0 ? 0 : (value - invested) / invested * 100;

/// Proportional cost basis: invested reduces by invested × (redeemed ÷
/// value); realized gain = amount received − that invested share.
({double investedReduction, double received, double realizedGain})
    proportionalWithdrawal({
  required double invested,
  required double value,
  required double redeemed,
  double charges = 0,
  double? received,
}) {
  final share = value <= 0 ? invested : invested * min(1.0, redeemed / value);
  final got = received ?? (redeemed - charges);
  return (investedReduction: share, received: got, realizedGain: got - share);
}

// ── XIRR ────────────────────────────────────────────────────────────────

class CashFlow {
  final DateTime date;

  /// Negative = money in (invested), positive = money out (withdrawn / value).
  final double amount;
  const CashFlow(this.date, this.amount);
}

/// Annualised return of dated cash flows (Excel XIRR convention: days / 365).
/// Newton from 10%, falling back to bisection on [-99.99%, 10000%].
/// Returns null when the flows don't have both signs or nothing converges.
/// Limits: tolerance 1e-10 on NPV, 100 Newton steps, 300 bisection steps.
double? xirr(List<CashFlow> flows) {
  if (flows.length < 2) return null;
  if (!flows.any((f) => f.amount < 0) || !flows.any((f) => f.amount > 0)) {
    return null;
  }
  final t0 = flows.map((f) => f.date).reduce((a, b) => a.isBefore(b) ? a : b);
  final ts = [
    for (final f in flows)
      DateTime.utc(f.date.year, f.date.month, f.date.day)
              .difference(DateTime.utc(t0.year, t0.month, t0.day))
              .inDays /
          365.0
  ];
  double npv(double r) {
    var s = 0.0;
    for (var i = 0; i < flows.length; i++) {
      s += flows[i].amount / pow(1 + r, ts[i]);
    }
    return s;
  }

  double dnpv(double r) {
    var s = 0.0;
    for (var i = 0; i < flows.length; i++) {
      s -= ts[i] * flows[i].amount / pow(1 + r, ts[i] + 1);
    }
    return s;
  }

  final scale = flows.fold(0.0, (s, f) => s + f.amount.abs());
  final tol = 1e-10 * max(1.0, scale);
  var r = 0.1;
  for (var i = 0; i < 100; i++) {
    final v = npv(r);
    if (v.abs() < tol) return r;
    final d = dnpv(r);
    if (d == 0 || !d.isFinite) break;
    final next = r - v / d;
    if (!next.isFinite || next <= -0.9999) break;
    if ((next - r).abs() < 1e-14) return next;
    r = next;
  }
  var lo = -0.9999, hi = 100.0;
  var flo = npv(lo), fhi = npv(hi);
  if (flo.sign == fhi.sign) return null;
  for (var i = 0; i < 300; i++) {
    final mid = (lo + hi) / 2;
    final fm = npv(mid);
    if (fm.abs() < tol || (hi - lo) < 1e-14) return mid;
    if (fm.sign == flo.sign) {
      lo = mid;
      flo = fm;
    } else {
      hi = mid;
      fhi = fm;
    }
  }
  return null;
}

// ── Step-up SIP ─────────────────────────────────────────────────────────

/// SIP amount on [on] for a SIP that started on [start] and steps up once a
/// year on its anniversary, by [value] percent or by [value] in currency.
double stepUpAmount({
  required double base,
  required DateTime start,
  required DateTime on,
  required bool percent,
  required double value,
}) {
  if (value <= 0) return base;
  var years = on.year - start.year;
  if (on.month < start.month || (on.month == start.month && on.day < start.day)) {
    years--;
  }
  if (years <= 0) return base;
  return percent ? base * pow(1 + value / 100, years) : base + value * years;
}

/// Year-by-year SIP amounts (year 1 = base), for the step-up notice and "i".
List<double> stepUpSeries(double base, bool percent, double value, int years) => [
      for (var y = 0; y < years; y++)
        value <= 0
            ? base
            : percent
                ? base * pow(1 + value / 100, y)
                : base + value * y
    ];
