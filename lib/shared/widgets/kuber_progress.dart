import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Progress colour state (tokens.md §7). Call sites map their existing status
/// labels onto these; no threshold is decided here.
enum KuberProgressState { normal, nearLimit, overLimit }

(Color, Color) _stateColors(BuildContext context, KuberProgressState s) {
  final cs = Theme.of(context).colorScheme;
  final m = context.kuberMoney;
  return switch (s) {
    KuberProgressState.normal => (cs.primary, cs.secondaryContainer),
    KuberProgressState.nearLimit => (m.warning, m.warningContainer),
    KuberProgressState.overLimit => (m.expense, Colors.transparent),
  };
}

/// M3 linear progress (components/progress.md): round ends, 4dp gap between
/// indicator and track, 4dp stop dot at the track end; over limit fills the
/// whole bar with no track. Thin bars (<= 4) draw the M3 Expressive wavy
/// indicator (amplitude 3, wavelength 24) unless [flat].
///
/// Painter structure adapted from Mull `shared/widgets/progress.dart`. Static
/// paint only; it never animates on its own.
class KuberLinearProgress extends StatelessWidget {
  final double value;
  final KuberProgressState state;
  final double height;
  final bool flat;
  final Color? color;
  final Color? trackColor;

  const KuberLinearProgress({
    super.key,
    required this.value,
    this.state = KuberProgressState.normal,
    this.height = 4,
    this.flat = false,
    this.color,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final (ind, trk) = _stateColors(context, state);
    final wavy = !flat && height <= 4;
    return RepaintBoundary(
      child: SizedBox(
        height: wavy ? 12 : height,
        width: double.infinity,
        child: CustomPaint(
          painter: _LinearPainter(
            value: value.isNaN ? 0 : value.clamp(0.0, 1.0),
            stroke: height,
            indicator: color ?? ind,
            track: trackColor ?? trk,
            wavy: wavy,
          ),
        ),
      ),
    );
  }
}

class _LinearPainter extends CustomPainter {
  final double value;
  final double stroke;
  final Color indicator;
  final Color track;
  final bool wavy;

  _LinearPainter({
    required this.value,
    required this.stroke,
    required this.indicator,
    required this.track,
    required this.wavy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final cy = size.height / 2;
    final full = value >= 1;
    final half = stroke / 2;
    const gap = 4.0;
    final p = Paint()
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final indEnd = full ? w : (value * w - gap / 2);
    final hasInd = value > 0 && indEnd > half;

    // Track + stop dot.
    if (!full && track.a > 0) {
      final start = hasInd ? indEnd + gap + stroke : half;
      if (start < w - half) {
        canvas.drawLine(Offset(start, cy), Offset(w - half, cy), p..color = track);
      }
      canvas.drawCircle(
          Offset(w - half, cy), half, Paint()..color = indicator);
    }

    if (!hasInd) return;
    p.color = indicator;
    if (!wavy || indEnd - half < 6) {
      canvas.drawLine(Offset(half, cy), Offset(indEnd - half, cy), p);
      return;
    }
    // Wavy indicator: amplitude 3, wavelength 24.
    const amp = 3.0, lambda = 24.0;
    final path = Path()..moveTo(half, cy);
    for (var x = half; x <= indEnd - half; x += 1) {
      path.lineTo(x, cy - amp * math.sin((x - half) / lambda * 2 * math.pi));
    }
    canvas.drawPath(path, p..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_LinearPainter o) =>
      o.value != value ||
      o.stroke != stroke ||
      o.indicator != indicator ||
      o.track != track ||
      o.wavy != wavy;
}

/// M3 ring progress: 4 stroke (6 for rings 72+, 8 for the 96 score ring),
/// round caps, 4dp gap, track from the state colours.
class KuberRingProgress extends StatelessWidget {
  final double value;
  final double size;
  final double? stroke;
  final KuberProgressState state;
  final Color? color;
  final Color? trackColor;
  final Widget? child;

  const KuberRingProgress({
    super.key,
    required this.value,
    this.size = 48,
    this.stroke,
    this.state = KuberProgressState.normal,
    this.color,
    this.trackColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final (ind, trk) = _stateColors(context, state);
    final sw = stroke ?? (size >= 96 ? 8 : (size >= 72 ? 6 : 4));
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.isNaN ? 0 : value.clamp(0.0, 1.0),
          stroke: sw,
          indicator: color ?? ind,
          track: trackColor ?? trk,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final Color indicator;
  final Color track;

  _RingPainter({
    required this.value,
    required this.stroke,
    required this.indicator,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    const top = -math.pi / 2;
    if (value >= 1) {
      canvas.drawArc(rect, 0, math.pi * 2, false, p..color = indicator);
      return;
    }
    // Gap includes the round caps.
    final gap = (stroke + 4) / r;
    final sweep = value * math.pi * 2;
    if (track.a > 0) {
      final tSweep = math.pi * 2 - sweep - gap * (value > 0 ? 2 : 1);
      if (tSweep > 0) {
        canvas.drawArc(rect, top + sweep + (value > 0 ? gap : gap / 2), tSweep,
            false, p..color = track);
      }
    }
    if (value > 0 && sweep > 0.0001) {
      canvas.drawArc(rect, top, math.max(0.0001, sweep), false,
          p..color = indicator);
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.value != value ||
      o.stroke != stroke ||
      o.indicator != indicator ||
      o.track != track;
}

/// Status chip colours for a progress state (normal secondaryContainer, near
/// warningContainer, over expenseContainer).
(Color, Color) kuberProgressChipColors(
    BuildContext context, KuberProgressState s) {
  final cs = Theme.of(context).colorScheme;
  final m = context.kuberMoney;
  return switch (s) {
    KuberProgressState.normal => (cs.secondaryContainer, cs.onSecondaryContainer),
    KuberProgressState.nearLimit => (m.warningContainer, m.onWarningContainer),
    KuberProgressState.overLimit => (m.expenseContainer, m.onExpenseContainer),
  };
}
