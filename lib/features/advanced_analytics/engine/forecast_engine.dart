part of 'analytics_engine_adapter.dart';

class ForecastResult {
  final int monthsTracked;
  final double projectedTotal;
  final double lockedInRecurring;
  final double discretionarySoFar;
  final double projectedDiscretionary;
  final String confidence;
  final List<BudgetForecast> budgetForecasts;
  final List<UpcomingCharge> upcomingCharges;

  const ForecastResult({
    required this.monthsTracked,
    required this.projectedTotal,
    required this.lockedInRecurring,
    required this.discretionarySoFar,
    required this.projectedDiscretionary,
    required this.confidence,
    required this.budgetForecasts,
    required this.upcomingCharges,
  });
}

class BudgetForecast {
  final String categoryId;
  final double budgetAmount;
  final double projectedSpend;

  const BudgetForecast({
    required this.categoryId,
    required this.budgetAmount,
    required this.projectedSpend,
  });

  double get utilization =>
      budgetAmount <= 0 ? 0 : projectedSpend / budgetAmount;
}

class UpcomingCharge {
  final String name;
  final double amount;
  final DateTime date;

  const UpcomingCharge({
    required this.name,
    required this.amount,
    required this.date,
  });
}

ForecastResult computeForecast(AnalyticsInput input) {
  final now = input.now;
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 0);
  final daysInMonth = monthEnd.day;
  final daysSoFar = now.day.clamp(1, daysInMonth);
  final monthsTracked = _trackedMonths(input.transactions);
  final recurring = input.recurringRules
      .where(
        (r) => !(r['isPaused'] as bool? ?? false) && r['type'] == 'expense',
      )
      .where((r) => _date(r['nextDueAt']).isBefore(_endInclusive(monthEnd)))
      .fold<double>(0, (sum, r) => sum + (r['amount'] as num).toDouble());

  final discretionarySoFar = input.transactions
      .map(_Txn.new)
      .where(
        (t) =>
            t.type == 'expense' &&
            t.linkedRuleType != 'recurring' &&
            !_skip(t) &&
            !t.date.isBefore(monthStart) &&
            t.date.isBefore(_endInclusive(now)),
      )
      .fold<double>(0, (sum, t) => sum + t.amount);

  final dailyPace = discretionarySoFar / daysSoFar;
  final projectedDiscretionary = dailyPace * (daysInMonth - daysSoFar);
  final monthly = _monthly(
    input.transactions,
    DateTime(now.year, now.month - 3, 1),
    monthStart,
  ).map((m) => m.expense).toList()..sort();
  final historicalMedian = monthly.isEmpty
      ? discretionarySoFar
      : _median(monthly);
  final raw = recurring + discretionarySoFar + projectedDiscretionary;
  final projected = raw * 0.7 + historicalMedian * 0.3;
  final confidence = monthsTracked >= 6 && now.day >= 14
      ? 'High'
      : monthsTracked >= 2
      ? 'Medium'
      : 'Low';

  final budgetForecasts =
      input.budgets
          .where((b) => b['isActive'] as bool? ?? false)
          .map((b) {
            final categoryId = b['categoryId'] as String;
            final spent = input.transactions
                .map(_Txn.new)
                .where(
                  (t) =>
                      t.type == 'expense' &&
                      t.categoryId == categoryId &&
                      !_skip(t) &&
                      !t.date.isBefore(monthStart) &&
                      t.date.isBefore(_endInclusive(now)),
                )
                .fold<double>(0, (sum, t) => sum + t.amount);
            final projectedSpend = (spent / daysSoFar) * daysInMonth;
            return BudgetForecast(
              categoryId: categoryId,
              budgetAmount: (b['amount'] as num).toDouble(),
              projectedSpend: projectedSpend,
            );
          })
          .where((b) => b.utilization >= 0.8)
          .toList()
        ..sort((a, b) => b.utilization.compareTo(a.utilization));

  final next30 = now.add(const Duration(days: 30));
  final charges =
      input.recurringRules
          .where(
            (r) => !(r['isPaused'] as bool? ?? false) && r['type'] == 'expense',
          )
          .where((r) {
            final d = _date(r['nextDueAt']);
            return !d.isBefore(now) && !d.isAfter(next30);
          })
          .map(
            (r) => UpcomingCharge(
              name: r['name'] as String,
              amount: (r['amount'] as num).toDouble(),
              date: _date(r['nextDueAt']),
            ),
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  return ForecastResult(
    monthsTracked: monthsTracked,
    projectedTotal: projected,
    lockedInRecurring: recurring,
    discretionarySoFar: discretionarySoFar,
    projectedDiscretionary: projectedDiscretionary,
    confidence: confidence,
    budgetForecasts: budgetForecasts.take(5).toList(),
    upcomingCharges: charges.take(5).toList(),
  );
}

double _median(List<double> values) {
  if (values.isEmpty) return 0;
  final sorted = [...values]..sort();
  final mid = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[mid]
      : (sorted[mid - 1] + sorted[mid]) / 2;
}
