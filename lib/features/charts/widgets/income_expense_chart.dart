import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/utils/chart_bucket.dart';
import 'income_expense_chart_controls.dart';
import 'income_expense_chart_model.dart';
import 'income_expense_chart_tooltip.dart';

export 'income_expense_chart_controls.dart'
    show IncomeExpenseChartMode, ChartRangeTab;
export 'income_expense_chart_model.dart';

part 'income_expense_chart_line.dart';

/// Redesigned Income & Expense chart (screens 4a-4d).
///
/// [compact] = Home tab (fixed-width bars, horizontally scrollable when many,
/// optional 7D/4W/6M range tabs). Expanded = Analytics tab (Day/Week/Month/
/// Year bucket switcher). Both share the Bar/Line toggle, a fixed Y-axis and
/// an above-the-bar tap tooltip that dismisses on an outside tap.
class IncomeExpenseChart extends ConsumerStatefulWidget {
  final List<IncomeExpensePoint> points;
  final bool compact;
  final String title;

  /// Compact-mode range tabs (Home): shown as a chip row below the title.
  final List<ChartRangeTab> rangeTabs;
  final String? selectedRangeId;
  final ValueChanged<String>? onRangeSelected;

  /// Expanded-mode bucket switcher (Analytics).
  final KuberChartBucket? bucket;
  final List<KuberChartBucket> availableBuckets;
  final ValueChanged<KuberChartBucket>? onBucketChanged;

  const IncomeExpenseChart({
    super.key,
    required this.points,
    required this.compact,
    this.title = 'Income & Expense',
    this.rangeTabs = const [],
    this.selectedRangeId,
    this.onRangeSelected,
    this.bucket,
    this.availableBuckets = const [],
    this.onBucketChanged,
  });

  @override
  ConsumerState<IncomeExpenseChart> createState() =>
      _IncomeExpenseChartState();
}

class _IncomeExpenseChartState extends ConsumerState<IncomeExpenseChart> {
  IncomeExpenseChartMode _mode = IncomeExpenseChartMode.bar;
  int? _selectedIndex;
  final _scrollController = ScrollController();
  int _lastCount = -1;

  static const double _axisW = 30;
  static const double _slot = 46;
  static const double _bottomAxis = 22;

  double get _chartHeight => widget.compact ? 156 : 176;
  double get _plotHeight => _chartHeight - _bottomAxis;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Axis top: the tallest bar sits at ~90% of the axis, rounded up to two
  /// significant figures for a clean mid-gridline label. This keeps the
  /// tallest bar consistently in the 83-90% band (never the old "50%" case
  /// where a value just above a power of ten doubled the axis).
  double get _maxY {
    var maxVal = 0.0;
    for (final p in widget.points) {
      maxVal = math.max(maxVal, math.max(p.income, p.expense));
    }
    if (maxVal <= 0) return 100;
    // Tallest bar at ~98% of the axis so the top label stays fully visible.
    final target = maxVal / 0.98;
    // Round up to 2 significant figures.
    final exp = (math.log(target) / math.ln10).floor() - 1;
    final magnitude = math.pow(10, exp).toDouble();
    return (target / magnitude).ceil() * magnitude;
  }

  void _onTapIndex(int? index) {
    setState(() => _selectedIndex = _selectedIndex == index ? null : index);
  }

