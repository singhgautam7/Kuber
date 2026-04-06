import '../../../core/utils/date_formatter.dart';
import '../../transactions/data/transaction.dart';

class DateGroup {
  final String label;
  final DateTime date;
  final double dayTotal;
  final List<Transaction> transactions;

  DateGroup({
    required this.label,
    required this.date,
    required this.dayTotal,
    required this.transactions,
  });
}

List<DateGroup> groupTransactionsByDate(List<Transaction> transactions) {
  // Filter out income legs of transfers (show only expense/FROM leg)
  final displayList = transactions
      .where((t) => !(t.isTransfer && t.type == 'income'))
      .toList();

  final groups = <String, List<Transaction>>{};
  for (final t in displayList) {
    final key = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day)
        .toIso8601String();
    groups.putIfAbsent(key, () => []).add(t);
  }

  final result = groups.entries.map((e) {
    final date = DateTime.parse(e.key);
    final txns = e.value..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    double dayTotal = 0;
    for (final t in txns) {
      if (t.isTransfer || t.isBalanceAdjustment) continue;
      dayTotal += t.type == 'income' ? t.amount : -t.amount;
    }

    final label = DateFormatter.groupHeader(date).toUpperCase();

    return DateGroup(
      label: label,
      date: date,
      dayTotal: dayTotal,
      transactions: txns,
    );
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  return result;
}
