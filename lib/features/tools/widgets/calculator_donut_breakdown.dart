import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';

class BreakdownSegment {
  final String label;
  final double value;
  final Color color;
  const BreakdownSegment(this.label, this.value, this.color);
}

/// A donut (ring) chart with a center label and a legend listing every segment
/// with its value and auto-computed percentage. Tap a slice to emphasize it.
class ToolDonutBreakdown extends ConsumerStatefulWidget {
  final List<BreakdownSegment> segments;
  final String centerBig;
  final String centerSmall;

  const ToolDonutBreakdown({
    super.key,
    required this.segments,
    required this.centerBig,
    required this.centerSmall,
  });

  @override
  ConsumerState<ToolDonutBreakdown> createState() => _ToolDonutBreakdownState();
}

class _ToolDonutBreakdownState extends ConsumerState<ToolDonutBreakdown> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final total = widget.segments.fold<double>(0, (a, s) => a + s.value);
    final safeTotal = total == 0 ? 1 : total;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RepaintBoundary(
                child: PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, resp) {
                      if (event is FlTapUpEvent || event is FlPanEndEvent) {
                        final idx =
                            resp?.touchedSection?.touchedSectionIndex ?? -1;
                        setState(() => _touched =
                            (idx >= 0 && idx == _touched) ? null : (idx >= 0 ? idx : null));
                      }
                    },
                  ),
                  sections: [
                    for (var i = 0; i < widget.segments.length; i++)
                      PieChartSectionData(
                        color: widget.segments[i].color,
                        value: widget.segments[i].value <= 0
                            ? 0.0001
                            : widget.segments[i].value,
                        radius: _touched == i ? 22 : 17,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.centerBig,
                    style: localeFont(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    widget.centerSmall.toUpperCase(),
                    style: localeFont(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: KuberSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.segments.length; i++) ...[
                if (i > 0) const SizedBox(height: 11),
                _LegendRow(
                  segment: widget.segments[i],
                  percent: widget.segments[i].value / safeTotal * 100,
                  emphasized: _touched == i,
                  formatValue: (v) =>
                      formatter.formatCurrency(v.roundToDouble(), symbol: currency.symbol),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final BreakdownSegment segment;
  final double percent;
  final bool emphasized;
  final String Function(double) formatValue;

  const _LegendRow({
    required this.segment,
    required this.percent,
    required this.emphasized,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration:
              BoxDecoration(color: segment.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                segment.label,
                style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 1),
              Text(
                formatValue(segment.value),
                style: localeFont(
                  fontSize: 13.5,
                  fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${percent.round()}%',
          style: localeFont(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
