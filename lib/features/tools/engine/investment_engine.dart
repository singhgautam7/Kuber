import 'dart:math';

/// Result of an investment-growth projection (SIP or lumpsum).
class InvestmentResult {
  final double futureValue;
  final double totalInvested;
  final double totalGains;

  /// Cumulative invested at the end of each year, index 0 = 0 (SIP) or the
  /// lumpsum principal (lumpsum).
  final List<double> investedSeries;

  /// Portfolio value at the end of each year, index 0 = start.
  final List<double> valueSeries;

  const InvestmentResult({
    required this.futureValue,
    required this.totalInvested,
    required this.totalGains,
    required this.investedSeries,
    required this.valueSeries,
  });

  double get absoluteReturnPercent =>
      totalInvested == 0 ? 0 : totalGains / totalInvested * 100;
}

/// SIP future value with monthly compounding (annuity-due: each month's
/// contribution earns a full month of growth).
///
/// `FV = Σ M(1+r)^k` computed iteratively as `v = (v + M)·(1+r)`.
InvestmentResult computeSip(
  double monthlyAmount,
  double annualRatePercent,
  int years,
) {
  final r = annualRatePercent / 100 / 12;
  final invested = <double>[0];
  final value = <double>[0];
  double v = 0;
  for (var y = 1; y <= years; y++) {
    for (var m = 0; m < 12; m++) {
      v = (v + monthlyAmount) * (1 + r);
    }
    invested.add(monthlyAmount * 12 * y);
    value.add(v);
  }
  final totalInvested = monthlyAmount * 12 * years;
  return InvestmentResult(
    futureValue: v,
    totalInvested: totalInvested,
    totalGains: v - totalInvested,
    investedSeries: invested,
    valueSeries: value,
  );
}

/// Lumpsum future value: `FV = P·(1+ar)^years`, compounded yearly.
InvestmentResult computeLumpsum(
  double principal,
  double annualRatePercent,
  int years,
) {
  final value = <double>[principal];
  final invested = <double>[principal];
  for (var y = 1; y <= years; y++) {
    value.add(principal * pow(1 + annualRatePercent / 100, y));
    invested.add(principal);
  }
  final fv = principal * pow(1 + annualRatePercent / 100, years).toDouble();
  return InvestmentResult(
    futureValue: fv,
    totalInvested: principal,
    totalGains: fv - principal,
    investedSeries: invested,
    valueSeries: value,
  );
}
