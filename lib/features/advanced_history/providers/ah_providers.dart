// Advanced History state and queries.
//
// * [ahViewProvider] holds the dashboard state (filter, group, sort, charts,
//   KPI choice). A saved view is exactly this.
// * One internal bundle job per view computes KPIs, groups, the first page,
//   every chart and the split blocks on a helper isolate (one isolate, one
//   match). The public providers read from it. Stale views are dropped by
//   autoDispose (a newer view rebuilds the bundle; Riverpod ignores the old
//   future), pagination by a generation counter.
// * The start state (`view.isStart`) runs no query anywhere.
//
// Entry is Pro-gated by `openAdvancedHistory`; these providers don't re-check.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../tags/data/transaction_tag.dart';
import '../../transactions/data/transaction.dart';
import '../data/saved_filter.dart';
import '../models/ah_view.dart';
import '../query/query_ast.dart';
import '../query/query_parser.dart';
import '../services/ah_engine.dart';
import '../services/ah_results.dart';

/// Injectable clock for relative dates (`thismonth`, `last30d`).
final ahClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Global KPI choice outside a saved view.
const kAhKpiPrefKey = 'ah_kpi_selection';

// ---------------------------------------------------------------------------
// View state

final ahViewProvider =
    NotifierProvider<AhViewNotifier, AhView>(AhViewNotifier.new);

class AhViewNotifier extends Notifier<AhView> {
  bool _kpiTouched = false;

  /// Advanced History pages on the navigator stack (filter page on top
  /// still counts: the page under it stays mounted).
  static int openPages = 0;

  @override
  AhView build() {
    _loadKpiPref();
    // Leaving the app ("closing" it on Android keeps the process) while the
    // page isn't open starts the next visit on an empty page; the KPI choice
    // is kept. Switching apps with the page open keeps the dashboard.
    try {
      final life = AppLifecycleListener(onHide: () {
        if (openPages == 0 && !state.isStart) clearAll();
      });
      ref.onDispose(life.dispose);
    } catch (_) {
      // No widgets binding (pure provider tests).
    }
    return const AhView();
  }

