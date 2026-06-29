import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';

class ChartSeries {
  final String name;
  final List<double> points;
  final Color color;
  final bool dashed;
  final bool fill;

  const ChartSeries({
    required this.name,
    required this.points,
    required this.color,
    this.dashed = false,
    this.fill = false,
  });
}

/// A line chart with 1–2 series, subtle gridlines, compact ₹ Y-axis labels, an
/// optional dashed horizontal reference line (target / "without prepayment" /
/// real value) and a tap/drag tooltip. Mirrors the Analytics tab styling.
class ToolLineChart extends ConsumerStatefulWidget {
  final List<ChartSeries> series;
  final List<String> xLabels;
  final double? target;
  final Color? targetColor;
  final String? targetLabel;
  final double height;

  const ToolLineChart({
    super.key,
    required this.series,
    required this.xLabels,
    this.target,
    this.targetColor,
    this.targetLabel,
    this.height = 180,
  });

  @override
  ConsumerState<ToolLineChart> createState() => _ToolLineChartState();
}

class _ToolLineChartState extends ConsumerState<ToolLineChart> {
  int? _touchedX;

  double get _maxY {
    double m = 0;
    for (final s in widget.series) {
      for (final v in s.points) {
        if (v > m) m = v;
      }
    }
    if (widget.target != null && widget.target! > m) m = widget.target!;
    return m <= 0 ? 1 : m * 1.08;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final maxY = _maxY;
    final n = widget.xLabels.length;
    final targetColor = widget.targetColor ?? cs.tertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          child: RepaintBoundary(
            child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY,
              minX: 0,
              maxX: (n - 1).toDouble().clamp(0, double.infinity),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: maxY / 4,
                verticalInterval: max(1, (n / 5).ceilToDouble()),
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: cs.outline.withValues(alpha: 0.5), strokeWidth: 1),
                getDrawingVerticalLine: (_) =>
                    FlLine(color: cs.outline.withValues(alpha: 0.25), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 38,
                    interval: maxY / 2,
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value > maxY) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          formatter.formatCompactCurrency(value,
                              symbol: currency.symbol),
                          style: localeFont(
                              fontSize: 8.5, color: cs.onSurfaceVariant),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    interval: max(1, (n / 5).ceilToDouble()),
                    getTitlesWidget: (value, meta) {
                      final i = value.round();
                      if (i < 0 || i >= n) return const SizedBox.shrink();
                      if ((value - i).abs() > 0.01) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          widget.xLabels[i],
                          style: localeFont(
                              fontSize: 9, color: cs.onSurfaceVariant),
                        ),
                      );
                    },
                  ),
                ),
              ),
              extraLinesData: widget.target == null
                  ? const ExtraLinesData()
                  : ExtraLinesData(horizontalLines: [
                      HorizontalLine(
                        y: widget.target!,
                        color: targetColor,
                        strokeWidth: 1.4,
                        dashArray: [5, 4],
                      ),
                    ]),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => cs.surfaceContainerHigh,
                  getTooltipItems: (spots) => spots.map((s) {
                    final series = widget.series[s.barIndex];
                    return LineTooltipItem(
                      '${series.name}\n',
                      localeFont(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600),
                      children: [
                        TextSpan(
                          text: formatter.formatCurrency(s.y.roundToDouble(),
                              symbol: currency.symbol),
                          style: localeFont(
                              fontSize: 12,
                              color: series.color,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                touchCallback: (event, resp) {
                  if (resp?.lineBarSpots != null &&
                      resp!.lineBarSpots!.isNotEmpty) {
                    setState(() => _touchedX = resp.lineBarSpots!.first.x.round());
                  } else if (event is FlTapUpEvent || event is FlPanEndEvent) {
                    setState(() => _touchedX = null);
                  }
                },
              ),
              lineBarsData: [
                for (final s in widget.series)
                  LineChartBarData(
                    isCurved: true,
                    preventCurveOverShooting: true,
                    curveSmoothness: 0.2,
                    color: s.color,
                    barWidth: 2.4,
                    isStrokeCapRound: true,
                    dashArray: s.dashed ? [5, 4] : null,
                    dotData: FlDotData(
                      show: _touchedX != null,
                      checkToShowDot: (spot, _) => spot.x.round() == _touchedX,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: s.color,
                        strokeWidth: 2,
                        strokeColor: cs.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: s.fill,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          s.color.withValues(alpha: 0.18),
                          s.color.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    spots: [
                      for (var i = 0; i < s.points.length; i++)
                        FlSpot(i.toDouble(), s.points[i]),
                    ],
                  ),
              ],
            ),
          ),
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        Wrap(
          spacing: KuberSpacing.lg,
          runSpacing: KuberSpacing.sm,
          children: [
            for (final s in widget.series)
              _LegendItem(color: s.color, label: s.name, dashed: s.dashed),
            if (widget.targetLabel != null)
              _LegendItem(
                  color: targetColor, label: widget.targetLabel!, dashed: true),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _LegendItem(
      {required this.color, required this.label, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
            color: dashed ? null : color,
            borderRadius: BorderRadius.circular(2),
            border: dashed ? Border.all(color: color, width: 1) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: localeFont(fontSize: 11.5, color: cs.onSurfaceVariant)),
      ],
    );
  }
}
