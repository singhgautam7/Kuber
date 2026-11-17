import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_harmonizer.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../charts/widgets/income_expense_chart_controls.dart'
    show chartSelectionColumn, kChartSelectionRadius;
import '../../models/ah_view.dart';
import '../../services/ah_engine.dart' show ahDayKey;
import '../../services/ah_results.dart';
import '../common/ah_common.dart';
import '../common/ah_motion.dart';

/// Donut, bars, line or calendar heatmap for [points]. Draws in on first
/// show (donut sweep 400 ms, bars 300 ms 30 ms apart, line 400 ms; none when
/// motion is reduced).
///
/// Tapping a part selects it (it grows, the others fade to 38%); tapping it
/// again clears the selection. Bars and line then show a floating tooltip
/// (as on the Home chart); the donut and the heatmap show a detail row under
/// the chart. All of them offer "View transactions", which calls [onView].
///
/// With [series] (up to 3 compared values) bars stack them and the line draws
/// one line each. Bars and lines with many points scroll sideways like the
/// Home chart, starting at the latest; the line's Y axis stays put.
class AhChartView extends StatefulWidget {
  const AhChartView({
    super.key,
    required this.type,
    required this.points,
    required this.fmt,
    this.series = const [],
    this.fullFmt,
    this.axisFmt,
    this.dayLabel,
    this.onView,
  });
  final AhChartType type;
  final List<AhChartPoint> points;
  final List<AhChartSeries> series;

  /// Compact values (bar tops, axis).
  final String Function(double) fmt;

  /// Exact values (tooltip, detail rows). Defaults to [fmt].
  final String Function(double)? fullFmt;

  /// Y axis ticks on the line (short, no symbol). Defaults to [fmt].
  final String Function(double)? axisFmt;

  /// Heatmap: the detail row's name for a day key (`2026-11-03`).
  final String Function(String)? dayLabel;
  final ValueChanged<AhChartPoint>? onView;

  @override
  State<AhChartView> createState() => _AhChartViewState();
}

const _barsH = 168.0, _barsTop = 18.0, _labelH = 22.0;
const _lineH = 176.0, _lineTop = 12.0, _axisW = 44.0;
const _tipW = 176.0;

/// Narrowest slot before bars / lines scroll sideways (Home chart style).
const _minBarSlot = 56.0, _minLineSlot = 56.0;

