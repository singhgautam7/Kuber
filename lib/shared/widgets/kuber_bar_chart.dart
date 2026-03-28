import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/settings/providers/settings_provider.dart';

class KuberBarBucket {
  final String dayLabel;    // e.g. "21"
  final String monthLabel;  // e.g. "OCT"
  final double income;
  final double expense;
  final bool isHighlighted; // true for today / last item in period

  const KuberBarBucket({
    required this.dayLabel,
    required this.monthLabel,
    required this.income,
    required this.expense,
    this.isHighlighted = false,
  });
}

class KuberBarChart extends ConsumerStatefulWidget {
  final List<KuberBarBucket> buckets;
  final String title;
  final String? subtitle;
  final double height;
  final String Function(double)? formatAmount;

  const KuberBarChart({
    super.key,
    required this.buckets,
    required this.title,
    this.subtitle,
    this.height = 200,
    this.formatAmount,
  });

  @override
  ConsumerState<KuberBarChart> createState() => _KuberBarChartState();
}

class _KuberBarChartState extends ConsumerState<KuberBarChart> {
  int _touchedGroupIndex = -1;

  // Visual gap in logical pixels
  static const double _visualGapPx = 3.0;
  // Black overlay blended into bar color when dimmed
  static const Color _dimOverlay  = Color(0x99000000); // 60% black

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(widget.subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurfaceVariant)),
                  ],
                ],
              ),
              // Legend
              Row(children: [
                _LegendDot(color: cs.tertiary, label: 'INC'),
                const SizedBox(width: 12),
                _LegendDot(color: cs.error, label: 'EXP'),
              ]),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cs = Theme.of(context).colorScheme;
                final slotWidth =
                    constraints.maxWidth / widget.buckets.length;
                final barWidth =
                    (slotWidth * 0.55).clamp(12.0, 32.0);

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _maxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.transparent,
                        tooltipPadding: EdgeInsets.zero,
                        getTooltipItem: (_, _, _, _) => null,
                      ),
                      touchCallback: (FlTouchEvent event, response) {
                        if (event is FlTapUpEvent) {
                          setState(() {
                            if (response?.spot == null) {
                              _touchedGroupIndex = -1;
                            } else {
                              final idx = response!.spot!.touchedBarGroupIndex;
                              _touchedGroupIndex = _touchedGroupIndex == idx ? -1 : idx;
                            }
                          });
                        }
                      },
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _gridInterval,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: cs.outline,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max && (value % _gridInterval) != 0) {
                              return const SizedBox.shrink();
                            }
                            final formatter = ref.watch(formatterProvider);
                            if (value == meta.min) {
                              return Text(formatter.formatCurrency(0),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant));
                            }
                            return Text(formatter.formatCompactCurrency(value),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: cs.onSurfaceVariant));
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= widget.buckets.length) {
                              return const SizedBox.shrink();
                            }
                            final b = widget.buckets[i];
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(b.dayLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: b.isHighlighted
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: b.isHighlighted
                                          ? cs.onSurface
                                          : cs.onSurfaceVariant)),
                                  Text(b.monthLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: b.isHighlighted
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: b.isHighlighted
                                          ? cs.onSurface
                                          : cs.onSurfaceVariant)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: _buildGroups(barWidth, cs),
                  ),
                );
              },
            ),
          ),

          // Detail panel
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _touchedGroupIndex != -1 && _touchedGroupIndex < widget.buckets.length
                ? _buildDetailPanel(widget.buckets[_touchedGroupIndex], cs)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(KuberBarBucket bucket, ColorScheme cs) {
    final net = bucket.income - bucket.expense;
    final maxVal = max(bucket.income, bucket.expense).clamp(1.0, double.infinity);

    String formatAmt(double val) {
      if (widget.formatAmount != null) return widget.formatAmount!(val);
      return ref.watch(formatterProvider).formatCurrency(val);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _DetailBar(
            label: 'Income',
            amount: formatAmt(bucket.income),
            ratio: bucket.income / maxVal,
            color: cs.tertiary,
          ),
          const SizedBox(height: 12),
          _DetailBar(
            label: 'Expense',
            amount: formatAmt(bucket.expense),
            ratio: bucket.expense / maxVal,
            color: cs.error,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                '${net >= 0 ? '+' : ''}${formatAmt(net)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: net >= 0 ? cs.tertiary : cs.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildGroups(double barWidth, ColorScheme cs) {
    // Gap in data terms based on the max Y value and chart height
    final double dataGap = (_maxY * _visualGapPx) / widget.height;

    return widget.buckets.asMap().entries.map((entry) {
      final i = entry.key;
      final b = entry.value;
      final isDimmed =
          _touchedGroupIndex != -1 && _touchedGroupIndex != i;

      // Determine which segment goes on top (larger value)
      final bool expenseOnTop = b.expense >= b.income;
      final double bottomVal  = expenseOnTop ? b.income   : b.expense;
      final double topVal     = expenseOnTop ? b.expense  : b.income;
      final Color  bottomColor = expenseOnTop
          ? cs.tertiary
          : cs.error;
      final Color  topColor    = expenseOnTop
          ? cs.error
          : cs.tertiary;

      // Apply dim overlay by blending black into the color
      Color applyDim(Color c) => isDimmed
          ? Color.alphaBlend(_dimOverlay, c)
          : c;

      final bool hasBottom = bottomVal > 0;
      final bool hasTop = topVal > 0;
      final double gap = (hasBottom && hasTop && topVal > bottomVal) ? dataGap : 0.0;

      double adjustedTopFrom = bottomVal + gap;
      double adjustedTopTo = topVal;

      if (hasTop && hasBottom && adjustedTopTo <= adjustedTopFrom) {
         adjustedTopTo = adjustedTopFrom + (dataGap * 0.5);
      }

      return BarChartGroupData(
        x: i,
        barsSpace: -barWidth,
        barRods: (!hasBottom && !hasTop)
            ? [
                BarChartRodData(
                  toY: 0,
                  color: Colors.transparent,
                  width: barWidth,
                )
              ]
            : [
                if (hasBottom)
                  BarChartRodData(
                    fromY: 0,
                    toY: bottomVal,
                    color: applyDim(bottomColor),
                    width: barWidth,
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                  ),
                if (hasTop)
                  BarChartRodData(
                    fromY: adjustedTopFrom,
                    toY: adjustedTopTo,
                    color: applyDim(topColor),
                    width: barWidth,
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                  ),
              ],
      );
    }).toList();
  }

  double get _maxY {
    if (widget.buckets.isEmpty) return 100;
    double maxVal = 0;
    for (final b in widget.buckets) {
      final highest = max(b.income, b.expense);
      if (highest > maxVal) maxVal = highest;
    }
    // ensure gap logic doesn't inflate max bound endlessly
    return (maxVal * 1.15).ceilToDouble();
  }

  double get _gridInterval {
    final max = _maxY;
    if (max <= 100)    return 25;
    if (max <= 500)    return 100;
    if (max <= 2000)   return 500;
    if (max <= 10000)  return 2000;
    return (max / 4).roundToDouble();
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label,
      style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w600,
        color: color)),
  ]);
}

class _DetailBar extends StatelessWidget {
  final String label;
  final String amount;
  final double ratio;
  final Color color;

  const _DetailBar({
    required this.label,
    required this.amount,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
