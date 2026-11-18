import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/app_theme.dart';
import '../expressive_shapes.dart';
import 'chart_model.dart';

const double _h = ExpressiveChartMetrics.plotHeight;
const double _pad = ExpressiveChartMetrics.topPad;

/// Live animation values the painter reads each frame. The chart state
/// implements it over its controllers; [Listenable] merges them so the plot
/// repaints from springs without rebuilding any widget.
abstract class ChartLive implements Listenable {
  /// Scroll offset in dp of the *target* slot, 0 = today, > 0 = older.
  double get pixels;
  double get maxExtent;

  /// Visible slots (animates 6 to 12).
  double get win;
  double get yMax;

  /// 0 = bars, 1 = line.
  double get mode;

  /// Data change progress 0..1 (from -> to).
  double get dataT;

  /// First-show progress 0..1 (linear), and which kind drives it.
  double get intro;
  bool get introIsLine;

  /// Selection: period indices and their progress 0..1.
  int? get selIdx;
  int? get prevSelIdx;
  double get selIn;
  double get selOut;

  /// 0..1: others dimmed to 38 %.
  double get dim;

  /// Y label roll 0..1 (old label out, new in).
  double get yRoll;
  double get yPrevMax;
  double get yTargetMax;
}

/// Caches laid-out labels so painting never allocates text objects per frame.
class ChartTextCache {
  final _cache = <String, TextPainter>{};

  TextPainter get(String text, TextStyle style, TextScaler scaler) {
    final key =
        '$text|${style.color?.toARGB32()}|${style.fontWeight?.value}|${style.fontSize}';
    return _cache.putIfAbsent(key, () {
      return TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
    });
  }
}

/// Everything the plot paints that is not animated per frame. A new frame
/// object means "repaint"; the painter compares identity.
@immutable
class ChartFrame {
  const ChartFrame({
    required this.periods,
    required this.series,
    required this.from,
    required this.to,
    required this.skeletons,
    required this.window,
    required this.level,
    required this.axisWidth,
    required this.labelHeight,
    required this.cs,
    required this.gridline,
    required this.surface,
    required this.labelStyle,
    required this.textScaler,
    required this.texts,
    required this.formatAxis,
    required this.firstLetters,
    required this.labelEvery,
    required this.semanticsLabel,
    required this.onSemanticsTap,
    required this.semanticsPixels,
    required this.dark,
    required this.skeletonShimmer,
    this.textDirection = TextDirection.ltr,
  });

  final List<ExpressivePeriod> periods;
  final List<ExpressiveSeries> series;

  /// Per period: the series values. Same length as [periods].
  final List<List<double>> from;
  final List<List<double>> to;

  /// Skeleton pills prepended on the left.
  final int skeletons;
  final int window;
  final MotionLevel level;
  final double axisWidth;
  final double labelHeight;
  final ColorScheme cs;
  final Color gridline;
  final Color surface;
  final TextStyle labelStyle;
  final TextScaler textScaler;
  final ChartTextCache texts;
  final String Function(double) formatAxis;

  /// 1Y: labels are first letters (except the current period).
  final bool firstLetters;

  /// 2 at the largest font in 1Y: every second label.
  final int labelEvery;
  final String Function(int periodIndex) semanticsLabel;
  final void Function(int periodIndex) onSemanticsTap;

  /// Scroll offset when semantics were last rebuilt (scroll end).
  final double semanticsPixels;
  final bool dark;
  final bool skeletonShimmer;
  final TextDirection textDirection;

  int get total => skeletons + periods.length;
  bool get isTwo => series.length == 2;
}

/// Column positions for one scroll state. [pixels] is in dp of the target
/// slot ([slotTarget]); [slot] is the (animated) drawn slot.
class ChartGeometry {
  ChartGeometry({
    required this.plotWidth,
    required this.total,
    required double win,
    required double pixels,
    required int windowTarget,
  })  : slot = plotWidth / win,
        slotTarget = plotWidth / windowTarget {
    adj = pixels * slot / slotTarget;
  }

  final double plotWidth;
  final int total;
  final double slot;
  final double slotTarget;
  late final double adj;

  double x(int t) => plotWidth - (total - t) * slot + adj;
  double cx(int t) => x(t) + slot / 2;

