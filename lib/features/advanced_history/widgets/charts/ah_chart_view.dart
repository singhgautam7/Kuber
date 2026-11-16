import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_harmonizer.dart';
import '../../../../core/utils/locale_font.dart';
import '../../models/ah_view.dart';
import '../../services/ah_results.dart';
import '../common/ah_common.dart';
import '../common/ah_motion.dart';

/// Donut, bars or line for [points]. Draws in on first show (donut sweep
/// 400 ms, bars 300 ms 30 ms apart, line 400 ms; none when motion is
/// reduced). Tapping a part grows it, fades the others to 38% and calls
/// [onTapPoint].
class AhChartView extends StatefulWidget {
  const AhChartView({
    super.key,
    required this.type,
    required this.points,
    required this.fmt,
    required this.onTapPoint,
  });
  final AhChartType type;
  final List<AhChartPoint> points;
  final String Function(double) fmt;
  final ValueChanged<AhChartPoint> onTapPoint;

  @override
  State<AhChartView> createState() => _AhChartViewState();
}

class _AhChartViewState extends State<AhChartView>
    with TickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(vsync: this);
  late final AnimationController _sel =
      AnimationController(vsync: this, duration: AhMotion.fast);
  int? _selected;
  bool _started = false;

  Duration get _drawDur => widget.type == AhChartType.bars
      ? Duration(milliseconds: 300 + 30 * math.max(0, widget.points.length - 1))
      : const Duration(milliseconds: 400);

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
    if (!_same(old.points, widget.points) || old.type != widget.type) {
      _selected = null;
      _sel.value = 0;
      _run();
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    _sel.dispose();
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
    if (i == null) return;
    setState(() => _selected = i);
    _sel.forward(from: 0);
    widget.onTapPoint(widget.points[i]);
    // The part stays raised while the sheet is open, then settles.
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _selected = null);
        _sel.value = 0;
      }
    });
  }

  Color _color(BuildContext c, int i) {
    final cs = Theme.of(c).colorScheme;
    final p = widget.points[i];
    if (p.key == '__other') return cs.outline;
    if (p.colorValue != null) return categoryVizColor(c, Color(p.colorValue!));
    final pal = [
      cs.primary,
      cs.tertiary,
      cs.secondary,
      cs.inversePrimary,
      cs.onSurfaceVariant,
      cs.outlineVariant,
    ];
    return pal[i % pal.length];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = localeFont(fontSize: 11, color: cs.onSurfaceVariant);
    final colors = [
      for (var i = 0; i < widget.points.length; i++) _color(context, i),
    ];
    final anim = Listenable.merge([_draw, _sel]);
    final pts = widget.points;

    Widget canvas(CustomPainter Function() make, double h,
        int? Function(Offset, Size) hit) {
      return LayoutBuilder(
        builder: (context, bc) {
          final size = Size(bc.maxWidth, h);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _tap(hit(d.localPosition, size)),
            child: RepaintBoundary(
              child: CustomPaint(size: size, painter: make()),
            ),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final t = AhMotion.decelerate.transform(_draw.value);
        final s = Curves.easeOutCubic.transform(_sel.value);
        switch (widget.type) {
          case AhChartType.donut:
            final total = pts.fold<double>(0, (a, p) => a + p.value.abs());
            return Row(
              children: [
                SizedBox(
                  width: 140,
                  child: canvas(
                    () => _DonutPainter(pts, colors, t, _selected, s, cs.surfaceContainer),
                    140,
                    (o, size) => _donutHit(o, size, pts, total),
                  ),
                ),
                const SizedBox(width: KuberSpace.lg),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < pts.length; i++)
                        _LegendRow(
                          color: colors[i],
                          label: pts[i].label,
                          value: widget.fmt(pts[i].value),
                          dim: _selected != null && _selected != i,
                          onTap: () => _tap(i),
                        ),
                    ],
                  ),
                ),
              ],
            );
          case AhChartType.bars:
            return canvas(
              () => _BarsPainter(pts, colors, _draw.value, _drawDur, _selected,
                  s, label, cs.outlineVariant, widget.fmt),
              168,
              (o, size) => _slotHit(o, size, pts.length),
            );
          case AhChartType.line:
            return canvas(
              () => _LinePainter(pts, cs.primary, t, _selected, s, label,
                  cs.outlineVariant, widget.fmt),
              168,
              (o, size) => _slotHit(o, size, pts.length, edge: true),
            );
        }
      },
    );
  }
}

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

