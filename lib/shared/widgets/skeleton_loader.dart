import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A single skeleton placeholder block with shimmer animation.
class SkeletonBlock extends StatefulWidget {
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
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseColor = cs.outline;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
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
