import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';

final _chartInr =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

/// One x-position's tooltip content.
class AaTapPoint {
  final String title;
  final List<AaTapRow> rows;
  const AaTapPoint(this.title, this.rows);
}

class AaTapRow {
  final String label;
  final String value;
  final Color color;
  const AaTapRow(this.label, this.value, this.color);
}

/// Wraps a [CustomPainter]-based line/area chart and adds a tap tooltip that
/// maps the tap x-position to the nearest data point. Reused by the cash-flow,
/// forecast and savings charts so they all get the same tooltip behaviour as
/// the bar charts.
class AaChartTapArea extends StatefulWidget {
  final double height;
  final CustomPainter painter;
  final List<AaTapPoint> points;

  const AaChartTapArea({
    super.key,
    required this.height,
    required this.painter,
    required this.points,
  });

  @override
  State<AaChartTapArea> createState() => _AaChartTapAreaState();
}

class _AaChartTapAreaState extends State<AaChartTapArea> {
  int _touched = -1;
  static const double _cardW = 160;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final n = widget.points.length;
        int indexAt(double dx) =>
            n <= 1 ? 0 : ((dx / w) * (n - 1)).round().clamp(0, n - 1);
        void select(double dx) {
          if (n == 0) return;
          final i = indexAt(dx);
          if (i != _touched) setState(() => _touched = i);
        }

