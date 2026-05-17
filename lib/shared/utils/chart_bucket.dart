/// X-axis bucketing options for [KuberBarChart]. The dropdown shown on the
/// analytics chart lets the user override the auto-selected bucket.
enum KuberChartBucket { day, week, month, quarter, year }

extension KuberChartBucketLabel on KuberChartBucket {
  String get label => switch (this) {
        KuberChartBucket.day => 'Day',
        KuberChartBucket.week => 'Week',
        KuberChartBucket.month => 'Month',
        KuberChartBucket.quarter => 'Quarter',
        KuberChartBucket.year => 'Year',
      };
}

/// Available bucketing options for a date range:
///
///   ≤ 1 week              → [Day]
///   > 1 week  ≤ 1 month   → [Day, Week]
///   > 1 month ≤ 1 year    → [Day, Week, Month]
///   > 1 year              → [Day, Week, Month, Quarter, Year]
///
/// Tested in `test/charts/bucket_selection_test.dart`.
List<KuberChartBucket> availableBucketsForRange(DateTime from, DateTime to) {
  final days = _inclusiveDayDiff(from, to);
  if (days <= 7) return const [KuberChartBucket.day];
  if (days <= 31) {
    return const [KuberChartBucket.day, KuberChartBucket.week];
  }
  if (days <= 366) {
    return const [
      KuberChartBucket.day,
      KuberChartBucket.week,
      KuberChartBucket.month,
    ];
  }
  return const [
    KuberChartBucket.day,
    KuberChartBucket.week,
    KuberChartBucket.month,
    KuberChartBucket.quarter,
    KuberChartBucket.year,
  ];
}

/// Auto-pick the bucket that best fits a date range. Used as the default
/// when the user hasn't explicitly chosen a bucket for the current range.
///
///   ≤ 1 week               → day
///   ≤ ~6 weeks             → day
///   ≤ 6 months             → week
///   ≤ ~2 years             → month
///   ≤ ~6 years             → quarter
///   > ~6 years             → year
KuberChartBucket bestBucketForRange(DateTime from, DateTime to) {
  final days = _inclusiveDayDiff(from, to);
  if (days <= 42) return KuberChartBucket.day;
  if (days <= 183) return KuberChartBucket.week;
  if (days <= 731) return KuberChartBucket.month;
  if (days <= 2192) return KuberChartBucket.quarter;
  return KuberChartBucket.year;
}

int _inclusiveDayDiff(DateTime from, DateTime to) {
  final a = DateTime(from.year, from.month, from.day);
  final b = DateTime(to.year, to.month, to.day);
  return b.difference(a).inDays + 1; // both endpoints inclusive
}
