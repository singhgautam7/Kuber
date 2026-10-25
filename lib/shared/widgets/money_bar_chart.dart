// Bar chart for the money full-screen pages (summary-sheet.md chart rules):
// single or stacked bars, one bar selected (others at 38%) or bars after an
// index faded to 50% (future years), compact labels on the right, dashed
// gridlines, solid baseline. fl_chart, like the rest of Kuber's charts.

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/settings_provider.dart';

class MoneyBar {
  final String label;

  /// Stack segments bottom to top.
  final List<double> values;
  const MoneyBar(this.label, this.values);
  double get total => values.fold(0.0, (s, v) => s + v);
}

class MoneyBarChart extends ConsumerWidget {
  final List<MoneyBar> bars;
  final List<Color> colors;
  final int? selected;
  final int? fadeFrom;
  final double height;

  const MoneyBarChart({
    super.key,
    required this.bars,
    required this.colors,
    this.selected,
    this.fadeFrom,
    this.height = 132,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final maxY = max(1.0, bars.fold(0.0, (m, b) => max(m, b.total))) * 1.1;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final width = bars.length > 14 ? 8.0 : 14.0;
    return SizedBox(
      height: height + 24,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          borderData: FlBorderData(
            show: true,
            border: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: cs.outlineVariant, strokeWidth: 1, dashArray: [4, 4]),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY / 3,
                getTitlesWidget: (v, meta) => v == meta.max
                    ? const SizedBox.shrink()
                    : Text(fmt.formatCompactCurrency(v),
                        style: tt.labelSmall!.copyWith(color: cs.onSurfaceVariant)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= bars.length) return const SizedBox.shrink();
                  final every = (bars.length / 6).ceil();
                  if (i % every != 0 && i != selected) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(bars[i].label,
                        style: tt.labelSmall!.copyWith(
                            color: i == selected ? cs.onSurface : cs.onSurfaceVariant,
                            fontWeight: i == selected ? FontWeight.w700 : null)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < bars.length; i++)
              BarChartGroupData(x: i, barRods: [
                () {
                  final alpha = selected != null && i != selected
                      ? 0.38
                      : (fadeFrom != null && i >= fadeFrom! ? 0.5 : 1.0);
                  var from = 0.0;
                  final stack = <BarChartRodStackItem>[];
                  for (var s = 0; s < bars[i].values.length; s++) {
                    final to = from + bars[i].values[s];
                    stack.add(BarChartRodStackItem(
                        from, to, colors[s % colors.length].withValues(alpha: alpha)));
                    from = to;
                  }
                  return BarChartRodData(
                    toY: bars[i].total,
                    width: width,
                    rodStackItems: stack,
                    color: colors.first.withValues(alpha: alpha),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  );
                }(),
              ]),
          ],
        ),
        duration: reduce ? Duration.zero : const Duration(milliseconds: 300),
      ),
    );
  }
}
