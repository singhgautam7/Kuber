import '../../transactions/data/transaction.dart';
import '../data/ledger.dart';

/// Pure calculation functions for ledger — no Isar, no Flutter.

/// Returns all transactions linked to this ledger, excluding the initial one.
/// The initial transaction is the one whose name starts with "Lent to" or "Borrowed from".
List<Transaction> _payments(String ledgerUid, List<Transaction> allTxns) {
  return allTxns.where((t) {
    if (t.linkedRuleId != ledgerUid) return false;
    // Exclude initial transaction
    final lower = t.name.toLowerCase();
    if (lower.startsWith('lent to') || lower.startsWith('borrowed from')) {
      return false;
    }
    return true;
  }).toList();
}

/// Sum of payment amounts for a ledger (excludes initial transaction).
double computePaid(String ledgerUid, List<Transaction> allTxns) {
  return _payments(ledgerUid, allTxns)
      .fold(0.0, (sum, t) => sum + t.amount);
}

/// Remaining = originalAmount - paid. Can go negative if overpaid.
double computeRemaining(Ledger ledger, List<Transaction> allTxns) {
  return ledger.originalAmount - computePaid(ledger.uid, allTxns);
}

/// Progress from 0.0 to 1.0. Clamped at 1.0 if overpaid.
double computeProgress(Ledger ledger, List<Transaction> allTxns) {
  if (ledger.originalAmount <= 0) return 0.0;
  final paid = computePaid(ledger.uid, allTxns);
  return (paid / ledger.originalAmount).clamp(0.0, 1.0);
}

/// Sum of remaining on all active 'lent' ledgers.
double totalToReceive(List<Ledger> ledgers, List<Transaction> allTxns) {
  return ledgers
      .where((l) => l.type == 'lent' && !l.isSettled)
      .fold(0.0, (sum, l) => sum + computeRemaining(l, allTxns).clamp(0.0, double.infinity));
}

/// Sum of remaining on all active 'borrowed' ledgers.
double totalOwed(List<Ledger> ledgers, List<Transaction> allTxns) {
  return ledgers
      .where((l) => l.type == 'borrowed' && !l.isSettled)
      .fold(0.0, (sum, l) => sum + computeRemaining(l, allTxns).clamp(0.0, double.infinity));
}
