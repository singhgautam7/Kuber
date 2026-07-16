part of 'analytics_engine_adapter.dart';

class SpendingPatternsResult {
  final int transactionCount;
  final List<double> weekdayAverages;
  final Map<String, double> timeBuckets;
  final double weekdaySpend;
  final double weekendSpend;
  final double recurringSpend;
  final double oneTimeSpend;
  final List<String> insights;

  const SpendingPatternsResult({
    required this.transactionCount,
    required this.weekdayAverages,
    required this.timeBuckets,
    required this.weekdaySpend,
    required this.weekendSpend,
    required this.recurringSpend,
    required this.oneTimeSpend,
    required this.insights,
  });
}

SpendingPatternsResult computeSpendingPatterns(AnalyticsInput input) {
  final txns = _expensesInRange(input.transactions, input.range);
  final weekdayTotals = List<double>.filled(7, 0);
  final weekdayCounts = List<int>.filled(7, 0);
  final buckets = <String, double>{
    'Morning': 0,
    'Afternoon': 0,
    'Evening': 0,
    'Night': 0,
  };
  var weekdaySpend = 0.0;
  var weekendSpend = 0.0;
  var recurring = 0.0;
  var oneTime = 0.0;

  for (final t in txns) {
    final date = t.date;
    final amount = t.amount;
    weekdayTotals[date.weekday - 1] += amount;
    weekdayCounts[date.weekday - 1]++;
    if (date.weekday >= 6) {
      weekendSpend += amount;
    } else {
      weekdaySpend += amount;
    }
    if (t.linkedRuleType == 'recurring') {
      recurring += amount;
    } else {
      oneTime += amount;
    }
    final bucket = date.hour < 12
        ? 'Morning'
        : date.hour < 17
        ? 'Afternoon'
        : date.hour < 21
        ? 'Evening'
        : 'Night';
    buckets[bucket] = buckets[bucket]! + amount;
  }

  final averages = List<double>.generate(
    7,
    (i) => weekdayCounts[i] == 0 ? 0 : weekdayTotals[i] / weekdayCounts[i],
  );
  final maxDay = averages.indexWhere((v) => v == averages.reduce(math.max));
  final maxBucket = buckets.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final total = weekdaySpend + weekendSpend;
  final insights = <String>[
    if (txns.isNotEmpty)
      'Most spending happens on ${_weekdayName(maxDay + 1)}.',
    if (maxBucket.isNotEmpty)
      '${maxBucket.first.key} is your busiest spending window.',
    if (total > 0)
      weekendSpend > weekdaySpend
          ? 'Weekends carry more spending than weekdays in this range.'
          : 'Weekday spending is higher than weekend spending in this range.',
  ];

  return SpendingPatternsResult(
    transactionCount: txns.length,
    weekdayAverages: averages,
    timeBuckets: buckets,
    weekdaySpend: weekdaySpend,
    weekendSpend: weekendSpend,
    recurringSpend: recurring,
    oneTimeSpend: oneTime,
    insights: insights.take(3).toList(),
  );
}

String _weekdayName(int weekday) => const [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][weekday - 1];
