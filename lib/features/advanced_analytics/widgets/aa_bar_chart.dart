import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';

/// One x-axis slot. [previous] is null for single-series charts (e.g. category
/// spend-over-time, weekday); when set, the slot renders a previous + current
/// pair and the tooltip compares them.
class AaBarDatum {
  final String label;
  final double current;
  final double? previous;

  const AaBarDatum({required this.label, required this.current, this.previous});
}

/// Shared Advanced Analytics bar chart, matching the Home/Analytics chart:
/// transparent (theme) background, a Y-axis, fixed-width bars that scroll
/// horizontally when they overflow, and a floating tooltip on tap that stays
/// clamped inside the chart (never clips at the edges).
class AaBarChart extends ConsumerStatefulWidget {
  final List<AaBarDatum> data;
  final String currentLabel;
  final String previousLabel;
  final Color? currentColor;
  final Color? previousColor;
  final double height;

  /// Show the Y-axis. Off for the weekday chart (always 7 bars, no axis).
  final bool showYAxis;

  /// Allow horizontal scroll + fixed bar width when overflowing. Off for the
  /// weekday chart (always fits 7 bars to the width).
  final bool scrollable;

  /// When set (single-series only), that bar is drawn in [currentColor] and the
  /// rest muted — used to highlight the peak weekday.
  final int? highlightIndex;

  /// Draw the card border. Off when the chart is embedded inside another
  /// bordered card (avoids a double border).
  final bool showBorder;

  const AaBarChart({
    super.key,
    required this.data,
    this.currentLabel = 'Current',
    this.previousLabel = 'Previous',
    this.currentColor,
    this.previousColor,
    this.height = 210,
    this.showYAxis = true,
    this.scrollable = true,
    this.highlightIndex,
    this.showBorder = true,
  });

  @override
  ConsumerState<AaBarChart> createState() => _AaBarChartState();
}

class _AaBarChartState extends ConsumerState<AaBarChart> {
  int _touched = -1;
  final _scroll = ScrollController();
  int _lastCount = -1;

  static const double _yAxisWidth = 40.0;
  static const double _bottomReserved = 26.0;
  static const double _cardWidth = 150.0;