class _AhChartViewState extends State<AhChartView>
    with TickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(vsync: this);
  late final AnimationController _sel =
      AnimationController(vsync: this, duration: AhMotion.fast);
  final _scroll = ScrollController();
  int? _selected;
  bool _started = false;
  bool _jumped = false;

  Duration get _drawDur => widget.type == AhChartType.bars
      ? Duration(
          milliseconds:
              300 + 30 * math.max(0, math.min(widget.points.length, 12) - 1))
      : const Duration(milliseconds: 400);

  String _full(double v) => (widget.fullFmt ?? widget.fmt)(v);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _run();
  }

  void _run() {
    if (AhMotion.reduced(context)) {
      _draw.value = 1;
      return;
    }
    _draw.duration = _drawDur;
    _draw.forward(from: 0);
  }

  @override
  void didUpdateWidget(AhChartView old) {
    super.didUpdateWidget(old);
    if (!_same(old.points, widget.points) ||
        old.type != widget.type ||
        old.series.length != widget.series.length) {
      _selected = null;
      _sel.value = 0;
      _jumped = false;
      _run();
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    _sel.dispose();
    _scroll.dispose();
    super.dispose();
  }

  static bool _same(List<AhChartPoint> a, List<AhChartPoint> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].key != b[i].key ||
          a[i].label != b[i].label ||
          a[i].value != b[i].value) {
        return false;
      }
    }
    return true;
  }

  void _tap(int? i) {
    if (i == null || i == _selected) {
      if (_selected == null) return;
      _sel.reverse().whenComplete(() {
        if (mounted && _sel.value == 0) setState(() => _selected = null);
      });
      return;
    }
    setState(() => _selected = i);
    _sel.forward(from: 0);
  }

  bool _viewable(AhChartPoint p) => widget.onView != null && p.key != '__other';

  List<Color> _palette(ColorScheme cs) => [
        cs.primary,
        cs.tertiary,
        cs.secondary,
        cs.inversePrimary,
        cs.onSurfaceVariant,
        cs.outlineVariant,
      ];

  Color _color(BuildContext c, int i) {
    final cs = Theme.of(c).colorScheme;
    final p = widget.points[i];
    if (p.key == '__other') return cs.outline;
    if (p.colorValue != null) return categoryVizColor(c, Color(p.colorValue!));
    final pal = _palette(cs);
    return pal[i % pal.length];
  }

  /// Compared values: their own (category) colour when they have one and it
  /// isn't taken, else primary / tertiary / secondary.
  List<Color> _seriesColors(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    final pal = _palette(cs);
    final out = <Color>[];
    for (var i = 0; i < widget.series.length; i++) {
      final v = widget.series[i].colorValue;
      final own = v == null ? null : categoryVizColor(c, Color(v));
      out.add(own != null && !out.contains(own) ? own : pal[i % 3]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = localeFont(fontSize: 11, color: cs.onSurfaceVariant);
    final pts = widget.points;
    final selCol = chartSelectionColumn(cs);
    final anim = Listenable.merge([_draw, _sel]);
    final sColors = _seriesColors(context);

    switch (widget.type) {
      case AhChartType.donut:
        return _donut(context,
            [for (var i = 0; i < pts.length; i++) _color(context, i)], anim);
      case AhChartType.heatmap:
        return _AhHeatmap(
          points: pts,
          fmt: _full,
          dayLabel: widget.dayLabel ?? (k) => k,
          draw: _draw,
          onView: widget.onView,
        );
      case AhChartType.bars:
      case AhChartType.line:
        final bars = widget.type == AhChartType.bars;
        final colors = [for (var i = 0; i < pts.length; i++) _color(context, i)];
        final plot = _plot(
          context,
          height: bars ? _barsH : _lineH,
          minSlot: bars ? _minBarSlot : _minLineSlot,
          anim: anim,
          painter: (t, s) => bars
              ? _BarsPainter(pts, colors, widget.series, sColors, t, _drawDur,
                  _selected, s, label, cs.outlineVariant, selCol, widget.fmt)
              : _LinePainter(pts, widget.series, sColors, cs.primary, t,
                  _selected, s, label, cs.outlineVariant, selCol),
          anchor: (i, size) => bars
              ? _barsAnchor(i, size)
              : _LinePainter.at(_lineValues(), i, size),
          sColors: sColors,
          axis: bars
              ? null
              : _YAxisPainter(
                  _lineValues(), label, widget.axisFmt ?? widget.fmt),
        );
        if (widget.series.isEmpty) return plot;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Legend(
                labels: [for (final s in widget.series) s.label],
                colors: sColors),
            const SizedBox(height: KuberSpace.md),
            plot,
          ],
        );
    }
  }

  /// Every value the line plots (all series, or the points).
  List<List<double>> _lineValues() => widget.series.isEmpty
      ? [
          [for (final p in widget.points) p.value]
        ]
      : [for (final s in widget.series) s.values];

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
                  scale: AhMotion.reduced(context) ? 1 : 0.92 + 0.08 * v,
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
                      painter: painter(_draw.value,
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

  Offset _barsAnchor(int i, Size size) {
    final pts = widget.points;
    final maxV = pts.map((p) => p.value.abs()).fold<double>(0, math.max);
    final plotH = size.height - _labelH - _barsTop;
    final slot = size.width / pts.length;
    final h = maxV <= 0 ? 0.0 : pts[i].value.abs() / maxV * plotH;
    return Offset(slot * i + slot / 2, _barsTop + plotH - h);
  }

  // --- donut -----------------------------------------------------------------

  Widget _donut(BuildContext context, List<Color> colors, Listenable anim) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pts = widget.points;
    final total = pts.fold<double>(0, (a, p) => a + p.value.abs());
    final sel = _selected;
    String pct(int i) => total <= 0
        ? '0%'
        : '${(pts[i].value.abs() / total * 100).round()}%';

    final ring = SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _tap(
                _donutHit(d.localPosition, const Size(140, 140), pts, total)),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: anim,
                builder: (context, _) => CustomPaint(
                  size: const Size(140, 140),
                  painter: _DonutPainter(
                      pts,
                      colors,
                      AhMotion.decelerate.transform(_draw.value),
                      sel,
                      Curves.easeOutCubic.transform(_sel.value)),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: SizedBox(
              width: 76,
              child: AnimatedSwitcher(
                duration: AhMotion.dur(context, AhMotion.fast),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(
                    scale: Tween(
                            begin: AhMotion.reduced(context) ? 1.0 : 0.8,
                            end: 1.0)
                        .animate(CurvedAnimation(
                            parent: a, curve: AhMotion.fastCurve)),
                    child: child,
                  ),
                ),
                child: sel == null || sel >= pts.length
                    ? const SizedBox.shrink(key: ValueKey('none'))
                    : FittedBox(
                        key: ValueKey('c$sel'),
                        fit: BoxFit.scaleDown,
                        child: Text(pct(sel),
                            style: tt.titleLarge!.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                                fontFeatures: kAhTabular)),
                      ),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ring,
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: AnimatedBuilder(
                animation: _sel,
                builder: (context, _) {
                  final s = Curves.easeOutCubic.transform(_sel.value);
                  return Column(
                    children: [
                      for (var i = 0; i < pts.length; i++)
                        _LegendRow(
                          color: colors[i],
                          label: pts[i].label,
                          value: widget.fmt(pts[i].value),
                          opacity: sel != null && sel != i ? 1 - 0.62 * s : 1,
                          selected: sel == i,
                          onTap: () => _tap(i),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        _DetailSlot(
          child: sel == null || sel >= pts.length
              ? null
              : _ChartDetail(
                  key: ValueKey('d$sel'),
                  color: colors[sel],
                  label: pts[sel].label,
                  value: _full(pts[sel].value),
                  note: context.l10n.ahdOfTotal(pct(sel)),
                  onView: _viewable(pts[sel])
                      ? () => widget.onView!(pts[sel])
                      : null,
                ),
        ),
      ],
    );
  }
}

/// Clips left and right only (the tooltip may rise above the plot).
class _SideClipper extends CustomClipper<Rect> {
  const _SideClipper();
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, -200, size.width, size.height + 200);
  @override
  bool shouldReclip(_SideClipper oldClipper) => false;
}

/// Grows to fit the detail row (expressiveDefaultSpatial) and back.
class _DetailSlot extends StatelessWidget {
  const _DetailSlot({required this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final reduced = AhMotion.reduced(context);
    return AnimatedSize(
      duration: reduced ? AhMotion.instant : AhMotion.defaultCurve.settle,
      curve: reduced ? Curves.linear : AhMotion.defaultSize,
      alignment: Alignment.topCenter,
      child: child ?? const SizedBox(width: double.infinity),
    );
  }
}

/// Dots and names of the compared values.
class _Legend extends StatelessWidget {
  const _Legend({required this.labels, required this.colors});
  final List<String> labels;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Wrap(
      spacing: KuberSpace.lg,
      runSpacing: KuberSpace.xs,
      children: [
        for (var i = 0; i < labels.length; i++)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: colors[i], shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(labels[i],
                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ]),
      ],
    );
  }
}

/// Floating tooltip on bars and line (Home chart style): inverseSurface, r8,
/// label, value (or one row per compared value plus the total), "View
/// transactions".
class _ChartTooltip extends StatelessWidget {
  const _ChartTooltip({
    required this.label,
    required this.value,
    required this.rows,
    required this.onView,
  });
  final String label;

  /// The point's value; null when the single row says it.
  final String? value;
  final List<(Color, String, String)> rows;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final on = cs.onInverseSurface;
    final small = tt.labelMedium!;
    return Container(
      key: const ValueKey('ah-chart-tooltip'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: KuberShape.smallR,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: small.copyWith(color: on.withValues(alpha: 0.8))),
          const SizedBox(height: 2),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: r.$1, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(r.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: small.copyWith(color: on.withValues(alpha: 0.8))),
                ),
                const SizedBox(width: 6),
                Text(r.$3,
                    style: small.copyWith(
                        color: on,
                        fontWeight: FontWeight.w600,
                        fontFeatures: kAhTabular)),
              ]),
            ),
          if (value != null)
            Padding(
              padding: EdgeInsets.only(top: rows.isEmpty ? 0 : 4),
              child: Text(value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall!.copyWith(
                      color: on,
                      fontWeight: FontWeight.w700,
                      fontFeatures: kAhTabular)),
            ),
          if (onView != null)
            GestureDetector(
              key: const ValueKey('ah-chart-view'),
              behavior: HitTestBehavior.opaque,
              onTap: onView,
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(context.l10n.ahdViewTxns,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: small.copyWith(color: cs.inversePrimary)),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        size: 14, color: cs.inversePrimary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Under the donut / heatmap once a part is picked: name, exact value and a
/// note, then "View transactions". Each part fades up 30 ms after the one
/// before.
class _ChartDetail extends StatelessWidget {
  const _ChartDetail({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    required this.onView,
    this.note,
  });
  final Color color;
  final String label, value;
  final String? note;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('ah-donut-detail'),
      margin: const EdgeInsets.only(top: KuberSpace.md),
      padding: const EdgeInsets.fromLTRB(
          KuberSpace.lg, KuberSpace.md, KuberSpace.md, KuberSpace.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.mediumR,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AhFadeIn(
                  child: Row(children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodyMedium!
                              .copyWith(color: cs.onSurfaceVariant)),
                    ),
                  ]),
                ),
                const SizedBox(height: 2),
                AhFadeIn(
                  delay: const Duration(milliseconds: 30),
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium!.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontFeatures: kAhTabular)),
                ),
                if (note != null)
                  AhFadeIn(
                    delay: const Duration(milliseconds: 60),
                    child: Text(note!,
                        style:
                            tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          if (onView != null)
            AhFadeIn(
              delay: const Duration(milliseconds: 90),
              child: AppButton(
                key: const ValueKey('ah-chart-view'),
                label: context.l10n.ahdViewTxns,
                height: 40,
                icon: Icons.arrow_forward_rounded,
                iconAfterLabel: true,
                onPressed: onView,
              ),
            ),
        ],
      ),
    );
  }
}