        return TapRegion(
          // Close the tooltip when tapping anywhere outside the chart, like the
          // Home/Analytics charts.
          onTapOutside: (_) {
            if (_touched != -1) setState(() => _touched = -1);
          },
          child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Tap toggles; horizontal drag scrubs the selection across the chart
          // (like the Home/Analytics line charts).
          onTapDown: (d) {
            if (n == 0) return;
            final i = indexAt(d.localPosition.dx);
            setState(() => _touched = _touched == i ? -1 : i);
          },
          onHorizontalDragStart: (d) => select(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => select(d.localPosition.dx),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // RepaintBoundary isolates the hand-drawn chart so it isn't
              // repainted by the enclosing scrollable / tooltip rebuilds
              // (performance.md §5).
              RepaintBoundary(
                child: SizedBox(
                  width: double.infinity,
                  height: widget.height,
                  child: CustomPaint(painter: widget.painter),
                ),
              ),
              if (_touched >= 0 && _touched < n) ...[
                _selectionLine(cs, w, n),
                _tooltip(cs, w, n),
              ],
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _selectionLine(ColorScheme cs, double w, int n) {
    final x = n <= 1 ? w / 2 : (_touched / (n - 1)) * w;
    return Positioned(
      left: (x - 0.75).clamp(0.0, math.max(0.0, w - 1.5)).toDouble(),
      top: 0,
      bottom: 0,
      child: Container(
        width: 1.5,
        color: cs.primary.withValues(alpha: 0.55),
      ),
    );
  }

  Widget _tooltip(ColorScheme cs, double w, int n) {
    final p = widget.points[_touched];
    final x = n <= 1 ? w / 2 : (_touched / (n - 1)) * w;
    final left = (x - _cardW / 2)
        .clamp(0.0, math.max(0.0, w - _cardW))
        .toDouble();
    return Positioned(
      left: left,
      top: 0,
      width: _cardW,
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
              p.title.toUpperCase(),
              style: localeFont(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: cs.onSurfaceVariant,
              ),
            ),
            for (final r in p.rows)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.label,
                        style: localeFont(
                            fontSize: 11, color: cs.onSurfaceVariant)),
                    Text(r.value,
                        style: localeFont(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: r.color)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shared vertical bar with a fixed width and an explicit height, bottom
/// aligned inside its parent. Every Advanced Analytics bar chart uses this so
/// bars are a consistent width regardless of how many there are; the enclosing
/// chart scrolls horizontally when they overflow rather than squeezing them
/// thinner (see the charts below).
class _FixedBar extends StatelessWidget {
  final double factor; // 0..1 of [maxHeight]
  final double width;
  final double maxHeight;
  final Color color;
  final BorderRadius radius;

  const _FixedBar({
    required this.factor,
    required this.width,
    required this.maxHeight,
    required this.color,
    this.radius = const BorderRadius.vertical(top: Radius.circular(2)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: (factor.clamp(0.04, 1.0)) * maxHeight,
      decoration: BoxDecoration(color: color, borderRadius: radius),
    );
  }
}

/// A horizontally scrollable strip of fixed-width bar "columns". Each column is
/// bottom-aligned bars plus a caption below. Kept generic so the trends,
/// category and day-of-week charts share one scrolling layout.
class _ScrollableBarStrip extends StatelessWidget {
  final int count;
  final double columnWidth;
  final double chartHeight;
  final Widget Function(int index) barsBuilder;
  final Widget Function(int index) labelBuilder;

  const _ScrollableBarStrip({
    required this.count,
    required this.columnWidth,
    required this.chartHeight,
    required this.barsBuilder,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < count; i++)
            SizedBox(
              width: columnWidth,
              child: Column(
                children: [
                  SizedBox(
                    height: chartHeight,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: barsBuilder(i),
                    ),
                  ),
                  const SizedBox(height: 6),
                  labelBuilder(i),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TrendsDualBarChart extends StatelessWidget {
  final List<double> currentValues;
  final List<double> previousValues;
  final List<String> labels;

  const TrendsDualBarChart({
    super.key,
    required this.currentValues,
    required this.previousValues,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxVal = [...currentValues, ...previousValues].fold<double>(
      0.01,
      (max, v) => v > max ? v : max,
    );
    const chartH = 110.0;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScrollableBarStrip(
            count: currentValues.length,
            columnWidth: 36,
            chartHeight: chartH,
            barsBuilder: (i) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _FixedBar(
                  factor: previousValues[i] / maxVal,
                  width: 12,
                  maxHeight: chartH,
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                _FixedBar(
                  factor: currentValues[i] / maxVal,
                  width: 12,
                  maxHeight: chartH,
                  color: cs.primary,
                ),
              ],
            ),
            labelBuilder: (i) => Text(
              i < labels.length ? labels[i] : '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: localeFont(fontSize: 10, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _LegendDot(color: cs.outlineVariant.withValues(alpha: 0.5)),
              const SizedBox(width: 5),
              Text('Previous', style: localeFont(fontSize: 10.5, color: cs.onSurfaceVariant)),
              const SizedBox(width: 14),
              _LegendDot(color: cs.primary),
              const SizedBox(width: 5),
              Text('Current', style: localeFont(fontSize: 10.5, color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }
}

class CategoryDeepDiveChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const CategoryDeepDiveChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxVal = values.fold<double>(0.01, (max, v) => v > max ? v : max);
    const chartH = 70.0;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spend over time',
            style: localeFont(fontSize: 11, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          _ScrollableBarStrip(
            count: values.length,
            columnWidth: 26,
            chartHeight: chartH,
            barsBuilder: (i) => _FixedBar(
              factor: values[i] / maxVal,
              width: 16,
              maxHeight: chartH,
              color: cs.error,
            ),
            labelBuilder: (i) => Text(
              i < labels.length ? labels[i] : '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: localeFont(fontSize: 9, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class DayOfWeekChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  /// Optional card title; pass null to render just the bars (e.g. embedded
  /// under an existing "Weekday distribution" header).
  final String? title;

  const DayOfWeekChart({
    super.key,
    required this.values,
    required this.labels,
    this.title = 'Day of week',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxVal = values.fold<double>(0.01, (max, v) => v > max ? v : max);
    final maxIdx = values.indexOf(maxVal);
    const chartH = 50.0;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: localeFont(fontSize: 11, fontWeight: FontWeight.bold, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
          ],
          _ScrollableBarStrip(
            count: values.length,
            columnWidth: 32,
            chartHeight: chartH,
            barsBuilder: (i) => _FixedBar(
              factor: values[i] / maxVal,
              width: 18,
              maxHeight: chartH,
              color: i == maxIdx ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
              radius: BorderRadius.circular(2),
            ),
            labelBuilder: (i) => Text(
              i < labels.length ? labels[i] : '',
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 9,
                color: i == maxIdx ? cs.primary : cs.onSurfaceVariant,
                fontWeight: i == maxIdx ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForecastZoneChart extends StatelessWidget {
  final List<double> actuals;
  final List<double> projections;
  final double limit;

  const ForecastZoneChart({
    super.key,
    required this.actuals,
    required this.projections,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final warningColor = context.kuberColors.warning;
    final all = [...actuals, ...projections];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: AaChartTapArea(
        height: 80,
        painter: _ForecastPainter(
          actuals: actuals,
          projections: projections,
          limit: limit,
          primaryColor: cs.primary,
          safeColor: cs.tertiary,
          warningColor: warningColor,
          overColor: cs.error,
          outlineColor: cs.outline,
        ),
        points: [
          for (var i = 0; i < all.length; i++)
            AaTapPoint('Day ${i + 1}', [
              AaTapRow(
                i < actuals.length ? 'Spent so far' : 'Projected',
                _chartInr.format(all[i]),
                cs.primary,
              ),
            ]),
        ],
      ),
    );
  }
}

class _ForecastPainter extends CustomPainter {
  final List<double> actuals;
  final List<double> projections;
  final double limit;
  final Color primaryColor;
  final Color safeColor;
  final Color warningColor;
  final Color overColor;
  final Color outlineColor;

  _ForecastPainter({
    required this.actuals,
    required this.projections,
    required this.limit,
    required this.primaryColor,
    required this.safeColor,
    required this.warningColor,
    required this.overColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw background bands
    // Green (Safe) - bottom 55%
    final safePaint = Paint()..color = safeColor.withValues(alpha: 0.1);
    canvas.drawRect(Rect.fromLTRB(0, h * 0.55, w, h), safePaint);

    // Amber (Warning) - middle 30%
    final warningPaint = Paint()..color = warningColor.withValues(alpha: 0.1);
    canvas.drawRect(Rect.fromLTRB(0, h * 0.25, w, h * 0.55), warningPaint);

    // Red (Over) - top 25%
    final overPaint = Paint()..color = overColor.withValues(alpha: 0.1);
    canvas.drawRect(Rect.fromLTRB(0, 0, w, h * 0.25), overPaint);

    // Grid separators
    final linePaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, h * 0.55), Offset(w, h * 0.55), linePaint);
    canvas.drawLine(Offset(0, h * 0.25), Offset(w, h * 0.25), linePaint);

    final allPoints = [...actuals, ...projections];
    if (allPoints.isEmpty) return;
    final maxPoint = allPoints.fold<double>(0.01, (max, v) => v > max ? v : max);
    final scaleY = maxPoint > limit ? maxPoint * 1.15 : limit * 1.15;

    double getX(int index, int total) {
      if (total <= 1) return 0;
      return (index / (total - 1)) * w;
    }

    double getY(double val) {
      return h - (val / scaleY) * h;
    }

    final totalDays = actuals.length + projections.length;
    if (totalDays <= 1) return;

    // Draw actual solid line
    if (actuals.isNotEmpty) {
      final actualPath = Path();
      actualPath.moveTo(getX(0, totalDays), getY(actuals[0]));
      for (int i = 1; i < actuals.length; i++) {
        actualPath.lineTo(getX(i, totalDays), getY(actuals[i]));
      }
      final solidPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(actualPath, solidPaint);
    }

    // Draw projection dashed line
    if (projections.isNotEmpty && actuals.isNotEmpty) {
      final startIdx = actuals.length - 1;
      final points = [actuals.last, ...projections];
      final dashPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < points.length - 1; i++) {
        final x1 = getX(startIdx + i, totalDays);
        final y1 = getY(points[i]);
        final x2 = getX(startIdx + i + 1, totalDays);
        final y2 = getY(points[i + 1]);

        final dx = x2 - x1;
        final dy = y2 - y1;
        final dist = math.sqrt(dx * dx + dy * dy);
        const dashLen = 6.0;
        const gapLen = 4.0;
        var curDist = 0.0;
        while (curDist < dist) {
          final t1 = curDist / dist;
          curDist += dashLen;
          final t2 = (curDist > dist ? dist : curDist) / dist;
          canvas.drawLine(
            Offset(x1 + dx * t1, y1 + dy * t1),
            Offset(x1 + dx * t2, y1 + dy * t2),
            dashPaint,
          );
          curDist += gapLen;
        }
      }

      // Draw transition dot
      final dotPaint = Paint()..color = primaryColor;
      canvas.drawCircle(Offset(getX(startIdx, totalDays), getY(actuals.last)), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CashFlowAreaChart extends StatelessWidget {
  final List<double> incomes;
  final List<double> expenses;
  final List<double> nets;
  final List<String> labels;

  const CashFlowAreaChart({
    super.key,
    required this.incomes,
    required this.expenses,
    required this.nets,
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AaChartTapArea(
            height: 110,
            painter: _CashFlowPainter(
              incomes: incomes,
              expenses: expenses,
              nets: nets,
              incomeColor: cs.tertiary,
              expenseColor: cs.error,
              netColor: cs.onSurface,
              outlineColor: cs.outline,
            ),
            points: [
              for (var i = 0; i < incomes.length; i++)
                AaTapPoint(i < labels.length ? labels[i] : 'Month ${i + 1}', [
                  AaTapRow('Income', _chartInr.format(incomes[i]), cs.tertiary),
                  AaTapRow('Expense', _chartInr.format(expenses[i]), cs.error),
                  AaTapRow(
                    'Net',
                    '${nets[i] >= 0 ? '+' : ''}${_chartInr.format(nets[i])}',
                    nets[i] >= 0 ? cs.tertiary : cs.error,
                  ),
                ]),
            ],
          ),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            children: [
              _CfLegend(color: cs.tertiary, label: 'Income'),
              const SizedBox(width: KuberSpacing.md),
              _CfLegend(color: cs.error, label: 'Expense'),
              const SizedBox(width: KuberSpacing.md),
              _CfLegend(color: cs.onSurface, label: 'Net', line: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _CfLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool line;
  const _CfLegend({required this.color, required this.label, this.line = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: line ? 12 : 8,
          height: line ? 2 : 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: localeFont(fontSize: 10, color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class _CashFlowPainter extends CustomPainter {
  final List<double> incomes;
  final List<double> expenses;
  final List<double> nets;
  final Color incomeColor;
  final Color expenseColor;
  final Color netColor;
  final Color outlineColor;

  _CashFlowPainter({
    required this.incomes,
    required this.expenses,
    required this.nets,
    required this.incomeColor,
    required this.expenseColor,
    required this.netColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw baseline
    final basePaint = Paint()
      ..color = outlineColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), basePaint);

    final total = incomes.length;
    if (total <= 1) return;

    final maxVal = [...incomes, ...expenses].fold<double>(
      0.01,
      (max, v) => v > max ? v : max,
    );
    final scaleY = maxVal * 1.15;

    double getX(int index) => (index / (total - 1)) * w;
    double getYIncome(double val) => h * 0.5 - (val / scaleY) * h * 0.45;
    double getYExpense(double val) => h * 0.5 + (val / scaleY) * h * 0.45;
    double getYNet(double val) {
      if (val >= 0) {
        return h * 0.5 - (val / scaleY) * h * 0.45;
      } else {
        return h * 0.5 + (val.abs() / scaleY) * h * 0.45;
      }
    }

    // Draw income area
    final incAreaPath = Path();
    incAreaPath.moveTo(getX(0), h * 0.5);
    for (int i = 0; i < total; i++) {
      incAreaPath.lineTo(getX(i), getYIncome(incomes[i]));
    }
    incAreaPath.lineTo(getX(total - 1), h * 0.5);
    incAreaPath.close();
    canvas.drawPath(incAreaPath, Paint()..color = incomeColor.withValues(alpha: 0.12));

    // Draw income line
    final incLinePath = Path();
    incLinePath.moveTo(getX(0), getYIncome(incomes[0]));
    for (int i = 1; i < total; i++) {
      incLinePath.lineTo(getX(i), getYIncome(incomes[i]));
    }
    canvas.drawPath(
      incLinePath,
      Paint()
        ..color = incomeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw expense area
    final expAreaPath = Path();
    expAreaPath.moveTo(getX(0), h * 0.5);
    for (int i = 0; i < total; i++) {
      expAreaPath.lineTo(getX(i), getYExpense(expenses[i]));
    }
    expAreaPath.lineTo(getX(total - 1), h * 0.5);
    expAreaPath.close();
    canvas.drawPath(expAreaPath, Paint()..color = expenseColor.withValues(alpha: 0.12));

    // Draw expense line
    final expLinePath = Path();
    expLinePath.moveTo(getX(0), getYExpense(expenses[0]));
    for (int i = 1; i < total; i++) {
      expLinePath.lineTo(getX(i), getYExpense(expenses[i]));
    }
    canvas.drawPath(
      expLinePath,
      Paint()
        ..color = expenseColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw net line (dashed)
    final netPaint = Paint()
      ..color = netColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < total - 1; i++) {
      final x1 = getX(i);
      final y1 = getYNet(nets[i]);
      final x2 = getX(i + 1);
      final y2 = getYNet(nets[i + 1]);

      final dx = x2 - x1;
      final dy = y2 - y1;
      final dist = math.sqrt(dx * dx + dy * dy);
      const dashLen = 4.0;
      const gapLen = 3.0;
      var curDist = 0.0;
      while (curDist < dist) {
        final t1 = curDist / dist;
        curDist += dashLen;
        final t2 = (curDist > dist ? dist : curDist) / dist;
        canvas.drawLine(
          Offset(x1 + dx * t1, y1 + dy * t1),
          Offset(x1 + dx * t2, y1 + dy * t2),
          netPaint,
        );
        curDist += gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SavingsRateLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const SavingsRateLineChart({
    super.key,
    required this.values,
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: AaChartTapArea(
        height: 90,
        painter: _SavingsRatePainter(
          values: values,
          primaryColor: cs.primary,
          // Brighter than cs.outline so the 20% / 10% reference dashes read.
          outlineColor: cs.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        points: [
          for (var i = 0; i < values.length; i++)
            AaTapPoint(i < labels.length ? labels[i] : 'Month ${i + 1}', [
              AaTapRow(
                'Savings rate',
                '${values[i].toStringAsFixed(1)}%',
                values[i] >= 20
                    ? cs.tertiary
                    : values[i] >= 0
                        ? cs.primary
                        : cs.error,
              ),
            ]),
        ],
      ),
    );
  }
}

class _SavingsRatePainter extends CustomPainter {
  final List<double> values;
  final Color primaryColor;
  final Color outlineColor;

  _SavingsRatePainter({
    required this.values,
    required this.primaryColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const maxVal = 30.0;
    double getY(double val) {
      final clamped = val.clamp(-5.0, maxVal);
      return h - ((clamped + 5) / (maxVal + 5)) * h;
    }

    final dashPaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    void drawHorizontalDash(double yVal) {
      final y = getY(yVal);
      const dashLen = 3.0;
      const gapLen = 3.0;
      var curX = 0.0;
      while (curX < w) {
        canvas.drawLine(Offset(curX, y), Offset(curX + dashLen, y), dashPaint);
        curX += dashLen + gapLen;
      }
    }

    drawHorizontalDash(20);
    drawHorizontalDash(10);

    final total = values.length;
    if (total <= 1) return;

    double getX(int index) => (index / (total - 1)) * w;

    final path = Path();
    path.moveTo(getX(0), getY(values[0]));
    for (int i = 1; i < total; i++) {
      path.lineTo(getX(i), getY(values[i]));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(Offset(getX(total - 1), getY(values.last)), 4, Paint()..color = primaryColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
