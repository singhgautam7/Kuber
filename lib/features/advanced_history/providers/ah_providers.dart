// Advanced History state and queries.
//
// * [ahViewProvider] holds the dashboard state (filter, group, sort, charts,
//   KPI choice). A saved view is exactly this.
// * Results are keyed by what they depend on, so a change recomputes only
//   its own part, on the AH worker isolate (see ah_worker.dart):
//     - base bundle: filter + grouping -> KPIs, split blocks, the charts
//       present at that moment, and the order for the sort at that moment
//       (one match on a fresh query);
//     - order: + sort -> group rows and every matched id in display order;
//       reuses the bundle's when the sort matches, else its own job;
//     - one provider per chart spec (filter only): reads the bundle when the
//       spec was in it, else runs its own chart job. Reordering, removing
//       and the order of charts never touch a key; adding / editing runs
//       only that chart.
//   Later pages are fetched by id from the order's id list on the UI side.
//   Stale work is dropped by autoDispose, pagination by a generation counter.
// * The start state (`view.isStart`) runs no query anywhere.
//
// Entry is Pro-gated by `openAdvancedHistory`; these providers don't re-check.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show ValueListenable, ValueNotifier, listEquals;
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../tags/data/transaction_tag.dart';
import '../../transactions/data/transaction.dart';
import '../data/saved_filter.dart';
import '../models/ah_view.dart';
import 'ah_saved_repository.dart';
import '../query/query_ast.dart';
import '../query/query_parser.dart';
import '../services/ah_jobs.dart';
import '../services/ah_results.dart';
import '../services/ah_worker.dart';