  /// Column under [localX] or null.
  int? columnAt(double localX) {
    if (localX < 0 || localX > plotWidth || total == 0) return null;
    final t = ((localX - adj - plotWidth) / slot).floor() + total;
    return t < 0 || t >= total ? null : t;
  }
}

class _Seg {
  _Seg(this.rect, this.color,
      {this.topJoint = false,
      this.bottomJoint = false,
      this.joint = 6,
      this.topR = 0,
      this.half = 0,
      this.halfTop = 0})
      ;
  final Rect rect;
  final Color color;
  final bool topJoint, bottomJoint;
  final double joint, topR;

  /// -1 left half, 1 right half, 0 a layered / single segment.
  final int half;
  final double halfTop;
}

double _cl(double r, Rect rect) =>
    math.min(r, rect.shortestSide / 2).clamp(0.0, double.infinity);

/// Segments of one bar column. [g] grows it from the baseline, [sel] is the
/// selection geometry factor (wider, 10 dp top, 8 dp joint).
List<_Seg> _barSegments({
  required List<double> v,
  required List<ExpressiveSeries> series,
  required double yMax,
  required double cx,
  required double colW,
  required double sel,
  required double g,
}) {
  double hOf(double x) => x / yMax * _h;
  final cw = colW + 3 * sel;
  final x0 = cx - cw / 2;
  final j = ui.lerpDouble(6, 8, sel)!;
  final top = ui.lerpDouble(cw / 2, 10, sel)!;
  const minSeg = ExpressiveChartMetrics.minSegment;

  if (series.length == 1) {
    if (v[0] <= 0) return const [];
    final h = g * math.max(minSeg, hOf(v[0]));
    return [
      _Seg(Rect.fromLTWH(x0, _h - h, cw, h), series[0].color, topR: top),
    ];
  }
  final a = v[0], b = v[1];
  if (a <= 0 && b <= 0) return const [];
  if (a == b) {
    final hw = (cw - 2) / 2;
    final hh = g * math.max(minSeg, hOf(a));
    final tp = ui.lerpDouble(hw, 8, sel)!;
    return [
      _Seg(Rect.fromLTWH(cx - 1 - hw, _h - hh, hw, hh), series[0].color,
          half: -1, halfTop: tp),
      _Seg(Rect.fromLTWH(cx + 1, _h - hh, hw, hh), series[1].color,
          half: 1, halfTop: tp),
    ];
  }
  final loI = a < b ? 0 : 1, hiI = 1 - loI;
  final lo = v[loI], hi = v[hiI];
  final hLo = lo > 0 ? g * math.max(minSeg, hOf(lo)) : 0.0;
  final hHi =
      g * math.max((hLo > 0 ? hLo / math.max(g, 1e-6) + 8 : minSeg), hOf(hi));
  final split = hLo > 0 && hHi > hLo + 1;
  final out = <_Seg>[];
  if (hLo > 0) {
    out.add(_Seg(Rect.fromLTWH(x0, _h - hLo, cw, hLo), series[loI].color,
        topJoint: split, joint: j, topR: top));
  }
  if (hHi > hLo + 1) {
    final segH = hHi - hLo - (hLo > 0 ? 2 : 0);
    out.add(_Seg(Rect.fromLTWH(x0, _h - hHi, cw, segH), series[hiI].color,
        bottomJoint: hLo > 0, joint: j, topR: top));
  }
  return out;
}

/// y (from the plot top) of the highest point of a column at rest, including
/// its top: where the tooltip's bottom sits 12 dp above.
double chartColumnTop({
  required ExpressivePeriod period,
  required List<ExpressiveSeries> series,
  required double yMax,
  required bool lineMode,
  required double colW,
}) {
  if (period.noData || period.isZero) {
    return lineMode && !period.noData ? _h - 6 : _h - 8;
  }
  var top = _h;
  if (lineMode) {
    for (final v in period.values) {
      top = math.min(top, _h - v / yMax * _h - 6);
    }
    return top;
  }
  for (final s in _barSegments(
      v: period.values,
      series: series,
      yMax: yMax,
      cx: 0,
      colW: colW,
      sel: 0,
      g: 1)) {
    top = math.min(top, s.rect.top);
  }
  return top;
}

class ChartPainter extends CustomPainter {
  ChartPainter({required this.frame, required this.live}) : super(repaint: live);

  final ChartFrame frame;
  final ChartLive live;

  @override
  bool shouldRepaint(ChartPainter oldDelegate) =>
      !identical(oldDelegate.frame, frame) || oldDelegate.live != live;