  // Loaded on first use of the page (this provider is first read there).
  Future<void> _loadKpiPref() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final names = prefs.getStringList(kAhKpiPrefKey);
      if (names == null || _kpiTouched || state.savedId != null) return;
      final k = kpisFromNames(names);
      if (!listEquals(k, state.kpis)) state = state.copyWith(kpis: k);
    } catch (_) {}
  }

  /// Parses [queryText]. Valid (or empty) text replaces the filter and
  /// returns true; invalid text leaves the last valid filter in place and
  /// returns false.
  bool setFilter(String queryText) {
    final items = tokenize(queryText);
    if (items.isEmpty) {
      state = state.copyWith(queryText: '', clearNode: true);
      return true;
    }
    final r = parseItems(items);
    if (!r.isValid || r.node == null) return false;
    state = state.copyWith(queryText: serializeItems(items), node: r.node);
    return true;
  }

  void setGroup(AhGroupBy g) {
    if (g == state.groupBy) return;
    final wasNone = state.groupBy == AhGroupBy.none;
    final sort = (wasNone || g == AhGroupBy.none)
        ? (g == AhGroupBy.none ? AhSort.ungroupedDefault : AhSort.groupedDefault)
        : state.sort;
    state = state.copyWith(groupBy: g, sort: sort);
  }

  void setSort(AhSort s) => state = state.copyWith(sort: s);

  void addChart(AhChartSpec c) {
    if (state.charts.length >= kAhMaxCharts) return;
    // At the top, just under the Add chart button.
    state = state.copyWith(charts: [c, ...state.charts]);
  }

  void updateChart(int index, AhChartSpec c) {
    if (index < 0 || index >= state.charts.length) return;
    final l = [...state.charts]..[index] = c;
    state = state.copyWith(charts: l);
  }

  void insertChart(int index, AhChartSpec c) {
    if (state.charts.length >= kAhMaxCharts) return;
    final l = [...state.charts]..insert(index.clamp(0, state.charts.length), c);
    state = state.copyWith(charts: l);
  }

  AhChartSpec removeChart(int index) {
    final l = [...state.charts];
    final c = l.removeAt(index);
    state = state.copyWith(charts: l);
    return c;
  }

  /// Moves the chart at [from] so it ends up at index [to].
  void moveChart(int from, int to) {
    final n = state.charts.length;
    if (from < 0 || from >= n || to < 0 || to >= n || from == to) return;
    final l = [...state.charts];
    l.insert(to, l.removeAt(from));
    state = state.copyWith(charts: l);
  }

  void setKpis(List<AhKpi> kpis) {
    final k = kpis.toSet().isEmpty ? kAhDefaultKpis : kpis.toSet().toList();
    state = state.copyWith(kpis: k);
    if (state.savedId == null) {
      _kpiTouched = true;
      SharedPreferences.getInstance()
          .then((p) => p.setStringList(kAhKpiPrefKey, [for (final x in k) x.name]))
          .catchError((_) => false);
    }
  }

  /// Applies a whole view (example chips, undo).
  void applyView(AhView v) => state = v.copyWith(sort: v.sort.fitFor(v.groupBy));

  void applySaved(SavedFilter f) {
    state = viewFromSaved(f);
    ref.read(savedFilterRepositoryProvider).markUsed(f.id).catchError((_) {});
  }

  /// Marks the open view as the saved view [id] (after saveNew).
  void markSaved(int id) => state = state.copyWith(savedId: id);

  /// The open saved view was deleted: keep the page, drop the link.
  void detachSaved() => state = state.copyWith(clearSaved: true);

  /// Clears filter, group, sort and charts; keeps the KPI choice.
  void clearAll() => state = AhView(kpis: state.kpis);
}

List<AhKpi> kpisFromNames(List<String> names) {
  final out = <AhKpi>[];
  for (final n in names) {
    final k = AhKpi.values.where((e) => e.name == n).firstOrNull;
    if (k != null && !out.contains(k)) out.add(k);
  }
  return out.isEmpty ? kAhDefaultKpis : out;
}

/// The view a saved record restores (everything, charts in order).
AhView viewFromSaved(SavedFilter f) {
  final items = tokenize(f.queryText);
  var r = parseItems(items);
  QueryNode? node = r.isValid ? r.node : null;
  if (node == null && f.astJson != null && items.isNotEmpty) {
    try {
      node = QueryNode.fromJson(
          Map<String, dynamic>.from(jsonDecode(f.astJson!) as Map));
    } catch (_) {}
  }
  final charts = [...f.charts]..sort((a, b) => a.order.compareTo(b.order));
  return AhView(
    queryText: node == null ? '' : f.queryText,
    node: node,
    groupBy: f.groupBy,
    sort: AhSort(f.sortField, descending: f.sortDescending).fitFor(f.groupBy),
    charts: [
      for (final c in charts)
        AhChartSpec(c.type, c.split, c.measure,
            seriesBy: AhChartSplit.values
                .where((e) => e.name == c.seriesBy)
                .firstOrNull,
            series: List.of(c.series)),
    ],
    kpis: kpisFromNames(f.kpiSelection),
    savedId: f.id,
  );
}

// ---------------------------------------------------------------------------
// Changes since the open saved view

enum AhChange { filter, group, sort, kpis, chartAdded, chartRemoved, chartMoved, chartEdited }

