import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import 'motion_level.dart';
import 'spring_curve.dart';

/// `sheetAnimationStyle:` for showModalBottomSheet at the current level.
///
/// Expressive: in on springSlow (clamped, so no overshoot gap shows), out on
/// springStandard (clamped). Subtle: springSubtle both ways. Off: 90 ms
/// (Flutter's sheet route slides, it cannot fade in place).
AnimationStyle kuberSheetStyle(BuildContext context) =>
    _style(KuberMotion.levelOf(context), KuberMotion.slowCurve,
        reverse: KuberMotion.standardCurve);

/// `animationStyle:` for showDialog at the current level. Expressive:
/// springDefault clamped, out on the same. Subtle: springSubtle. Off: 90 ms.
/// (Flutter's dialog transition is a fade; there is no scale hook.)
AnimationStyle kuberDialogStyle(BuildContext context) =>
    _style(KuberMotion.levelOf(context), KuberMotion.defaultCurve);

AnimationStyle _style(MotionLevel level, SpringCurve spring,
    {SpringCurve? reverse}) {
  if (level == MotionLevel.off) {
    return AnimationStyle(
      curve: Curves.linear,
      duration: KuberMotion.fxInstant,
      reverseCurve: Curves.linear,
      reverseDuration: KuberMotion.fxInstant,
    );
  }
  final inC = KuberMotion.spatialCurve(level, spring);
  final outC = level == MotionLevel.subtle
      ? KuberMotion.subtleCurve
      : (reverse ?? spring);
  return AnimationStyle(
    curve: inC.clamped,
    duration: inC.settle,
    reverseCurve: outC.clamped,
    reverseDuration: outC.settle,
  );
}
