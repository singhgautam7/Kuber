import '../../transactions/data/transaction.dart';
import '../data/loan.dart';

/// Pure calculation functions for loans — no Isar, no Flutter.

/// Sum of all expense transactions linked to this loan.
double computeTotalPaid(String loanUid, List<Transaction> allTxns) {
  return allTxns
      .where((t) => t.linkedRuleId == loanUid && t.linkedRuleType == 'loan')
      .fold(0.0, (sum, t) => sum + t.amount);
}

/// Remaining = principalAmount - totalPaid. Can go negative if overpaid.
double computeRemaining(Loan loan, List<Transaction> allTxns) {
  return loan.principalAmount - computeTotalPaid(loan.uid, allTxns);
}

/// Progress from 0.0 to 1.0. Clamped at 1.0 if overpaid.
double computeProgress(Loan loan, List<Transaction> allTxns) {
  if (loan.principalAmount <= 0) return 0.0;
  final paid = computeTotalPaid(loan.uid, allTxns);
  return (paid / loan.principalAmount).clamp(0.0, 1.0);
}

/// Next occurrence of loan.billDate on or after today.
/// Returns null if loan isCompleted.
DateTime? computeNextDueDate(Loan loan) {
  if (loan.isCompleted) return null;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thisMonth = DateTime(now.year, now.month, loan.billDate);
  if (!thisMonth.isBefore(today)) return thisMonth;
  // Bill date already passed this month — next month
  if (now.month == 12) {
    return DateTime(now.year + 1, 1, loan.billDate);
  }
  return DateTime(now.year, now.month + 1, loan.billDate);
}

/// Sum of remaining across all active (non-completed) loans.
double totalOutstanding(List<Loan> loans, List<Transaction> allTxns) {
  return loans
      .where((l) => !l.isCompleted)
      .fold(0.0, (sum, l) => sum + computeRemaining(l, allTxns).clamp(0.0, double.infinity));
}

/// Sum of all payments across all loans (including completed).
double totalPaidAllLoans(List<Loan> loans, List<Transaction> allTxns) {
  return loans.fold(0.0, (sum, l) => sum + computeTotalPaid(l.uid, allTxns));
}
