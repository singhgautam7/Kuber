part of 'analytics_engine_adapter.dart';

class TrendsResult {
  final String mode;
  final double currentExpense;
  final double previousExpense;
  final double currentIncome;
  final double previousIncome;
  final int monthsTracked;

  /// Per-category this-year vs last-year change for EXPENSE categories (used
  /// under the "Total Spending" tab).
  final List<AnalyticsComparisonRow> categoryChanges;

  /// Same, for INCOME categories (used under the "Total Income" tab).
  final List<AnalyticsComparisonRow> incomeCategoryChanges;
  final List<MonthlyAggregate> currentSeries;
  final List<MonthlyAggregate> previousSeries;

  const TrendsResult({
    required this.mode,
    required this.currentExpense,
    required this.previousExpense,
    required this.currentIncome,
    required this.previousIncome,
    required this.monthsTracked,
    required this.categoryChanges,
    required this.incomeCategoryChanges,
    required this.currentSeries,
    required this.previousSeries,
  });

  double get percentChange => previousExpense <= 0
      ? 0
      : ((currentExpense - previousExpense) / previousExpense) * 100;
}

class AnalyticsComparisonRow {
  final String id;
  final double current;
  final double previous;

  const AnalyticsComparisonRow({
    required this.id,
    required this.current,
    required this.previous,
  });

  double get delta => current - previous;
  double get percent => previous <= 0 ? 0 : (delta / previous) * 100;
}

TrendsResult computeTrends(AnalyticsInput input) {
  final monthsTracked = _trackedMonths(input.transactions);

  // Year over year: the current range (this year to date) vs the SAME calendar
  // range one year earlier. Totals use the app's standard expense/income
  // definition (transfers and balance adjustments excluded, via _summary), so
  // "This year" matches what the rest of the app reports for the period.
  final currentStart = input.range.from;
  final currentEnd = _endInclusive(input.range.to);
  final previousStart = DateTime(
    input.range.from.year - 1,
    input.range.from.month,
    input.range.from.day,
  );
  final previousEnd = _endInclusive(
    DateTime(
      input.range.to.year - 1,
      input.range.to.month,
      input.range.to.day,
    ),
  );

  final current = _summary(input.transactions, currentStart, currentEnd);
  final previous = _summary(input.transactions, previousStart, previousEnd);

  List<AnalyticsComparisonRow> changes(
    Map<String, double> cur,
    Map<String, double> prev,
  ) {
    final ids = {...cur.keys, ...prev.keys};
    return ids
        .map(
          (id) => AnalyticsComparisonRow(
            id: id,
            current: cur[id] ?? 0,
            previous: prev[id] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.delta.abs().compareTo(a.delta.abs()));
  }

  // Income-by-category for both windows (expense-by-category already lives in
  // the summaries' categorySpend).
  final curIncomeByCat = _incomeByCategory(
    input.transactions,
    currentStart,
    currentEnd,
  );
  final prevIncomeByCat = _incomeByCategory(
    input.transactions,
    previousStart,
    previousEnd,
  );

  return TrendsResult(
    mode: 'yoy',
    currentExpense: current.expense,
    previousExpense: previous.expense,
    currentIncome: current.income,
    previousIncome: previous.income,
    monthsTracked: monthsTracked,
    categoryChanges: changes(
      current.categorySpend,
      previous.categorySpend,
    ).take(8).toList(),
    incomeCategoryChanges: changes(
      curIncomeByCat,
      prevIncomeByCat,
    ).take(8).toList(),
    currentSeries: _monthly(input.transactions, currentStart, currentEnd),
    previousSeries: _monthly(input.transactions, previousStart, previousEnd),
  );
}

Map<String, double> _incomeByCategory(
  List<Map<String, Object?>> txns,
  DateTime start,
  DateTime end,
) {
  final m = <String, double>{};
  for (final raw in txns) {
    final t = _Txn(raw);
    if (_skip(t) || t.type != 'income') continue;
    if (t.date.isBefore(start) || !t.date.isBefore(end)) continue;
    m[t.categoryId] = (m[t.categoryId] ?? 0) + t.amount;
  }
  return m;
}
