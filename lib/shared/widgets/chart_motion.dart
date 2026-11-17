import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';

/// Glue between the motion kit and fl_chart (motion.md "Charts").
///
/// Draw-in once per page visit: wrap the chart in [ChartDrawIn] and pass its
/// [ChartProgress] to [riseBars] / [sweepSections] / [RevealX]. Data changes:
/// give the chart [chartSwapDuration] / [chartSwapCurve] (springStandard at
/// Expressive, fx.default cross-fade at Subtle, none at Off). While a draw-in
/// is running pass `drawing: true` so the two never fight.
Duration chartSwapDuration(BuildContext context, {bool drawing = false}) {
  if (drawing) return Duration.zero;
  return switch (KuberMotion.levelOf(context)) {
    MotionLevel.expressive => KuberMotion.standardCurve.settle,
    MotionLevel.subtle => KuberMotion.fxDefault,
    MotionLevel.off => Duration.zero,
  };
}

Curve chartSwapCurve(BuildContext context) =>
    KuberMotion.levelOf(context) == MotionLevel.expressive
        ? KuberMotion.standardCurve.clamped
        : KuberMotion.curveEffects;

bool isDrawing(ChartProgress p) => p.linear < 1;

/// Bars rise from the baseline, staggered (30 ms, at most 6 steps).
List<BarChartGroupData> riseBars(
    List<BarChartGroupData> groups, ChartProgress p) {
  if (!isDrawing(p)) return groups;
  return [
    for (var i = 0; i < groups.length; i++)
      groups[i].copyWith(barRods: [
        for (final r in groups[i].barRods)
          r.copyWith(
            fromY: r.fromY * p.item(i),
            toY: r.toY * p.item(i),
            rodStackItems: [
              for (final s in r.rodStackItems)
                BarChartRodStackItem(
                    s.fromY * p.item(i), s.toY * p.item(i), s.color,
                    gradient: s.gradient,
                    label: s.label,
                    labelStyle: s.labelStyle,
                    borderSide: s.borderSide),
            ],
          ),
      ]),
  ];
}

/// Donut sweep: the sections fill [p.t] of the circle, the rest is an
/// invisible section so angles stay proportional.
List<PieChartSectionData> sweepSections(
    List<PieChartSectionData> sections, ChartProgress p) {
  if (!isDrawing(p) || sections.isEmpty) return sections;
  final sum = sections.fold<double>(0, (s, e) => s + e.value);
  final t = p.t.clamp(0.001, 1.0);
  return [
    ...sections,
    PieChartSectionData(
      value: sum * (1 - t) / t,
      color: Colors.transparent,
      radius: sections.first.radius,
      showTitle: false,
    ),
  ];
}

/// Line draw: reveals the chart left to right by clipping only.
class RevealX extends StatelessWidget {
  const RevealX({super.key, required this.progress, required this.child});
  final ChartProgress progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDrawing(progress)) return child;
    return ClipRect(
      clipper: _RevealClipper(progress.t),
      child: child,
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  const _RevealClipper(this.t);
  final double t;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, -2000, size.width * t, size.height + 2000);
  @override
  bool shouldReclip(_RevealClipper o) => o.t != t;
}
