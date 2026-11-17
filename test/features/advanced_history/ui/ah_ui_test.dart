import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/advanced_history/widgets/charts/ah_charts_area.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';
import 'package:kuber/features/advanced_history/providers/ah_providers.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/screens/advanced_history_screen.dart';
import 'package:kuber/features/advanced_history/widgets/charts/ah_chart_card.dart';
import 'package:kuber/features/advanced_history/widgets/charts/ah_chart_view.dart';
import 'package:kuber/features/advanced_history/widgets/dashboard/ah_export_sheet.dart';
import 'package:kuber/features/advanced_history/widgets/dashboard/ah_group_detail_sheet.dart';
import 'package:kuber/features/advanced_history/widgets/saved/ah_save_sheet.dart';
import 'package:kuber/features/advanced_history/services/ah_results.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/shared/widgets/app_button.dart';

import 'ah_ui_harness.dart';

const _two = AndNode([
  ConditionNode(QueryField.category, QueryOp.eq, ['food']),
  ConditionNode(QueryField.type, QueryOp.eq, ['expense']),
]);

AhView _filtered({
  List<AhChartSpec> charts = const [],
  AhGroupBy group = AhGroupBy.none,
  int? savedId,
}) =>
    AhView(
      queryText: 'category:food type:expense',
      node: _two,
      groupBy: group,
      sort: group == AhGroupBy.none
          ? AhSort.ungroupedDefault
          : AhSort.groupedDefault,
      charts: charts,
      savedId: savedId,
    );

const _donut = AhChartSpec(
    AhChartType.donut, AhChartSplit.category, AhChartMeasure.total);
const _bars =
    AhChartSpec(AhChartType.bars, AhChartSplit.account, AhChartMeasure.count);

Finder _cardMenu(int i) => find.descendant(
    of: find.byType(AhChartCard).at(i),
    matching: find.byIcon(Icons.more_vert_rounded));

