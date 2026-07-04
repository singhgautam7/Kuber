import 'package:intl/intl.dart';

/// One period on the income/expense chart.
class IncomeExpensePoint {
  /// Short X-axis label, e.g. "Feb" or "12".
  final String label;

  final double income;
  final double expense;

  /// Period start/end, used by the tooltip's "View transactions" link and
  /// the tooltip header.
  final DateTime? date;
  final DateTime? endDate;

  const IncomeExpensePoint({
    required this.label,
    required this.income,
    required this.expense,
    this.date,
    this.endDate,
  });

  /// Header line of the tooltip: "June 2026" for month buckets, otherwise a
  /// date or date range.
  String get tooltipLabel {
    final d = date;
    if (d == null) return label;
    final e = endDate ?? d;
    final sameDay = d.year == e.year && d.month == e.month && d.day == e.day;
    if (sameDay) return DateFormat('d MMM yyyy').format(d);
    final wholeMonth = d.day == 1 &&
        d.month == e.month &&
        d.year == e.year &&
        e.day >= DateTime(d.year, d.month + 1, 0).day - 1;
    if (wholeMonth) return DateFormat('MMMM yyyy').format(d);
    if (d.year == e.year && d.month == 1 && d.day == 1 &&
        e.month == 12 && e.day >= 30) {
      return '${d.year}';
    }
    return '${DateFormat('d MMM').format(d)} - ${DateFormat('d MMM').format(e)}';
  }
}
