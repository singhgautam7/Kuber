part of 'ah_chart_view.dart';

extension _BarsChart on _AhChartViewState {
  Offset _barsAnchor(int i, Size size) {
    final pts = widget.points;
    final maxV = pts.map((p) => p.value.abs()).fold<double>(0, math.max);
    final plotH = size.height - _labelH - _barsTop;
    final slot = size.width / pts.length;
    final h = maxV <= 0 ? 0.0 : pts[i].value.abs() / maxV * plotH;
    return Offset(slot * i + slot / 2, _barsTop + plotH - h);
  }
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
      final localMs = t * totalMs - KuberMotion.staggerDelay(i).inMilliseconds;
      final p = KuberMotion.curveEffects.transform((localMs / 300).clamp(0.0, 1.0));
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
  bool shouldRepaint(_BarsPainter o) =>
      !identical(o.pts, pts) ||
      !identical(o.series, series) ||
      !listEquals(o.colors, colors) ||
      !listEquals(o.sColors, sColors) ||
      o.t != t ||
      o.dur != dur ||
      o.sel != sel ||
      o.s != s ||
      o.label != label ||
      o.axis != axis ||
      o.selCol != selCol ||
      !_sameFmt(o.fmt, fmt);
}
