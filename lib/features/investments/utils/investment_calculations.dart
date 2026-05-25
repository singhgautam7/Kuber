import '../data/investment.dart';

/// Pure calculation functions for investments — no Isar, no Flutter.

/// Total invested for a single investment.
/// Uses the investedAmount field directly (falls back to 0).
double computeTotalInvested(Investment investment) {
  return investment.investedAmount ?? 0.0;
}

/// Gain/loss = currentValue - investedAmount.
/// Returns 0.0 if either value is null.
double computeGainLoss(Investment investment) {
  if (investment.currentValue == null || investment.investedAmount == null) {
    return 0.0;
  }
  return investment.currentValue! - investment.investedAmount!;
}

/// Gain/loss as percentage of investedAmount.
/// Returns 0.0 if investedAmount is 0 or null.
double computeGainLossPercent(Investment investment) {
  final invested = investment.investedAmount ?? 0.0;
  if (invested == 0) return 0.0;
  return computeGainLoss(investment) / invested * 100;
}

/// Sum of investedAmount across all investments.
double totalInvestedAll(List<Investment> investments) {
  return investments.fold(
      0.0, (sum, inv) => sum + (inv.investedAmount ?? 0.0));
}

/// Sum of currentValue across all investments (null treated as 0).
double totalCurrentValueAll(List<Investment> investments) {
  return investments.fold(0.0, (sum, inv) => sum + (inv.currentValue ?? 0));
}

/// Aggregate gain/loss across all investments.
double totalGainLossAll(List<Investment> investments) {
  return totalCurrentValueAll(investments) - totalInvestedAll(investments);
}

/// Count of investments.
int totalAssetCount(List<Investment> investments) {
  return investments.length;
}