// --- heatmap -------------------------------------------------------------------

const _cell = 14.0, _gap = 3.0, _col = _cell + _gap, _monthH = 18.0;
const _dayGutter = 22.0;

/// Calendar heatmap: one rounded square per day, weeks as columns (Monday
/// on top), up to the last 53 weeks of the results; darker = more. Scrolls
/// sideways, starting at the latest week. A tap picks a day and shows its
/// value and "View transactions" under the grid.
class _AhHeatmap extends StatefulWidget {
  const _AhHeatmap({
    required this.points,
    required this.fmt,
    required this.dayLabel,
    required this.draw,
    required this.onView,
  });
  final List<AhChartPoint> points;
  final String Function(double) fmt;
  final String Function(String) dayLabel;
  final Animation<double> draw;
  final ValueChanged<AhChartPoint>? onView;

  @override
  State<_AhHeatmap> createState() => _AhHeatmapState();
}

class _AhHeatmapState extends State<_AhHeatmap> {
  final _scroll = ScrollController();
  DateTime? _selected;
  bool _jumped = false;

  @override
  void didUpdateWidget(_AhHeatmap old) {
    super.didUpdateWidget(old);
    // The card maps a fresh list on every build: compare the content.
    if (!_AhChartViewState._same(old.points, widget.points)) {
      _selected = null;
      _jumped = false;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final values = <DateTime, AhChartPoint>{
      // Keys are day keys (`2026-11-03`) from the engine.
      for (final p in widget.points) DateTime.parse(p.key): p,
    };
    if (values.isEmpty) return const SizedBox.shrink();
    final days = values.keys.toList()..sort();
    final end = days.last;
    final first = days.first;
    final floor = DateTime(end.year, end.month, end.day - 7 * 53 + 1);
    final start = first.isAfter(floor) ? first : floor;
    final gridStart =
        DateTime(start.year, start.month, start.day - (start.weekday - 1));
    final weeks = end.difference(gridStart).inDays ~/ 7 + 1;

    // Four steps over the non-zero values (quartiles).
    final nz = [
      for (final d in days)
        if (!d.isBefore(start) && values[d]!.value > 0) values[d]!.value
    ]..sort();
    double q(double f) => nz.isEmpty ? 0 : nz[((nz.length - 1) * f).round()];
    final cuts = [q(0.25), q(0.5), q(0.75)];
    int level(double v) => v <= 0
        ? 0
        : v <= cuts[0]
            ? 1
            : v <= cuts[1]
                ? 2
                : v <= cuts[2]
                    ? 3
                    : 4;
    final shades = [
      cs.surfaceContainerHighest,
      cs.primary.withValues(alpha: 0.28),
      cs.primary.withValues(alpha: 0.5),
      cs.primary.withValues(alpha: 0.75),
      cs.primary,
    ];

    final locale = Localizations.localeOf(context).toString();
    final monthFmt = DateFormat('MMM', locale);
    final narrow = MaterialLocalizations.of(context).narrowWeekdays; // Sun first
    final width = weeks * _col;
    final height = _monthH + 7 * _col;
    if (!_jumped) {
      _jumped = true;
      // Start at the latest week.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    }

    DateTime? dayAt(Offset o) {
      final c = (o.dx / _col).floor();
      final r = ((o.dy - _monthH) / _col).floor();
      if (c < 0 || c >= weeks || r < 0 || r > 6) return null;
      final d =
          DateTime(gridStart.year, gridStart.month, gridStart.day + c * 7 + r);
      if (d.isBefore(start) || d.isAfter(end)) return null;
      return d;
    }

    final sel = _selected;
    final selPoint = sel == null ? null : values[sel];
    final selValue = selPoint?.value ?? 0;
    final small = tt.labelSmall!.copyWith(color: cs.onSurfaceVariant);

    final grid = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (dt) {
        final d = dayAt(dt.localPosition);
        setState(() => _selected = d == null || d == _selected ? null : d);
      },
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: widget.draw,
          builder: (context, _) => CustomPaint(
            size: Size(width, height),
            painter: _HeatmapPainter(
              gridStart: gridStart,
              start: start,
              end: end,
              weeks: weeks,
              shadeOf: (d) => shades[level(values[d]?.value ?? 0)],
              selected: sel,
              ring: cs.onSurface,
              monthLabel: monthFmt.format,
              label: small,
              t: AhMotion.decelerate.transform(widget.draw.value),
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mon, Wed, Fri (rows 0, 2, 4), pinned while the grid scrolls.
              SizedBox(
                width: _dayGutter,
                child: Column(children: [
                  const SizedBox(height: _monthH),
                  for (var r = 0; r < 7; r++)
                    SizedBox(
                      height: _col,
                      child: r.isEven && r < 6
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text(narrow[(r + 1) % 7], style: small),
                            )
                          : null,
                    ),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('ah-heatmap-scroll'),
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  child: grid,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpace.sm),
        // Less [] [] [] [] [] More
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(context.l10n.ahdLess, style: small),
            const SizedBox(width: 6),
            for (final c in shades) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: c,
                    borderRadius:
                        BorderRadius.circular(KuberShape.extraSmall)),
              ),
              const SizedBox(width: 3),
            ],
            const SizedBox(width: 3),
            Text(context.l10n.ahdMore, style: small),
          ],
        ),
        _DetailSlot(
          child: sel == null
              ? null
              : _ChartDetail(
                  key: ValueKey('h$sel'),
                  color: shades[level(selValue)],
                  label: widget.dayLabel(ahDayKey(sel)),
                  value: widget.fmt(selValue),
                  onView: widget.onView != null && selPoint != null
                      ? () => widget.onView!(selPoint)
                      : null,
                ),
        ),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.gridStart,
    required this.start,
    required this.end,
    required this.weeks,
    required this.shadeOf,
    required this.selected,
    required this.ring,
    required this.monthLabel,
    required this.label,
    required this.t,
  });
  final DateTime gridStart, start, end;
  final int weeks;
  final Color Function(DateTime) shadeOf;
  final DateTime? selected;
  final Color ring;
  final String Function(DateTime) monthLabel;
  final TextStyle label;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const r = Radius.circular(KuberShape.extraSmall);
    var lastMonth = -1;
    for (var c = 0; c < weeks; c++) {
      // Columns fade in left to right as the chart draws.
      final a = (t * weeks * 1.5 - c).clamp(0.0, 1.0);
      final colStart =
          DateTime(gridStart.year, gridStart.month, gridStart.day + c * 7);
      for (var row = 0; row < 7; row++) {
        final d = DateTime(colStart.year, colStart.month, colStart.day + row);
        if (d.isBefore(start) || d.isAfter(end)) continue;
        // Month name over the first column a month shows in.
        if (d.month != lastMonth && (d.day <= 7 || lastMonth < 0)) {
          lastMonth = d.month;
          final tp = TextPainter(
            text: TextSpan(text: monthLabel(d), style: label),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          tp.paint(canvas, Offset(c * _col, 0));
          tp.dispose();
        }
        final rect = Rect.fromLTWH(c * _col, _monthH + row * _col, _cell, _cell);
        final shade = shadeOf(d);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, r),
            Paint()..color = shade.withValues(alpha: shade.a * a));
        if (selected == d) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.inflate(1.5), r),
            Paint()
              ..color = ring
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter o) => true;
}

