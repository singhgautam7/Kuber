part of 'ah_chart_view.dart';

extension _LineChart on _AhChartViewState {
  /// Every value the line plots (all series, or the points).
  List<List<double>> _lineValues() => widget.series.isEmpty
      ? [
          [for (final p in widget.points) p.value]
        ]
      : [for (final s in widget.series) s.values];
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
  bool shouldRepaint(_YAxisPainter o) =>
      o.label != label ||
      !_sameFmt(o.fmt, fmt) ||
      o.values.length != values.length ||
      [for (var i = 0; i < values.length; i++)
        if (!listEquals(o.values[i], values[i])) i].isNotEmpty;
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
  bool shouldRepaint(_LinePainter o) =>
      !identical(o.pts, pts) ||
      !identical(o.series, series) ||
      !listEquals(o.sColors, sColors) ||
      o.color != color ||
      o.t != t ||
      o.sel != sel ||
      o.s != s ||
      o.label != label ||
      o.axis != axis ||
      o.selCol != selCol;
}
