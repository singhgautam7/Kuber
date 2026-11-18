import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/app_theme.dart';

// Polar shapes (same family as KuberShapeLoader, whose tables are private).
const _n = 72;

double _ell(double th, double a, double b, double rot) {
  final q = th + rot;
  return 1 / math.sqrt(math.pow(math.cos(q), 2) + math.pow(math.sin(q) / b, 2));
}

double _pent(double th) {
  const s = 2 * math.pi / 5;
  final m = ((th + math.pi / 2) % s + s) % s - s / 2;
  return .72 * math.cos(math.pi / 5) / math.cos(m) + .28;
}

Float32List _table(double Function(double) f) {
  final r = Float32List(_n);
  var mx = 0.0;
  for (var i = 0; i < _n; i++) {
    r[i] = f(i / _n * 2 * math.pi);
    mx = math.max(mx, r[i]);
  }
  for (var i = 0; i < _n; i++) {
    r[i] /= mx;
  }
  return r;
}

final _cookie9 = _table((t) => 1 + .09 * math.cos(9 * t));
final _softBurst = _table((t) => 1 + .07 * math.cos(10 * t));
final _cookie4 = _table((t) => 1 + .13 * math.cos(4 * t));
final _pill = _table((t) => _ell(t, 1, .6, -math.pi / 4));
final _sunny = _table((t) => 1 + .05 * math.cos(8 * t));
final _pentagon = _table(_pent);
final _oval = _table((t) => _ell(t, 1, .78, math.pi / 4));

class _Spark {
  final double angle, size;
  final Float32List shape;
  final bool tertiary;
  const _Spark(this.angle, this.shape, this.size, this.tertiary);
}

final _sparks = [
  _Spark(-60, _cookie4, 14, true),
  _Spark(-10, _pill, 12, false),
  _Spark(40, _sunny, 10, true),
  _Spark(120, _cookie9, 13, false),
  _Spark(170, _pentagon, 11, true),
  _Spark(225, _oval, 12, false),
];

/// Total length of the celebration at [level] (ms).
int trialMomentMs(MotionLevel level) => switch (level) {
      MotionLevel.expressive => 1100,
      MotionLevel.subtle => 700,
      MotionLevel.off => 0,
    };

/// Spring value at [ms] after its start (can overshoot).
double trialSpring(SpringCurve c, double ms) =>
    ms <= 0 ? 0 : c.transform((ms / c.settle.inMilliseconds).clamp(0.0, 1.0));

/// Badge (Cookie 9 morphing to Soft burst, 8 degrees) and the 6 burst shapes
/// (motion.md "Trial sheet"). Driven by [progress] 0..1 over
/// [trialMomentMs]; one Confirm haptic when it lands. [burst] false = badge
/// only (restored trial), no shapes.
class TrialCelebration extends StatefulWidget {
  const TrialCelebration({
    super.key,
    required this.progress,
    required this.level,
    this.size = 112,
    this.burst = true,
  });

  final Animation<double> progress;
  final MotionLevel level;
  final double size;
  final bool burst;

  @override
  State<TrialCelebration> createState() => _TrialCelebrationState();
}

class _TrialCelebrationState extends State<TrialCelebration> {
  bool _haptic = false;

