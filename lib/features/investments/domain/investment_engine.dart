// Investment record -> value, invested, gains, XIRR, maturity. Pure Dart over
// the Isar models, shared by the holding sheets, the list, Ask Kuber, the
// maturity check and Upcoming events.

import '../../../core/money_math/investment_math.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../tools/engine/fd_rd_engine.dart';
import '../../transactions/data/transaction.dart';
import '../data/investment.dart';

/// Asset-class group on the list (design I.1).
enum InvestmentGroup { mutualFunds, stocks, gold, crypto, fixed, other }

InvestmentGroup groupOf(Investment i) => switch (i.investmentType) {
      'mutual_fund' || 'sip' || 'etf' => InvestmentGroup.mutualFunds,
      'stocks' => InvestmentGroup.stocks,
      'gold' => InvestmentGroup.gold,
      'crypto' => InvestmentGroup.crypto,
      'fd' || 'rd' || 'ppf' || 'bonds' => i.behaviour == InvestmentBehaviour.fixedReturn
          ? InvestmentGroup.fixed
          : InvestmentGroup.other,
      _ => InvestmentGroup.other,
    };

InvestmentBehaviour behaviourForType(String type) => switch (type) {
      'sip' || 'mutual_fund' || 'stocks' || 'etf' || 'gold' || 'crypto' =>
        InvestmentBehaviour.market,
      'fd' || 'rd' || 'ppf' || 'bonds' => InvestmentBehaviour.fixedReturn,
      _ => InvestmentBehaviour.other,
    };

bool isRd(Investment i) => i.investmentType == 'rd';
bool isPpf(Investment i) => i.investmentType == 'ppf';

/// Fixed-return holdings have terms; ones migrated without terms behave as
/// "other" (typed value).
bool hasFixedTerms(Investment i) =>
    i.behaviour == InvestmentBehaviour.fixedReturn &&
    i.fixedRate != null &&
    i.fixedStart != null &&
    (i.fixedTenureMonths ?? 0) > 0 &&
    ((i.fixedPrincipal ?? 0) > 0 || (i.installment ?? 0) > 0);

DateTime? maturityDateOf(Investment i) {
  if (!hasFixedTerms(i)) return i.maturityDate;
  final s = i.fixedStart!;
  return DateTime(s.year, s.month + i.fixedTenureMonths!, s.day);
}

/// Value at maturity for a fixed-return holding.
double? maturityValue(Investment i) {
  if (!hasFixedTerms(i)) return null;
  final months = i.fixedTenureMonths!;
  if (isRd(i)) return rdMaturity(i.installment!, i.fixedRate!, months);
  if (isPpf(i)) {
    return ppfMaturity((i.installment ?? i.fixedPrincipal!) , i.fixedRate!, (months / 12).round());
  }
  if (i.payout != PayoutType.cumulative) return i.fixedPrincipal;
  return fdMaturity(i.fixedPrincipal!, i.fixedRate!, months, i.compounding);
}

/// Today's value: calculated for fixed return, last entered otherwise.
double currentValue(Investment i, {DateTime? now}) {
  final at = now ?? DateTime.now();
  if (hasFixedTerms(i)) {
    if (isRd(i)) {
      return rdValueOn(
          installment: i.installment!,
          rate: i.fixedRate!,
          start: i.fixedStart!,
          tenureMonths: i.fixedTenureMonths!,
          at: at);
    }
    if (isPpf(i)) {
      final years = yearsBetween(i.fixedStart!, at).floor().clamp(0, 50);
      return years == 0 ? (i.investedAmount ?? 0) : ppfMaturity(i.installment ?? i.fixedPrincipal!, i.fixedRate!, years);
    }
    return fdValueOn(
        principal: i.fixedPrincipal!,
        rate: i.fixedRate!,
        freq: i.compounding,
        start: i.fixedStart!,
        tenureMonths: i.fixedTenureMonths!,
        at: at,
        cumulative: i.payout == PayoutType.cumulative);
  }
  if (i.snapshots.isNotEmpty) {
    final latest = [...i.snapshots]..sort((a, b) => a.date!.compareTo(b.date!));
    return latest.last.value;
  }
  return i.currentValue ?? i.investedAmount ?? 0;
}

double investedOf(Investment i) => i.investedAmount ?? 0;

double realizedGainOf(Investment i) =>
    i.withdrawals.fold(0.0, (s, w) => s + w.realizedGain);

double withdrawnOf(Investment i) =>
    i.withdrawals.fold(0.0, (s, w) => s + w.received);

DateTime? lastValueDate(Investment i) {
  if (i.snapshots.isEmpty) return null;
  return i.snapshots.map((s) => s.date!).reduce((a, b) => a.isAfter(b) ? a : b);
}

/// Market-valued holdings not updated for 30+ days are flagged.
int? staleDays(Investment i, {DateTime? now}) {
  if (i.behaviour != InvestmentBehaviour.market) return null;
  final last = lastValueDate(i) ?? i.updatedAt;
  final days = (now ?? DateTime.now()).difference(last).inDays;
  return days > 30 ? days : null;
}

/// Dated cash flows for XIRR: contributions out, withdrawals in, value today.
List<CashFlow> cashFlows(Investment i, List<Transaction> linked, {DateTime? now}) {
  final flows = <CashFlow>[
    if (i.openingInvested > 0)
      CashFlow(i.openingDate ?? i.createdAt, -i.openingInvested),
    for (final t in linked)
      if (t.type == 'expense') CashFlow(t.createdAt, -t.amount),
    for (final w in i.withdrawals)
      if (w.date != null) CashFlow(w.date!, w.received),
  ];
  final value = i.status == InvestmentStatus.closed ? 0.0 : currentValue(i, now: now);
  if (value > 0) flows.add(CashFlow(now ?? DateTime.now(), value));
  return flows;
}

double? xirrOf(Investment i, List<Transaction> linked, {DateTime? now}) =>
    xirr(cashFlows(i, linked, now: now));

/// Next SIP amount and date (step-up aware).
({int day, double amount})? nextSip(Investment i, {DateTime? now}) {
  final s = i.sip;
  if (s == null || i.status == InvestmentStatus.closed) return null;
  final day = nextDate(s, fromKey: todayKey(now));
  if (day == null) return null;
  final base = i.sipAmount ?? i.installment ?? 0;
  return (
    day: day,
    amount: stepUpAmount(
        base: base,
        start: s.startDate!,
        on: dayOf(day),
        percent: i.stepUpKind == StepUpKind.percent,
        value: i.stepUpValue),
  );
}

/// Compounding label index for the chips (monthly, quarterly, half, yearly).
const compoundingChips = [
  CompoundingFrequency.monthly,
  CompoundingFrequency.quarterly,
  CompoundingFrequency.halfYearly,
  CompoundingFrequency.yearly,
];
