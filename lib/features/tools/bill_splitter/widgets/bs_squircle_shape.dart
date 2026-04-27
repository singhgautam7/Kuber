import 'package:flutter/material.dart';

/// Lightweight squircle helpers — replaces the figma_squircle package.
///
/// Flutter's built-in [ContinuousRectangleBorder] uses the same
/// superellipse math as Figma's "corner smoothing". No external package needed.
///
/// Usage:
///   ShapeDecoration(shape: bsSquircle(14))
///   ShapeDecoration(shape: bsSquircle(14, side: BorderSide(color: ...)))

/// Returns a [ContinuousRectangleBorder] that approximates a Figma squircle
/// with ~65% smoothing. Use this everywhere instead of SmoothRectangleBorder.
ContinuousRectangleBorder bsSquircle(
  double cornerRadius, {
  BorderSide side = BorderSide.none,
}) {
  return ContinuousRectangleBorder(
    borderRadius: BorderRadius.circular(cornerRadius),
    side: side,
  );
}

/// Clips a child to a squircle shape. Safe in sliver / unbounded contexts.
///
/// Uses [ClipRRect] (not ClipPath) so it works correctly when the parent
/// provides an unbounded height constraint (e.g. inside SliverToBoxAdapter).
class BsClipSquircle extends StatelessWidget {
  final double cornerRadius;
  final Widget child;

  const BsClipSquircle({
    super.key,
    required this.cornerRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: child,
    );
  }
}
