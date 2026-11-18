import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/expressive_chart/chart_painter.dart';
import 'package:kuber/shared/widgets/expressive_chart/expressive_chart.dart';

List<ExpressivePeriod> samplePeriods(int n, {int firstKey = 1000}) {
  const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return [
    for (var i = 0; i < n; i++)
      ExpressivePeriod(
        key: firstKey + i,
        label: names[(firstKey + i) % 12],
        fullLabel: '${names[(firstKey + i) % 12]} 2026',
        values: [60000.0 + (i % 4) * 3000, 30000.0 + (i * 7919) % 30000],
        isCurrent: i == n - 1,
      ),
  ];
}

Widget chartHarness({
  required List<ExpressivePeriod> periods,
  ExpressiveChartMode mode = ExpressiveChartMode.bar,
  int window = 6,
  double topGap = 300,
  ThemeData? theme,
  double textScale = 1,
  String? emptyTitle,
  String? singleNote,
  String Function(double)? formatAxis,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light(const Locale('en')),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (c, child) => MediaQuery(
      data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: Scaffold(
      body: ListView(
        children: [
          SizedBox(height: topGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Builder(builder: (context) {
              final m = context.kuberMoney;
              return ExpressiveChart(
                series: [
                  ExpressiveSeries(name: 'Income', color: m.income, inverseColor: m.inverseIncome),
                  ExpressiveSeries(name: 'Expense', color: m.expense, inverseColor: m.inverseExpense),
                ],
                periods: periods,
                mode: mode,
                window: window,
                formatAmount: (v) => '₹${v.round()}',
                formatAxis: formatAxis ?? (v) => '${(v / 1000).round()}K',
                emptyTitle: emptyTitle,
                singleNote: singleNote,
              );
            }),
          ),
          const SizedBox(height: 1200),
        ],
      ),
    ),
  );
}

Future<void> useSmallPhone(WidgetTester t) async {
  t.view.physicalSize = const Size(412, 892);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

ScrollPosition chartPosition(WidgetTester t) => t
    .state<ScrollableState>(find.descendant(
        of: find.byKey(kExpressiveChartScrollKey), matching: find.byType(Scrollable)))
    .position;

Future<void> tapColumn(WidgetTester t, int fromToday) async {
  final tl = t.getTopLeft(find.byKey(kExpressiveChartScrollKey));
  final plotW = t.getSize(find.byKey(kExpressiveChartScrollKey)).width;
  final slot = plotW / 6;
  await t.tapAt(Offset(tl.dx + plotW - slot * (fromToday + 0.5), tl.dy + 60));
  await t.pumpAndSettle();
}

void main() {
  group('placeTooltip', () {
    const tip = Size(184, 120);
    test('normal: 12 dp above the column, centred', () {
      final p = placeTooltip(
        cx: 150, columnTop: 80, labelsBottom: 170, tip: tip,
        chartGlobal: const Offset(20, 400), screenWidth: 412, viewportTop: 100,
      );
      expect(p.flipped, isFalse);
      expect(p.top, 80 - 12 - 120);
      expect(p.left, 150 - 92);
      expect(p.pointerX, 92);
    });
    test('near the top of the viewport: flips below the labels', () {
      final p = placeTooltip(
        cx: 150, columnTop: 40, labelsBottom: 170, tip: tip,
        chartGlobal: const Offset(20, 130), screenWidth: 412, viewportTop: 100,
      );
      expect(p.flipped, isTrue);
      expect(p.top, 170 + 8);
    });
    test('left edge: 8 dp from the screen, pointer stays on the column', () {
      final p = placeTooltip(
        cx: 20, columnTop: 80, labelsBottom: 170, tip: tip,
        chartGlobal: const Offset(20, 400), screenWidth: 412, viewportTop: 0,
      );
      expect(p.left + 20, 8);
      expect(p.left + p.pointerX, 20); // pointer stays on the column
    });
    test('right edge: 8 dp from the screen', () {
      final p = placeTooltip(
        cx: 330, columnTop: 80, labelsBottom: 170, tip: tip,
        chartGlobal: const Offset(20, 400), screenWidth: 412, viewportTop: 0,
      );
      expect(p.left + 20 + 184, 412 - 8);
      expect(p.left + p.pointerX, 330);
    });
  });

  test('geometry: every column has its own slot inside the plot at rest', () {
    final g = ChartGeometry(plotWidth: 336, total: 6, win: 6, pixels: 0, windowTarget: 6);
    final xs = [for (var t = 0; t < 6; t++) g.cx(t)];
    expect(xs.toSet().length, 6);
    expect(xs.first, greaterThan(0));
    expect(xs.last + 14, lessThanOrEqualTo(336));
    expect(g.columnAt(xs.last), 5);
    expect(g.columnAt(xs.first), 0);
    expect(g.columnAt(340), isNull);
  });

  testWidgets('largest font: the axis fits its widest label (22.5K, not 2.5K)', (t) async {
    await useSmallPhone(t);
    String fmt(double v) => '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K';
    final periods = [
      for (var i = 0; i < 6; i++)
        ExpressivePeriod(key: i, label: 'M$i', fullLabel: 'M$i', values: [11000, 44000.0 - i], isCurrent: i == 5),
    ];
    await t.pumpWidget(chartHarness(periods: periods, textScale: 2, formatAxis: fmt));
    await t.pumpAndSettle();
    final painter = t
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<ChartPainter>()
        .first;
    final tp = TextPainter(
      text: TextSpan(text: '22.5K', style: Theme.of(t.element(find.byType(ExpressiveChart))).textTheme.labelSmall!
          .copyWith(fontWeight: FontWeight.w500)),
      textDirection: TextDirection.ltr,
      textScaler: const TextScaler.linear(2),
    )..layout();
    expect(painter.frame.axisWidth, greaterThanOrEqualTo(tp.width));
    // Month labels wider than their column: every other one, never touching.
    expect(painter.frame.labelEvery, greaterThan(1));
  });

  testWidgets('tap selects, tooltip sits above the column, tap again closes', (t) async {
    await useSmallPhone(t);
    await t.pumpWidget(chartHarness(periods: samplePeriods(6)));
    await t.pumpAndSettle();
    expect(find.byKey(kExpressiveChartTooltipKey), findsNothing);
    await tapColumn(t, 2);
    final tip = t.getRect(find.byKey(kExpressiveChartTooltipKey));
    final plotTop = t.getTopLeft(find.byKey(kExpressiveChartScrollKey)).dy;
    expect(tip.bottom, lessThan(plotTop + 132));
    expect(find.text('Saved'), findsOneWidget);
    await tapColumn(t, 2);
    expect(find.byKey(kExpressiveChartTooltipKey), findsNothing);
  });

  testWidgets('tooltip flips below the labels near the top of the page', (t) async {
    await useSmallPhone(t);
    await t.pumpWidget(chartHarness(periods: samplePeriods(6), topGap: 0));
    await t.pumpAndSettle();
    await tapColumn(t, 1);
    final tip = t.getRect(find.byKey(kExpressiveChartTooltipKey));
    final scroll = t.getRect(find.byKey(kExpressiveChartScrollKey));
    expect(tip.top, greaterThanOrEqualTo(scroll.bottom));
  });

  testWidgets('tooltip stays 8 dp inside the screen at both edges', (t) async {
    await useSmallPhone(t);
    await t.pumpWidget(chartHarness(periods: samplePeriods(6)));
    await t.pumpAndSettle();
    await tapColumn(t, 0);
    var r = t.getRect(find.byKey(kExpressiveChartTooltipKey));
    expect(r.right, lessThanOrEqualTo(412 - 8 + 0.01));
    await tapColumn(t, 5);
    r = t.getRect(find.byKey(kExpressiveChartTooltipKey));
    expect(r.left, greaterThanOrEqualTo(8 - 0.01));
  });

  testWidgets('prepending older periods keeps the scroll offset', (t) async {
    await useSmallPhone(t);
    await t.pumpWidget(chartHarness(periods: samplePeriods(12, firstKey: 1006)));
    await t.pumpAndSettle();
    await t.drag(find.byKey(kExpressiveChartScrollKey), const Offset(112, 0));
    await t.pumpAndSettle();
    final before = chartPosition(t).pixels;
    expect(before, greaterThan(0));
    await t.pumpWidget(chartHarness(periods: samplePeriods(18, firstKey: 1000)));
    await t.pumpAndSettle();
    expect(chartPosition(t).pixels, before);
  });

  testWidgets('Bar to Line keeps the selection; a window change clears it', (t) async {
    await useSmallPhone(t);
    await t.pumpWidget(chartHarness(periods: samplePeriods(12, firstKey: 1006)));
    await t.pumpAndSettle();
    await tapColumn(t, 1);
    expect(find.byKey(kExpressiveChartTooltipKey), findsOneWidget);
    await t.pumpWidget(chartHarness(
        periods: samplePeriods(12, firstKey: 1006), mode: ExpressiveChartMode.line));
    await t.pumpAndSettle();
    expect(find.byKey(kExpressiveChartTooltipKey), findsOneWidget);
    await t.pumpWidget(chartHarness(
        periods: samplePeriods(12, firstKey: 1006), mode: ExpressiveChartMode.line, window: 12));
    await t.pumpAndSettle();
    expect(find.byKey(kExpressiveChartTooltipKey), findsNothing);
  });

  testWidgets('empty and single states show their notes', (t) async {
    await useSmallPhone(t);
    await t.pumpWidget(chartHarness(periods: const [], emptyTitle: 'Nothing yet'));
    await t.pumpAndSettle();
    expect(find.text('Nothing yet'), findsOneWidget);
    await t.pumpWidget(chartHarness(periods: samplePeriods(1), singleNote: 'Only one'));
    await t.pumpAndSettle();
    expect(find.text('Only one'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