// --- shared painters -------------------------------------------------------------

int? _donutHit(Offset o, Size size, List<AhChartPoint> pts, double total) {
  final c = size.center(Offset.zero);
  final d = o - c;
  final r = d.distance;
  final outer = math.min(size.width, size.height) / 2;
  if (r < outer * 0.4 || r > outer + 6 || total <= 0) return null;
  var a = math.atan2(d.dy, d.dx) + math.pi / 2;
  if (a < 0) a += 2 * math.pi;
  var acc = 0.0;
  for (var i = 0; i < pts.length; i++) {
    acc += pts[i].value.abs() / total * 2 * math.pi;
    if (a <= acc) return i;
  }
  return pts.isEmpty ? null : pts.length - 1;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.opacity,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final String label;
  final String value;
  final double opacity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final weight = selected ? FontWeight.w600 : FontWeight.w400;
    return InkWell(
      onTap: onTap,
      borderRadius: KuberShape.smallR,
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                        fontSize: 13, fontWeight: weight, color: cs.onSurface)),
              ),
              const SizedBox(width: 8),
              Text(value,
                  style: localeFont(
                      fontSize: 13,
                      fontWeight: weight,
                      color: cs.onSurfaceVariant,
                      fontFeatures: kAhTabular)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.pts, this.colors, this.t, this.sel, this.s);
  final List<AhChartPoint> pts;
  final List<Color> colors;
  final double t;
  final int? sel;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final total = pts.fold<double>(0, (a, p) => a + p.value.abs());
    if (total <= 0) return;
    const stroke = 22.0;
    final outer = math.min(size.width, size.height) / 2 - 4;
    final rect = Rect.fromCircle(
        center: size.center(Offset.zero), radius: outer - stroke / 2);
    var start = -math.pi / 2;
    final sweepTotal = 2 * math.pi * t;
    var drawn = 0.0;
    for (var i = 0; i < pts.length; i++) {
      final full = pts[i].value.abs() / total * 2 * math.pi;
      final sw = math.max(0.0, math.min(full, sweepTotal - drawn));
      drawn += full;
      if (sw <= 0) break;
      final isSel = sel == i;
      final dim = sel != null && !isSel;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + (isSel ? 6 * s : 0)
        ..color = colors[i].withValues(alpha: dim ? 1 - 0.62 * s : 1);
      final g = pts.length > 1 ? 0.03 : 0.0;
      canvas.drawArc(rect, start + g / 2, math.max(0.001, sw - g), false, paint);
      start += full;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter o) => true;
}