void main() {
  testWidgets('free users see only the gate and no query provider runs',
      (t) async {
    Never boom(Object? _) => throw StateError('query provider watched');
    await pumpAh(t, const AdvancedHistoryScreen(), [
      kuberProStateProvider
          .overrideWith(() => ProState(const KuberProState(source: ProSource.free))),
      ahViewProvider.overrideWith(() => throw StateError('view watched')),
      ahKpisProvider.overrideWith(boom),
      ahGroupsProvider.overrideWith(boom),
      ahTxnPagesProvider.overrideWith(() => throw StateError('pages')),
      ahSplitBlocksProvider.overrideWith(boom),
    ]);
    expect(find.text('Filter, group and chart every transaction'), findsOneWidget);
    expect(find.text('See Kuber Pro'), findsOneWidget);
    expect(find.text('Sample data'), findsOneWidget);
  });

  testWidgets('start screen runs no query',
      (t) async {
    Never boom(Object? _) => throw StateError('query ran at start');
    final c = await pumpAh(t, const AdvancedHistoryScreen(), [
      ...ahOverrides(view: const AhView()),
      ahKpisProvider.overrideWith(boom),
    ]);
    expect(find.text('Pick a filter or a grouping to start, or open a saved view.'),
        findsOneWidget);
    expect(find.text('Add filter'), findsOneWidget);
    expect(find.text('Nothing saved yet'), findsOneWidget);
    expect(find.text('Untagged expenses'), findsOneWidget);
    expect(find.text('Clear all'), findsNothing);

    expect(c.read(ahViewProvider).isStart, isTrue);
  });

  testWidgets('an example chip applies a whole view', (t) async {
    final c = await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: const AhView(), categories: ['Fuel']));
    // Examples use the user's own category and currency.
    expect(find.text('Fuel over ₹500 this year'), findsOneWidget);
    await t.tap(find.text('Fuel in ${DateTime.now().year} by month'));
    await settleAh(t);
    final v = c.read(ahViewProvider);
    expect(v.groupBy, AhGroupBy.month);
    expect(v.queryText, 'category:Fuel and date:${DateTime.now().year}');
    expect(find.text('Clear all'), findsOneWidget);
    expect(find.text('Pick a filter or a grouping to start, or open a saved view.'),
        findsNothing);
  });

  testWidgets('action row badge, Clear all confirm returns to start',
      (t) async {
    final c = await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: _filtered(group: AhGroupBy.category)));
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('2'), findsWidgets); // badge
    expect(find.text('Category'), findsWidgets); // Group value
    expect(find.text('Clear all'), findsOneWidget);

    await t.tap(find.text('Clear all'));
    await settleAh(t);
    expect(find.text('Clear filters, grouping, sorting and charts?'),
        findsOneWidget);
    expect(find.text('Saved views are not changed.'), findsOneWidget);
    await t.tap(find.widgetWithText(AppButton, 'Cancel'));
    await settleAh(t);
    expect(c.read(ahViewProvider).node, isNotNull);

    await t.tap(find.text('Clear all'));
    await settleAh(t);
    await t.tap(find.widgetWithText(AppButton, 'Clear all'));
    await settleAh(t);
    expect(c.read(ahViewProvider).isStart, isTrue);
    expect(find.text('Pick a filter or a grouping to start, or open a saved view.'),
        findsOneWidget);
  });

  testWidgets('an accessibility change keeps the dashboard state', (t) async {
    // TalkBack or UiAutomator flips accessibleNavigation (reduced motion).
    // The page must not rebuild its tree: that reset the scroll and killed the
    // charts area while a card menu was open (Move up / down did nothing).
    await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: _filtered(charts: [_donut, _bars])));
    final before = t.state(find.byType(AhChartsArea));
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(accessibleNavigation: true);
    await settleAh(t);
    expect(identical(t.state(find.byType(AhChartsArea)), before), isTrue);
    t.platformDispatcher.clearAccessibilityFeaturesTestValue();
    await settleAh(t);
    expect(identical(t.state(find.byType(AhChartsArea)), before), isTrue);
  });

  testWidgets('charts: add, move, remove with undo', (t) async {
    final c = await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: _filtered(charts: [_donut, _bars])));
    expect(find.byType(AhChartCard), findsNWidgets(2));
    expect(find.text('Add chart · 2 of 4'), findsOneWidget);
    expect(find.text('Total by category'), findsOneWidget);
    expect(find.text('Count by account'), findsOneWidget);

    // Add
    await t.tap(find.text('Add chart · 2 of 4'));
    await settleAh(t);
    await t.tap(find.widgetWithText(AppButton, 'Add chart'));
    await settleAh(t);
    expect(c.read(ahViewProvider).charts.length, 3);
    expect(find.byType(AhChartCard), findsNWidgets(3));

    // The new chart (the builder's default, a donut) went on top.
    expect(c.read(ahViewProvider).charts, [_donut, _donut, _bars]);

    // Move the last one up
    await t.tap(_cardMenu(2));
    await settleAh(t);
    await t.tap(find.text('Move up'));
    await settleAh(t);
    expect(c.read(ahViewProvider).charts, [_donut, _bars, _donut]);

    // Move down the first
    await t.tap(_cardMenu(0));
    await settleAh(t);
    await t.tap(find.text('Move down'));
    await settleAh(t);
    expect(c.read(ahViewProvider).charts.first, _bars);
    // Cards are drawn in the new order.
    double top(String s) => t.getTopLeft(find.text(s).first).dy;
    expect(top('Count by account') < top('Total by category'), isTrue);

    // Remove the first, then undo
    await t.tap(_cardMenu(0));
    await settleAh(t);
    await t.tap(find.text('Remove'));
    await settleAh(t);
    expect(c.read(ahViewProvider).charts.length, 2);
    expect(find.text('Chart removed'), findsOneWidget);
    await t.tap(find.text('Undo'));
    await settleAh(t);
    expect(c.read(ahViewProvider).charts.length, 3);
    expect(c.read(ahViewProvider).charts.first, _bars);
  });

  for (final e in {
    AhChartState.notEnoughData: 'A line needs at least 2 months of data.',
    AhChartState.nothingToSplit: 'No categories in these results.',
    AhChartState.noResults: 'No transactions match this filter.',
  }.entries) {
    testWidgets('chart state ${e.key.name} shows in the card', (t) async {
      await pumpAh(t, const AdvancedHistoryScreen(),
          ahOverrides(view: _filtered(charts: [_donut]), chart: e.key));
      expect(find.text(e.value), findsOneWidget);
    });
  }

  testWidgets('wrongCombo offers Split by month which fixes the chart',
      (t) async {
    const bad = AhChartSpec(
        AhChartType.line, AhChartSplit.category, AhChartMeasure.total);
    final c = await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: _filtered(charts: [bad]), chart: AhChartState.wrongCombo));
    expect(find.text('Line charts work by month or year. Change the split or the chart type.'),
        findsOneWidget);
    expect(find.text('Change chart'), findsOneWidget);
    await t.tap(find.text('Split by month'));
    await settleAh(t);
    expect(c.read(ahViewProvider).charts.single.split, AhChartSplit.month);
  });

  testWidgets('builder: split defaults to the group, blocked splits dim',
      (t) async {
    final c = await pumpAh(
        t,
        const AdvancedHistoryScreen(),
        ahOverrides(
          view: _filtered(group: AhGroupBy.tag),
          blocks: const {AhChartSplit.account: AhSplitBlock.oneAccount},
        ));
    await t.tap(find.text('Add a chart'));
    await settleAh(t);
    expect(find.text('Current group'), findsOneWidget);
    expect(find.text('Only one account in these results'), findsOneWidget);
    final dim = find.ancestor(
        of: find.text('Only one account in these results'),
        matching: find.byType(Opacity));
    expect(t.widget<Opacity>(dim.first).opacity, 0.38);

    await t.tap(find.text('Account'), warnIfMissed: false); // blocked: ignored
    await t.tap(find.widgetWithText(AppButton, 'Add chart'));
    await settleAh(t);
    expect(c.read(ahViewProvider).charts.single.split, AhChartSplit.tag);
  });

  testWidgets('builder: switching to Line picks Month', (t) async {
    final c = await pumpAh(
        t, const AdvancedHistoryScreen(), ahOverrides(view: _filtered()));
    await t.tap(find.text('Add a chart'));
    await settleAh(t);
    await t.tap(find.text('Line'));
    await settleAh(t);
    await t.tap(find.widgetWithText(AppButton, 'Add chart'));
    await settleAh(t);
    final s = c.read(ahViewProvider).charts.single;
    expect((s.type, s.split), (AhChartType.line, AhChartSplit.month));
  });

  group('save sheet', () {
    Future<void> open(WidgetTester t, FakeRepo repo) async {
      await pumpAh(
        t,
        Consumer(
          builder: (context, ref, _) => Scaffold(
            body: TextButton(
              onPressed: () => showAhNameSheet(context, mode: AhNameMode.save),
              child: const Text('open'),
            ),
          ),
        ),
        ahOverrides(view: _filtered(charts: [_donut]), repo: repo),
      );
      await t.tap(find.text('open'));
      await settleAh(t);
    }

    bool enabled(WidgetTester t) =>
        t.widget<AppButton>(find.widgetWithText(AppButton, 'Save')).onPressed !=
        null;

    testWidgets('name is required, 40 max, unique ignoring case', (t) async {
      await open(t, FakeRepo(taken: {'food'}));
      expect(find.text('2 filters · 1 chart'),
          findsOneWidget);
      expect(find.text('Included in your JSON backup.'), findsOneWidget);
      expect(enabled(t), isFalse);

      await t.enterText(find.byType(TextField), 'x' * 55);
      await settleAh(t);
      expect(t.widget<TextField>(find.byType(TextField)).controller!.text.length,
          40);
      expect(enabled(t), isTrue);

      await t.enterText(find.byType(TextField), 'FOOD');
      await settleAh(t);
      expect(find.text('You already have a view called FOOD'), findsOneWidget);
      expect(enabled(t), isFalse);

      await t.enterText(find.byType(TextField), 'Monthly');
      await settleAh(t);
      expect(enabled(t), isTrue);
    });
  });

  testWidgets('change bar after a change to a saved view', (t) async {
    final c = await pumpAh(
      t,
      const AdvancedHistoryScreen(),
      ahOverrides(
        view: _filtered(savedId: 1),
        saved: [savedView(1, 'Monthly')],
      ),
    );
    // The saved view has no filter or group, the open one has a filter.
    expect(find.text('You changed Monthly'), findsOneWidget);
    expect(find.text('Changed the filter'), findsOneWidget);
    expect(find.text('Save as new'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Saved · edited'), findsOneWidget);
    expect(c.read(ahViewProvider).savedId, 1);
  });

  testWidgets('Save changes, then Undo writes the saved view back', (t) async {
    final repo = FakeRepo();
    await pumpAh(
      t,
      const AdvancedHistoryScreen(),
      ahOverrides(
        view: _filtered(savedId: 1),
        saved: [savedView(1, 'Monthly')],
        repo: repo,
      ),
    );
    await t.tap(find.text('Save changes'));
    await settleAh(t);
    expect(repo.changes.length, 1);
    expect(repo.changes.first.queryText, 'category:food type:expense');
    await t.tap(find.text('Undo'));
    await settleAh(t);
    expect(repo.changes.length, 2);
    expect(repo.changes.last.queryText, '');
  });

  testWidgets('export is disabled at 0 results', (t) async {
    await pumpAh(
      t,
      Consumer(
        builder: (context, ref, _) => Scaffold(
          body: TextButton(
            onPressed: () => showAhExportSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
      ahOverrides(
        view: _filtered(),
        kpis: const AhKpis(
            transactions: 0,
            income: 0,
            expense: 0,
            average: 0,
            attachments: 0,
            largest: 0),
      ),
    );
    await t.tap(find.text('open'));
    await settleAh(t);
    expect(find.text('Export results'), findsOneWidget);
    expect(
        t.widget<AppButton>(find.widgetWithText(AppButton, 'Save to folder')).onPressed,
        isNull);
    expect(t.widget<AppButton>(find.widgetWithText(AppButton, 'Share')).onPressed,
        isNull);
  });

  testWidgets('reduced motion path builds the whole dashboard', (t) async {
    await pumpAh(
      t,
      const AdvancedHistoryScreen(),
      ahOverrides(
          view: _filtered(charts: [_donut, _bars], group: AhGroupBy.category)),
      reduced: true,
    );
    expect(find.byType(AhChartCard), findsNWidgets(2));
    expect(find.text('Transactions'), findsWidgets);
    expect(t.takeException(), isNull);
  });

  testWidgets('bars: a tap shows the tooltip, a second tap hides it',
      (t) async {
    await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: _filtered(charts: [_bars])));
    final r = t.getRect(find.byType(AhChartView));
    final slot0 = Offset(r.left + r.width / 4, r.bottom - 40);
    expect(find.byKey(const ValueKey('ah-chart-tooltip')), findsNothing);
    await t.tapAt(slot0);
    await settleAh(t);
    expect(find.byKey(const ValueKey('ah-chart-tooltip')), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('View transactions'), findsOneWidget);
    await t.tapAt(slot0);
    await settleAh(t);
    expect(find.byKey(const ValueKey('ah-chart-tooltip')), findsNothing);
  });

  testWidgets('donut: picking a slice shows its share, value and the button',
      (t) async {
    await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: _filtered(charts: [_donut])));
    await t.tap(find.text('Food'));
    await settleAh(t);
    expect(find.byKey(const ValueKey('ah-donut-detail')), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('60% of total'), findsOneWidget);
    final detail = find.byKey(const ValueKey('ah-donut-detail'));
    expect(find.descendant(of: detail, matching: find.text('₹300')),
        findsOneWidget);
    expect(find.widgetWithText(AppButton, 'View transactions'), findsOneWidget);
    // Another slice swaps the detail.
    await t.tap(find.text('Travel').first);
    await settleAh(t);
    expect(find.text('40%'), findsOneWidget);
  });

  testWidgets('scrolling pins the compact action row; the app bar scrolls away',
      (t) async {
    await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: _filtered(charts: [_donut, _bars, _donut, _bars])));
    double compactOpacity() => t
        .widget<Opacity>(find
            .ancestor(
                of: find.byKey(const ValueKey('ah-action-compact')),
                matching: find.byType(Opacity))
            .first)
        .opacity;
    expect(compactOpacity(), 0);
    await t.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await settleAh(t);
    expect(compactOpacity(), 1);
    expect(find.text('Custom Dashboard').hitTestable(), findsNothing);
    // The pinned row still opens the Filter sheets: Sort is tappable.
    expect(find.byKey(const ValueKey('ah-action-compact')).hitTestable(),
        findsOneWidget);
  });

  testWidgets('leaving the app with the page closed resets the dashboard',
      (t) async {
    final c = await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: _filtered(charts: [_donut])));
    // Page open: switching apps keeps it.
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(c.read(ahViewProvider).isStart, isFalse);
    // Page closed, then the app goes away: next visit starts empty.
    await t.pumpWidget(UncontrolledProviderScope(
        container: c, child: const MaterialApp(home: SizedBox())));
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    expect(c.read(ahViewProvider).isStart, isTrue);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('Saved views sheet: Start fresh empties the dashboard, Undo',
      (t) async {
    final c = await pumpAh(t, const AdvancedHistoryScreen(),
        ahOverrides(view: _filtered(charts: [_donut])));
    await t.tap(find.text('Saved').first);
    await settleAh(t);
    await t.tap(find.byKey(const ValueKey('ahd-start-fresh')));
    await settleAh(t);
    expect(c.read(ahViewProvider).isStart, isTrue);
    await t.tap(find.text('Undo'));
    await settleAh(t);
    expect(c.read(ahViewProvider).charts, [_donut]);
  });

  testWidgets('group sheet loads the next page by itself, with a loader',
      (t) async {
    final pages = _MorePages();
    await pumpAh(
        t,
        const Scaffold(body: SizedBox()),
        [
          ...ahOverrides(view: _filtered()),
          ahTxnPagesProvider.overrideWith(() => pages),
          ahGroupKpisProvider.overrideWith((ref, g) async => kTestKpis),
        ]);
    showAhGroupDetail(t.element(find.byType(SizedBox).last),
        groupKey: const AhGroupKey(AhGroupBy.category, '1'), title: 'Food');
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    // Short page, more to come: it asks for the next one without a button.
    expect(pages.calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('heatmap: a square per day, a tap shows the day and its value',
      (t) async {
    const heat = AhChartSpec(
        AhChartType.heatmap, AhChartSplit.month, AhChartMeasure.total);
    final today = DateTime.now();
    String k(int back) {
      final d = DateTime(today.year, today.month, today.day - back);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    await pumpAh(t, const AdvancedHistoryScreen(), [
      ...ahOverrides(view: _filtered(charts: [heat])),
      ahChartDataProvider.overrideWith((ref, spec) async => AhChartData(
          AhChartState.ok,
          count: 3,
          points: [
            AhChartPoint(k(40), k(40), 120),
            AhChartPoint(k(3), k(3), 900),
            AhChartPoint(k(0), k(0), 300),
          ])),
    ]);
    expect(find.text('Total by day'), findsOneWidget);
    expect(find.text('Less'), findsOneWidget);
    expect(find.byKey(const ValueKey('ah-heatmap-scroll')), findsOneWidget);
    // Today is the last square (bottom right is the latest week).
    final grid = find.descendant(
        of: find.byKey(const ValueKey('ah-heatmap-scroll')),
        matching: find.byType(CustomPaint));
    final r = t.getRect(grid.last);
    final row = today.weekday - 1;
    await t.tapAt(Offset(r.right - 7, r.top + 18 + row * 17 + 7));
    await settleAh(t);
    expect(find.byKey(const ValueKey('ah-donut-detail')), findsOneWidget);
    expect(find.text('₹300'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'View transactions'), findsOneWidget);
  });

  testWidgets('stacked bars: legend, one tooltip row per value, scrolls', (t) async {
    const stacked = AhChartSpec(
        AhChartType.bars, AhChartSplit.month, AhChartMeasure.total,
        seriesBy: AhChartSplit.category, series: ['1', '2', '3']);
    final months = [for (var m = 1; m <= 12; m++) '2026-${m.toString().padLeft(2, '0')}'];
    await pumpAh(t, const AdvancedHistoryScreen(), [
      ...ahOverrides(view: _filtered(charts: [stacked])),
      ahChartDataProvider.overrideWith((ref, spec) async => AhChartData(
            AhChartState.ok,
            count: 30,
            points: [for (final m in months) AhChartPoint(m, m, 60)],
            series: [
              for (final (k, n) in [('1', 'Food'), ('2', 'Fuel'), ('3', 'Rent')])
                AhChartSeries(k, n, [for (final _ in months) 20]),
            ],
          )),
    ]);
    expect(find.text('Stacked bars · 30 transactions'), findsOneWidget);
    for (final n in ['Food', 'Fuel', 'Rent']) {
      expect(find.text(n), findsOneWidget);
    }
    // 12 months do not fit: it scrolls, starting at the latest.
    final scroll = find.byKey(const ValueKey('ah-chart-scroll'));
    expect(scroll, findsOneWidget);
    final pos = t.state<ScrollableState>(find.descendant(
        of: scroll, matching: find.byType(Scrollable))).position;
    expect(pos.pixels, pos.maxScrollExtent);
    final r = t.getRect(scroll);
    await t.tapAt(Offset(r.right - 20, r.bottom - 40));
    await settleAh(t);
    final tip = find.byKey(const ValueKey('ah-chart-tooltip'));
    expect(tip, findsOneWidget);
    expect(find.descendant(of: tip, matching: find.text('₹20')), findsNWidgets(3));
    expect(find.descendant(of: tip, matching: find.text('₹60')), findsOneWidget);
  });

  testWidgets('builder: Compare picks the top 3, bars switch to months',
      (t) async {
    final c = await pumpAh(t, const AdvancedHistoryScreen(), [
      ...ahOverrides(view: _filtered()),
      ahChartDataProvider.overrideWith((ref, spec) async => const AhChartData(
            AhChartState.ok,
            count: 9,
            points: [
              AhChartPoint('1', 'Food', 300),
              AhChartPoint('2', 'Fuel', 200),
              AhChartPoint('3', 'Rent', 150),
              AhChartPoint('4', 'Fun', 50),
            ],
          )),
    ]);
    await t.tap(find.text('Add a chart'));
    await settleAh(t);
    await t.tap(find.text('Bars'));
    await settleAh(t);
    await t.tap(find.byKey(const ValueKey('ahd-compare-category')));
    await settleAh(t);
    // Fun is the 4th: shown but off and dimmed (3 at most).
    final fun = t.widget<Opacity>(find.ancestor(
        of: find.byKey(const ValueKey('ahd-series-4')),
        matching: find.byType(Opacity)).first);
    expect(fun.opacity, 0.38);
    await t.tap(find.widgetWithText(AppButton, 'Add chart'));
    await settleAh(t);
    final spec = c.read(ahViewProvider).charts.first;
    expect(spec.type, AhChartType.bars);
    expect(spec.split, AhChartSplit.month);
    expect(spec.seriesBy, AhChartSplit.category);
    expect(spec.series, ['1', '2', '3']);
  });
}

class _MorePages extends AhTxnPagesNotifier {
  int calls = 0;
  @override
  Future<AhTxnPage> build(AhGroupKey? arg) async =>
      const AhTxnPage([], hasMore: true, total: 120);
  @override
  Future<void> loadMore() async => calls++;
}
