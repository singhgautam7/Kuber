import '../../transactions/data/transaction.dart';
import '../data/investment.dart';

/// Pure calculation functions for investments — no Isar, no Flutter.

/// Sum of all expense transactions linked to this investment.
double computeTotalInvested(String investmentUid, List<Transaction> allTxns) {
  return allTxns
      .where((t) =>
          t.linkedRuleId == investmentUid && t.linkedRuleType == 'investment')
      .fold(0.0, (sum, t) => sum + t.amount);
}

/// Gain/loss = currentValue - totalInvested.
/// Returns 0.0 if currentValue is null.
double computeGainLoss(Investment investment, List<Transaction> allTxns) {
  if (investment.currentValue == null) return 0.0;
  return investment.currentValue! - computeTotalInvested(investment.uid, allTxns);
}

/// Gain/loss as percentage of totalInvested.
/// Returns 0.0 if totalInvested is 0.
double computeGainLossPercent(Investment investment, List<Transaction> allTxns) {
  final totalInvested = computeTotalInvested(investment.uid, allTxns);
  if (totalInvested == 0) return 0.0;
  return computeGainLoss(investment, allTxns) / totalInvested * 100;
}

/// Sum of totalInvested across all investments.
double totalInvestedAll(List<Investment> investments, List<Transaction> allTxns) {
  return investments.fold(
      0.0, (sum, inv) => sum + computeTotalInvested(inv.uid, allTxns));
}

/// Sum of currentValue across all investments (null treated as 0).
double totalCurrentValueAll(List<Investment> investments) {
  return investments.fold(0.0, (sum, inv) => sum + (inv.currentValue ?? 0));
}

/// Aggregate gain/loss across all investments.
double totalGainLossAll(List<Investment> investments, List<Transaction> allTxns) {
  return totalCurrentValueAll(investments) - totalInvestedAll(investments, allTxns);
}

/// Count of investments.
int totalAssetCount(List<Investment> investments) {
  return investments.length;
}