export 'ah_saved_repository.dart';

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

  static final _pages = <Object>{};
  static final _pagesCount = ValueNotifier<int>(0);

  /// Advanced History pages on the navigator stack (filter page on top
  /// still counts: the page under it stays mounted). Never negative.
  static int get openPages => _pages.length;

  /// Fires when the number of open pages changes.
  static ValueListenable<int> get openPagesListenable => _pagesCount;

  /// A page state calls this in initState and [pageClosed] in dispose.
  static void pageOpened(Object page) {
    _pages.add(page);
    _pagesCount.value = _pages.length;
  }

  static void pageClosed(Object page) {
    if (!_pages.remove(page)) return;
    if (_pages.isEmpty) AhWorker.shutdown();
    // Not while the tree is being torn down.
    scheduleMicrotask(() => _pagesCount.value = _pages.length);
  }

  @override
  AhView build() {
    _loadKpiPref();
    // Leaving the app ("closing" it on Android keeps the process) while the
    // page isn't open starts the next visit on an empty page; the KPI choice
    // is kept. Switching apps with the page open keeps the dashboard.
    try {
      final life = AppLifecycleListener(onHide: () {
        if (openPages == 0) {
          AhWorker.shutdown();
          if (!state.isStart) clearAll();
        }
      });
      ref.onDispose(life.dispose);
    } catch (_) {
      // No widgets binding (pure provider tests).
    }
    ref.onDispose(AhWorker.shutdown);
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
// Transactions changed signal (read-only)

class _ChangeCounter extends AutoDisposeNotifier<int> {
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

/// Auto-disposed: the two watchers live only while some query provider does.
final _ahChangeProvider =
    NotifierProvider.autoDispose<_ChangeCounter, int>(_ChangeCounter.new);

// ---------------------------------------------------------------------------
// Results

/// The filter (and whether the page is in its start state).
class _NodeKey {
  _NodeKey(AhView v)
      : node = v.node,
        json = v.node == null ? '' : jsonEncode(v.node!.toJson()),
        isStart = v.isStart;
  final QueryNode? node;
  final String json;
  final bool isStart;

  @override
  bool operator ==(Object other) =>
      other is _NodeKey && other.json == json && other.isStart == isStart;
  @override
  int get hashCode => Object.hash(json, isStart);
}

/// Filter + grouping: what the base bundle depends on.
class _MatchKey extends _NodeKey {
  _MatchKey(super.v) : groupBy = v.groupBy;
  final AhGroupBy groupBy;

  @override
  bool operator ==(Object other) =>
      other is _MatchKey && super == other && other.groupBy == groupBy;
  @override
  int get hashCode => Object.hash(super.hashCode, groupBy);
}

/// Filter + grouping + sort: what the order depends on.
class _OrderKey extends _MatchKey {
  _OrderKey(super.v) : sort = v.sort;
  final AhSort sort;

  @override
  bool operator ==(Object other) =>
      other is _OrderKey && super == other && other.sort == sort;
  @override
  int get hashCode => Object.hash(super.hashCode, sort);
}

final _ahBaseProvider = FutureProvider.autoDispose<AhBundle?>((ref) async {
  final key = ref.watch(ahViewProvider.select(_MatchKey.new));
  ref.watch(_ahChangeProvider);
  if (key.isStart) return null;
  final isar = ref.watch(isarProvider);
  final now = ref.read(ahClockProvider)();
  // Sort and charts are read, not watched: they must not rerun this.
  final v = ref.read(ahViewProvider);
  return runAh(isar,
      AhBundleParams(key.node, key.groupBy, v.sort, v.charts, now), ahBundleJob);
});

final _ahOrderProvider = FutureProvider.autoDispose<AhOrder?>((ref) async {
  final key = ref.watch(ahViewProvider.select(_OrderKey.new));
  ref.watch(_ahChangeProvider);
  if (key.isStart) return null;
  final base = await ref.watch(_ahBaseProvider.future);
  if (base != null && base.sort == key.sort) return base.order;
  return runAh(
      ref.watch(isarProvider),
      AhBundleParams(key.node, key.groupBy, key.sort, const [],
          ref.read(ahClockProvider)()),
      ahOrderJob);
});

const _emptyPage = AhTxnPage([], hasMore: false, total: 0);

/// KPIs for the current view; null for the start state.
final ahKpisProvider = FutureProvider.autoDispose<AhKpis?>((ref) async {
  return (await ref.watch(_ahBaseProvider.future))?.kpis;
});

/// Groups for the current view; null when not grouped or start state.
final ahGroupsProvider = FutureProvider.autoDispose<AhGroups?>((ref) async {
  return (await ref.watch(_ahOrderProvider.future))?.groups;
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

  /// Every matched id in display order (from the query) and how many of
  /// them are already loaded. Page N is a by-id fetch, no query.
  List<int> _ids = const [];
  int _offset = 0;

  @override
  Future<AhTxnPage> build(AhGroupKey? arg) async {
    _gen++;
    _loading = false;
    final AhOrder? order;
    if (arg == null) {
      order = await ref.watch(_ahOrderProvider.future);
    } else {
      final key = ref.watch(ahViewProvider.select(_NodeKey.new));
      ref.watch(_ahChangeProvider);
      order = await runAh(
          ref.watch(isarProvider),
          AhPageParams(key.node, AhSort.ungroupedDefault, ref.read(ahClockProvider)(),
              by: arg.by, key: arg.key),
          ahGroupOrderJob);
    }
    _ids = order?.ids ?? const [];
    _offset = order?.page.items.length ?? 0;
    return order?.page ?? _emptyPage;
  }

  /// Appends the next 50. No-op while loading or when !hasMore.
  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || !cur.hasMore || _loading) return;
    final gen = _gen;
    final ids = _ids;
    final from = _offset;
    _loading = true;
    try {
      final to = (from + kAhPageSize).clamp(0, ids.length);
      final rows = await _fetch(ids.sublist(from, to));
      if (gen != _gen) return; // a newer view / data change rebuilt us
      _offset = to;
      state = AsyncData(AhTxnPage([...cur.items, ...rows],
          hasMore: to < ids.length, total: ids.length));
    } finally {
      if (gen == _gen) _loading = false;
    }
  }

  /// Every matched transaction (export), fetched by id in chunks.
  Future<List<Transaction>> allMatching() async {
    await future;
    final ids = _ids;
    final out = <Transaction>[];
    for (var i = 0; i < ids.length; i += 500) {
      out.addAll(await _fetch(ids.sublist(i, (i + 500).clamp(0, ids.length))));
    }
    return out;
  }

  /// By-id fetch; ids deleted since the query come back null and are skipped.
  Future<List<Transaction>> _fetch(List<int> ids) async =>
      (await ref.read(isarProvider).transactions.getAll(ids))
          .whereType<Transaction>()
          .toList();
}

/// KPIs of one group (group sheet).
final ahGroupKpisProvider =
    FutureProvider.autoDispose.family<AhKpis, AhGroupKey>((ref, g) {
  final key = ref.watch(ahViewProvider.select(_NodeKey.new));
  ref.watch(_ahChangeProvider);
  return runAh(
      ref.watch(isarProvider),
      AhPageParams(key.node, AhSort.ungroupedDefault, ref.read(ahClockProvider)(),
          by: g.by, key: g.key),
      ahGroupKpisJob);
});

/// Data for one chart card. Keyed by the chart spec and the filter only, so
/// reordering charts computes nothing and adding / editing one computes just
/// that one. A spec the base bundle already holds is read from it (one match
/// for a fresh query); any other (new, edited, builder preview) gets its own
/// job.
final ahChartDataProvider =
    FutureProvider.autoDispose.family<AhChartData, AhChartSpec>((ref, spec) async {
  final key = ref.watch(ahViewProvider.select(_NodeKey.new));
  if (key.isStart) return const AhChartData(AhChartState.noResults);
  ref.watch(_ahChangeProvider);
  // Read, not watched: the chart list changing must not rerun this.
  if (ref.read(ahViewProvider).charts.contains(spec)) {
    final d = (await ref.watch(_ahBaseProvider.future))?.charts[spec];
    if (d != null) return d;
  }
  return runAh(ref.watch(isarProvider),
      AhChartParams(key.node, spec, ref.read(ahClockProvider)()), ahChartJob);
});

/// Which splits are blocked for the current results (chart builder).
final ahSplitBlocksProvider =
    FutureProvider.autoDispose<Map<AhChartSplit, AhSplitBlock>>((ref) async {
  return (await ref.watch(_ahBaseProvider.future))?.blocks ?? const {};
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
  // Kept while a dashboards page is open (suggestions feel instant), released
  // when the last one closes.
  final link = ref.keepAlive();
  final pages = AhViewNotifier.openPagesListenable;
  void release() {
    if (pages.value == 0) link.close();
  }

  pages.addListener(release);
  ref.onDispose(() => pages.removeListener(release));
  release();
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
