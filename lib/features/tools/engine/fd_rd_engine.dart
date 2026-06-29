import 'dart:math';

/// Compounding frequency for a fixed deposit.
enum CompoundingFrequency { yearly, halfYearly, quarterly, monthly }

extension CompoundingFrequencyX on CompoundingFrequency {
  /// Number of compounding events per year.
  int get perYear {
    switch (this) {
      case CompoundingFrequency.yearly:
        return 1;
      case CompoundingFrequency.halfYearly:
        return 2;
      case CompoundingFrequency.quarterly:
        return 4;
      case CompoundingFrequency.monthly:
        return 12;
    }
  }
}

class DepositPeriodRow {
  final int period; // year index, 1-based
  final double opening;
  final double interest;
  final double closing;

  const DepositPeriodRow({
    required this.period,
    required this.opening,
    required this.interest,
    required this.closing,
  });
}

class DepositResult {
  final double maturity;
  final double totalInvested;
  final double interestEarned;
  final double effectiveYieldPercent;

  /// Balance at the end of each year, index 0 = start.
  final List<double> balanceSeries;
  final List<DepositPeriodRow> yearly;

  const DepositResult({
    required this.maturity,
    required this.totalInvested,
    required this.interestEarned,
    required this.effectiveYieldPercent,
    required this.balanceSeries,
    required this.yearly,
  });
}

double _effectiveYield(double maturity, double invested, int years) {
  if (invested <= 0 || years <= 0) return 0;
  return (pow(maturity / invested, 1 / years) - 1) * 100;
}

/// Fixed Deposit: `A = P·(1 + r/f)^(f·years)`.
DepositResult computeFd(
  double principal,
  double annualRatePercent,
  int years,
  CompoundingFrequency frequency,
) {
  final f = frequency.perYear;
  final periodicRate = annualRatePercent / 100 / f;
  final balanceSeries = <double>[];
  for (var y = 0; y <= years; y++) {
    balanceSeries.add(principal * pow(1 + periodicRate, f * y));
  }
  final maturity = balanceSeries[years];
  final yearly = <DepositPeriodRow>[];
  for (var y = 1; y <= years; y++) {
    final opening = balanceSeries[y - 1];
    final closing = balanceSeries[y];
    yearly.add(DepositPeriodRow(
      period: y,
      opening: opening,
      interest: closing - opening,
      closing: closing,
    ));
  }
  return DepositResult(
    maturity: maturity,
    totalInvested: principal,
    interestEarned: maturity - principal,
    effectiveYieldPercent: _effectiveYield(maturity, principal, years),
    balanceSeries: balanceSeries,
    yearly: yearly,
  );
}

/// Recurring Deposit: a fixed [monthlyDeposit] is contributed at the start of
/// each month and compounds monthly to maturity (annuity-due).
DepositResult computeRd(
  double monthlyDeposit,
  double annualRatePercent,
  int years,
) {
  final r = annualRatePercent / 100 / 12;
  final balanceSeries = <double>[0];
  double bal = 0;
  final yearly = <DepositPeriodRow>[];
  for (var y = 1; y <= years; y++) {
    final opening = bal;
    for (var m = 0; m < 12; m++) {
      bal = (bal + monthlyDeposit) * (1 + r);
    }
    final deposits = monthlyDeposit * 12;
    yearly.add(DepositPeriodRow(
      period: y,
      opening: opening,
      interest: bal - opening - deposits,
      closing: bal,
    ));
    balanceSeries.add(bal);
  }
  final invested = monthlyDeposit * 12 * years;
  return DepositResult(
    maturity: bal,
    totalInvested: invested,
    interestEarned: bal - invested,
    effectiveYieldPercent: _effectiveYield(bal, invested, years),
    balanceSeries: balanceSeries,
    yearly: yearly,
  );
}
