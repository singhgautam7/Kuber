// Custom dashboards: month-split bars / line draw through ExpressiveChart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion_level.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart' show AhChartType;
import 'package:kuber/features/advanced_history/services/ah_results.dart';
import 'package:kuber/features/advanced_history/widgets/charts/ah_chart_view.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/expressive_chart/expressive_chart.dart';

final _pts = [
  for (var m = 1; m <= 6; m++)
    AhChartPoint('2026-0$m', 'M$m 2026', m * 100.0),
];

Widget _app(AhChartType type, List<AhChartPoint> pts, List<String> viewed) =>
    MotionScope(
      level: MotionLevel.off,
      systemOff: true,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: AhChartView(
              type: type,
              points: pts,
              fmt: (v) => '${v.round()}',
              seriesName: 'Food',
              onView: (p) => viewed.add(p.key),
            ),
          ),
        ),
      ),
    );

void main() {
  for (final type in [AhChartType.bars, AhChartType.line]) {
    testWidgets('$type by month uses ExpressiveChart; a tap offers View transactions',
        (t) async {
      final viewed = <String>[];
      await t.pumpWidget(_app(type, _pts, viewed));
      await t.pumpAndSettle();
      final chart = t.widget<ExpressiveChart>(find.byType(ExpressiveChart));
      expect([for (final p in chart.periods) p.values.single],
          [100, 200, 300, 400, 500, 600]);
      expect(chart.mode,
          type == AhChartType.bars ? ExpressiveChartMode.bar : ExpressiveChartMode.line);
      expect(find.byKey(kExpressiveChartTooltipKey), findsNothing);
      expect(find.text('View transactions'), findsNothing);

      // Newest month: 1st of the 6 slots counts from the right (axis on the right).
      final r = t.getRect(find.byType(ExpressiveChart));
      await t.tapAt(Offset(r.left + (r.width - 36) / 12, r.top + 100));
      await t.pumpAndSettle();
      expect(find.byKey(kExpressiveChartTooltipKey), findsOneWidget);
      expect(find.text('View transactions'), findsOneWidget);
      await t.tap(find.text('View transactions'));
      expect(viewed.length, 1);
    });
  }

  testWidgets('category bars keep the AH painter', (t) async {
    await t.pumpWidget(_app(AhChartType.bars,
        const [AhChartPoint('1', 'Food', 10), AhChartPoint('2', 'Fuel', 5)], []));
    await t.pumpAndSettle();
    expect(find.byType(ExpressiveChart), findsNothing);
  });
}
