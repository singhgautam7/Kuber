import '../../../core/utils/date_formatter.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/helpers/transaction_filters.dart';

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
  final displayList = transactions.validForFeed.toList();

  // Int day key (yyyymmdd) rather than an ISO string round-trip: this runs
  // over every filtered transaction each time History re-derives its view.
  final groups = <int, List<Transaction>>{};
  for (final t in displayList) {
    final c = t.createdAt;
    final key = c.year * 10000 + c.month * 100 + c.day;
    groups.putIfAbsent(key, () => []).add(t);
  }

  final result = groups.entries.map((e) {
    final key = e.key;
    final date = DateTime(key ~/ 10000, (key ~/ 100) % 100, key % 100);
    final txns = e.value..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    double dayTotal = 0;
    for (final t in txns.validForCalculations) {
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
