// CONTRACT FILE. Owned by H-data. Result shapes the dashboard renders.

import '../../transactions/data/transaction.dart';
import '../models/ah_view.dart';

/// Income / expense follow the Analytics rules (same function Analytics
/// uses); transfers count in [transactions] only.
class AhKpis {
  const AhKpis({
    required this.transactions,
    required this.income,
    required this.expense,
    required this.average,
    required this.attachments,
    required this.largest,
  });
  final int transactions;
  final double income;
  final double expense;
  double get net => income - expense;

  /// Average of all matching absolute amounts.
  final double average;

  /// Transactions with at least one attachment.
  final int attachments;

  /// Largest absolute amount.
  final double largest;

  static const empty = AhKpis(
      transactions: 0, income: 0, expense: 0, average: 0, attachments: 0, largest: 0);
}

/// One group row. [key] is the group's id as a string (category id, account
/// id, tag id, type name, source name, `2026-03`, `2026`), or `''` for
/// "No category" / "Untagged".
class AhGroupRow {
  const AhGroupRow({
    required this.by,
    required this.key,
    required this.label,
    required this.count,
    required this.total,
    required this.share,
    this.colorValue,
    this.icon,
  });
  final AhGroupBy by;
  final String key;
  final String label;
  final int count;
  final double total;

  /// 0..1 against the overall total (tag shares can add up to more than 1).
  final double share;
  final int? colorValue;
  final String? icon;
}

class AhGroups {
  const AhGroups(this.rows, {this.multiTagNote = false});
  final List<AhGroupRow> rows;

  /// True when grouped by tag and some transaction sits in several groups.
  final bool multiTagNote;
}

/// A page of transactions, newest first unless sorted otherwise.
class AhTxnPage {
  const AhTxnPage(this.items, {required this.hasMore, required this.total});
  final List<Transaction> items;
  final bool hasMore;
  final int total;
}

class AhChartPoint {
  const AhChartPoint(this.key, this.label, this.value, {this.colorValue});
  final String key;
  final String label;
  final double value;
  final int? colorValue;
}

/// In-card states (never a dialog).
enum AhChartState { ok, loading, notEnoughData, nothingToSplit, wrongCombo, noResults }

/// One compared value of a stacked-bar / multi-line chart: its value in
/// each of the chart's points (months or years), in the same order.
class AhChartSeries {
  const AhChartSeries(this.key, this.label, this.values, {this.colorValue});
  final String key;
  final String label;
  final List<double> values;
  final int? colorValue;
}

class AhChartData {
  const AhChartData(this.state,
      {this.points = const [], this.count = 0, this.series = const []});
  final AhChartState state;

  /// Compared values (empty for a plain chart). Points then hold the months
  /// or years and their summed value.
  final List<AhChartSeries> series;

  /// Donut: at most 6, the rest merged into "Other" (key `__other`).
  final List<AhChartPoint> points;
  final int count;
}

/// Why a split is disabled in the chart builder (null = available).
enum AhSplitBlock { noTags, oneAccount, oneType, oneSource, oneCategory, oneMonth, oneYear }
