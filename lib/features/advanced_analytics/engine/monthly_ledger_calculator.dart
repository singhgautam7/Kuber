part of 'analytics_engine_adapter.dart';

/// Month-by-month income / expense / net aggregation. This is the core
/// aggregation the whole engine leans on: Trends, Savings Rate, Forecast and
/// Category deep-dive all reuse [_monthly] in addition to the Monthly Ledger
/// (cash flow) section itself.
class MonthlyAggregate {
  final DateTime month;
  final double income;
  final double expense;
  final int transactionCount;
  final Map<String, double> categorySpend;

  const MonthlyAggregate({
    required this.month,
    required this.income,
    required this.expense,
    required this.transactionCount,
    required this.categorySpend,
  });

  double get net => income - expense;
  double get savingsRate =>
      income <= 0 ? 0 : ((income - expense) / income) * 100;
  String get label => DateFormat('MMM yy').format(month);
}

List<MonthlyAggregate> computeMonthlyAggregates(AnalyticsInput input) {
  return _monthly(
    input.transactions,
    input.range.from,
    _endInclusive(input.range.to),
  );
}

List<MonthlyAggregate> _monthly(
  List<Map<String, Object?>> txns,
  DateTime start,
  DateTime end,
) {
  final from = DateTime(start.year, start.month, 1);
  final to = DateTime(end.year, end.month, 1);
  final months = <String, MonthlyAggregate>{};
  var cursor = from;
  while (!cursor.isAfter(to)) {
    final key = '${cursor.year}-${cursor.month}';
    months[key] = MonthlyAggregate(
      month: cursor,
      income: 0,
      expense: 0,
      transactionCount: 0,
      categorySpend: const {},
    );
    cursor = DateTime(cursor.year, cursor.month + 1, 1);
  }
  final mutable = <String, _MonthMutable>{
    for (final m in months.values)
      '${m.month.year}-${m.month.month}': _MonthMutable(m.month),
  };
  for (final raw in txns) {
    final t = _Txn(raw);
    if (_skip(t) || t.date.isBefore(start) || !t.date.isBefore(end)) continue;
    final key = '${t.date.year}-${t.date.month}';
    final bucket = mutable[key];
    if (bucket == null) continue;
    bucket.count++;
    if (t.type == 'income') {
      bucket.income += t.amount;
    } else if (t.type == 'expense') {
      bucket.expense += t.amount;
      bucket.categorySpend[t.categoryId] =
          (bucket.categorySpend[t.categoryId] ?? 0) + t.amount;
    }
  }
  return mutable.values
      .map(
        (m) => MonthlyAggregate(
          month: m.month,
          income: m.income,
          expense: m.expense,
          transactionCount: m.count,
          categorySpend: Map.unmodifiable(m.categorySpend),
        ),
      )
      .toList();
}

class _MonthMutable {
  final DateTime month;
  var income = 0.0;
  var expense = 0.0;
  var count = 0;
  final categorySpend = <String, double>{};

  _MonthMutable(this.month);
}
