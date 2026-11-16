import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_theme.dart';

/// Advanced History motion tokens (design v1.1 / v1.2 motion.md). Owned by
/// H-UI; H-token reads them. Effects (opacity, colour) never spring.
abstract final class AhMotion {
  static const instant = KuberMotion.instant; // 90
  static const fast = KuberMotion.fast; // 150
  static const reflow = Duration(milliseconds: 230);
  static const containerTransform = Duration(milliseconds: 240);
  static const sheet = Duration(milliseconds: 260);
  static const snackEnter = Duration(milliseconds: 180);
  static const snackExit = Duration(milliseconds: 140);
  static const digitRoll = Duration(milliseconds: 300);
  static const decelerate = Curves.easeOutCubic;

  static final expressiveFastSpatial =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 800, ratio: 0.6);
  static final expressiveDefaultSpatial =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 380, ratio: 0.8);
  static final standardDefaultSpatial =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 700, ratio: 0.9);

  /// Reduced motion: cross-fades only, 90 ms, no springs, no digit roll.
  static bool reduced(BuildContext c) => KuberMotion.reduced(c);

  /// Cached spring curves (one simulation each) for implicit animations.
  static final fastCurve = AhSpringCurve(expressiveFastSpatial);
  static final defaultCurve = AhSpringCurve(expressiveDefaultSpatial);
  static final standardCurve = AhSpringCurve(standardDefaultSpatial);

  /// Same springs, clamped to 0..1 for sizes and width factors that must
  /// never go negative or overshoot (the overshoot is kept for scale only).
  static final fastSize = AhClamped(fastCurve);
  static final defaultSize = AhClamped(defaultCurve);
  static final standardSize = AhClamped(standardCurve);

  /// Duration for [d] or [instant] when motion is reduced.
  static Duration dur(BuildContext c, Duration d) =>
      reduced(c) ? instant : d;
}

/// [inner] clamped to 0..1.
class AhClamped extends Curve {
  const AhClamped(this.inner);
  final AhSpringCurve inner;
  Duration get settle => inner.settle;
  @override
  double transformInternal(double t) => inner.transform(t).clamp(0.0, 1.0);
}

/// A [Curve] that follows [spring] from 0 to 1 and settles by t = 1, for use
/// with implicit animations. Pair it with [settle] as the duration.
class AhSpringCurve extends Curve {
  AhSpringCurve(this.spring) : _sim = SpringSimulation(spring, 0, 1, 0);
  final SpringDescription spring;
  final SpringSimulation _sim;

  /// Time for the spring to settle within 0.1 %.
  late final Duration settle = () {
    var t = 0.0;
    while (t < 2 && !(_sim.isDone(t))) {
      t += 0.005;
    }
    return Duration(milliseconds: (t * 1000).round());
  }();

  @override
  double transformInternal(double t) =>
      _sim.x(t * settle.inMilliseconds / 1000);
}
