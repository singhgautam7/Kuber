part of 'ah_chart_view.dart';

/// Bars and line: the scrolling, tappable plot with its tooltip.
extension _ScrollPlot on _AhChartViewState {
  // --- bars and line ---------------------------------------------------------

  Widget _plot(
    BuildContext context, {
    required double height,
    required double minSlot,
    required Listenable anim,
    required CustomPainter Function(double t, double s) painter,
    required Offset Function(int, Size) anchor,
    required List<Color> sColors,
    CustomPainter? axis,
  }) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final n = widget.points.length;
    return LayoutBuilder(builder: (context, bc) {
      final viewW = bc.maxWidth - (axis == null ? 0 : _axisW);
      final scrolls = n * minSlot > viewW;
      final contentW = scrolls ? n * minSlot : viewW;
      final size = Size(contentW, height);
      if (scrolls && !_jumped) {
        _jumped = true;
        // Start at the latest, like the Home chart.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
      final sel = _selected;
      Widget? tip;
      if (sel != null && sel < n) {
        final p = widget.points[sel];
        final a = anchor(sel, size);
        final rows = widget.series.length;
        final tipH = (54.0 +
                rows * 20 +
                (rows > 1 ? 20 : 0) +
                (_viewable(p) ? 24 : 0)) *
            scale;
        final tw = math.min(_tipW * scale, viewW);
        // Keep it inside the visible part of a scrolled chart.
        final lo = scrolls && _scroll.hasClients ? _scroll.offset : 0.0;
        final hi = math.max(lo, lo + viewW - tw);
        double left, top;
        if (a.dy - 10 >= tipH) {
          left = (a.dx - tw / 2).clamp(lo, hi);
          top = a.dy - 10 - tipH;
        } else {
          left = a.dx < lo + viewW / 2 ? a.dx + 14 : a.dx - 14 - tw;
          left = left.clamp(lo, hi);
          top = 0;
        }
        tip = Positioned(
          key: ValueKey('ah-chart-tip-$sel'),
          left: left,
          top: top,
          width: tw,
          child: AnimatedBuilder(
            animation: _sel,
            builder: (context, child) {
              final v = Curves.easeOutCubic.transform(_sel.value);
              return Opacity(
                opacity: v,
                child: Transform.scale(
                  scale: KuberMotion.reduced(context) ? 1 : 0.92 + 0.08 * v,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              );
            },
            child: _ChartTooltip(
              label: p.label,
              value: rows == 1 ? null : _full(p.value),
              rows: [
                for (var j = 0; j < rows; j++)
                  (
                    sColors[j],
                    widget.series[j].label,
                    _full(widget.series[j].values[sel]),
                  ),
              ],
              onView: _viewable(p) ? () => widget.onView!(p) : null,
            ),
          ),
        );
      }
      final chart = SizedBox(
        width: contentW,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _tap(n == 0
                    ? null
                    : (d.localPosition.dx / (contentW / n))
                        .floor()
                        .clamp(0, n - 1)),
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: anim,
                    builder: (context, _) => CustomPaint(
                      size: size,
                      painter: painter(_drawT.value,
                          Curves.easeOutCubic.transform(_sel.value)),
                    ),
                  ),
                ),
              ),
            ),
            ?tip,
          ],
        ),
      );
      final body = scrolls
          ? SingleChildScrollView(
              key: const ValueKey('ah-chart-scroll'),
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: chart,
            )
          : chart;
      return SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (axis != null)
              CustomPaint(size: Size(_axisW, height), painter: axis),
            // Clip sideways only, so the tooltip can still rise above.
            Expanded(
              child: ClipRect(clipper: const _SideClipper(), child: body),
            ),
          ],
        ),
      );
    });
  }
}

final _timeKey = RegExp(r'^\d{4}(-\d{2})?$');

/// One measure over months or years, drawn by the shared [ExpressiveChart]
/// (Home / Analytics chart). A tap selects a column: the chart shows its
/// tooltip, and the detail row under it offers "View transactions".
class _AhTimeChart extends StatefulWidget {
  const _AhTimeChart({
    required this.points,
    required this.line,
    required this.seriesName,
    required this.fmt,
    required this.axisFmt,
    required this.onView,
  });
  final List<AhChartPoint> points;
  final bool line;
  final String seriesName;
  final String Function(double) fmt, axisFmt;
  final ValueChanged<AhChartPoint>? onView;

  /// Months / years only; a line with negative values keeps its own painter
  /// (the shared chart plots from zero).
  static bool fits(List<AhChartPoint> pts, {required bool line}) =>
      pts.isNotEmpty &&
      pts.every((p) => _timeKey.hasMatch(p.key)) &&
      !(line && pts.any((p) => p.value < 0));

  @override
  State<_AhTimeChart> createState() => _AhTimeChartState();
}

class _AhTimeChartState extends State<_AhTimeChart> {
  int? _sel;
  List<AhChartPoint>? _forPts;
  List<ExpressivePeriod> _periods = const [];

  @override
  void didUpdateWidget(_AhTimeChart old) {
    super.didUpdateWidget(old);
    // The chart clears its own selection when the months change.
    if ([for (final p in old.points) p.key].join('|') !=
        [for (final p in widget.points) p.key].join('|')) {
      _sel = null;
    }
  }

  List<ExpressivePeriod> _build(List<AhChartPoint> pts) {
    if (identical(_forPts, pts)) return _periods;
    _forPts = pts;
    return _periods = [
      for (var i = 0; i < pts.length; i++)
        ExpressivePeriod(
          key: i,
          label: pts[i].label.replaceAll(pts[i].key.substring(0, 4), '').trim(),
          fullLabel: pts[i].label,
          values: [pts[i].value.abs()],
          noData: pts[i].value == 0,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pts = widget.points;
    final n = pts.length;
    final periods = _build(pts);
    final sel = _sel;
    final p = sel != null && sel < n ? pts[sel] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExpressiveChart(
          series: [
            ExpressiveSeries(
                name: widget.seriesName,
                color: cs.primary,
                inverseColor: cs.inversePrimary),
          ],
          periods: periods,
          mode: widget.line ? ExpressiveChartMode.line : ExpressiveChartMode.bar,
          window: n >= 2 && n <= 6 ? n : 6,
          formatAmount: widget.fmt,
          formatAxis: widget.axisFmt,
          selected: sel,
          onSelectedChanged: (k) => setState(() => _sel = k),
          resetKey: [for (final x in pts) x.key].join('|'),
        ),
        _DetailSlot(
          child: p == null || widget.onView == null
              ? null
              : _ChartDetail(
                  key: ValueKey('t$sel'),
                  color: cs.primary,
                  label: p.label,
                  value: widget.fmt(p.value),
                  onView: () => widget.onView!(p),
                ),
        ),
      ],
    );
  }
}
