import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/shared/utils/chart_bucket.dart';

void main() {
  group('availableBucketsForRange', () {
    test('7-day range — Day only', () {
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 1, 7);
      expect(availableBucketsForRange(from, to), [KuberChartBucket.day]);
    });

    test('8-day range — Day + Week', () {
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 1, 8);
      expect(availableBucketsForRange(from, to),
          [KuberChartBucket.day, KuberChartBucket.week]);
    });

    test('31-day range — Day + Week', () {
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 1, 31);
      expect(availableBucketsForRange(from, to),
          [KuberChartBucket.day, KuberChartBucket.week]);
    });

    test('32-day range — Day + Week + Month', () {
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 2, 1);
      expect(availableBucketsForRange(from, to), [
        KuberChartBucket.day,
        KuberChartBucket.week,
        KuberChartBucket.month,
      ]);
    });

    test('365-day range — Day + Week + Month', () {
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 12, 31);
      expect(availableBucketsForRange(from, to), [
        KuberChartBucket.day,
        KuberChartBucket.week,
        KuberChartBucket.month,
      ]);
    });

    test('1-year range (inclusive 366 days) — still Day/Week/Month', () {
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2027, 1, 1);
      expect(availableBucketsForRange(from, to), [
        KuberChartBucket.day,
        KuberChartBucket.week,
        KuberChartBucket.month,
      ]);
    });

    test('>1-year range — all five buckets', () {
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2027, 1, 2);
      expect(availableBucketsForRange(from, to), [
        KuberChartBucket.day,
        KuberChartBucket.week,
        KuberChartBucket.month,
        KuberChartBucket.quarter,
        KuberChartBucket.year,
      ]);
    });

    test('multi-year range — all five buckets', () {
      final from = DateTime(2020, 1, 1);
      final to = DateTime(2026, 12, 31);
      expect(availableBucketsForRange(from, to).length, 5);
    });
  });

  group('bestBucketForRange', () {
    test('1-week → day', () {
      expect(
          bestBucketForRange(DateTime(2026, 1, 1), DateTime(2026, 1, 7)),
          KuberChartBucket.day);
    });

    test('1-month → day (still small)', () {
      expect(
          bestBucketForRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
          KuberChartBucket.day);
    });

    test('3-month → week', () {
      expect(
          bestBucketForRange(DateTime(2026, 1, 1), DateTime(2026, 3, 31)),
          KuberChartBucket.week);
    });

    test('1-year → month', () {
      expect(
          bestBucketForRange(DateTime(2026, 1, 1), DateTime(2026, 12, 31)),
          KuberChartBucket.month);
    });

    test('3-year → quarter', () {
      expect(
          bestBucketForRange(DateTime(2024, 1, 1), DateTime(2026, 12, 31)),
          KuberChartBucket.quarter);
    });

    test('10-year → year', () {
      expect(
          bestBucketForRange(DateTime(2016, 1, 1), DateTime(2026, 12, 31)),
          KuberChartBucket.year);
    });
  });
}
