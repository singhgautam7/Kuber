// Advanced History jobs: top-level functions run by [runAh] (worker isolate,
// or inline in tests). Each takes an [Isar] and plain params.

import 'package:isar_community/isar.dart';

import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../tags/data/tag.dart';
import '../../tags/data/transaction_tag.dart';
import '../../transactions/data/transaction.dart';
import '../models/ah_view.dart';
import '../query/query_ast.dart';
import 'ah_engine.dart';
import 'ah_results.dart';

const kAhPageSize = 50;

/// Match-keyed results (filter + grouping): KPIs, split blocks and the
/// charts present when it ran, plus the ordering for the sort it ran with.
class AhBundle {
  const AhBundle(this.kpis, this.sort, this.order, this.charts, this.blocks);
  final AhKpis kpis;
  final AhSort sort;
  final AhOrder order;
  final Map<AhChartSpec, AhChartData> charts;
  final Map<AhChartSplit, AhSplitBlock> blocks;
}

/// Sort-keyed results: group rows (grouped) and every matched transaction id
/// in display order. [page] is the first 50 rows; later pages are fetched by
/// id (see `AhTxnPagesNotifier.loadMore`).
class AhOrder {
  const AhOrder(this.groups, this.ids, this.page);
  final AhGroups? groups;
  final List<int> ids;
  final AhTxnPage page;
}

class AhBundleParams {
  const AhBundleParams(this.node, this.groupBy, this.sort, this.charts, this.now);
  final QueryNode? node;
  final AhGroupBy groupBy;
  final AhSort sort;
  final List<AhChartSpec> charts;
  final DateTime now;
}

AhSort _pageSort(AhSort s) =>
    const [AhSortField.date, AhSortField.amount, AhSortField.category, AhSortField.account]
            .contains(s.field)
        ? s
        : AhSort.ungroupedDefault;

AhOrder _order(List<Transaction> txns, AhBundleParams p, AhLookups lk) {
  final sorted = ahSortTxns(txns, _pageSort(p.sort), lk);
  return AhOrder(
    p.groupBy == AhGroupBy.none ? null : ahGroupsOf(txns, p.groupBy, p.sort, lk),
    [for (final t in sorted) t.id],
    _firstPage(sorted),
  );
}

AhTxnPage _firstPage(List<Transaction> sorted) {
  final end = sorted.length < kAhPageSize ? sorted.length : kAhPageSize;
  return AhTxnPage(sorted.sublist(0, end),
      hasMore: end < sorted.length, total: sorted.length);
}

Future<AhBundle> ahBundleJob(Isar isar, AhBundleParams p) async {
  final lk = await AhLookups.load(isar);
  final txns = await ahMatch(isar, p.node, p.now, lk);
  return AhBundle(
    ahKpisOf(txns),
    p.sort,
    _order(txns, p, lk),
    {for (final c in p.charts) c: ahChartOf(txns, c, lk)},
    ahBlocksOf(txns, lk),
  );
}

/// Only the sort-dependent part (a sort change).
Future<AhOrder> ahOrderJob(Isar isar, AhBundleParams p) async {
  final lk = await AhLookups.load(isar);
  return _order(await ahMatch(isar, p.node, p.now, lk), p, lk);
}

class AhPageParams {
  const AhPageParams(this.node, this.sort, this.now, {this.by, this.key});
  final QueryNode? node;
  final AhSort sort;
  final DateTime now;
  final AhGroupBy? by;
  final String? key;
}

Future<List<Transaction>> _matchGroup(
    Isar isar, QueryNode? node, DateTime now, AhGroupBy? by, String? key,
    AhLookups lk) async {
  final txns = await ahMatch(isar, node, now, lk);
  if (by == null || by == AhGroupBy.none) return txns;
  return txns.where((t) => ahKeysOf(t, by, lk).contains(key)).toList();
}

/// One group's ids (newest first) and its first page.
Future<AhOrder> ahGroupOrderJob(Isar isar, AhPageParams p) async {
  final lk = await AhLookups.load(isar);
  final txns = await _matchGroup(isar, p.node, p.now, p.by, p.key, lk);
  final sorted = ahSortTxns(txns, AhSort.ungroupedDefault, lk);
  return AhOrder(null, [for (final t in sorted) t.id], _firstPage(sorted));
}

Future<AhKpis> ahGroupKpisJob(Isar isar, AhPageParams p) async {
  final lk = await AhLookups.load(isar);
  return ahKpisOf(await _matchGroup(isar, p.node, p.now, p.by, p.key, lk));
}

/// A chart spec outside the open view (builder preview): own match.
class AhChartParams {
  const AhChartParams(this.node, this.spec, this.now);
  final QueryNode? node;
  final AhChartSpec spec;
  final DateTime now;
}

Future<AhChartData> ahChartJob(Isar isar, AhChartParams p) async {
  final lk = await AhLookups.load(isar);
  return ahChartOf(await ahMatch(isar, p.node, p.now, lk), p.spec, lk);
}

class AhCountParams {
  const AhCountParams(this.node, this.now);
  final QueryNode? node;
  final DateTime now;
}

Future<int> ahCountJob(Isar isar, AhCountParams p) async {
  final lk = await AhLookups.load(isar);
  return (await ahMatch(isar, p.node, p.now, lk)).length;
}

/// A value of a field with how many transactions use it.
class AhValueCount {
  const AhValueCount(this.name, this.count);
  final String name;
  final int count;
}

/// The user's values for [field] with counts (suggestions).
Future<List<AhValueCount>> ahFieldValuesJob(Isar isar, QueryField field) async {
  Map<String, int> tally(Iterable<String> keys) {
    final m = <String, int>{};
    for (final k in keys) {
      m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }

  switch (field) {
    case QueryField.category:
      final counts =
          tally(await isar.transactions.where().categoryIdProperty().findAll());
      final cats = await isar.categorys.where().findAll();
      return [for (final c in cats) AhValueCount(c.name, counts['${c.id}'] ?? 0)];
    case QueryField.account:
      final counts =
          tally(await isar.transactions.where().accountIdProperty().findAll());
      final accs = await isar.accounts.where().findAll();
      return [for (final a in accs) AhValueCount(a.name, counts['${a.id}'] ?? 0)];
    case QueryField.tag:
      final counts = tally((await isar.transactionTags.where().tagIdProperty().findAll())
          .map((e) => '$e'));
      final tags = await isar.tags.where().findAll();
      return [for (final t in tags) AhValueCount(t.name, counts['${t.id}'] ?? 0)];
    default:
      return const [];
  }
}
