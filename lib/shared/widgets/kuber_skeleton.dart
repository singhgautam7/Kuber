import 'package:flutter/material.dart';

import '../../core/motion/shimmer.dart';
import '../../core/theme/app_theme.dart';

/// Canonical Kuber skeleton-loader primitive: a muted rounded rectangle.
/// Shimmers (a highlight translating over 1200 ms, linear) at Expressive;
/// static at Subtle and Off. Reuse this everywhere a loading state is needed;
/// swap it for the content with `SkeletonCrossFade`.
///
/// Uses `cs.surfaceContainerHigh` (the existing "muted element" role) with a
/// `surfaceContainerHighest` highlight, so it reads as an inert placeholder in
/// every theme without a new colour.
class KuberSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const KuberSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = KuberShape.medium,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ShimmerBox(
      width: width,
      height: height,
      radius: borderRadius,
      base: cs.surfaceContainerHigh,
      highlight: cs.surfaceContainerHighest,
    );
  }
}