/// Diff of [v] against the saved record [f] (empty = same).
List<AhChange> diffViewWithSaved(AhView v, SavedFilter f) {
  final s = viewFromSaved(f);
  final out = <AhChange>[];
  if (serializeItems(tokenize(v.queryText)) !=
      serializeItems(tokenize(s.queryText))) {
    out.add(AhChange.filter);
  }
  if (v.groupBy != s.groupBy) out.add(AhChange.group);
  if (v.sort != s.sort) out.add(AhChange.sort);
  if (!listEquals(v.kpis, s.kpis)) out.add(AhChange.kpis);
  // Charts: what was added / removed as multisets, then order.
  final removed = [...s.charts];
  final added = <AhChartSpec>[];
  for (final c in v.charts) {
    if (!removed.remove(c)) added.add(c);
  }
  if (added.isNotEmpty && removed.isNotEmpty) out.add(AhChange.chartEdited);
  if (added.length > removed.length) out.add(AhChange.chartAdded);
  if (removed.length > added.length) out.add(AhChange.chartRemoved);
  if (added.isEmpty && removed.isEmpty && !listEquals(v.charts, s.charts)) {
    out.add(AhChange.chartMoved);
  }
  return out;
}

/// What changed since the open saved view (empty = nothing / no saved view).
final ahChangesProvider = Provider.autoDispose<List<AhChange>>((ref) {
  final v = ref.watch(ahViewProvider);
  final id = v.savedId;
  if (id == null) return const [];
  final f = ref
      .watch(savedFiltersProvider)
      .valueOrNull
      ?.where((x) => x.id == id)
      .firstOrNull;
  return f == null ? const [] : diffViewWithSaved(v, f);
});

// ---------------------------------------------------------------------------
// Saved views

enum SavedFilterNameProblem { empty, tooLong, taken }

class SavedFilterNameException implements Exception {
  const SavedFilterNameException(this.problem);
  final SavedFilterNameProblem problem;
  @override
  String toString() => 'SavedFilterNameException($problem)';
}

const kAhNameMax = 40;

/// Saved views CRUD. Names: required, 40 max, unique ignoring case; a bad
/// name throws [SavedFilterNameException].
final savedFilterRepositoryProvider = Provider<SavedFilterRepository>((ref) {
  return IsarSavedFilterRepository(
    ref.watch(isarProvider),
    onDeleted: (id) {
      if (ref.read(ahViewProvider).savedId == id) {
        ref.read(ahViewProvider.notifier).detachSaved();
      }
    },
  );
});

abstract class SavedFilterRepository {
  Future<bool> nameTaken(String name, {int? exceptId});
  Future<SavedFilter> saveNew(String name, AhView view);
  /// Writes [view] over the saved view [id] and returns the view it
  /// replaced (read in the same write, so Undo can put exactly that back),
  /// or null when [id] is gone.
  Future<AhView?> saveChanges(int id, AhView view);
  Future<void> rename(int id, String name);
  Future<void> delete(int id);
  Future<void> markUsed(int id);
}

class IsarSavedFilterRepository implements SavedFilterRepository {
  IsarSavedFilterRepository(this.isar, {this.onDeleted});
  final Isar isar;
  final void Function(int id)? onDeleted;

  Future<void> _check(String name, {int? exceptId}) async {
    if (name.isEmpty) {
      throw const SavedFilterNameException(SavedFilterNameProblem.empty);
    }
    if (name.length > kAhNameMax) {
      throw const SavedFilterNameException(SavedFilterNameProblem.tooLong);
    }
    if (await nameTaken(name, exceptId: exceptId)) {
      throw const SavedFilterNameException(SavedFilterNameProblem.taken);
    }
  }

  @override
  Future<bool> nameTaken(String name, {int? exceptId}) async {
    final hit = await isar.savedFilters
        .filter()
        .nameEqualTo(name.trim(), caseSensitive: false)
        .findFirst();
    return hit != null && hit.id != exceptId;
  }

