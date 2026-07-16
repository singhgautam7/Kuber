part of 'analytics_engine_adapter.dart';

class SavingsRateResult {
  final List<MonthlyAggregate> months;
  final double overallRate;
  final double previousRate;
  final MonthlyAggregate? bestMonth;
  final MonthlyAggregate? worstMonth;
  final String assessment;

  const SavingsRateResult({
    required this.months,
    required this.overallRate,
    required this.previousRate,
    required this.bestMonth,
    required this.worstMonth,
    required this.assessment,
  });

  double get delta => overallRate - previousRate;
}

SavingsRateResult computeSavingsRate(AnalyticsInput input) {
  final months = _monthly(
    input.transactions,
    input.range.from,
    _endInclusive(input.range.to),
  );
  final totalIncome = months.fold<double>(0, (sum, m) => sum + m.income);
  final totalExpense = months.fold<double>(0, (sum, m) => sum + m.expense);
  final overall = totalIncome <= 0
      ? 0.0
      : ((totalIncome - totalExpense) / totalIncome) * 100;
  final previous = _monthly(
    input.transactions,
    input.range.from.subtract(Duration(days: input.range.inclusiveDays)),
    input.range.from,
  );
  final prevIncome = previous.fold<double>(0, (sum, m) => sum + m.income);
  final prevExpense = previous.fold<double>(0, (sum, m) => sum + m.expense);
  final prevRate = prevIncome <= 0
      ? 0.0
      : ((prevIncome - prevExpense) / prevIncome) * 100;
  final positiveMonths = months.where((m) => m.savingsRate > 0).length;
  final sorted = [...months]
    ..sort((a, b) => b.savingsRate.compareTo(a.savingsRate));
  return SavingsRateResult(
    months: months,
    overallRate: overall,
    previousRate: prevRate,
    bestMonth: sorted.isEmpty ? null : sorted.first,
    worstMonth: sorted.isEmpty ? null : sorted.last,
    assessment: positiveMonths >= (months.length * 0.75).ceil()
        ? 'Consistent'
        : overall < 0
        ? 'Negative'
        : 'Variable',
  );
}
