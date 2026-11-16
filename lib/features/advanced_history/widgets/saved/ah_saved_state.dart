import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../data/saved_filter.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../../query/query_ast.dart';
import '../common/ah_common.dart';

/// The saved view the page currently shows, if it still exists.
final ahOpenSavedProvider = Provider.autoDispose<SavedFilter?>((ref) {
  final id = ref.watch(ahViewProvider.select((v) => v.savedId));
  if (id == null) return null;
  final list = ref.watch(savedFiltersProvider).valueOrNull;
  if (list == null) return null;
  for (final f in list) {
    if (f.id == id) return f;
  }
  return null;
});

QueryNode? _nodeOf(SavedFilter f) {
  final j = f.astJson;
  if (j == null || j.isEmpty) return null;
  try {
    return QueryNode.fromJson(Map<String, dynamic>.from(jsonDecode(j) as Map));
  } catch (_) {
    return null;
  }
}

String ahSavedSummary(AppLocalizations l, SavedFilter f) => ahSummaryLine(
      l,
      filters: ahFilterCount(_nodeOf(f)),
      group: f.groupBy,
      sort: AhSort(f.sortField, descending: f.sortDescending),
      charts: f.charts.length,
    );
