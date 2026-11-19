// Chart draw-in: once per page visit, per motion level.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion_level.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart' show AhChartType;
import 'package:kuber/features/advanced_history/services/ah_results.dart';
import 'package:kuber/features/advanced_history/widgets/charts/ah_chart_view.dart';
import 'package:kuber/l10n/app_localizations.dart';

const _pts = [
  AhChartPoint('a', 'A', 10),
  AhChartPoint('b', 'B', 20),
  AhChartPoint('c', 'C', 30),
];

Widget _app(MotionLevel level, List<AhChartPoint> pts) => MotionScope(
      level: level,
      systemOff: level == MotionLevel.off,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AhChartView(
            type: AhChartType.bars,
            points: pts,
            fmt: (v) => '$v',
          ),
        ),
      ),
    );

void main() {
  testWidgets('Expressive: draws in once, a rebuild does not replay it', (t) async {
    await t.pumpWidget(_app(MotionLevel.expressive, _pts));
    await t.pump(const Duration(milliseconds: 100));
    expect(t.hasRunningAnimations, isTrue);
    await t.pumpAndSettle();
    await t.pumpWidget(_app(MotionLevel.expressive, List.of(_pts)));
    await t.pump(const Duration(milliseconds: 16));
    expect(t.hasRunningAnimations, isFalse);
  });

  testWidgets('Expressive: a data change springs, no draw-in replay', (t) async {
    await t.pumpWidget(_app(MotionLevel.expressive, _pts));
    await t.pumpAndSettle();
    const next = [
      AhChartPoint('a', 'A', 25),
      AhChartPoint('b', 'B', 5),
      AhChartPoint('c', 'C', 30),
    ];
    await t.pumpWidget(_app(MotionLevel.expressive, next));
    await t.pump(const Duration(milliseconds: 16));
    expect(t.hasRunningAnimations, isTrue, reason: 'values spring');
    await t.pumpAndSettle();
  });

  testWidgets('Subtle: fades in, no draw', (t) async {
    await t.pumpWidget(_app(MotionLevel.subtle, _pts));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byType(FadeTransition), findsWidgets);
    await t.pumpAndSettle();
  });

  testWidgets('Off: appears, nothing animates', (t) async {
    await t.pumpWidget(_app(MotionLevel.off, _pts));
    await t.pump(const Duration(milliseconds: 16));
    expect(t.hasRunningAnimations, isFalse);
  });
}