void _text(Canvas c, String s, TextStyle st, Offset at,
    {double maxW = 80,
    TextAlign align = TextAlign.center,
    double alpha = 1,
    double? within,
    bool right = false}) {
  final tp = TextPainter(
    text: TextSpan(
        text: s,
        style: st.copyWith(color: st.color?.withValues(alpha: alpha))),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
    textAlign: align,
  )..layout(maxWidth: maxW);
  var x = right ? at.dx - tp.width : at.dx - tp.width / 2;
  // Keep edge labels inside the chart instead of running off the card.
  if (within != null) x = x.clamp(0.0, math.max(0.0, within - tp.width));
  tp.paint(c, Offset(x, at.dy));
  tp.dispose();
}

/// Rounded column behind the selected slot (Home chart selection).
void _selColumn(Canvas c, double cx, double w, double h, Color col, double s) {
  if (s <= 0) return;
  c.drawRRect(
    RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h / 2), width: w, height: h),
        const Radius.circular(kChartSelectionRadius)),
    Paint()..color = col.withValues(alpha: col.a * s),
  );
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.pts, this.colors, this.series, this.sColors, this.t,
      this.dur, this.sel, this.s, this.label, this.axis, this.selCol, this.fmt);
  final List<AhChartPoint> pts;
  final List<Color> colors;
  final List<AhChartSeries> series;
  final List<Color> sColors;
  final double t;
  final Duration dur;
  final int? sel;
  final double s;
  final TextStyle label;
  final Color axis, selCol;
  final String Function(double) fmt;

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.isEmpty) return;
    final maxV = pts.map((p) => p.value.abs()).fold<double>(0, math.max);
    if (maxV <= 0) return;
    final plotH = size.height - _labelH - _barsTop;
    final slot = size.width / pts.length;
    final barW = math.min(36.0, slot * 0.6);
    final totalMs = dur.inMilliseconds;
    if (sel != null) {
      _selColumn(
          canvas, slot * sel! + slot / 2, slot - 4, size.height, selCol, s);
    }
    final base = _barsTop + plotH;
    canvas.drawLine(
        Offset(0, base), Offset(size.width, base), Paint()..color = axis);
    for (var i = 0; i < pts.length; i++) {
      // Long scrolled charts: bars after the 12th grow with the 12th.
      final localMs = t * totalMs - math.min(i, 11) * 30;
      final p = Curves.easeOutCubic.transform((localMs / 300).clamp(0.0, 1.0));
      final isSel = sel == i;
      final dim = sel != null && !isSel;
      final alpha = dim ? 1 - 0.62 * s : 1.0;
      final w = barW + (isSel ? 6 * s : 0);
      final cx = slot * i + slot / 2;
      if (series.isEmpty) {
        final h = pts[i].value.abs() / maxV * plotH * p;
        canvas.drawRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTWH(cx - w / 2, base - h, w, h),
              topLeft: const Radius.circular(4),
              topRight: const Radius.circular(4),
            ),
            Paint()..color = colors[i].withValues(alpha: alpha));
      } else {
        // Stacked: first value at the bottom, 1.5 dp apart, round top.
        var top = -1;
        for (var j = 0; j < series.length; j++) {
          if (series[j].values[i].abs() > 0) top = j;
        }
        var y = base;
        for (var j = 0; j < series.length; j++) {
          final v = series[j].values[i].abs();
          if (v <= 0) continue;
          final h = v / maxV * plotH * p;
          final gap = j == top ? 0.0 : math.min(1.5, h / 3);
          final r = j == top ? const Radius.circular(4) : Radius.zero;
          canvas.drawRRect(
              RRect.fromRectAndCorners(
                Rect.fromLTWH(cx - w / 2, y - h + gap, w, h - gap),
                topLeft: r,
                topRight: r,
              ),
              Paint()..color = sColors[j].withValues(alpha: alpha));
          y -= h;
        }
      }
      _text(canvas, pts[i].label, label, Offset(cx, base + 4),
          maxW: slot - 4, alpha: alpha);
      // Values on top when they fit; the selected bar shows its tooltip.
      if (pts.length <= 4 && !isSel && series.isEmpty) {
        final h = pts[i].value.abs() / maxV * plotH * p;
        _text(canvas, fmt(pts[i].value),
            label.copyWith(fontWeight: FontWeight.w600),
            Offset(cx, base - h - 16),
            maxW: slot + 20, alpha: dim ? alpha : p);
      }
    }
  }

  @override
  bool shouldRepaint(_BarsPainter o) => true;
}

