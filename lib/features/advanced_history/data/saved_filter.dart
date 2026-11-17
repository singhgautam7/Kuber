import 'package:isar_community/isar.dart';

import '../models/ah_view.dart';

part 'saved_filter.g.dart';

/// A saved view ("Saved views" in the UI): the whole Advanced History page.
/// Enums are stored by name so reordering an enum never corrupts data.
/// Included in JSON backups (`savedFilters`).
@collection
class SavedFilter {
  Id id = Isar.autoIncrement;

  /// Unique, case ignored, 40 characters max (enforced by the repository).
  @Index(unique: true, caseSensitive: false)
  late String name;

  /// Canonical query text (source of truth); [astJson] is a cache of its tree.
  late String queryText;
  String? astJson;

  @Enumerated(EnumType.name)
  AhGroupBy groupBy = AhGroupBy.none;

  @Enumerated(EnumType.name)
  AhSortField sortField = AhSortField.date;
  bool sortDescending = true;

  /// In display order ([SavedChart.order] mirrors the index).
  List<SavedChart> charts = [];

  /// [AhKpi] names in display order. Empty = the default set.
  List<String> kpiSelection = [];

  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? lastUsedAt;
}

@embedded
class SavedChart {
  int order = 0;

  @Enumerated(EnumType.name)
  AhChartType type = AhChartType.donut;

  @Enumerated(EnumType.name)
  AhChartSplit split = AhChartSplit.category;

  @Enumerated(EnumType.name)
  AhChartMeasure measure = AhChartMeasure.total;

  /// [AhChartSplit] name of the compared values, null = none.
  String? seriesBy;

  /// Compared group keys, at most [kAhMaxSeries].
  List<String> series = [];
}