  // Adaptive geometry so the intra-group gap is always SMALLER than the
  // inter-group gap. For dual (this year / last year) the group is kept narrow
  // (2 slim bars + a small gap) inside a wider slot; for single series the bar
  // is wide inside a snug slot so bars read close together (design 2b).
  double get _barWidth => _hasPrevious ? 15.0 : 28.0;
  double get _barsSpace => _hasPrevious ? 3.0 : 0.0;
  double get _slotWidth => _hasPrevious ? 58.0 : 52.0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeJumpToEnd() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.maxScrollExtent <= 0) return;
    _scroll.jumpTo(pos.maxScrollExtent);
  }

  bool get _hasPrevious => widget.data.any((d) => d.previous != null);

  double get _maxY {
    var m = 0.0;
    for (final d in widget.data) {
      m = math.max(m, d.current);
      if (d.previous != null) m = math.max(m, d.previous!);
    }
    if (m <= 0) return 100;
    return (m * 1.15).ceilToDouble();
  }

  // ~4 gridlines at a "nice" (1/2/5 x 10^n) interval, so the Y-axis always
  // has several labels regardless of the value magnitude.
  double get _gridInterval {
    final raw = _maxY / 4;
    if (raw <= 0) return 25;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final norm = raw / mag;
    final nice = norm <= 1
        ? 1.0
        : norm <= 2
            ? 2.0
            : norm <= 5
                ? 5.0
                : 10.0;
    return nice * mag;
  }

  void _onTap(int i) => setState(() => _touched = _touched == i ? -1 : i);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final currentColor = widget.currentColor ?? cs.primary;
    final previousColor = widget.previousColor ?? cs.outlineVariant;

    String money(double v) => maskAmount(
      formatter.formatCurrency(v.roundToDouble()).replaceAll('.00', ''),
      isPrivate,
    );

    return TapRegion(
      onTapOutside: (_) {
        if (_touched != -1) setState(() => _touched = -1);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          KuberSpacing.sm,
          KuberSpacing.lg,
          KuberSpacing.md,
          KuberSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: widget.showBorder ? Border.all(color: cs.outline) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasPrevious)
              Padding(
                padding: const EdgeInsets.only(
                  left: KuberSpacing.sm,
                  bottom: KuberSpacing.md,
                ),
                child: Row(
                  children: [
                    _LegendDot(color: previousColor, label: widget.previousLabel),
                    const SizedBox(width: KuberSpacing.md),
                    _LegendDot(color: currentColor, label: widget.currentLabel),
                  ],
                ),
              ),
            SizedBox(
              height: widget.height,
              child: LayoutBuilder(
                builder: (context, c) {
                  final needScroll = widget.scrollable &&
                      widget.data.length * _slotWidth > c.maxWidth &&
                      widget.data.length > 1;

                  if (!needScroll) {
                    final plotLeft = widget.showYAxis ? _yAxisWidth : 0.0;
                    final slot = widget.data.isEmpty
                        ? 0.0
                        : (c.maxWidth - plotLeft) / widget.data.length;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _chart(
                          cs,
                          formatter,
                          isPrivate,
                          currentColor,
                          previousColor,
                          showLeftTitles: widget.showYAxis,
                        ),
                        if (_touched >= 0 && _touched < widget.data.length)
                          _tooltip(
                            cs,
                            money,
                            currentColor,
                            previousColor,
                            left: (plotLeft +
                                    (_touched + 0.5) * slot -
                                    _cardWidth / 2)
                                .clamp(0.0, math.max(0.0, c.maxWidth - _cardWidth)),
                          ),
                      ],
                    );
                  }

                  final plotWidth = widget.data.length * _slotWidth;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    if (_lastCount != widget.data.length) {
                      _lastCount = widget.data.length;
                      _maybeJumpToEnd();
                    }
                  });
                  return Row(
                    children: [
                      if (widget.showYAxis)
                        SizedBox(
                          width: _yAxisWidth,
                          child: _YAxis(
                            maxY: _maxY,
                            interval: _gridInterval,
                            bottomReserved: _bottomReserved,
                          ),
                        ),
                      Expanded(
                        // Clip horizontally so scrolled-off bars don't bleed
                        // over the Y-axis / edges. The tooltip lives inside and
                        // sits within the chart height, so it isn't clipped.
                        child: ClipRect(
                          child: SingleChildScrollView(
                            controller: _scroll,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: plotWidth,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                _chart(
                                  cs,
                                  formatter,
                                  isPrivate,
                                  currentColor,
                                  previousColor,
                                  showLeftTitles: false,
                                ),
                                if (_touched >= 0 &&
                                    _touched < widget.data.length)
                                  _tooltip(
                                    cs,
                                    money,
                                    currentColor,
                                    previousColor,
                                    left: ((_touched + 0.5) * _slotWidth -
                                            _cardWidth / 2)
                                        .clamp(0.0,
                                            math.max(0.0, plotWidth - _cardWidth)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tooltip(
    ColorScheme cs,
    String Function(double) money,
    Color currentColor,
    Color previousColor, {
    required double left,
  }) {
    final d = widget.data[_touched];
    final prev = d.previous;
    final change =
        (prev == null || prev <= 0) ? 0.0 : ((d.current - prev) / prev) * 100;
    final up = change > 0;

    Widget row(String k, String v, Color color, {bool bold = false}) => Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: localeFont(fontSize: 11, color: cs.onSurfaceVariant)),
          Text(
            v,
            style: localeFont(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );

    return Positioned(
      left: left,
      top: 0,
      width: _cardWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md,
          vertical: KuberSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              d.label.toUpperCase(),
              style: localeFont(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: cs.onSurfaceVariant,
              ),
            ),
            row(widget.currentLabel, money(d.current), cs.onSurface),
            if (prev != null) ...[
              row(widget.previousLabel, money(prev), cs.onSurfaceVariant),
              row(
                'Change',
                '${up ? '+' : ''}${change.toStringAsFixed(1)}%',
                up ? cs.error : cs.tertiary,
                bold: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chart(
    ColorScheme cs,
    dynamic formatter,
    bool isPrivate,
    Color currentColor,
    Color previousColor, {
    required bool showLeftTitles,
  }) {
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
              getTooltipItem: (_, __, ___, ____) => null,
            ),
            touchCallback: (event, response) {
              if (event is FlTapUpEvent) {
                _onTap(response?.spot?.touchedBarGroupIndex ?? -1);
              }
            },
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _gridInterval,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: cs.outline.withValues(alpha: 0.5), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: _titles(cs, formatter, isPrivate, showLeftTitles),
          barGroups: _groups(cs, currentColor, previousColor),
        ),
      ),
    );
  }

  List<BarChartGroupData> _groups(
    ColorScheme cs,
    Color currentColor,
    Color previousColor,
  ) {
    return [
      for (var i = 0; i < widget.data.length; i++)
        _group(i, cs, currentColor, previousColor),
    ];
  }

  BarChartGroupData _group(
    int i,
    ColorScheme cs,
    Color currentColor,
    Color previousColor,
  ) {
    final d = widget.data[i];
    final dim = _touched != -1 && _touched != i;
    // Optional peak highlight (single-series weekday chart).
    final baseCurrent = widget.highlightIndex != null && i != widget.highlightIndex
        ? cs.outlineVariant
        : currentColor;
    Color shade(Color c) => c.withValues(alpha: dim ? 0.3 : 1);
    return BarChartGroupData(
      x: i,
      barsSpace: _barsSpace,
      barRods: [
        if (d.previous != null)
          BarChartRodData(
            toY: d.previous!,
            color: shade(previousColor),
            width: _barWidth,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        BarChartRodData(
          toY: d.current,
          color: shade(baseCurrent),
          width: _barWidth,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ],
    );
  }

  FlTitlesData _titles(
    ColorScheme cs,
    dynamic formatter,
    bool isPrivate,
    bool showLeft,
  ) {
    final axisStyle = localeFont(fontSize: 9.5, color: cs.onSurfaceVariant);
    return FlTitlesData(
      leftTitles: showLeft
          ? AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: _yAxisWidth,
                interval: _gridInterval,
                getTitlesWidget: (value, meta) {
                  if (value > _maxY) return const SizedBox.shrink();
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
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _bottomReserved,
          interval: 1,
          getTitlesWidget: (value, meta) {
            if ((value - value.roundToDouble()).abs() > 0.001) {
              return const SizedBox.shrink();
            }
            final i = value.toInt();
            if (i < 0 || i >= widget.data.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(widget.data[i].label, style: axisStyle),
            );
          },
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: localeFont(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _YAxis extends ConsumerWidget {
  final double maxY;
  final double interval;
  final double bottomReserved;

  const _YAxis({
    required this.maxY,
    required this.interval,
    required this.bottomReserved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final style = localeFont(fontSize: 9.5, color: cs.onSurfaceVariant);

    final ticks = <double>[];
    for (var v = 0.0; v <= maxY + 0.001; v += interval) {
      ticks.add(v);
    }

    return LayoutBuilder(
      builder: (context, c) {
        final plotH = (c.maxHeight - bottomReserved).clamp(0.0, c.maxHeight);
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final v in ticks)
                Positioned(
                  right: 0,
                  top: plotH - (plotH * (v / (maxY == 0 ? 1 : maxY))) - 6,
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