  @override
  bool shouldRebuildSemantics(ChartPainter oldDelegate) =>
      !identical(oldDelegate.frame, frame);

  @override
  SemanticsBuilderCallback get semanticsBuilder => (size) {
        final f = frame;
        final plotW = size.width - f.axisWidth;
        final geo = ChartGeometry(
            plotWidth: plotW,
            total: f.total,
            win: f.window.toDouble(),
            pixels: f.semanticsPixels,
            windowTarget: f.window);
        return [
          for (var p = 0; p < f.periods.length; p++)
            if (geo.x(p + f.skeletons) + geo.slot > 0 && geo.x(p + f.skeletons) < plotW)
              CustomPainterSemantics(
                key: ValueKey(f.periods[p].key),
                rect: Rect.fromLTWH(
                    geo.x(p + f.skeletons), 0, geo.slot, _h + _pad + f.labelHeight),
                properties: SemanticsProperties(
                  label: f.semanticsLabel(p),
                  textDirection: f.textDirection,
                  button: true,
                  onTap: () => f.onSemanticsTap(p),
                  onDidGainAccessibilityFocus: () => f.onSemanticsTap(p),
                ),
              ),
        ];
      };

  // ---- value helpers ------------------------------------------------------

  double _val(int p, int s) {
    final a = frame.from[p][s], b = frame.to[p][s];
    final v = a + (b - a) * live.dataT;
    return v < 0 ? 0 : v;
  }

  List<double> _vals(int p) =>
      [for (var s = 0; s < frame.series.length; s++) _val(p, s)];

  double _selFactor(int p) {
    var f = 0.0;
    if (p == live.selIdx) f += live.selIn;
    if (p == live.prevSelIdx) f += live.selOut;
    return f.clamp(0.0, 1.0);
  }

