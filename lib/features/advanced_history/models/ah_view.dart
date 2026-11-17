// CONTRACT FILE. Owned by H-data. The dashboard state: filter, group, sort,
// charts and KPI cards. A saved view stores exactly this.

import 'package:flutter/foundation.dart' show listEquals;

import '../query/query_ast.dart';

/// `day` is never offered as a grouping: it opens one heatmap day.
enum AhGroupBy { none, category, account, tag, type, source, month, year, day }

/// Ungrouped: date, amount, category, account. Grouped: total, count, name.
enum AhSortField { date, amount, category, account, total, count, name }

class AhSort {
  const AhSort(this.field, {this.descending = true});
  final AhSortField field;
  final bool descending;

  static const ungroupedDefault = AhSort(AhSortField.date);
  static const groupedDefault = AhSort(AhSortField.total);

  /// This sort if its field fits [g] (grouped: total / count / name;
  /// ungrouped: the rest), else [g]'s default. Guards restored views.
  AhSort fitFor(AhGroupBy g) {
    const grouped = {AhSortField.total, AhSortField.count, AhSortField.name};
    if ((g != AhGroupBy.none) == grouped.contains(field)) return this;
    return g == AhGroupBy.none ? ungroupedDefault : groupedDefault;
  }

  bool isDefaultFor(AhGroupBy g) =>
      this == (g == AhGroupBy.none ? ungroupedDefault : groupedDefault);

  @override
  bool operator ==(Object other) =>
      other is AhSort && other.field == field && other.descending == descending;
  @override
  int get hashCode => Object.hash(field, descending);
}

/// Stored by name: append only.
enum AhChartType { donut, bars, line, heatmap }

/// At most this many compared values (stacked in a bar, or lines).
const kAhMaxSeries = 3;

/// Line allows only month and year.
enum AhChartSplit { category, account, tag, type, source, month, year }

enum AhChartMeasure { total, count, average }

class AhChartSpec {
  const AhChartSpec(this.type, this.split, this.measure,
      {this.seriesBy, this.series = const []});
  final AhChartType type;
  final AhChartSplit split;
  final AhChartMeasure measure;

  /// Bars and line only: compare up to [kAhMaxSeries] values of [seriesBy]
  /// (category, account, tag, type or source) over months or years. Bars
  /// stack them in one bar, the line draws one line each. [series] holds
  /// their group keys (category id, account id, tag id, type name...).
  final AhChartSplit? seriesBy;
  final List<String> series;

  bool get isSeries =>
      seriesBy != null &&
      series.isNotEmpty &&
      (type == AhChartType.bars || type == AhChartType.line);

  AhChartSpec copyWith({
    AhChartType? type,
    AhChartSplit? split,
    AhChartMeasure? measure,
  }) =>
      AhChartSpec(type ?? this.type, split ?? this.split, measure ?? this.measure,
          seriesBy: seriesBy, series: series);

  @override
  bool operator ==(Object other) =>
      other is AhChartSpec &&
      other.type == type &&
      other.split == split &&
      other.measure == measure &&
      other.seriesBy == seriesBy &&
      listEquals(other.series, series);
  @override
  int get hashCode =>
      Object.hash(type, split, measure, seriesBy, Object.hashAll(series));
}

enum AhKpi { transactions, income, expense, net, average, attachments, largest }

const kAhDefaultKpis = AhKpi.values;
const kAhMaxCharts = 4;

class AhView {
  const AhView({
    this.queryText = '',
    this.node,
    this.groupBy = AhGroupBy.none,
    this.sort = AhSort.ungroupedDefault,
    this.charts = const [],
    this.kpis = kAhDefaultKpis,
    this.savedId,
  });

  /// Canonical filter text; [node] is its last valid tree (null = no filter).
  final String queryText;
  final QueryNode? node;
  final AhGroupBy groupBy;
  final AhSort sort;
  final List<AhChartSpec> charts;
  final List<AhKpi> kpis;

  /// The saved view this one came from, if any.
  final int? savedId;

  /// Start screen: nothing to query (no filter, no grouping). No query runs.
  bool get isStart => node == null && groupBy == AhGroupBy.none;

  /// Clear all is shown when any of these is set.
  bool get hasAnything =>
      node != null ||
      groupBy != AhGroupBy.none ||
      !sort.isDefaultFor(groupBy) ||
      charts.isNotEmpty;

  AhView copyWith({
    String? queryText,
    QueryNode? node,
    bool clearNode = false,
    AhGroupBy? groupBy,
    AhSort? sort,
    List<AhChartSpec>? charts,
    List<AhKpi>? kpis,
    int? savedId,
    bool clearSaved = false,
  }) =>
      AhView(
        queryText: queryText ?? this.queryText,
        node: clearNode ? null : (node ?? this.node),
        groupBy: groupBy ?? this.groupBy,
        sort: sort ?? this.sort,
        charts: charts ?? this.charts,
        kpis: kpis ?? this.kpis,
        savedId: clearSaved ? null : (savedId ?? this.savedId),
      );
}
