import 'dart:math';

/// Result of the "what monthly SIP do I need" calculation.
class SipRequiredResult {
  final double monthlyAmount;
  final double totalInvestment;
  final double totalGains;
  final double target;

  const SipRequiredResult({
    required this.monthlyAmount,
    required this.totalInvestment,
    required this.totalGains,
    required this.target,
  });
}

/// Monthly SIP required to reach [target] in [years] at [annualRatePercent],
/// assuming monthly compounding with contributions at the start of each month
/// (annuity-due):
///
/// `M = Target / ( ((1+r)^n − 1)/r · (1+r) )`.
double requiredMonthlySip(double target, double annualRatePercent, int years) {
  if (years <= 0 || target <= 0) return 0;
  final r = annualRatePercent / 100 / 12;
  final n = years * 12;
  if (r == 0) return target / n;
  final factor = (pow(1 + r, n) - 1) / r * (1 + r);
  if (factor == 0) return 0;
  return target / factor;
}

SipRequiredResult computeSipRequired(
  double target,
  double annualRatePercent,
  int years,
) {
  final monthly = requiredMonthlySip(target, annualRatePercent, years);
  final invested = monthly * 12 * years;
  return SipRequiredResult(
    monthlyAmount: monthly,
    totalInvestment: invested,
    totalGains: target - invested,
    target: target,
  );
}
