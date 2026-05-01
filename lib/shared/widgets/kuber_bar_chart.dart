import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/history/providers/history_filter_provider.dart';
import '../../features/settings/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class KuberBarBucket {
  final String dayLabel;    // e.g. "21"
  final String monthLabel;  // e.g. "OCT"
  final double income;
  final double expense;
  final bool isHighlighted; // true for today / last item in period
  final DateTime? date;
  final DateTime? endDate;

  const KuberBarBucket({
    required this.dayLabel,
    required this.monthLabel,
    required this.income,
    required this.expense,
    this.isHighlighted = false,
    this.date,
    this.endDate,
  });
}

// ---------------------------------------------------------------------------
// Chart type enum
// ---------------------------------------------------------------------------

enum KuberChartType { bar, line }

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

class KuberBarChart extends ConsumerStatefulWidget {
  final List<KuberBarBucket> buckets;
  final String title;
  final String? subtitle;
  final double height;

  const KuberBarChart({
    super.key,
    required this.buckets,
    required this.title,
    this.subtitle,
    this.height = 200,
  });

  @override
  ConsumerState<KuberBarChart> createState() => _KuberBarChartState();
}

class _KuberBarChartState extends ConsumerState<KuberBarChart>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  KuberChartType _chartType = KuberChartType.bar;

  late final AnimationController _detailAnim;
  late final Animation<double> _detailFade;
  late final Animation<Offset> _detailSlide;
  BoxConstraints? _latestConstraints;

  // Visual gap between stacked bar segments (data-space units)
  static const double _segmentGap = 2.0;

  @override
  void initState() {
    super.initState();
    _detailAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _detailFade = CurvedAnimation(parent: _detailAnim, curve: Curves.easeOut);
    _detailSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _detailAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _detailAnim.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      if (_touchedIndex == index) {
        _touchedIndex = -1;
        _detailAnim.reverse();
      } else {
        _touchedIndex = index;
        _detailAnim.forward();
      }
    });
  }

  void _switchChartType(KuberChartType type) {
    if (type == _chartType) return;
    setState(() {
      _chartType = type;
      _touchedIndex = -1;
      _detailAnim.reverse();
    });
  }

  // ---------------------------------------------------------------------------
  // Computed helpers
  // ---------------------------------------------------------------------------

  double get _maxY {
    if (widget.buckets.isEmpty) return 100;
    double maxVal = 0;
    for (final b in widget.buckets) {
      final highest = max(b.income, b.expense);
      if (highest > maxVal) maxVal = highest;
    }
    return (maxVal * 1.15).ceilToDouble();
  }

  double get _gridInterval {
    final m = _maxY;
    if (m <= 100) return 25;
    if (m <= 500) return 100;
    if (m <= 2000) return 500;
    if (m <= 10000) return 2000;
    return (m / 4).roundToDouble();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + subtitle ABOVE the card
        Text(
          widget.title,
          style: tt.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.subtitle!,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: KuberSpacing.sm),

        // Card container
        TapRegion(
          onTapOutside: (_) {
            if (_touchedIndex != -1) {
              setState(() => _touchedIndex = -1);
              _detailAnim.reverse();
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(KuberSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(
                    color: cs.outline.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Legend (left) + chart type tabs (right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _LegendDot(color: cs.tertiary, label: 'INC'),
                              const SizedBox(width: KuberSpacing.md),
                              _LegendDot(color: cs.error, label: 'EXP'),
                            ],
                          ),
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        _ChartTypeTabs(
                          current: _chartType,
                          onChanged: _switchChartType,
                        ),
                      ],
                    ),

                    const SizedBox(height: KuberSpacing.lg),

                    // Chart area
                    SizedBox(
                      height: widget.height,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _latestConstraints != constraints) {
                              setState(() {
                                _latestConstraints = constraints;
                              });
                            }
                          });
                          return _chartType == KuberChartType.bar
                              ? _buildBarChart(constraints, cs)
                              : _buildLineChart(cs);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Tooltip overlay
              if (_touchedIndex >= 0 &&
                  _touchedIndex < widget.buckets.length &&
                  _latestConstraints != null)
                _TooltipOverlay(
                  bucket: widget.buckets[_touchedIndex],
                  touchedIndex: _touchedIndex,
                  totalBuckets: widget.buckets.length,
                  maxWidth: _latestConstraints!.maxWidth,
                  chartHeight: _latestConstraints!.maxHeight,
                  maxY: _maxY,
                  slide: _detailSlide,
                  fade: _detailFade,
                  bottomOffset: KuberSpacing.lg,
                  leftOffset: KuberSpacing.lg,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared axis titles
  // ---------------------------------------------------------------------------

  FlTitlesData _titlesData(ColorScheme cs, TextTheme tt) {
    final axisStyle = tt.labelSmall?.copyWith(
      fontSize: 10,
      color: cs.onSurfaceVariant,
    );

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          getTitlesWidget: (value, meta) {
            if (value == meta.max && (value % _gridInterval) != 0) {
              return const SizedBox.shrink();
            }
            final formatter = ref.watch(formatterProvider);
            final isPrivate = ref.watch(privacyModeProvider);
            if (value == meta.min) {
              return Text(
                maskAmount(formatter.formatCurrency(0), isPrivate),
                style: axisStyle,
              );
            }
            return Text(
              maskAmount(formatter.formatCompactCurrency(value), isPrivate),
              style: axisStyle,
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
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
                  Text(
                    b.dayLabel,
                    style: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    b.monthLabel,
                    style: tt.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  FlGridData _gridData(ColorScheme cs) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: _gridInterval,
      getDrawingHorizontalLine: (_) => FlLine(
        color: cs.outline,
        strokeWidth: 1,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bar chart
  // ---------------------------------------------------------------------------

  Widget _buildBarChart(BoxConstraints constraints, ColorScheme cs) {
    final slotWidth = constraints.maxWidth / widget.buckets.length;
    final barWidth = (slotWidth * 0.55).clamp(12.0, 32.0);
    final double dataGap = (_maxY * _segmentGap) / widget.height;

    return RepaintBoundary(
      child: BarChart(
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
              if (response?.spot == null) {
                _onTap(-1);
              } else {
                _onTap(response!.spot!.touchedBarGroupIndex);
              }
            }
          },
        ),
        gridData: _gridData(cs),
        borderData: FlBorderData(show: false),
        titlesData: _titlesData(cs, Theme.of(context).textTheme),
        barGroups: _buildBarGroups(barWidth, dataGap, cs),
      ),
    ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
      double barWidth, double dataGap, ColorScheme cs) {

    return widget.buckets.asMap().entries.map((entry) {
      final i = entry.key;
      final b = entry.value;
      final isDimmed = _touchedIndex != -1 && _touchedIndex != i;

      final bool expenseOnTop = b.expense >= b.income;
      final double bottomVal = expenseOnTop ? b.income : b.expense;
      final double topVal = expenseOnTop ? b.expense : b.income;
      final Color bottomColor = expenseOnTop ? cs.tertiary : cs.error;
      final Color topColor = expenseOnTop ? cs.error : cs.tertiary;

      Color applyDim(Color c) => isDimmed
          ? Color.lerp(cs.surfaceContainer, cs.onSurface, 0.15)!.withValues(alpha: 1.0)
          : c;

      final bool hasBottom = bottomVal > 0;
      final bool hasTop = topVal > 0;
      final double gap =
          (hasBottom && hasTop && topVal > bottomVal) ? dataGap : 0.0;

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
                ),
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

  // ---------------------------------------------------------------------------
  // Line chart
  // ---------------------------------------------------------------------------

  Widget _buildLineChart(ColorScheme cs) {
    return RepaintBoundary(
      child: LineChart(
      LineChartData(
        maxY: _maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            getTooltipItems: (_) => [null, null],
          ),
          touchCallback: (FlTouchEvent event, response) {
            if (event is FlTapUpEvent) {
              if (response?.lineBarSpots == null ||
                  response!.lineBarSpots!.isEmpty) {
                _onTap(-1);
              } else {
                _onTap(response.lineBarSpots!.first.spotIndex);
              }
            } else if (event is FlPanUpdateEvent) {
              if (response?.lineBarSpots != null &&
                  response!.lineBarSpots!.isNotEmpty) {
                final idx = response.lineBarSpots!.first.spotIndex;
                if (idx != _touchedIndex) {
                  setState(() {
                    _touchedIndex = idx;
                  });
                  _detailAnim.forward();
                }
              }
            } else if (event is FlPanEndEvent) {
              setState(() {
                _touchedIndex = -1;
              });
              _detailAnim.reverse();
            }
          },
        ),
        gridData: _gridData(cs),
        borderData: FlBorderData(show: false),
        titlesData: _titlesData(cs, Theme.of(context).textTheme),
        lineBarsData: [
          _lineData(
            cs.tertiary,
            widget.buckets.map((b) => b.income).toList(),
          ),
          _lineData(
            cs.error,
            widget.buckets.map((b) => b.expense).toList(),
          ),
        ],
      ),
    ),
    );
  }

  LineChartBarData _lineData(Color color, List<double> values) {
    return LineChartBarData(
      isCurved: false,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, __, ___) {
          final isSelected = spot.x.toInt() == _touchedIndex;
          final cs = Theme.of(context).colorScheme;
          return FlDotCirclePainter(
            radius: isSelected ? 5 : 3,
            color: color,
            strokeWidth: isSelected ? 2 : 0,
            strokeColor: cs.surface,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
      spots: values
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ]);
}

class _ChartTypeTabs extends StatelessWidget {
  final KuberChartType current;
  final ValueChanged<KuberChartType> onChanged;

  const _ChartTypeTabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChartTypeTab(
            icon: Icons.bar_chart_rounded,
            isActive: current == KuberChartType.bar,
            onTap: () => onChanged(KuberChartType.bar),
          ),
          _ChartTypeTab(
            icon: Icons.show_chart_rounded,
            isActive: current == KuberChartType.line,
            onTap: () => onChanged(KuberChartType.line),
          ),
        ],
      ),
    );
  }
}

class _ChartTypeTab extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ChartTypeTab({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.sm,
          vertical: KuberSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive ? cs.surfaceContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(KuberRadius.sm),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? cs.primary : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _TooltipOverlay extends ConsumerWidget {
  final KuberBarBucket bucket;
  final int touchedIndex;
  final int totalBuckets;
  final double maxWidth;
  final double chartHeight;
  final double maxY;
  final Animation<Offset> slide;
  final Animation<double> fade;
  final double leftOffset;
  final double bottomOffset;

  const _TooltipOverlay({
    required this.bucket,
    required this.touchedIndex,
    required this.totalBuckets,
    required this.maxWidth,
    required this.chartHeight,
    required this.maxY,
    required this.slide,
    required this.fade,
    this.leftOffset = 0,
    this.bottomOffset = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final net = bucket.income - bucket.expense;
    final tt = Theme.of(context).textTheme;

    final double cardWidth = 160;
    final double slotWidth = maxWidth / totalBuckets;
    final double barCenter = (touchedIndex + 0.5) * slotWidth;

    double leftPos = barCenter - (cardWidth / 2);
    leftPos = leftPos.clamp(8.0, maxWidth - cardWidth - 8.0);

    double pointerOffset = barCenter - leftPos - 6; // 6 is half of pointer width
    pointerOffset = pointerOffset.clamp(8.0, cardWidth - 20.0);

    // Calculate dynamic bottom position over the bar
    final bool expenseOnTop = bucket.expense >= bucket.income;
    final double bottomVal = expenseOnTop ? bucket.income : bucket.expense;
    final double topVal = expenseOnTop ? bucket.expense : bucket.income;
    final double barGap = (bottomVal > 0 && topVal > 0 && topVal > bottomVal) ? 2.0 : 0.0;
    
    double adjustedTopTo = topVal;
    if (barGap > 0 && adjustedTopTo <= bottomVal + barGap) {
      adjustedTopTo = bottomVal + barGap + 1.0; 
    }
    double barMaxY = adjustedTopTo;
    if (barMaxY == 0 && bottomVal > 0) barMaxY = bottomVal;
    if (barMaxY == 0) barMaxY = maxY * 0.05; // min height for empty days

    final double barHeightRatio = (barMaxY / maxY).clamp(0.0, 1.0);
    final double drawingAreaHeight = chartHeight - 42; // reservedSize = 42 for bottom axis titles
    final double bottomPos = 42 + (barHeightRatio * drawingAreaHeight) + 8.0;

    return Positioned(
      left: leftPos + leftOffset,
      bottom: bottomPos + bottomOffset,
      child: SlideTransition(
        position: slide,
        child: FadeTransition(
          opacity: fade,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: SizedBox(
              width: cardWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.md,
                    vertical: KuberSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${bucket.dayLabel} ${bucket.monthLabel}'.toUpperCase(),
                        style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      _TooltipRow(
                        label: 'Income',
                        amount: maskAmount('+${formatter.formatCurrency(bucket.income)}', isPrivate),
                        color: cs.tertiary,
                        labelColor: cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      _TooltipRow(
                        label: 'Expense',
                        amount: maskAmount('-${formatter.formatCurrency(bucket.expense)}', isPrivate),
                        color: cs.error,
                        labelColor: cs.onSurfaceVariant,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: cs.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      _TooltipRow(
                        label: 'Net',
                        amount: maskAmount(formatter.formatCurrency(net), isPrivate),
                        color: cs.onSurface,
                        labelColor: cs.onSurface,
                        isBold: true,
                      ),
                      if (bucket.date != null) ...[
                        const SizedBox(height: KuberSpacing.sm),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: cs.outline.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: KuberSpacing.sm),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            final d = bucket.date!;
                            final e = bucket.endDate ?? d;
                            ref.read(historyFilterProvider.notifier).clearAll();
                            ref.read(historyFilterProvider.notifier).setFilters(
                              from: DateTime(d.year, d.month, d.day),
                              to: DateTime(e.year, e.month, e.day, 23, 59, 59),
                            );
                            context.go('/history');
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Transactions',
                                style: tt.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_outward_rounded, size: 12, color: cs.primary),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _TooltipRow extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final Color labelColor;
  final bool isBold;

  const _TooltipRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.labelColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.labelMedium?.copyWith(
            color: labelColor,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: tt.labelMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