  double get _ms => widget.progress.value * trialMomentMs(widget.level);

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_tick);
    _tick();
  }

  @override
  void dispose() {
    widget.progress.removeListener(_tick);
    super.dispose();
  }

  void _tick() {
    if (_haptic) return;
    final at = switch (widget.level) {
      MotionLevel.expressive => 300,
      MotionLevel.subtle => 200,
      MotionLevel.off => 0,
    };
    if (_ms >= at) {
      _haptic = true;
      KuberHaptics.confirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = widget.size;
    final core = s * .78;
    return Semantics(
      excludeSemantics: true,
      child: RepaintBoundary(
        child: SizedBox(
          width: s,
          height: s,
          child: AnimatedBuilder(
            animation: widget.progress,
            builder: (context, _) {
              final f = _frame(_ms, widget.level);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BurstPainter(
                        f: f,
                        burst: widget.burst,
                        size: s,
                        core: core,
                        badge: cs.primaryContainer,
                        tertiary: cs.tertiary,
                        primary: cs.primary,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: f.coreOpacity,
                    child: Transform.scale(
                      scale: f.coreScale,
                      child: Icon(Icons.workspace_premium_rounded,
                          size: core * .44, color: cs.onPrimaryContainer),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Frame {
  final double coreScale, coreOpacity, rotate, morph;
  final List<double> travel, opacity;
  const _Frame(this.coreScale, this.coreOpacity, this.rotate, this.morph, this.travel, this.opacity);
}

_Frame _frame(double ms, MotionLevel level) {
  const rest = 8 * math.pi / 180;
  switch (level) {
    case MotionLevel.off:
      return _Frame(1, 1, rest, 1, List.filled(6, 1), List.filled(6, 1));
    case MotionLevel.expressive:
      final bm = ms - 120;
      final q = (bm / 450).clamp(0.0, 1.0);
      return _Frame(
        bm <= 0 ? .6 : .6 + .4 * trialSpring(KuberMotion.fastCurve, bm),
        bm <= 0 ? 0 : (bm / 150).clamp(0.0, 1.0),
        rest * q,
        1 - math.pow(1 - q, 3).toDouble(),
        [for (var i = 0; i < 6; i++) trialSpring(KuberMotion.fastCurve, ms - 200 - i * 20)],
        [for (var i = 0; i < 6; i++) ms - 200 - i * 20 <= 0 ? 0.0 : 1.0],
      );
    case MotionLevel.subtle:
      final bm = ms - 80;
      final fo = (bm / 200).clamp(0.0, 1.0);
      return _Frame(.9 + .1 * trialSpring(KuberMotion.subtleCurve, bm), fo, rest, 1,
          List.filled(6, 1), List.filled(6, fo));
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.f,
    required this.burst,
    required this.size,
    required this.core,
    required this.badge,
    required this.tertiary,
    required this.primary,
  });

  final _Frame f;
  final bool burst;
  final double size, core;
  final Color badge, tertiary, primary;

  Path _path(Float32List r, double radius, Offset c, double rot) {
    final p = Path();
    for (var i = 0; i < _n; i++) {
      final a = i / _n * 2 * math.pi + rot;
      final o = Offset(c.dx + math.cos(a) * r[i] * radius, c.dy + math.sin(a) * r[i] * radius);
      i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size sz) {
    final c = Offset(sz.width / 2, sz.height / 2);
    if (burst) {
      for (var i = 0; i < _sparks.length; i++) {
        final sp = _sparks[i];
        final p = f.travel[i];
        if (f.opacity[i] <= 0 || p <= 0) continue;
        final ang = sp.angle * math.pi / 180;
        final d = size * .56 * p;
        final pos = Offset(c.dx + math.cos(ang) * d, c.dy + math.sin(ang) * d);
        final paint = Paint()
          ..color = (sp.tertiary ? tertiary : primary).withValues(alpha: f.opacity[i]);
        canvas.drawPath(
            _path(sp.shape, sp.size / 2 * p.clamp(0.0, 1.2), pos, ang * p), paint);
      }
    }
    if (f.coreOpacity <= 0) return;
    final r = Float32List(_n);
    for (var i = 0; i < _n; i++) {
      r[i] = _cookie9[i] + (_softBurst[i] - _cookie9[i]) * f.morph;
    }
    canvas.drawPath(
      _path(r, core / 2 * f.coreScale, c, f.rotate),
      Paint()..color = badge.withValues(alpha: f.coreOpacity),
    );
  }

  @override
  bool shouldRepaint(_BurstPainter o) =>
      o.f != f || o.size != size || o.badge != badge || o.burst != burst;
}
