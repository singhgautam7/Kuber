import '../../features/transactions/data/transaction.dart';

/// Returns the median of a list of doubles. Returns 0 if empty.
double median(List<double> values) {
  if (values.isEmpty) return 0;
  final sorted = List<double>.from(values)..sort();
  final mid = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[mid];
  return (sorted[mid - 1] + sorted[mid]) / 2;
}

/// Removes outliers > 3× the median. Skips if fewer than 4 items.
List<double> removeOutliers(List<double> values) {
  if (values.length < 4) return values;
  final med = median(values);
  if (med == 0) return values;
  return values.where((v) => v <= med * 3).toList();
}

/// Formats a percentage delta as a human-readable string.
/// Caps at 150% → "significantly more/less".
String formatDelta(double pct) {
  if (pct.abs() >= 150) {
    return 'significantly ${pct > 0 ? 'more' : 'less'}';
  }
  return '${pct.abs().toInt()}% ${pct > 0 ? 'more' : 'less'}';
}

/// Filters transactions to the last [days] days.
/// If [expenseOnly] is true, excludes non-expense types.
/// Always excludes transfers.
List<Transaction> window(
  List<Transaction> all, {
  required int days,
  bool expenseOnly = true,
}) {
  final cutoff = DateTime.now().subtract(Duration(days: days));
  return all.where((t) {
    if (t.type == 'transfer' || t.isBalanceAdjustment) return false;
    if (expenseOnly && t.type != 'expense') return false;
    return t.createdAt.isAfter(cutoff);
  }).toList();
}
