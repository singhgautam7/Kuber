import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_harmonizer.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/expressive_chart/expressive_chart.dart';
import '../../../charts/widgets/income_expense_chart_controls.dart'
    show chartSelectionColumn, kChartSelectionRadius;
import '../../models/ah_view.dart';
import '../../services/ah_engine.dart' show ahDayKey;
import '../../services/ah_results.dart';
import '../common/ah_common.dart';
import 'package:kuber/core/motion/motion.dart';

part 'ah_chart_common.dart';
part 'ah_chart_scroll_plot.dart';
part 'ah_chart_donut.dart';
part 'ah_chart_bars.dart';
part 'ah_chart_line.dart';
part 'ah_chart_heatmap.dart';

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
    this.seriesName = '',
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

  /// Name on the tooltip row of the month / year charts (the measure).
  final String seriesName;

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
      AnimationController(vsync: this, duration: KuberMotion.fxFast);

  /// Data change with the same shape: values spring from [_fromPts] (0) to
  /// the new ones (1) on springStandard.
  late final AnimationController _morph =
      AnimationController.unbounded(vsync: this, value: 1);
  List<AhChartPoint>? _fromPts;
  MotionLevel _level = MotionLevel.expressive;

  /// Subtle: the chart fades in (painters see a finished draw-in).
  bool get _subtle => _level == MotionLevel.subtle;

  /// Draw-in progress the painters read (finished at Subtle).
  Animation<double> get _drawT => _subtle ? kAlwaysCompleteAnimation : _draw;

  /// The points to paint: [AhChartView.points], or a spring-eased blend from
  /// the previous values while [_morph] runs.
  List<AhChartPoint> _shown() {
    final from = _fromPts, to = widget.points, m = _morph.value;
    if (from == null || m == 1 || from.length != to.length) return to;
    return [
      for (var i = 0; i < to.length; i++)
        AhChartPoint(to[i].key, to[i].label,
            from[i].value + (to[i].value - from[i].value) * m,
            colorValue: to[i].colorValue),
    ];
  }
  final _scroll = ScrollController();
  int? _selected;
  bool _started = false;
  bool _jumped = false;

  ChartKind get _kind => switch (widget.type) {
        AhChartType.bars => ChartKind.bars,
        AhChartType.line => ChartKind.line,
        _ => ChartKind.donut,
      };

  Duration get _drawDur =>
      ChartProgress(0, _kind, widget.points.length).total;

  String _full(double v) => (widget.fullFmt ?? widget.fmt)(v);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _level = KuberMotion.levelOf(context);
    if (_started) return;
    _started = true;
    _run();
  }

  /// Draw-in (motion.md "Charts"): Expressive draws, Subtle fades in
  /// fx.default, Off appears.
  void _run() {
    if (_level == MotionLevel.off) {
      _draw.value = 1;
      return;
    }
    _draw.duration = _subtle ? KuberMotion.fxDefault : _drawDur;
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
      final sameShape = old.type == widget.type &&
          old.series.length == widget.series.length &&
          old.points.length == widget.points.length &&
          [for (final p in old.points) p.key].join('|') ==
              [for (final p in widget.points) p.key].join('|');
      if (sameShape && _level != MotionLevel.off) {
        // Data change: spring the values, no new draw-in.
        _fromPts = _shown();
        _morph.value = 0;
        _morph.springTo(
            1, KuberMotion.spatial(_level, KuberMotion.springStandard));
      } else {
        _fromPts = null;
        _run();
      }
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    _sel.dispose();
    _morph.dispose();
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
    final body = _content(context);
    if (!_subtle) return body;
    return FadeTransition(
      opacity: CurvedAnimation(parent: _draw, curve: KuberMotion.curveEffects),
      child: body,
    );
  }

  Widget _content(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = localeFont(fontSize: 11, color: cs.onSurfaceVariant);
    final pts = widget.points;
    final selCol = chartSelectionColumn(cs);
    final anim = Listenable.merge([_draw, _sel, _morph]);
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
          draw: _drawT,
          onView: widget.onView,
        );
      case AhChartType.bars:
      case AhChartType.line:
        final bars = widget.type == AhChartType.bars;
        // One measure over months / years: the shared chart.
        if (widget.series.isEmpty && _AhTimeChart.fits(pts, line: !bars)) {
          return _AhTimeChart(
            points: pts,
            line: !bars,
            seriesName: widget.seriesName,
            fmt: _full,
            axisFmt: widget.axisFmt ?? widget.fmt,
            onView: widget.onView,
          );
        }
        final colors = [for (var i = 0; i < pts.length; i++) _color(context, i)];
        final plot = _plot(
          context,
          height: bars ? _barsH : _lineH,
          minSlot: bars ? _minBarSlot : _minLineSlot,
          anim: anim,
          painter: (t, s) => bars
              ? _BarsPainter(_shown(), colors, widget.series, sColors, t, _drawDur,
                  _selected, s, label, cs.outlineVariant, selCol, widget.fmt)
              : _LinePainter(_shown(), widget.series, sColors, cs.primary,
                  KuberMotion.curveEffects.transform(t),
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
}
