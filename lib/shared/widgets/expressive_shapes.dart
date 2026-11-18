import 'dart:ui';

/// v7.0.0-b shape language shared by the Expressive chart columns and the
/// Home balance card split bar: fully round outer ends, squircle corners
/// where two segments meet (handoff: "6 dp squircle joint").
///
/// Pure geometry: callers draw the result with `canvas.drawRSuperellipse`
/// (or clip with `Path()..addRSuperellipse`).
abstract final class ExpressiveShapes {
  /// Joint corner at rest / when focused or selected.
  static const double joint = 6;
  static const double jointActive = 8;

  /// Corner where a column stands on the X axis.
  static const double axis = 4;

  /// One segment of a horizontal split bar. [startJoint] / [endJoint] say
  /// whether that side touches the other segment (joint corners) or is an
  /// outer end (fully round: radius = height / 2).
  static RSuperellipse barSegment(
    Rect r, {
    required bool startJoint,
    required bool endJoint,
    double jointRadius = joint,
  }) {
    final outer = Radius.circular(r.height / 2);
    final j = Radius.circular(_clamp(jointRadius, r));
    final s = startJoint ? j : outer;
    final e = endJoint ? j : outer;
    return RSuperellipse.fromRectAndCorners(r, topLeft: s, bottomLeft: s, topRight: e, bottomRight: e);
  }

  /// One segment of a vertical column. The top is fully round unless
  /// [topJoint] (a segment sits above it) or [topRadius] overrides it (the
  /// selected column uses 10 dp). The bottom sits on the axis ([axis]
  /// corners) unless [bottomJoint].
  static RSuperellipse columnSegment(
    Rect r, {
    required bool topJoint,
    required bool bottomJoint,
    double jointRadius = joint,
    double? topRadius,
    double axisRadius = axis,
  }) {
    final j = Radius.circular(_clamp(jointRadius, r));
    final top = topJoint ? j : Radius.circular(_clamp(topRadius ?? r.width / 2, r));
    final bottom = bottomJoint ? j : Radius.circular(_clamp(axisRadius, r));
    return RSuperellipse.fromRectAndCorners(r,
        topLeft: top, topRight: top, bottomLeft: bottom, bottomRight: bottom);
  }

  static double _clamp(double radius, Rect r) {
    final max = (r.shortestSide / 2).clamp(0.0, double.infinity);
    return radius.clamp(0.0, max);
  }
}
