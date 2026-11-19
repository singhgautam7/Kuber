import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/utils/chart_bucket.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../transactions/data/transaction.dart';

/// Income / expense buckets for the Analytics chart, from the active filter
/// and its transactions (same rules as the rest of Analytics: `spendAmount`,
/// anything not income is expense). Cached by Riverpod, so rebuilding the
/// Analytics screen no longer re-runs the O(n) pass.
final analyticsBucketsProvider = Provider<List<KuberBarBucket>>((ref) {
  final filter = ref.watch(analyticsFilterProvider);
  final txns = ref.watch(analyticsTransactionsProvider);
  if (filter.type == FilterType.today) return _timeOfDay(txns, filter);
  return switch (filter.effectiveBucket) {
    KuberChartBucket.day => _days(txns, filter.from, filter.to),
    KuberChartBucket.week => _weeks(txns, filter.from, filter.to),
    KuberChartBucket.month => _months(txns, filter.from, filter.to),
    KuberChartBucket.quarter => _quarters(txns, filter.from, filter.to),
    KuberChartBucket.year => _years(txns, filter.from, filter.to),
  };
});

class _B {
  _B(this.day, this.month, {this.date, this.endDate, this.slot});
  final String day, month;
  final DateTime? date, endDate;
  final int? slot;
  double income = 0, expense = 0;

  void add(Transaction t) {
    if (t.type == 'income') {
      income += t.spendAmount;
    } else {
      expense += t.spendAmount;
    }
  }
}

List<KuberBarBucket> _out(List<_B> b) => [
      for (var i = 0; i < b.length; i++)
        KuberBarBucket(
          dayLabel: b[i].day,
          monthLabel: b[i].month,
          income: b[i].income,
          expense: b[i].expense,
          isHighlighted: i == b.length - 1,
          date: b[i].date,
          endDate: b[i].endDate,
          timeOfDaySlot: b[i].slot,
        ),
    ];

List<KuberBarBucket> _timeOfDay(List<Transaction> txns, AnalyticsFilter f) {
  final b = [
    _B('', '', date: f.from, endDate: f.from.add(const Duration(hours: 5, minutes: 59)), slot: 0),
    _B('', '', date: f.from.add(const Duration(hours: 6)), endDate: f.from.add(const Duration(hours: 10, minutes: 59)), slot: 1),
    _B('', '', date: f.from.add(const Duration(hours: 11)), endDate: f.from.add(const Duration(hours: 13, minutes: 59)), slot: 2),
    _B('', '', date: f.from.add(const Duration(hours: 14)), endDate: f.from.add(const Duration(hours: 18, minutes: 59)), slot: 3),
    _B('', '', date: f.from.add(const Duration(hours: 19)), endDate: f.to, slot: 4),
  ];
  for (final t in txns) {
    final h = t.createdAt.hour;
    b[h < 6 ? 0 : h < 11 ? 1 : h < 14 ? 2 : h < 19 ? 3 : 4].add(t);
  }
  return _out(b);
}

List<KuberBarBucket> _days(List<Transaction> txns, DateTime from, DateTime to) {
  final fromDay = DateTime(from.year, from.month, from.day);
  final count = DateTime(to.year, to.month, to.day).difference(fromDay).inDays + 1;
  final b = List.generate(count, (i) {
    final d = fromDay.add(Duration(days: i));
    return _B(DateFormat('d').format(d), DateFormat('MMM').format(d).toUpperCase(), date: d);
  });
  for (final t in txns) {
    final diff = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day)
        .difference(fromDay)
        .inDays;
    if (diff < 0 || diff >= count) continue;
    b[diff].add(t);
  }
  return _out(b);
}

List<KuberBarBucket> _weeks(List<Transaction> txns, DateTime from, DateTime to) {
  final fromDay = DateTime(from.year, from.month, from.day);
  final days = DateTime(to.year, to.month, to.day).difference(fromDay).inDays + 1;
  final weeks = (days / 7).ceil().clamp(1, 1000);
  final b = List.generate(weeks, (i) {
    final start = fromDay.add(Duration(days: i * 7));
    final end = i == weeks - 1 ? to : start.add(const Duration(days: 6));
    // X label is the week number (the old "Week" repeated under every bar).
    return _B('${i + 1}', '${i + 1}', date: start, endDate: end);
  });
  for (final t in txns) {
    final idx = (t.createdAt.difference(fromDay).inDays / 7).floor().clamp(0, weeks - 1);
    b[idx].add(t);
  }
  return _out(b);
}

List<KuberBarBucket> _months(List<Transaction> txns, DateTime from, DateTime to) {
  final diff = (to.year - from.year) * 12 + to.month - from.month;
  final count = (diff + 1).clamp(1, 240);
  final b = List.generate(count, (i) {
    final m = DateTime(from.year, from.month + i, 1);
    final endM = DateTime(m.year, m.month + 1, 0);
    return _B(DateFormat('MMM').format(m), DateFormat('yy').format(m),
        date: m, endDate: endM.isAfter(to) ? to : endM);
  });
  for (final t in txns) {
    final idx = (t.createdAt.year - from.year) * 12 + t.createdAt.month - from.month;
    if (idx < 0 || idx >= count) continue;
    b[idx].add(t);
  }
  return _out(b);
}

List<KuberBarBucket> _quarters(List<Transaction> txns, DateTime from, DateTime to) {
  final fromQ = DateTime(from.year, ((from.month - 1) ~/ 3) * 3 + 1, 1);
  final toQ = DateTime(to.year, ((to.month - 1) ~/ 3) * 3 + 1, 1);
  final diff = (toQ.year - fromQ.year) * 12 + toQ.month - fromQ.month;
  final count = (diff ~/ 3 + 1).clamp(1, 80);
  final b = List.generate(count, (i) {
    final s = DateTime(fromQ.year, fromQ.month + i * 3, 1);
    final e = DateTime(s.year, s.month + 3, 0);
    return _B('Q${((s.month - 1) ~/ 3) + 1}', DateFormat('yy').format(s),
        date: s, endDate: e.isAfter(to) ? to : e);
  });
  for (final t in txns) {
    final tq = DateTime(t.createdAt.year, ((t.createdAt.month - 1) ~/ 3) * 3 + 1, 1);
    final m = (tq.year - fromQ.year) * 12 + tq.month - fromQ.month;
    b[(m ~/ 3).clamp(0, count - 1)].add(t);
  }
  return _out(b);
}

List<KuberBarBucket> _years(List<Transaction> txns, DateTime from, DateTime to) {
  final years = (to.year - from.year + 1).clamp(1, 50);
  final b = List.generate(years, (i) {
    final e = DateTime(from.year + i, 12, 31);
    return _B('${from.year + i}', '',
        date: DateTime(from.year + i, 1, 1), endDate: e.isAfter(to) ? to : e);
  });
  for (final t in txns) {
    b[(t.createdAt.year - from.year).clamp(0, years - 1)].add(t);
  }
  return _out(b);
}