/// Y axis of the line (max, middle and min), outside the scrolling plot.
class _YAxisPainter extends CustomPainter {
  _YAxisPainter(this.values, this.label, this.fmt);
  final List<List<double>> values;
  final TextStyle label;
  final String Function(double) fmt;

  @override
  void paint(Canvas canvas, Size size) {
    final (minV, maxV) = _LinePainter._range(values);
    final plotH = size.height - _labelH - _lineTop;
    for (final f in const [0.0, 0.5, 1.0]) {
      final y = _lineTop + plotH * f;
      final v = maxV - (maxV - minV) * f;
      _text(canvas, v == 0 ? '0' : fmt(v), label,
          Offset(size.width - 8, y - 7),
          maxW: size.width - 8, right: true, align: TextAlign.right);
    }
  }

  @override
  bool shouldRepaint(_YAxisPainter o) => true;
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.pts, this.series, this.sColors, this.color, this.t,
      this.sel, this.s, this.label, this.axis, this.selCol);
  final List<AhChartPoint> pts;
  final List<AhChartSeries> series;
  final List<Color> sColors;
  final Color color;
  final double t;
  final int? sel;
  final double s;
  final TextStyle label;
  final Color axis, selCol;

  static (double, double) _range(List<List<double>> values) {
    var maxV = 0.0, minV = 0.0;
    for (final l in values) {
      for (final v in l) {
        maxV = math.max(maxV, v);
        minV = math.min(minV, v);
      }
    }
    return (minV, maxV);
  }

  /// Point [i] of the highest line in a plot of [size].
  static Offset at(List<List<double>> values, int i, Size size) {
    final (minV, maxV) = _range(values);
    var v = minV;
    for (final l in values) {
      v = math.max(v, l[i]);
    }
    return _pos(v, i, values.first.length, size, minV, maxV);
  }

  static Offset _pos(
      double v, int i, int n, Size size, double minV, double maxV) {
    final range = maxV - minV == 0 ? 1.0 : maxV - minV;
    final plotH = size.height - _labelH - _lineTop;
    final slot = size.width / n;
    return Offset(
        slot * i + slot / 2, _lineTop + plotH - (v - minV) / range * plotH);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.isEmpty) return;
    final lines = series.isEmpty
        ? [
            [for (final p in pts) p.value]
          ]
        : [for (final x in series) x.values];
    final colors = series.isEmpty ? [color] : sColors;
    final (minV, maxV) = _range(lines);
    final n = pts.length;
    final plotH = size.height - _labelH - _lineTop;
    final slot = size.width / n;

    final grid = Paint()
      ..color = axis.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (final f in const [0.0, 0.5]) {
      final y = _lineTop + plotH * f;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (sel != null) {
      _selColumn(canvas, slot * sel! + slot / 2, math.min(slot - 4, 48),
          size.height, selCol, s);
    }
    canvas.drawLine(Offset(0, _lineTop + plotH),
        Offset(size.width, _lineTop + plotH), Paint()..color = axis);

    for (var j = 0; j < lines.length; j++) {
      Offset p(int i) => _pos(lines[j][i], i, n, size, minV, maxV);
      final path = Path()..moveTo(p(0).dx, p(0).dy);
      for (var i = 1; i < n; i++) {
        path.lineTo(p(i).dx, p(i).dy);
      }
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final m = metrics.first;
        canvas.drawPath(
            m.extractPath(0, m.length * t),
            Paint()
              ..color = colors[j]
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round);
      }
      for (var i = 0; i < n; i++) {
        final appear = n <= 1 ? 1.0 : (t * (n - 1) - i + 1).clamp(0.0, 1.0);
        final isSel = sel == i;
        final dim = sel != null && !isSel;
        final a = (dim ? 1 - 0.62 * s : 1.0) * appear;
        if (isSel) {
          canvas.drawCircle(p(i), 4 + 4 * s,
              Paint()..color = colors[j].withValues(alpha: 0.24 * s));
        }
        canvas.drawCircle(p(i), isSel ? 4 + 2 * s : 4,
            Paint()..color = colors[j].withValues(alpha: a));
      }
    }
    // Month labels ("Oct 2026") need about 64 dp each.
    final step = math.max(1, (n / (size.width / 64)).ceil());
    for (var i = 0; i < n; i += step) {
      final dim = sel != null && sel != i;
      _text(canvas, pts[i].label, label,
          Offset(slot * i + slot / 2, _lineTop + plotH + 4),
          maxW: math.max(slot * step, 56),
          alpha: dim ? 1 - 0.62 * s : 1,
          within: size.width);
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) => true;
}
