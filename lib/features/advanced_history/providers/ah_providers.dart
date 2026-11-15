// CONTRACT STUB. Owned by H-data, who implements every provider body.
// H-token and H-UI watch these by name. Nothing here may run a query for
// the start state (view.isStart) or for users without Pro.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/saved_filter.dart';
import '../models/ah_view.dart';
import '../query/query_ast.dart';
import '../services/ah_results.dart';

/// The current view, kept for the session (not autoDispose).
/// H-data adds the mutators (setFilter, setGroup, setSort, add / update /
/// remove / move chart, setKpis, applySaved, clearAll, markSaved) and the
/// "what changed since the saved view" list for the change bar.
final ahViewProvider =
    NotifierProvider<AhViewNotifier, AhView>(AhViewNotifier.new);

class AhViewNotifier extends Notifier<AhView> {
  @override
  AhView build() => const AhView();

  /// Parses [queryText]; keeps the last valid node when it doesn't parse.
  void setFilter(String queryText) => throw UnimplementedError();
  void setGroup(AhGroupBy g) => throw UnimplementedError();
  void setSort(AhSort s) => throw UnimplementedError();
  void addChart(AhChartSpec c) => throw UnimplementedError();
  void updateChart(int index, AhChartSpec c) => throw UnimplementedError();
  void insertChart(int index, AhChartSpec c) => throw UnimplementedError();
  AhChartSpec removeChart(int index) => throw UnimplementedError();
  void moveChart(int from, int to) => throw UnimplementedError();
  void setKpis(List<AhKpi> kpis) => throw UnimplementedError();

  /// Applies a whole view (example chips, undo).
  void applyView(AhView v) => throw UnimplementedError();
  void applySaved(SavedFilter f) => throw UnimplementedError();

  /// Clears filter, group, sort and charts; keeps the KPI choice.
  void clearAll() => throw UnimplementedError();
}

/// What changed since the open saved view (empty = nothing / no saved view).
enum AhChange { filter, group, sort, kpis, chartAdded, chartRemoved, chartMoved, chartEdited }

final ahChangesProvider =
    Provider.autoDispose<List<AhChange>>((ref) => throw UnimplementedError());

/// Saved views CRUD. Names: required, 40 max, unique ignoring case.
final savedFilterRepositoryProvider =
    Provider<SavedFilterRepository>((ref) => throw UnimplementedError());

abstract class SavedFilterRepository {
  Future<bool> nameTaken(String name, {int? exceptId});
  Future<SavedFilter> saveNew(String name, AhView view);
  Future<void> saveChanges(int id, AhView view);
  Future<void> rename(int id, String name);
  Future<void> delete(int id);
  Future<void> markUsed(int id);
}

/// KPIs for the current view; null for the start state.
final ahKpisProvider =
    FutureProvider.autoDispose<AhKpis?>((ref) => throw UnimplementedError());

/// Groups for the current view; null when not grouped or start state.
final ahGroupsProvider =
    FutureProvider.autoDispose<AhGroups?>((ref) => throw UnimplementedError());

/// Paginated transactions (50 a page) for the current view, or for one
/// group when [AhGroupKey] is given (group sheet).
final ahTxnPagesProvider = AsyncNotifierProvider.autoDispose
    .family<AhTxnPagesNotifier, AhTxnPage, AhGroupKey?>(AhTxnPagesNotifier.new);

class AhTxnPagesNotifier
    extends AutoDisposeFamilyAsyncNotifier<AhTxnPage, AhGroupKey?> {
  @override
  Future<AhTxnPage> build(AhGroupKey? arg) => throw UnimplementedError();

  /// Appends the next 50. No-op while loading or when !hasMore.
  Future<void> loadMore() => throw UnimplementedError();
}

class AhGroupKey {
  const AhGroupKey(this.by, this.key);
  final AhGroupBy by;
  final String key;
  @override
  bool operator ==(Object o) => o is AhGroupKey && o.by == by && o.key == key;
  @override
  int get hashCode => Object.hash(by, key);
}

/// KPIs of one group (group sheet).
final ahGroupKpisProvider = FutureProvider.autoDispose
    .family<AhKpis, AhGroupKey>((ref, key) => throw UnimplementedError());

/// Data for one chart card, computed off the UI thread, in parallel with
/// the results.
final ahChartDataProvider = FutureProvider.autoDispose
    .family<AhChartData, AhChartSpec>((ref, spec) => throw UnimplementedError());

/// Which splits are blocked for the current results (chart builder), from a
/// cheap distinct-count query.
final ahSplitBlocksProvider = FutureProvider.autoDispose<
    Map<AhChartSplit, AhSplitBlock>>((ref) => throw UnimplementedError());

/// Live count for the Filter page draft. The page debounces (300 ms) and
/// passes the draft's valid node; stale counts are dropped.
final ahCountProvider = FutureProvider.autoDispose
    .family<int, QueryNode?>((ref, node) => throw UnimplementedError());

/// Autocomplete: the user's values for a field with counts, prefix-matched
/// case-insensitively, cached, computed off the UI thread.
final ahSuggestionsProvider = FutureProvider.autoDispose
    .family<List<AhSuggestion>, AhSuggestionQuery>(
        (ref, q) => throw UnimplementedError());

class AhSuggestionQuery {
  const AhSuggestionQuery(this.field, this.prefix);

  /// Null = suggest field names.
  final QueryField? field;
  final String prefix;
  @override
  bool operator ==(Object o) =>
      o is AhSuggestionQuery && o.field == field && o.prefix == prefix;
  @override
  int get hashCode => Object.hash(field, prefix);
}

class AhSuggestion {
  const AhSuggestion(this.value, this.label, {this.count, this.hint});

  /// Text inserted into the token (`food`, `"Food & Dining"`, `category:`).
  final String value;
  final String label;
  final int? count;
  final String? hint;
}

/// Saved views, last used first.
final savedFiltersProvider = StreamProvider.autoDispose<List<SavedFilter>>(
    (ref) => throw UnimplementedError());