int? _slotHit(Offset o, Size size, int n, {bool edge = false}) {
  if (n == 0) return null;
  final w = size.width / n;
  return (o.dx / w).floor().clamp(0, n - 1);
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.dim,
    required this.onTap,
  });
  final Color color;
  final String label;
  final String value;
  final bool dim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: dim ? 0.38 : 1,
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
                    style: localeFont(fontSize: 13, color: cs.onSurface)),
              ),
              const SizedBox(width: 8),
              Text(value,
                  style: localeFont(
                      fontSize: 13,
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
  _DonutPainter(this.pts, this.colors, this.t, this.sel, this.s, this.gap);
  final List<AhChartPoint> pts;
  final List<Color> colors;
  final double t;
  final int? sel;
  final double s;
  final Color gap;

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
    double? within}) {
  final tp = TextPainter(
    text: TextSpan(
        text: s,
        style: st.copyWith(color: st.color?.withValues(alpha: alpha))),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
    textAlign: align,
  )..layout(maxWidth: maxW);
  var x = at.dx - tp.width / 2;
  // Keep edge labels inside the chart instead of running off the card.
  if (within != null) x = x.clamp(0.0, math.max(0.0, within - tp.width));
  tp.paint(c, Offset(x, at.dy));
}

class _BarsPainter extends CustomPainter {
  _BarsPainter(this.pts, this.colors, this.t, this.dur, this.sel, this.s,
      this.label, this.axis, this.fmt);
  final List<AhChartPoint> pts;
  final List<Color> colors;
  final double t;
  final Duration dur;
  final int? sel;
  final double s;
  final TextStyle label;
  final Color axis;
  final String Function(double) fmt;

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.isEmpty) return;
    const labelH = 22.0, top = 18.0;
    final maxV = pts.map((p) => p.value.abs()).fold<double>(0, math.max);
    if (maxV <= 0) return;
    final plotH = size.height - labelH - top;
    final slot = size.width / pts.length;
    final barW = math.min(36.0, slot * 0.6);
    final totalMs = dur.inMilliseconds;
    canvas.drawLine(Offset(0, top + plotH), Offset(size.width, top + plotH),
        Paint()..color = axis);
    for (var i = 0; i < pts.length; i++) {
      final localMs = t * totalMs - i * 30;
      final p = Curves.easeOutCubic.transform((localMs / 300).clamp(0.0, 1.0));
      final isSel = sel == i;
      final dim = sel != null && !isSel;
      final h = pts[i].value.abs() / maxV * plotH * p;
      final w = barW + (isSel ? 6 * s : 0);
      final cx = slot * i + slot / 2;
      final r = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - w / 2, top + plotH - h, w, h),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(
          r,
          Paint()
            ..color = colors[i].withValues(alpha: dim ? 1 - 0.62 * s : 1));
      _text(canvas, pts[i].label, label, Offset(cx, top + plotH + 4),
          maxW: slot - 4, alpha: dim ? 1 - 0.62 * s : 1);
      if (isSel || pts.length <= 4) {
        _text(canvas, fmt(pts[i].value), label.copyWith(fontWeight: FontWeight.w600),
            Offset(cx, top + plotH - h - 16),
            maxW: slot + 20, alpha: dim ? 1 - 0.62 * s : p);
      }
    }
  }

  @override
  bool shouldRepaint(_BarsPainter o) => true;
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.pts, this.color, this.t, this.sel, this.s, this.label,
      this.axis, this.fmt);
  final List<AhChartPoint> pts;
  final Color color;
  final double t;
  final int? sel;
  final double s;
  final TextStyle label;
  final Color axis;
  final String Function(double) fmt;

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.isEmpty) return;
    const labelH = 22.0, top = 22.0;
    final maxV = pts.map((p) => p.value).fold<double>(0, math.max);
    final minV = math.min(0.0, pts.map((p) => p.value).fold<double>(0, math.min));
    final range = maxV - minV == 0 ? 1.0 : maxV - minV;
    final plotH = size.height - labelH - top;
    final slot = size.width / pts.length;
    Offset at(int i) => Offset(slot * i + slot / 2,
        top + plotH - (pts[i].value - minV) / range * plotH);
    canvas.drawLine(Offset(0, top + plotH), Offset(size.width, top + plotH),
        Paint()..color = axis);
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    final m = path.computeMetrics().first;
    canvas.drawPath(
        m.extractPath(0, m.length * t),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
    // Month labels ("Oct 2026") need about 64 dp each.
    final step = math.max(1, (pts.length / (size.width / 64)).ceil());
    for (var i = 0; i < pts.length; i++) {
      final appear = pts.length <= 1 ? 1.0 : (t * (pts.length - 1) - i + 1).clamp(0.0, 1.0);
      final isSel = sel == i;
      final dim = sel != null && !isSel;
      final a = (dim ? 1 - 0.62 * s : 1.0) * appear;
      canvas.drawCircle(at(i), isSel ? 4 + 4 * s : 4,
          Paint()..color = color.withValues(alpha: a));
      if (i % step == 0 || isSel) {
        _text(canvas, pts[i].label, label, Offset(at(i).dx, top + plotH + 4),
            maxW: math.max(slot * step, 56), alpha: dim ? 1 - 0.62 * s : 1,
            within: size.width);
      }
      if (isSel) {
        _text(canvas, fmt(pts[i].value),
            label.copyWith(fontWeight: FontWeight.w600), at(i) - const Offset(0, 22),
            maxW: 110);
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) => true;
}
