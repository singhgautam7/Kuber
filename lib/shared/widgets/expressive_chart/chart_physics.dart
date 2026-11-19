import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/app_theme.dart';
import 'chart_model.dart';

/// Chart scroll: per-pixel drag, snaps to whole slots on release, and at the
/// ends a 0.3 rubber band that stops 24 dp out (replaces glow / stretch).
/// [level] Off: no overscroll, snaps without movement.
class ChartScrollPhysics extends ScrollPhysics {
  const ChartScrollPhysics({
    super.parent,
    required this.slot,
    required this.level,
  });

  /// Width of one slot (snap step).
  final double slot;
  final MotionLevel level;

  @override
  ChartScrollPhysics applyTo(ScrollPhysics? ancestor) => ChartScrollPhysics(
        parent: buildParent(ancestor),
        slot: slot,
        level: level,
      );

  double get _maxOver =>
      level == MotionLevel.off ? 0 : ExpressiveChartMetrics.rubberMax;

  SpringDescription get _snapSpring => switch (level) {
        MotionLevel.expressive => KuberMotion.springStandard,
        MotionLevel.subtle => KuberMotion.springSubtle,
        // Off: so stiff it lands within a frame or two.
        MotionLevel.off => SpringDescription(mass: 1, stiffness: 40000, damping: 400),
      };

  SpringDescription get _backSpring => switch (level) {
        MotionLevel.expressive => KuberMotion.springFast,
        MotionLevel.subtle => KuberMotion.springSubtle,
        MotionLevel.off => _snapSpring,
      };

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // `offset` is the finger delta; pixels move by -offset.
    final pushingOut = (position.pixels < position.minScrollExtent && offset > 0) ||
        (position.pixels > position.maxScrollExtent && offset < 0);
    if (pushingOut) return offset * ExpressiveChartMetrics.rubberFactor;
    // Crossing into overscroll in one move: scale only the part beyond.
    final next = position.pixels - offset;
    if (next < position.minScrollExtent && position.pixels >= position.minScrollExtent) {
      final inside = position.pixels - position.minScrollExtent;
      return inside + (offset - inside) * ExpressiveChartMetrics.rubberFactor;
    }
    if (next > position.maxScrollExtent && position.pixels <= position.maxScrollExtent) {
      final inside = position.maxScrollExtent - position.pixels;
      return -(inside + (-offset - inside) * ExpressiveChartMetrics.rubberFactor);
    }
    return offset;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final lo = position.minScrollExtent - _maxOver;
    final hi = position.maxScrollExtent + _maxOver;
    if (value < position.pixels && position.pixels <= lo) return value - position.pixels;
    if (hi <= position.pixels && position.pixels < value) return value - position.pixels;
    if (value < lo && lo < position.pixels) return value - lo;
    if (position.pixels < hi && hi < value) return value - hi;
    return 0;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final tol = toleranceFor(position);
    if (position.outOfRange) {
      final end = position.pixels < position.minScrollExtent
          ? position.minScrollExtent
          : position.maxScrollExtent;
      return ScrollSpringSimulation(_backSpring, position.pixels, end, velocity,
          tolerance: tol);
    }
    if (slot <= 0) return null;
    final predicted =
        FrictionSimulation(0.135, position.pixels, velocity).finalX;
    final target = ((predicted / slot).round() * slot)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if ((position.pixels - target).abs() < 0.5 && velocity.abs() < tol.velocity) {
      return null;
    }
    return ScrollSpringSimulation(_snapSpring, position.pixels, target, velocity,
        tolerance: tol);
  }

  @override
  bool get allowImplicitScrolling => false;
}
