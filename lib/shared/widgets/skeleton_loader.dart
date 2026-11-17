import 'package:flutter/material.dart';

import '../../core/motion/shimmer.dart';
import '../../core/theme/app_theme.dart';

/// A single skeleton placeholder block. Shimmers at Expressive only (see
/// [ShimmerBox]); static at Subtle and Off.
class SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ShimmerBox(
      width: width,
      height: height,
      radius: borderRadius,
      base: cs.outline.withValues(alpha: 0.45),
      highlight: cs.outline.withValues(alpha: 0.8),
    );
  }
}

/// Skeleton layout matching the visual structure of a form bottom sheet.
class FormSheetSkeleton extends StatelessWidget {
  const FormSheetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KuberSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(KuberShape.full),
              ),
            ),
          ),
          const SizedBox(height: KuberSpace.lg),
          // Title placeholder
          const SkeletonBlock(width: 160, height: 24, borderRadius: 4),
          const SizedBox(height: KuberSpace.lg),
          // Name field
          const SkeletonBlock(
              width: double.infinity, height: 52, borderRadius: 8),
          const SizedBox(height: KuberSpace.md),
          // Amount field
          const SkeletonBlock(
              width: double.infinity, height: 52, borderRadius: 8),
          const SizedBox(height: KuberSpace.md),
          // Type toggle
          const SkeletonBlock(
              width: double.infinity, height: 44, borderRadius: 8),
          const SizedBox(height: KuberSpace.md),
          // Category chips row
          Row(
            children: const [
              SkeletonBlock(width: 80, height: 34, borderRadius: 17),
              SizedBox(width: KuberSpace.sm),
              SkeletonBlock(width: 96, height: 34, borderRadius: 17),
              SizedBox(width: KuberSpace.sm),
              SkeletonBlock(width: 72, height: 34, borderRadius: 17),
            ],
          ),
          const SizedBox(height: KuberSpace.md),
          // Account dropdown
          const SkeletonBlock(
              width: double.infinity, height: 52, borderRadius: 8),
          const SizedBox(height: KuberSpace.md),
          // Date row
          const SkeletonBlock(
              width: double.infinity, height: 48, borderRadius: 8),
          const SizedBox(height: KuberSpace.xl),
          // Action buttons
          Row(
            children: const [
              Expanded(
                  child: SkeletonBlock(
                      width: double.infinity, height: 48, borderRadius: 8)),
              SizedBox(width: KuberSpace.md),
              Expanded(
                  child: SkeletonBlock(
                      width: double.infinity, height: 48, borderRadius: 8)),
            ],
          ),
        ],
      ),
    );
  }
}