  static void _fill(SavedFilter f, AhView v) {
    f.queryText = v.queryText;
    f.astJson = v.node == null ? null : jsonEncode(v.node!.toJson());
    f.groupBy = v.groupBy;
    f.sortField = v.sort.field;
    f.sortDescending = v.sort.descending;
    f.charts = [
      for (var i = 0; i < v.charts.length; i++)
        SavedChart()
          ..order = i
          ..type = v.charts[i].type
          ..split = v.charts[i].split
          ..measure = v.charts[i].measure
          ..seriesBy = v.charts[i].seriesBy?.name
          ..series = List.of(v.charts[i].series)
    ];
    f.kpiSelection = [for (final k in v.kpis) k.name];
  }

  @override
  Future<SavedFilter> saveNew(String name, AhView view) async {
    final n = name.trim();
    await _check(n);
    final now = DateTime.now();
    final f = SavedFilter()
      ..name = n
      ..createdAt = now
      ..updatedAt = now
      ..lastUsedAt = now;
    _fill(f, view);
    await isar.writeTxn(() => isar.savedFilters.put(f));
    return f;
  }

  @override
  Future<AhView?> saveChanges(int id, AhView view) async {
    AhView? before;
    await isar.writeTxn(() async {
      final f = await isar.savedFilters.get(id);
      if (f == null) return;
      before = viewFromSaved(f);
      _fill(f, view);
      f.updatedAt = DateTime.now();
      await isar.savedFilters.put(f);
    });
    return before;
  }

  @override
  Future<void> rename(int id, String name) async {
    final n = name.trim();
    await _check(n, exceptId: id);
    await isar.writeTxn(() async {
      final f = await isar.savedFilters.get(id);
      if (f == null) return;
      f.name = n;
      f.updatedAt = DateTime.now();
      await isar.savedFilters.put(f);
    });
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() => isar.savedFilters.delete(id));
    onDeleted?.call(id);
  }

  @override
  Future<void> markUsed(int id) => isar.writeTxn(() async {
        final f = await isar.savedFilters.get(id);
        if (f == null) return;
        f.lastUsedAt = DateTime.now();
        await isar.savedFilters.put(f);
      });
}

/// Saved views, last used first.
final savedFiltersProvider = StreamProvider.autoDispose<List<SavedFilter>>((ref) async* {
  final isar = ref.watch(isarProvider);
  await for (final _ in isar.savedFilters.watchLazy(fireImmediately: true)) {
    final all = await isar.savedFilters.where().findAll();
    all.sort((a, b) {
      final x = a.lastUsedAt ?? a.createdAt;
      final y = b.lastUsedAt ?? b.createdAt;
      return y.compareTo(x);
    });
    yield all;
  }
});

// ---------------------------------------------------------------------------
// Transactions changed signal (read-only)

class _ChangeCounter extends Notifier<int> {
  @override
  int build() {
    final isar = ref.watch(isarProvider);
    Timer? debounce;
    void bump(void _) {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 120), () => state++);
    }

    final subs = [
      isar.transactions.watchLazy().listen(bump),
      isar.transactionTags.watchLazy().listen(bump),
    ];
    ref.onDispose(() {
      debounce?.cancel();
      for (final s in subs) {
        s.cancel();
      }
    });
    return 0;
  }
}

final _ahChangeProvider = NotifierProvider<_ChangeCounter, int>(_ChangeCounter.new);

// ---------------------------------------------------------------------------
// Results

class _QueryKey {
  _QueryKey(AhView v)
      : node = v.node,
        json = v.node == null ? '' : jsonEncode(v.node!.toJson()),
        groupBy = v.groupBy,
        sort = v.sort,
        charts = v.charts;
  final QueryNode? node;
  final String json;
  final AhGroupBy groupBy;
  final AhSort sort;
  final List<AhChartSpec> charts;

  bool get isStart => node == null && groupBy == AhGroupBy.none;

  @override
  bool operator ==(Object other) =>
      other is _QueryKey &&
      other.json == json &&
      other.groupBy == groupBy &&
      other.sort == sort &&
      listEquals(other.charts, charts);
  @override
  int get hashCode => Object.hash(json, groupBy, sort, Object.hashAll(charts));
}

