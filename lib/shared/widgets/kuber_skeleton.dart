import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Canonical Kuber skeleton-loader primitive. No skeleton pattern existed in
/// the repo before this round, so this establishes it: a muted rounded
/// rectangle that pulses opacity, no shimmer sweep. Reuse this everywhere a
/// loading state is needed; don't invent a second style.
///
/// Uses `cs.surfaceContainerHigh` (the existing "muted element" role — see
/// inputs, inactive chips) so it reads as an inert placeholder in both
/// Obsidian and Alabaster without introducing a new color.
class KuberSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const KuberSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = KuberRadius.md,
  });

  @override
  State<KuberSkeleton> createState() => _KuberSkeletonState();
}

class _KuberSkeletonState extends State<KuberSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.55).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}
