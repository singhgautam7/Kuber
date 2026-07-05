import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/history/providers/history_filter_provider.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../utils/chart_bucket.dart';
import 'package:go_router/go_router.dart';

export '../utils/chart_bucket.dart' show KuberChartBucket, KuberChartBucketLabel;

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

  /// Analytics-only: show the X-axis bucket dropdown next to the chart-type
  /// toggle. Hidden when there's only one available bucket.
  final bool enableBucketDropdown;
  final KuberChartBucket bucket;
  final List<KuberChartBucket> availableBuckets;
  final ValueChanged<KuberChartBucket>? onBucketChanged;

  const KuberBarChart({
    super.key,
    required this.buckets,
    required this.title,
    this.subtitle,
    this.height = 200,
    this.enableBucketDropdown = false,
    this.bucket = KuberChartBucket.day,
    this.availableBuckets = const [
      KuberChartBucket.day,
      KuberChartBucket.week,
      KuberChartBucket.month,
      KuberChartBucket.quarter,
      KuberChartBucket.year,
    ],
    this.onBucketChanged,
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

  // Drives the horizontal scroll in scroll mode. Used to auto-jump to the
  // rightmost (newest) bucket whenever the data set changes — users expect
  // to see the most recent period first, with the ability to swipe right→left
  // to view older buckets.
  final ScrollController _scrollController = ScrollController();
  int _lastBucketCount = -1;

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
    _scrollController.dispose();
    super.dispose();
  }

  /// Jumps the scroll position to the rightmost bar — used on initial render
  /// and whenever the bucket count changes (filter switch, bucket dropdown).
  void _maybeJumpToEnd() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) return;
    _scrollController.jumpTo(pos.maxScrollExtent);
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

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
                // Asymmetric padding: less on the left so the plot area
                // gets more room, with the right side keeping enough room
                // for the legend/dropdown chrome.
                padding: const EdgeInsets.fromLTRB(
                  KuberSpacing.sm,
                  KuberSpacing.lg,
                  KuberSpacing.lg,
                  KuberSpacing.lg,
                ),
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
                    // Legend (left) + chart type tabs + optional bucket dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _LegendDot(color: cs.tertiary, label: context.l10n.incShort),
                              const SizedBox(width: KuberSpacing.md),
                              _LegendDot(color: cs.error, label: context.l10n.expShort),
                            ],
                          ),
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        _ChartTypeTabs(
                          current: _chartType,
                          onChanged: _switchChartType,
                        ),
                        if (widget.enableBucketDropdown &&
                            widget.availableBuckets.length > 1) ...[
                          const SizedBox(width: KuberSpacing.sm),
                          _BucketDropdown(
                            current: widget.bucket,
                            options: widget.availableBuckets,
                            onChanged: (v) =>
                                widget.onBucketChanged?.call(v),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: KuberSpacing.lg),

                    // Chart area
                    SizedBox(
                      height: widget.height,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Decide fit vs horizontal scroll dynamically based
                          // on the viewport width and bucket count.
                          final fitCount = constraints.maxWidth <= 0
                              ? widget.buckets.length
                              : (constraints.maxWidth / _minSlotWidthDp)
                                  .floor();
                          final shouldScroll = widget.buckets.length > fitCount
                              && widget.buckets.length > 1;

                          if (shouldScroll) {
                            // Scrolling: fixed Y-axis + scrollable plot. The
                            // tooltip lives INSIDE the scroll, so its
                            // positioning math is unchanged (uses the wide
                            // plot's bucket-relative slot width).
                            final plotWidth =
                                widget.buckets.length * _minSlotWidthDp;
                            final plotConstraints = BoxConstraints(
                              maxWidth: plotWidth,
                              maxHeight: constraints.maxHeight,
                            );
                            // Post-frame: cache constraints AND auto-scroll
                            // to the rightmost (newest) bar when the bucket
                            // count changes (filter switch, bucket dropdown).
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) {
                              if (!mounted) return;
                              if (_latestConstraints != plotConstraints) {
                                setState(() {
                                  _latestConstraints = plotConstraints;
                                });
                              }
                              if (_lastBucketCount !=
                                  widget.buckets.length) {
                                _lastBucketCount = widget.buckets.length;
                                _maybeJumpToEnd();
                              }
                            });
                            return Row(
                              children: [
                                SizedBox(
                                  width: _fixedYAxisWidth,
                                  child: _YAxisColumn(
                                    maxY: _maxY,
                                    gridInterval: _gridInterval,
                                  ),
                                ),
                                Expanded(
                                  // We use a custom clipper to clip the bars horizontally (so they don't paint
                                  // over the Y-axis or right padding) but leave them unclipped vertically
                                  // so the tooltip overlay can extend above the chart bounds.
                                  child: ClipRect(
                                    clipper: const _HorizontalClipper(),
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      scrollDirection: Axis.horizontal,
                                      clipBehavior: Clip.none,
                                      child: SizedBox(
                                        width: plotWidth,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            _chartType == KuberChartType.bar
                                                ? _buildBarChart(
                                                    plotConstraints,
                                                    cs,
                                                    showLeftTitles: false,
                                                  )
                                                : _buildLineChart(
                                                    cs,
                                                    showLeftTitles: false,
                                                  ),
                                            if (_touchedIndex >= 0 &&
                                                _touchedIndex <
                                                    widget.buckets.length)
                                              _TooltipOverlay(
                                                bucket: widget
                                                    .buckets[_touchedIndex],
                                                touchedIndex: _touchedIndex,
                                                totalBuckets:
                                                    widget.buckets.length,
                                                maxWidth: plotWidth,
                                                chartHeight:
                                                    constraints.maxHeight,
                                                maxY: _maxY,
                                                slide: _detailSlide,
                                                fade: _detailFade,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          // Fit mode: the original layout — tooltip lives in
                          // the outer Stack and is offset by card padding.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted &&
                                _latestConstraints != constraints) {
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
              // Tooltip overlay (fit mode only — scroll mode renders its
              // own tooltip inside the scrollable above).
              if (_touchedIndex >= 0 &&
                  _touchedIndex < widget.buckets.length &&
                  _latestConstraints != null &&
                  widget.buckets.length <=
                      ((_latestConstraints!.maxWidth /
                                  _minSlotWidthDp)
                              .floor()
                          .clamp(1, widget.buckets.length)))
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
  // Horizontal scroll config
  // ---------------------------------------------------------------------------

  /// Minimum width per bar slot. When the total plot can't fit this many
  /// pixels per bar in the viewport, we switch to horizontal scroll.
  static const double _minSlotWidthDp = 36.0;

  /// Width of the fixed Y-axis column in scroll mode. Kept compact so the
  /// plot area gets as much horizontal room as possible.
  static const double _fixedYAxisWidth = 32.0;

  // ---------------------------------------------------------------------------
  // Shared axis titles
  // ---------------------------------------------------------------------------

  /// Build [FlTitlesData] for the chart.
  /// When [showLeftTitles] is false, the Y-axis labels are hidden — used in
  /// horizontal-scroll mode where the Y-axis lives outside the scroll.
  FlTitlesData _titlesData(
    ColorScheme cs,
    TextTheme tt, {
    bool showLeftTitles = true,
  }) {
    final axisStyle = tt.labelSmall?.copyWith(
      fontSize: 10,
      color: cs.onSurfaceVariant,
    );

    return FlTitlesData(
      // In horizontal-scroll mode the Y-axis is rendered externally as a
      // fixed column. We pass a fully-empty AxisTitles here so fl_chart
      // doesn't auto-generate any left titles inside the plot area.
      leftTitles: showLeftTitles
          ? AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                // Force the label interval to match our gridline interval,
                // otherwise fl_chart auto-picks an interval that produces
                // odd values (e.g. 18, 37, 56) which don't align with the
                // visible gridlines.
                interval: _gridInterval,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max && (value % _gridInterval) != 0) {
                    return const SizedBox.shrink();
                  }
                  final formatter = ref.watch(formatterProvider);
                  final isPrivate = ref.watch(privacyModeProvider);
                  // No ₹ symbol on axis labels — keeps the column narrow
                  // so the plot gets more room. Currency is unambiguous
                  // from the tooltip and summary cards above.
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      maskAmount(
                        formatter.formatCompactCurrency(value, symbol: ''),
                        isPrivate,
                      ),
                      style: axisStyle,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            )
          : const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
          // interval: 1 prevents fl_chart from emitting fractional ticks
          // (which truncate to the same bucket index and render duplicate
          // X-axis labels in line mode).
          interval: 1,
          getTitlesWidget: (value, meta) {
            // Only render a label when value sits exactly on an integer tick.
            if ((value - value.roundToDouble()).abs() > 0.001) {
              return const SizedBox.shrink();
            }
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

  Widget _buildBarChart(
    BoxConstraints constraints,
    ColorScheme cs, {
    bool showLeftTitles = true,
  }) {
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
        titlesData: _titlesData(
          cs,
          Theme.of(context).textTheme,
          showLeftTitles: showLeftTitles,
        ),
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

  Widget _buildLineChart(ColorScheme cs, {bool showLeftTitles = true}) {
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
        titlesData: _titlesData(
          cs,
          Theme.of(context).textTheme,
          showLeftTitles: showLeftTitles,
        ),
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

    // Whole-number, locale-aware currency. Strip trailing ".00" for the
    // common "1234.00" → "1234" case.
    String whole(double v) =>
        formatter.formatCurrency(v.roundToDouble()).replaceAll('.00', '');

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
                        label: context.l10n.incomeLabel,
                        amount: maskAmount('+${whole(bucket.income)}', isPrivate),
                        color: cs.tertiary,
                        labelColor: cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      _TooltipRow(
                        label: context.l10n.expenseLabel,
                        amount: maskAmount('-${whole(bucket.expense)}', isPrivate),
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
                        label: context.l10n.netLabel,
                        amount: maskAmount(
                            (net >= 0 ? whole(net) : '-${whole(net.abs())}'),
                            isPrivate),
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
                                context.l10n.viewTransactions,
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

/// Fixed Y-axis column shown when the chart enters horizontal-scroll mode.
/// Renders the same gridline values as the in-chart Y-axis would, but stays
/// pinned outside the scrollable plot.
class _YAxisColumn extends ConsumerWidget {
  final double maxY;
  final double gridInterval;
  const _YAxisColumn({required this.maxY, required this.gridInterval});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final formatter = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final style = tt.labelSmall?.copyWith(
      fontSize: 10,
      color: cs.onSurfaceVariant,
    );

    // Build tick values from 0 → maxY at every gridInterval.
    final ticks = <double>[];
    for (var v = 0.0; v <= maxY + 0.001; v += gridInterval) {
      ticks.add(v);
    }

    return LayoutBuilder(
      builder: (context, c) {
        // The plot area inside fl_chart sits *above* the bottom-titles
        // reserved height. Match that here so labels line up with gridlines.
        const bottomTitlesReserved = 42.0;
        final plotHeight = (c.maxHeight - bottomTitlesReserved).clamp(0.0, c.maxHeight);
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final v in ticks)
                Positioned(
                  right: 0,
                  top: plotHeight - (plotHeight * (v / (maxY == 0 ? 1 : maxY))) - 6,
                  // Drop the currency symbol on the Y-axis labels — the
                  // ₹ prefix doubles label width and forces the column to
                  // grow, eating into the plot area. Tooltip + summary
                  // already make the currency explicit.
                  child: Text(
                    maskAmount(
                      formatter.formatCompactCurrency(v, symbol: ''),
                      isPrivate,
                    ),
                    style: style,
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// X-axis bucket dropdown — shown only when `enableBucketDropdown` is true
/// and there's more than one option available for the current date range.
/// All five values are always rendered as menu items, with disabled rows
/// dimmed.
class _BucketDropdown extends StatelessWidget {
  final KuberChartBucket current;
  final List<KuberChartBucket> options;
  final ValueChanged<KuberChartBucket> onChanged;

  const _BucketDropdown({
    required this.current,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<KuberChartBucket>(
      offset: const Offset(0, 36),
      tooltip: 'X-axis bucket',
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final b in KuberChartBucket.values)
          PopupMenuItem(
            value: b,
            enabled: options.contains(b),
            child: Row(
              children: [
                Icon(
                  current == b ? Icons.check_rounded : Icons.remove_rounded,
                  size: 16,
                  color: current == b
                      ? cs.primary
                      : cs.onSurfaceVariant.withValues(alpha: 0.0),
                ),
                const SizedBox(width: 8),
                Text(
                  b.label,
                  style: localeFont(
                    fontSize: 13,
                    fontWeight:
                        current == b ? FontWeight.w700 : FontWeight.w500,
                    color: options.contains(b)
                        ? cs.onSurface
                        : cs.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.sm),
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current.label,
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.unfold_more_rounded,
                size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _HorizontalClipper extends CustomClipper<Rect> {
  const _HorizontalClipper();

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, -2000, size.width, size.height + 2000);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
