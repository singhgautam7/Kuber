part of 'analytics_engine_adapter.dart';

class CategoryDeepDiveResult {
  final String? categoryId;
  final double totalSpent;
  final double monthlyAverage;
  final List<MonthlyAggregate> series;
  final List<MerchantRow> topMerchants;
  final List<double> weekdayTotals;
  final double previousTotal;
  final List<String> relatedCategoryIds;

  const CategoryDeepDiveResult({
    required this.categoryId,
    required this.totalSpent,
    required this.monthlyAverage,
    required this.series,
    required this.topMerchants,
    required this.weekdayTotals,
    required this.previousTotal,
    required this.relatedCategoryIds,
  });

  double get percentChange => previousTotal <= 0
      ? 0
      : ((totalSpent - previousTotal) / previousTotal) * 100;
}

CategoryDeepDiveResult computeCategoryDeepDive(AnalyticsInput input) {
  final id = input.selectedCategoryId;
  if (id == null) {
    return const CategoryDeepDiveResult(
      categoryId: null,
      totalSpent: 0,
      monthlyAverage: 0,
      series: [],
      topMerchants: [],
      weekdayTotals: [],
      previousTotal: 0,
      relatedCategoryIds: [],
    );
  }
  final current = _expensesInRange(
    input.transactions,
    input.range,
  ).where((t) => t.categoryId == id).toList();
  final series = _monthly(
    current.map((t) => t.map).toList(),
    input.range.from,
    _endInclusive(input.range.to),
  );
  final total = current.fold<double>(0, (sum, t) => sum + t.amount);
  final months = math.max(1, series.length);
  final previousRange = AnalyticsRange(
    input.range.from.subtract(Duration(days: input.range.inclusiveDays)),
    input.range.from.subtract(const Duration(days: 1)),
  );
  final previousTotal = _expensesInRange(input.transactions, previousRange)
      .where((t) => t.categoryId == id)
      .fold<double>(0, (sum, t) => sum + t.amount);
  final weekdays = List<double>.filled(7, 0);
  for (final t in current) {
    weekdays[t.date.weekday - 1] += t.amount;
  }
  final merchants = _merchantRows(current, const {});
  final related = <String, double>{};
  for (final t in _expensesInRange(input.transactions, input.range)) {
    if (t.categoryId == id) continue;
    final dayKey = DateTime(t.date.year, t.date.month, t.date.day);
    final hasTargetSameDay = current.any(
      (c) =>
          c.date.year == dayKey.year &&
          c.date.month == dayKey.month &&
          c.date.day == dayKey.day,
    );
    if (hasTargetSameDay) {
      related[t.categoryId] = (related[t.categoryId] ?? 0) + t.amount;
    }
  }
  final relatedIds = related.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return CategoryDeepDiveResult(
    categoryId: id,
    totalSpent: total,
    monthlyAverage: total / months,
    series: series,
    topMerchants: merchants.take(5).toList(),
    weekdayTotals: weekdays,
    previousTotal: previousTotal,
    relatedCategoryIds: relatedIds.take(3).map((e) => e.key).toList(),
  );
}
