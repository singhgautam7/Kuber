import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';
import 'package:kuber/features/advanced_history/providers/ah_providers.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/query/query_parser.dart';
import 'package:kuber/features/advanced_history/services/ah_results.dart';
import 'package:kuber/features/analytics/providers/analytics_provider.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/isar_test_helper.dart';
import '../data/ah_fixture.dart';

void main() {
  late Isar isar;
  late AhFixture fx;
  late ProviderContainer c;
  setUpAll(initialiseIsarForTests);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    isar = await openTestIsar();
    fx = await buildFixture(isar);
    c = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(isar),
      ahClockProvider.overrideWithValue(() => fixtureNow),
    ]);
  });
  tearDown(() async {
    c.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await closeAndCleanIsar(isar);
  });

  AhViewNotifier view() => c.read(ahViewProvider.notifier);

  test('start state runs nothing', () async {
    expect(await c.read(ahKpisProvider.future), isNull);
    expect(await c.read(ahGroupsProvider.future), isNull);
    expect((await c.read(ahTxnPagesProvider(null).future)).items, isEmpty);
    expect(await c.read(ahSplitBlocksProvider.future), isEmpty);
    expect(
        (await c.read(ahChartDataProvider(const AhChartSpec(
                AhChartType.donut, AhChartSplit.category, AhChartMeasure.total))
            .future))
            .state,
        AhChartState.noResults);
    expect(await c.read(ahCountProvider(null).future), 0);
  });

  test('KPIs: transfers count in Transactions only, income/expense match Analytics',
      () async {
    view().setFilter('amount:>=0');
    final k = (await c.read(ahKpisProvider.future))!;
    expect(k.transactions, fx.txns.length);
    expect(fx.txns.any((t) => t.isTransfer), isTrue);
    expect(fx.txns.any((t) => t.isBalanceAdjustment), isTrue);

    // Analytics on the same ledger and range.
    final ac = ProviderContainer(overrides: [isarProvider.overrideWithValue(isar)]);
    await ac.read(transactionListProvider.future);
    ac.read(analyticsFilterProvider.notifier).setFilter(FilterType.custom,
        from: DateTime(2020), to: DateTime(2030));
    final a = ac.read(analyticsComputedProvider)!;
    expect(k.income, closeTo(a.totalIncome, 1e-6));
    expect(k.expense, closeTo(a.totalExpense, 1e-6));
    expect(k.net, closeTo(a.netAmount, 1e-6));
    await Future<void>.delayed(Duration.zero);
    ac.dispose();

    final abs = fx.txns.map((t) => t.amount.abs());
    expect(k.largest, abs.reduce((a, b) => a > b ? a : b));
    expect(k.average, closeTo(abs.reduce((a, b) => a + b) / fx.txns.length, 1e-6));
    expect(k.attachments, fx.txns.where((t) => t.attachmentPaths.isNotEmpty).length);
  });

  test('grouping: multi-tag, Untagged, shares, sort, count', () async {
    view().setFilter('amount:>=0');
    view().setGroup(AhGroupBy.tag);
    var g = (await c.read(ahGroupsProvider.future))!;
    expect(g.multiTagNote, isTrue);
    final untagged = g.rows.firstWhere((r) => r.key == '');
    expect(untagged.count, fx.txns.where((t) => (fx.txnTags[t.id] ?? {}).isEmpty).length);
    for (final tag in fx.tags) {
      final row = g.rows.firstWhere((r) => r.key == '${tag.id}');
      expect(row.label, tag.name);
      expect(row.count, fx.txns.where((t) => (fx.txnTags[t.id] ?? {}).contains(tag.id)).length);
    }
    expect(g.rows.fold<double>(0, (s, r) => s + r.share), greaterThan(1));
    final totals = g.rows.map((r) => r.total).toList();
    expect(totals, [...totals]..sort((a, b) => b.compareTo(a)));

    view().setGroup(AhGroupBy.category);
    g = (await c.read(ahGroupsProvider.future))!;
    expect(g.multiTagNote, isFalse);
    expect(g.rows.fold<double>(0, (s, r) => s + r.share), closeTo(1, 1e-9));
    expect(g.rows.fold<int>(0, (s, r) => s + r.count), fx.txns.length);
    expect(g.rows.any((r) => r.key == ''), isTrue); // No category
    view().setSort(const AhSort(AhSortField.count));
    g = (await c.read(ahGroupsProvider.future))!;
    final counts = g.rows.map((r) => r.count).toList();
    expect(counts, [...counts]..sort((a, b) => b.compareTo(a)));
    view().setSort(const AhSort(AhSortField.name, descending: false));
    g = (await c.read(ahGroupsProvider.future))!;
    final names = g.rows.map((r) => r.label.toLowerCase()).toList();
    expect(names, [...names]..sort());

    view().setGroup(AhGroupBy.month);
    g = (await c.read(ahGroupsProvider.future))!;
    expect(g.rows.first.key, matches(RegExp(r'^\d{4}-\d{2}$')));
    view().setGroup(AhGroupBy.source);
    g = (await c.read(ahGroupsProvider.future))!;
    expect(g.rows.map((r) => r.key).toSet().difference({'manual', 'sms', 'quickadd', 'recurring'}), isEmpty);
  });

  test('pages: 50 a page, loadMore, sort, group sheet', () async {
    view().setFilter('amount:>=0');
    final p = ahTxnPagesProvider(null);
    c.listen(p, (_, __) {});
    var page = await c.read(p.future);
    expect(page.items.length, 50);
    expect(page.hasMore, isTrue);
    expect(page.total, fx.txns.length);
    expect(page.items.first.createdAt.isAfter(page.items.last.createdAt), isTrue);
    await c.read(p.notifier).loadMore();
    page = c.read(p).value!;
    expect(page.items.length, 100);
    expect(page.items.map((t) => t.id).toSet().length, 100);
    while (c.read(p).value!.hasMore) {
      await c.read(p.notifier).loadMore();
    }
    expect(c.read(p).value!.items.length, fx.txns.length);

    view().setSort(const AhSort(AhSortField.amount));
    page = await c.read(p.future);
    expect(page.items.first.amount.abs(),
        fx.txns.map((t) => t.amount.abs()).reduce((a, b) => a > b ? a : b));

    final food = fx.cats.first;
    final key = AhGroupKey(AhGroupBy.category, '${food.id}');
    final gp = await c.read(ahTxnPagesProvider(key).future);
    final want = fx.txns.where((t) => t.categoryId == '${food.id}').length;
    expect(gp.total, want);
    expect(gp.items.every((t) => t.categoryId == '${food.id}'), isTrue);
    final gk = await c.read(ahGroupKpisProvider(key).future);
    expect(gk.transactions, want);
  });


  test('charts: states', () async {
    AhChartSpec s(AhChartType t, AhChartSplit sp,
            [AhChartMeasure m = AhChartMeasure.total]) =>
        AhChartSpec(t, sp, m);
    Future<AhChartData> d(AhChartSpec x) {
      view().addChart(x);
      return c.read(ahChartDataProvider(x).future);
    }

    view().setFilter('amount:>=0');
    final line = await d(s(AhChartType.line, AhChartSplit.month));
    expect(line.state, AhChartState.ok);
    expect(line.points.length, greaterThanOrEqualTo(2));
    expect(line.points.map((p) => p.key).toList(),
        [...line.points.map((p) => p.key)]..sort());
    final avg = await c.read(ahChartDataProvider(
            s(AhChartType.bars, AhChartSplit.category, AhChartMeasure.average))
        .future);
    expect(avg.state, AhChartState.ok);
    final cnt = await c.read(ahChartDataProvider(
            s(AhChartType.bars, AhChartSplit.type, AhChartMeasure.count))
        .future);
    expect(cnt.points.fold<double>(0, (a, p) => a + p.value), fx.txns.length);
    // line + non time split restored from a view
    expect((await d(s(AhChartType.line, AhChartSplit.category))).state,
        AhChartState.wrongCombo);
    // one month only
    view().setFilter('date:2026-03');
    expect(
        (await c.read(ahChartDataProvider(s(AhChartType.line, AhChartSplit.month)).future))
            .state,
        AhChartState.notEnoughData);
    // nothing matches
    view().setFilter('category:nothing');
    expect(
        (await c.read(ahChartDataProvider(s(AhChartType.bars, AhChartSplit.account)).future))
            .state,
        AhChartState.noResults);
    // tags all deleted -> nothingToSplit, no crash
    view().setFilter('tag:none');
    expect(
        (await c.read(ahChartDataProvider(s(AhChartType.donut, AhChartSplit.tag)).future))
            .state,
        AhChartState.nothingToSplit);
    final blocks = await c.read(ahSplitBlocksProvider.future);
    expect(blocks[AhChartSplit.tag], AhSplitBlock.noTags);
    expect(blocks.containsKey(AhChartSplit.account), isFalse);
  });

  test('donut keeps 5 + Other', () async {
    view().setFilter('amount:>=0');
    // 6 categories + No category = 7 groups
    final x = const AhChartSpec(
        AhChartType.donut, AhChartSplit.category, AhChartMeasure.total);
    view().addChart(x);
    final d = await c.read(ahChartDataProvider(x).future);
    expect(d.points.length, 6);
    expect(d.points.last.key, '__other');
    final total = fx.txns.fold<double>(0, (s, t) => s + t.amount.abs());
    expect(d.points.fold<double>(0, (s, p) => s + p.value), closeTo(total, 1e-6));
  });

  test('count and data change refresh', () async {
    final node = parseItems(tokenize('type:expense')).node;
    final n = await c.read(ahCountProvider(node).future);
    expect(n, fx.txns.where((t) => t.type == 'expense' && !t.isTransfer).length);

    view().setFilter('swiggy');
    final sub = c.listen(ahKpisProvider, (_, __) {});
    final before = (await c.read(ahKpisProvider.future))!.transactions;
    await isar.writeTxn(() => isar.transactions.put(Transaction()
      ..name = 'Swiggy new'
      ..nameLower = 'swiggy new'
      ..amount = 10
      ..type = 'expense'
      ..categoryId = ''
      ..accountId = '1'
      ..createdAt = fixtureNow
      ..updatedAt = fixtureNow));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final after = (await c.read(ahKpisProvider.future))!.transactions;
    expect(after, before + 1);
    sub.close();
  });

  test('suggestions', () async {
    final f = await c.read(ahSuggestionsProvider(const AhSuggestionQuery(null, 'ca')).future);
    expect(f.map((s) => s.value), ['category:']);
    final cats = await c.read(
        ahSuggestionsProvider(const AhSuggestionQuery(QueryField.category, 'F')).future);
    expect(cats.map((s) => s.label), containsAll(['Food', 'Fuel', 'Fun']));
    expect(cats.every((s) => s.count != null), isTrue);
    expect(cats.first.count! >= cats.last.count!, isTrue);
    final accs = await c.read(
        ahSuggestionsProvider(const AhSuggestionQuery(QueryField.account, 'hd')).future);
    expect(accs.single.value, '"HDFC Millennia"');
    final tags = await c.read(
        ahSuggestionsProvider(const AhSuggestionQuery(QueryField.tag, '#tr')).future);
    expect(tags.single.label, '#trip');
  });
}