final _ahBundleProvider = FutureProvider.autoDispose<AhBundle?>((ref) async {
  final key = ref.watch(ahViewProvider.select(_QueryKey.new));
  ref.watch(_ahChangeProvider);
  if (key.isStart) return null;
  final isar = ref.watch(isarProvider);
  final now = ref.read(ahClockProvider)();
  return runAh(isar, AhBundleParams(key.node, key.groupBy, key.sort, key.charts, now),
      ahBundleJob);
});

const _emptyPage = AhTxnPage([], hasMore: false, total: 0);

/// KPIs for the current view; null for the start state.
final ahKpisProvider = FutureProvider.autoDispose<AhKpis?>((ref) async {
  return (await ref.watch(_ahBundleProvider.future))?.kpis;
});

/// Groups for the current view; null when not grouped or start state.
final ahGroupsProvider = FutureProvider.autoDispose<AhGroups?>((ref) async {
  return (await ref.watch(_ahBundleProvider.future))?.groups;
});

class AhGroupKey {
  const AhGroupKey(this.by, this.key);
  final AhGroupBy by;
  final String key;
  @override
  bool operator ==(Object other) => other is AhGroupKey && other.by == by && other.key == key;
  @override
  int get hashCode => Object.hash(by, key);
}

/// Paginated transactions (50 a page) for the current view, or for one
/// group when [AhGroupKey] is given (group sheet, newest first).
final ahTxnPagesProvider = AsyncNotifierProvider.autoDispose
    .family<AhTxnPagesNotifier, AhTxnPage, AhGroupKey?>(AhTxnPagesNotifier.new);

class AhTxnPagesNotifier
    extends AutoDisposeFamilyAsyncNotifier<AhTxnPage, AhGroupKey?> {
  int _gen = 0;
  bool _loading = false;

  @override
  Future<AhTxnPage> build(AhGroupKey? arg) async {
    _gen++;
    _loading = false;
    if (arg == null) {
      return (await ref.watch(_ahBundleProvider.future))?.page ?? _emptyPage;
    }
    final key = ref.watch(ahViewProvider.select(_QueryKey.new));
    ref.watch(_ahChangeProvider);
    return runAh(
        ref.watch(isarProvider),
        AhPageParams(key.node, key.sort, ref.read(ahClockProvider)(), 0,
            by: arg.by, key: arg.key),
        ahPageJob);
  }

  /// Appends the next 50. No-op while loading or when !hasMore.
  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || !cur.hasMore || _loading) return;
    final gen = _gen;
    _loading = true;
    try {
      final v = ref.read(ahViewProvider);
      final next = await runAh(
          ref.read(isarProvider),
          AhPageParams(v.node, v.sort, ref.read(ahClockProvider)(), cur.items.length,
              by: arg?.by, key: arg?.key),
          ahPageJob);
      if (gen != _gen) return; // a newer view / data change rebuilt us
      state = AsyncData(AhTxnPage([...cur.items, ...next.items],
          hasMore: next.hasMore, total: next.total));
    } finally {
      _loading = false;
    }
  }
}

/// KPIs of one group (group sheet).
final ahGroupKpisProvider =
    FutureProvider.autoDispose.family<AhKpis, AhGroupKey>((ref, g) {
  final key = ref.watch(ahViewProvider.select(_QueryKey.new));
  ref.watch(_ahChangeProvider);
  return runAh(
      ref.watch(isarProvider),
      AhPageParams(key.node, key.sort, ref.read(ahClockProvider)(), 0,
          by: g.by, key: g.key),
      ahGroupKpisJob);
});

