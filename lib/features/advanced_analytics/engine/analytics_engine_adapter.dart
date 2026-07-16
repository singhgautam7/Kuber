import 'dart:math' as math;

import 'package:intl/intl.dart';

// The Advanced Analytics engine. Each analytical section has its own
// calculator in a sibling file, joined into this one library via `part` so the
// small shared helpers below (`_summary`, `_monthly`, `_Txn`, ...) stay
// library-private and are reused, not duplicated. Every calculator is pure and
// runs off the main thread via `compute()` from the section providers, so the
// only inputs are the plain-map [AnalyticsInput] snapshots (Isar rows cannot
// cross an isolate boundary). Nothing here touches Riverpod, Isar or Flutter.
part 'monthly_ledger_calculator.dart';
part 'trends_calculator.dart';
part 'patterns_analyzer.dart';
part 'forecast_engine.dart';
part 'merchant_analyzer.dart';
part 'savings_rate_calculator.dart';
part 'financial_health_scorer.dart';
part 'anomaly_detector.dart';
part 'category_deep_dive_calculator.dart';

class AnalyticsRange {
  final DateTime from;
  final DateTime to;

  const AnalyticsRange(this.from, this.to);

  int get inclusiveDays =>
      DateTime(
        to.year,
        to.month,
        to.day,
      ).difference(DateTime(from.year, from.month, from.day)).inDays +
      1;
}

class AnalyticsInput {
  final List<Map<String, Object?>> transactions;
  final List<Map<String, Object?>> categories;
  final List<Map<String, Object?>> budgets;
  final List<Map<String, Object?>> accounts;
  final Map<int, double> balances;
  final List<Map<String, Object?>> loans;
  final List<Map<String, Object?>> recurringRules;
  final AnalyticsRange range;
  final String? selectedCategoryId;
  final DateTime now;
  final String mode;

  const AnalyticsInput({
    required this.transactions,
    required this.categories,
    required this.budgets,
    required this.accounts,
    required this.balances,
    required this.loans,
    required this.recurringRules,
    required this.range,
    required this.now,
    this.selectedCategoryId,
    this.mode = 'mom',
  });
}

// ---------------------------------------------------------------------------
// Shared private helpers, used across two or more calculators. Calculator-only
// helpers (e.g. `_median`, `_weekdayName`, the subscore helpers) live next to
// their single caller instead.
// ---------------------------------------------------------------------------

_Summary _summary(
  List<Map<String, Object?>> txns,
  DateTime start,
  DateTime end,
) {
  var income = 0.0;
  var expense = 0.0;
  var count = 0;
  final categorySpend = <String, double>{};
  for (final t in txns) {
    final row = _Txn(t);
    if (_skip(row) || row.date.isBefore(start) || !row.date.isBefore(end)) {
      continue;
    }
    count++;
    if (row.type == 'income') {
      income += row.amount;
    } else if (row.type == 'expense') {
      expense += row.amount;
      categorySpend[row.categoryId] =
          (categorySpend[row.categoryId] ?? 0) + row.amount;
    }
  }
  return _Summary(income, expense, count, categorySpend);
}

List<_Txn> _expensesInRange(
  List<Map<String, Object?>> txns,
  AnalyticsRange range,
) {
  final end = _endInclusive(range.to);
  return txns
      .map(_Txn.new)
      .where(
        (t) =>
            t.type == 'expense' &&
            !_skip(t) &&
            !t.date.isBefore(range.from) &&
            t.date.isBefore(end),
      )
      .toList();
}

bool _skip(_Txn t) => t.isTransfer || t.isBalanceAdjustment;

DateTime _endInclusive(DateTime d) =>
    DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

DateTime _date(Object? value) {
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

int _trackedMonths(List<Map<String, Object?>> txns) {
  final months = <String>{};
  for (final t in txns.map(_Txn.new).where((t) => !_skip(t))) {
    months.add('${t.date.year}-${t.date.month}');
  }
  return months.length;
}

class _Txn {
  final Map<String, Object?> map;
  _Txn(this.map);

  String get name => (map['name'] as String?)?.trim().isEmpty ?? true
      ? 'Unknown merchant'
      : map['name'] as String;
  double get amount => (map['amount'] as num).toDouble();
  String get type => map['type'] as String;
  String get categoryId => map['categoryId'] as String;
  DateTime get date => _date(map['createdAt']);
  String? get linkedRuleType => map['linkedRuleType'] as String?;
  bool get isTransfer => map['isTransfer'] as bool? ?? false;
  bool get isBalanceAdjustment => map['isBalanceAdjustment'] as bool? ?? false;
}

class _Summary {
  final double income;
  final double expense;
  final int count;
  final Map<String, double> categorySpend;

  const _Summary(this.income, this.expense, this.count, this.categorySpend);
}