  /// Stagger progress of the column at distance [r] from today (0 = today).
  double _introGrow(int r) {
    final i = live.intro;
    if (i >= 1) return 1;
    final settle = KuberMotion.standardCurve.settle.inMilliseconds;
    final total = settle + KuberMotion.staggerDelay(ExpressiveChartMetrics.minSegment.toInt()).inMilliseconds;
    final ms = i * total - KuberMotion.staggerDelay(r).inMilliseconds;
    return KuberMotion.standardCurve.clamped.transform((ms / settle).clamp(0.0, 1.0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame;
    final plotW = size.width - f.axisWidth;
    if (plotW <= 0) return;
    final yMax = live.yMax <= 0 ? 1.0 : live.yMax;
    final geo = ChartGeometry(
        plotWidth: plotW,
        total: f.total,
        win: live.win,
        pixels: live.pixels,
        windowTarget: f.window);
    final expressive = f.level == MotionLevel.expressive;
    canvas.save();
    canvas.translate(0, _pad);
    _paintGrid(canvas, plotW, f);

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, -_pad, plotW, _h + f.labelHeight));

    final m = live.mode;
    // Subtle: bars and line cross-fade; Expressive: morph; Off: swapped.
    final barAlpha = expressive ? 1.0 : (1 - m);
    final lineAlpha = expressive ? 1.0 : m;
    final morph = expressive ? m : 0.0;
    final colW = ExpressiveChartMetrics.columnWidth(live.win);
    final fadeIn = f.level == MotionLevel.subtle ? Curves.easeOut.transform(live.intro) : 1.0;

    final tLo = math.max(0, ((plotW + geo.adj) / geo.slot).isFinite ? f.total - ((plotW + geo.adj) / geo.slot).ceil() - 1 : 0);
    final tHi = math.min(f.total - 1, (f.total - geo.adj / geo.slot).ceil() + 1);

    final over = live.pixels < 0
        ? -live.pixels
        : (live.pixels > live.maxExtent ? live.pixels - live.maxExtent : 0.0);
    final squish = expressive ? (over / ExpressiveChartMetrics.rubberMax).clamp(0.0, 1.0) : 0.0;
    final atToday = live.pixels < 0;

    // Selected guide (line).
    final selP = live.selIdx;
    if (selP != null && m > 0 && lineAlpha > 0) {
      final sf = live.selIn;
      final x = geo.cx(selP + f.skeletons);
      canvas.drawLine(
          Offset(x, 0),
          Offset(x, _h),
          Paint()
            ..color = f.cs.outlineVariant.withValues(alpha: sf * lineAlpha * m)
            ..strokeWidth = 1.5);
    }

    final introBar = !live.introIsLine;
    for (var t = tLo; t <= tHi; t++) {
      final p = t - f.skeletons;
      final cx = geo.cx(t);
      if (p < 0) {
        _skeleton(canvas, t, cx, colW, f);
        continue;
      }
      final period = f.periods[p];
      final r = f.total - 1 - t;
      final g = introBar ? _introGrow(r) : 1.0;
      var sq = 1.0;
      if (squish > 0) {
        if (atToday) {
          if (t == f.total - 1) {
            sq = 1 - 0.14 * squish;
          } else if (t == f.total - 2) {
            sq = 1 - 0.08 * squish;
          }
        } else if (t == 0) {
          sq = 1 - 0.14 * squish;
        } else if (t == 1) {
          sq = 1 - 0.08 * squish;
        }
      }
      final selF = _selFactor(p);
      final selGeom = expressive ? selF : 0.0;
      final op = (1 - live.dim * (1 - KuberChartThemeAlpha.unselected) * (1 - selF)) *
          fadeIn;
      if (barAlpha > 0) {
        _barColumn(canvas, p, period, cx, colW * sq, selGeom, g, yMax, morph,
            op * barAlpha, f);
      }
    }
    if (m > 0 || lineAlpha > 0) {
      if (m > 0 && lineAlpha > 0) {
        _lineLayer(canvas, geo, tLo, tHi, yMax, f, lineAlpha, fadeIn);
      }
    }
    canvas.restore(); // clip

    // Labels (clipped to the plot).
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, _h, plotW, _h + f.labelHeight + 4));
    for (var t = tLo; t <= tHi; t++) {
      final p = t - f.skeletons;
      if (p < 0) continue;
      if ((f.total - 1 - t) % f.labelEvery != 0) continue;
      final period = f.periods[p];
      final selF = _selFactor(p);
      final isSel = selF > 0.5;
      final w = isSel ? FontWeight.w700 : period.isCurrent ? FontWeight.w600 : FontWeight.w500;
      final color = (isSel || period.isCurrent) ? f.cs.onSurface : f.cs.onSurfaceVariant;
      var text = period.label;
      if (f.firstLetters && !period.isCurrent && text.isNotEmpty) {
        text = text.characters.first;
      }
      final tp = f.texts.get(
          text,
          KuberMotion.weightStyle(f.labelStyle, w.value.toDouble()).copyWith(color: color),
          f.textScaler);
      tp.paint(canvas, Offset(geo.cx(t) - tp.width / 2, _h + 6));
    }
    canvas.restore();

    // Fade where columns continue to the left.
    if (f.total > 0 && geo.x(0) < -2) {
      canvas.drawRect(
        Rect.fromLTWH(0, -_pad, ExpressiveChartMetrics.edgeFade, _h + _pad + f.labelHeight),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            const Offset(ExpressiveChartMetrics.edgeFade, 0),
            [f.surface, f.surface.withValues(alpha: 0)],
          ),
      );
    }
    canvas.restore();
  }

  // ---- grid and Y labels ----------------------------------------------------

  void _paintGrid(Canvas canvas, double plotW, ChartFrame f) {
    final base = Paint()
      ..color = f.gridline
      ..strokeWidth = 1;
    final empty = f.periods.isEmpty;
    final style = f.labelStyle.copyWith(color: f.cs.onSurfaceVariant, fontWeight: FontWeight.w500);
    for (var k = 0; k < 3; k++) {
      final y = _h * (1 - k / 2);
      if (k == 0) {
        canvas.drawLine(Offset(0, y), Offset(plotW, y), base);
      } else {
        _dashLine(canvas, Offset(0, y), Offset(plotW, y), 4, 4, base);
      }
      if (empty && k > 0) continue;
      void label(double max, double alpha, double dy) {
        if (alpha <= 0) return;
        final v = max * k / 2;
        final tp = f.texts.get(
            k == 0 ? '0' : f.formatAxis(v),
            style.copyWith(color: f.cs.onSurfaceVariant.withValues(alpha: alpha)),
            f.textScaler);
        final w = plotW + f.axisWidth;
        tp.paint(canvas, Offset(w - tp.width, y - tp.height / 2 + dy));
      }

      if (k == 0) {
        label(1, 1, 0);
      } else {
        final r = live.yRoll;
        if (r >= 1 || live.yPrevMax == live.yTargetMax) {
          label(live.yTargetMax, 1, 0);
        } else {
          label(live.yPrevMax, 1 - r, -6 * r);
          label(live.yTargetMax, r, 6 * (1 - r));
        }
      }
    }
  }

  void _dashLine(Canvas c, Offset a, Offset b, double dash, double gap, Paint p) {
    final len = (b - a).distance;
    if (len == 0) return;
    final d = (b - a) / len;
    var s = 0.0;
    while (s < len) {
      final e = math.min(s + dash, len);
      c.drawLine(a + d * s, a + d * e, p);
      s += dash + gap;
    }
  }

  // ---- columns --------------------------------------------------------------

  void _skeleton(Canvas canvas, int t, double cx, double colW, ChartFrame f) {
    final hh = ExpressiveChartMetrics.skeletonFraction(t) * _h;
    final rect = Rect.fromLTWH(cx - colW / 2, _h - hh, colW, hh);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(colW / 2));
    final base = f.cs.surfaceContainerHighest;
    final paint = Paint()..color = base;
    if (f.skeletonShimmer) {
      final ph = ShimmerClock.instance.phase.value;
      final dx = (ph * 2 - 1) * 120;
      paint.shader = ui.Gradient.linear(
        Offset(cx + dx - 60, 0),
        Offset(cx + dx + 60, 0),
        [base, Color.alphaBlend(f.cs.onSurface.withValues(alpha: 0.08), base), base],
        const [0.25, 0.5, 0.75],
      );
    }
    canvas.drawRRect(rr, paint);
  }

  void _barColumn(Canvas canvas, int p, ExpressivePeriod period, double cx,
      double colW, double selGeom, double g, double yMax, double morph,
      double alpha, ChartFrame f) {
    final v = _vals(p);
    final zero = v.every((x) => x <= 0) || period.noData;
    if (zero) {
      // Hollow 7 dp ring on the axis.
      canvas.drawCircle(
          Offset(cx, _h - 4),
          3.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = f.cs.outline.withValues(alpha: alpha * (1 - morph) * (0.4 + 0.6 * g)));
      return;
    }
    final segs = _barSegments(
        v: v, series: f.series, yMax: yMax, cx: cx, colW: colW, sel: selGeom, g: g);
    for (final s in segs) {
      _drawSeg(canvas, s, morph, cx, alpha);
    }
  }

  void _drawSeg(Canvas canvas, _Seg s, double m, double cx, double alpha) {
    var rect = s.rect;
    RSuperellipse rs;
    if (m <= 0 && s.half == 0) {
      rs = ExpressiveShapes.columnSegment(rect,
          topJoint: s.topJoint,
          bottomJoint: s.bottomJoint,
          jointRadius: s.joint,
          topRadius: s.topR,
          axisRadius: ExpressiveShapes.axis);
    } else {
      double tl, tr, br, bl;
      if (s.half == -1) {
        tl = s.halfTop; tr = 4; br = 2; bl = 4;
      } else if (s.half == 1) {
        tl = 4; tr = s.halfTop; br = 4; bl = 2;
      } else {
        final top = s.topJoint ? s.joint : s.topR;
        final bottom = s.bottomJoint ? s.joint : ExpressiveShapes.axis;
        tl = tr = top;
        bl = br = bottom;
      }
      if (m > 0) {
        const ds = 8.0;
        final w = ui.lerpDouble(rect.width, ds, m)!;
        final h = ui.lerpDouble(rect.height, ds, m)!;
        final c = ui.lerpDouble(rect.center.dx, cx, m)!;
        rect = Rect.fromLTWH(c - w / 2, rect.top - m * ds / 2, w, h);
        final full = w / 2;
        tl = ui.lerpDouble(tl, full, m)!;
        tr = ui.lerpDouble(tr, full, m)!;
        br = ui.lerpDouble(br, full, m)!;
        bl = ui.lerpDouble(bl, full, m)!;
      }
      rs = RSuperellipse.fromRectAndCorners(rect,
          topLeft: Radius.circular(_cl(tl, rect)),
          topRight: Radius.circular(_cl(tr, rect)),
          bottomRight: Radius.circular(_cl(br, rect)),
          bottomLeft: Radius.circular(_cl(bl, rect)));
    }
    canvas.drawRSuperellipse(rs, Paint()..color = s.color.withValues(alpha: alpha));
  }

  // ---- line layer -----------------------------------------------------------

  void _lineLayer(Canvas canvas, ChartGeometry geo, int tLo, int tHi,
      double yMax, ChartFrame f, double layerAlpha, double fadeIn) {
    final expressive = f.level == MotionLevel.expressive;
    final m = live.mode;
    var lp = expressive ? ((m - 0.35) / 0.65).clamp(0.0, 1.0) : 1.0;
    if (live.introIsLine && live.intro < 1) {
      lp = math.min(lp, KuberMotion.curveEffects.transform(live.intro));
    }
    final a = layerAlpha * fadeIn;
    final lo = math.max(f.skeletons, tLo - 2), hi = math.min(f.total - 1, tHi + 2);
    for (var s = 0; s < f.series.length; s++) {
      final color = f.series[s].color;
      // Runs of consecutive data periods; no-data periods break the line.
      final runs = <List<Offset>>[<Offset>[]];
      final dotIdx = <List<int>>[<int>[]];
      for (var t = lo; t <= hi; t++) {
        final p = t - f.skeletons;
        if (f.periods[p].noData) {
          if (runs.last.isNotEmpty) {
            runs.add(<Offset>[]);
            dotIdx.add(<int>[]);
          }
          continue;
        }
        runs.last.add(Offset(geo.cx(t), _h - _val(p, s) / yMax * _h));
        dotIdx.last.add(p);
      }
      final fillPaint = Paint();
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: a);
      for (var ri = 0; ri < runs.length; ri++) {
        final pts = runs[ri];
        if (pts.isEmpty) continue;
        final path = _smooth(pts);
        if (pts.length > 1) {
          final area = Path.from(path)
            ..lineTo(pts.last.dx, _h)
            ..lineTo(pts.first.dx, _h)
            ..close();
          final top = f.dark ? 0.32 : 0.24;
          fillPaint.shader = ui.Gradient.linear(
            Offset.zero,
            const Offset(0, _h),
            [color.withValues(alpha: top * lp * a), color.withValues(alpha: 0)],
          );
          canvas.drawPath(area, fillPaint);
          if (lp >= 1) {
            canvas.drawPath(path, line);
          } else {
            for (final mt in path.computeMetrics()) {
              canvas.drawPath(mt.extractPath(0, mt.length * lp), line);
            }
          }
        }
        if (ri < runs.length - 1 && runs[ri + 1].isNotEmpty) {
          _dashLine(
              canvas,
              pts.last,
              runs[ri + 1].first,
              2,
              5,
              Paint()
                ..strokeWidth = 2
                ..strokeCap = StrokeCap.round
                ..color = color.withValues(alpha: 0.6 * lp * a));
        }
      }
      // Dots only once the segments have become the line.
      if (m >= 1 || !expressive) {
        for (var ri = 0; ri < runs.length; ri++) {
          for (var i = 0; i < runs[ri].length; i++) {
            final pt = runs[ri][i];
            if (pt.dx < -8 || pt.dx > geo.plotWidth + 8) continue;
            if (!(lp >= 1 || pt.dx / geo.plotWidth <= lp)) continue;
            final sf = _selFactor(dotIdx[ri][i]);
            final r = ui.lerpDouble(3.5, 6, expressive ? sf : (sf > 0.5 ? 1 : 0))!;
            canvas.drawCircle(pt, r, Paint()..color = color.withValues(alpha: a));
            canvas.drawCircle(
                pt,
                r,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = f.surface.withValues(alpha: a));
          }
        }
      }
    }
  }

  /// Catmull-Rom through [pts], control points clamped into the plot so the
  /// curve never dips below 0 or above the top.
  Path _smooth(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    const t = 0.18;
    double cy(double v) => v.clamp(0.0, _h);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i], p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
      path.cubicTo(
        p1.dx + (p2.dx - p0.dx) * t,
        cy(p1.dy + (p2.dy - p0.dy) * t),
        p2.dx - (p3.dx - p1.dx) * t,
        cy(p2.dy - (p3.dy - p1.dy) * t),
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }
}

/// Mirrors `KuberChartTheme.unselectedAlpha` (kept local so the painter has
/// no theme dependency).
abstract final class KuberChartThemeAlpha {
  static const double unselected = 0.38;
}