/// Data for one chart card, computed off the UI thread together with the
/// results. A spec that isn't one of the view's charts (builder preview)
/// gets its own job.
final ahChartDataProvider =
    FutureProvider.autoDispose.family<AhChartData, AhChartSpec>((ref, spec) async {
  final key = ref.watch(ahViewProvider.select(_QueryKey.new));
  if (key.isStart) return const AhChartData(AhChartState.noResults);
  if (key.charts.contains(spec)) {
    final b = await ref.watch(_ahBundleProvider.future);
    final d = b?.charts[spec];
    if (d != null) return d;
  }
  ref.watch(_ahChangeProvider);
  return runAh(ref.watch(isarProvider),
      AhChartParams(key.node, spec, ref.read(ahClockProvider)()), ahChartJob);
});

/// Which splits are blocked for the current results (chart builder).
final ahSplitBlocksProvider =
    FutureProvider.autoDispose<Map<AhChartSplit, AhSplitBlock>>((ref) async {
  return (await ref.watch(_ahBundleProvider.future))?.blocks ?? const {};
});

/// Live count for the Filter page draft. A null node (empty box) is 0 and
/// runs no query. The page debounces; a draft that is no longer watched
/// drops its result.
final ahCountProvider =
    FutureProvider.autoDispose.family<int, QueryNode?>((ref, node) async {
  if (node == null) return 0;
  ref.watch(_ahChangeProvider);
  return runAh(ref.watch(isarProvider),
      AhCountParams(node, ref.read(ahClockProvider)()), ahCountJob);
});

// ---------------------------------------------------------------------------
// Suggestions

final _fieldValuesProvider = FutureProvider.autoDispose
    .family<List<AhValueCount>, QueryField>((ref, field) {
  ref.keepAlive();
  ref.watch(_ahChangeProvider);
  return runAh(ref.watch(isarProvider), field, ahFieldValuesJob);
});

class AhSuggestionQuery {
  const AhSuggestionQuery(this.field, this.prefix);

  /// Null = suggest field names.
  final QueryField? field;
  final String prefix;
  @override
  bool operator ==(Object other) =>
      other is AhSuggestionQuery && other.field == field && other.prefix == prefix;
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

const _dateSuggestions = ['thismonth', 'lastmonth', 'thisyear', 'lastyear', 'last30d'];

/// Field names (when `field == null`) or the user's values for a field with
/// counts, prefix-matched case-insensitively, cached, off the UI thread.
final ahSuggestionsProvider = FutureProvider.autoDispose
    .family<List<AhSuggestion>, AhSuggestionQuery>((ref, q) async {
  final p = q.prefix.replaceAll('"', '').replaceFirst('#', '').toLowerCase();
  bool hit(String s) => s.toLowerCase().startsWith(p);
  List<AhSuggestion> plain(Iterable<String> vs) =>
      [for (final v in vs) if (hit(v)) AhSuggestion(v, v)];

  final f = q.field;
  if (f == null) {
    return [
      for (final x in QueryField.values)
        if (x != QueryField.words && hit(x.keyword))
          AhSuggestion('${x.keyword}:', x.keyword)
    ];
  }
  switch (f) {
    case QueryField.category:
    case QueryField.account:
    case QueryField.tag:
      final all = await ref.watch(_fieldValuesProvider(f).future);
      final rows = all.where((v) => hit(v.name)).toList()
        ..sort((a, b) {
          final c = b.count.compareTo(a.count);
          return c != 0 ? c : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      return [
        for (final v in rows.take(50))
          AhSuggestion(quoteValue(v.name), f == QueryField.tag ? '#${v.name}' : v.name,
              count: v.count),
        if (f == QueryField.tag && hit('none')) const AhSuggestion('none', 'none'),
      ];
    case QueryField.type:
      return plain(const ['expense', 'income', 'transfer']);
    case QueryField.has:
      return plain(const ['attachment', 'note']);
    case QueryField.source:
      return plain(const ['manual', 'sms', 'quickadd', 'recurring', 'import']);
    case QueryField.subType:
      return plain([for (final s in TxnSubType.values) s.name]);
    case QueryField.date:
      return plain(_dateSuggestions);
    case QueryField.amount:
    case QueryField.words:
      return const [];
  }
});