  void _clearSelection() {
    if (_selectedIndex != null) setState(() => _selectedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style: localeFont(
                  fontSize: widget.compact ? 14 : 15,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          if (widget.compact && widget.rangeTabs.isNotEmpty) ...[
            const SizedBox(height: 12),
            CompactRangeTabs(
              tabs: widget.rangeTabs,
              selectedId: widget.selectedRangeId,
              onSelected: (id) {
                _clearSelection();
                widget.onRangeSelected?.call(id);
              },
            ),
          ],
          if (!widget.compact &&
              widget.bucket != null &&
              widget.onBucketChanged != null) ...[
            const SizedBox(height: 12),
            IncomeExpenseChartRangeSwitcher(
              selected: widget.bucket!,
              available: widget.availableBuckets,
              onChanged: (b) {
                _clearSelection();
                widget.onBucketChanged!(b);
              },
            ),
          ],
          // Bar | Line toggle sits below the title (and range chips), per the
          // design spec.
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: IncomeExpenseChartModeToggle(
              mode: _mode,
              onChanged: (m) => setState(() {
                _mode = m;
                _selectedIndex = null;
              }),
            ),
          ),
          const SizedBox(height: 16),
          TapRegion(
            onTapOutside: (_) => _clearSelection(),
            child: SizedBox(
              height: _chartHeight,
              child: widget.points.isEmpty
                  ? const SizedBox.shrink()
                  : LayoutBuilder(builder: _buildChartArea),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _legendDot(cs.tertiary, 'Income',
                  square: _mode == IncomeExpenseChartMode.bar),
              const SizedBox(width: 16),
              _legendDot(cs.error, 'Expense',
                  square: _mode == IncomeExpenseChartMode.bar),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartArea(BuildContext context, BoxConstraints constraints) {
    final cs = Theme.of(context).colorScheme;
    final maxY = _maxY;
    final n = widget.points.length;
    final plotAvail = constraints.maxWidth - _axisW;
    final fittedWidth = n * _slot;
    final scroll = fittedWidth > plotAvail && n > 1;
    final plotWidth = scroll ? fittedWidth : plotAvail;

    // Auto-jump to the newest (rightmost) bar when the dataset changes.
    if (scroll && _lastCount != n) {
      _lastCount = n;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } else if (!scroll) {
      _lastCount = n;
    }

    final plot = SizedBox(
      width: plotWidth,
      height: _chartHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _mode == IncomeExpenseChartMode.bar
              ? _buildBarChart(cs, maxY)
              : _buildLineChart(cs, maxY),
          if (_selectedIndex != null && _selectedIndex! < n)
            _positionedTooltip(plotWidth, maxY),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _axisW,
          height: _chartHeight,
          child: IncomeExpenseYAxis(maxY: maxY, plotHeight: _plotHeight),
        ),
        Expanded(
          // Clip horizontally so scrollable bars never paint outside the card,
          // but leave the top open so the tooltip can float above the bars.
          child: ClipRect(
            clipper: const _HorizontalClipper(),
            child: scroll
                ? SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: plot,
                  )
                : plot,
          ),
        ),
      ],
    );
  }

  Widget _positionedTooltip(double plotWidth, double maxY) {
    final n = widget.points.length;
    final point = widget.points[_selectedIndex!];
    final v = math.max(point.income, point.expense);
    // Anchor the tooltip's bottom just above the tallest bar's top so it
    // never covers the chart. It grows upward from there.
    final barTopFromPlotBottom = _plotHeight * (v / maxY);
    final bottom = _bottomAxis + barTopFromPlotBottom + 8;
    final center = (_selectedIndex! + 0.5) * plotWidth / n;
    var left = center - IncomeExpenseChartTooltip.width / 2;
    left = left.clamp(0.0, math.max(0.0, plotWidth - IncomeExpenseChartTooltip.width));
    return Positioned(
      left: left,
      bottom: bottom,
      child: IncomeExpenseChartTooltip(
        point: point,
        showViewTransactions: !widget.compact,
      ),
    );
  }

  Widget _legendDot(Color color, String label, {required bool square}) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: square ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: square ? BorderRadius.circular(2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: localeFont(fontSize: 11, color: cs.onSurfaceVariant)),
      ],
    );
  }

  // ── Shared axis / grid (left titles always hidden; external Y-axis) ─────────

  FlTitlesData _titles(ColorScheme cs) {
    return FlTitlesData(
      topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _bottomAxis,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= widget.points.length) {
              return const SizedBox.shrink();
            }
            final selected = i == _selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                widget.points[i].label,
                style: localeFont(
                  fontSize: 8.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? cs.onSurface
                      : cs.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  FlGridData _grid(ColorScheme cs, double maxY) => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 2,
        getDrawingHorizontalLine: (value) => FlLine(
          color: cs.outline.withValues(alpha: value == 0 ? 1 : 0.55),
          strokeWidth: 1,
        ),
      );

  // ── Bar variant (4a/4c) ───────────────────────────────────────────────────

  Widget _buildBarChart(ColorScheme cs, double maxY) {
    final n = widget.points.length;
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        titlesData: _titles(cs),
        gridData: _grid(cs, maxY),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (event, response) {
            if (event is! FlTapUpEvent) return;
            _onTapIndex(response?.spot?.touchedBarGroupIndex);
          },
        ),
        barGroups: [
          for (var i = 0; i < n; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 3,
              barRods: [
                // Both rods of the selected group turn solid primary blue so
                // the whole period reads as selected.
                BarChartRodData(
                  toY: widget.points[i].income,
                  width: 13,
                  borderRadius: BorderRadius.circular(3),
                  color: i == _selectedIndex
                      ? cs.primary
                      : cs.tertiary.withValues(alpha: 0.85),
                ),
                BarChartRodData(
                  toY: widget.points[i].expense,
                  width: 13,
                  borderRadius: BorderRadius.circular(3),
                  color: i == _selectedIndex
                      ? cs.primary
                      : cs.error.withValues(alpha: 0.85),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
