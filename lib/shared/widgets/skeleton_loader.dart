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
    final baseColor = cs.outlineVariant;

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
      padding: const EdgeInsets.all(KuberSpacing.lg),
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
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          // Title placeholder
          const SkeletonBlock(width: 160, height: 24, borderRadius: 4),
          const SizedBox(height: KuberSpacing.lg),
          // Name field
          const SkeletonBlock(
              width: double.infinity, height: 52, borderRadius: 8),
          const SizedBox(height: KuberSpacing.md),
          // Amount field
          const SkeletonBlock(
              width: double.infinity, height: 52, borderRadius: 8),
          const SizedBox(height: KuberSpacing.md),
          // Type toggle
          const SkeletonBlock(
              width: double.infinity, height: 44, borderRadius: 8),
          const SizedBox(height: KuberSpacing.md),
          // Category chips row
          Row(
            children: const [
              SkeletonBlock(width: 80, height: 34, borderRadius: 17),
              SizedBox(width: KuberSpacing.sm),
              SkeletonBlock(width: 96, height: 34, borderRadius: 17),
              SizedBox(width: KuberSpacing.sm),
              SkeletonBlock(width: 72, height: 34, borderRadius: 17),
            ],
          ),
          const SizedBox(height: KuberSpacing.md),
          // Account dropdown
          const SkeletonBlock(
              width: double.infinity, height: 52, borderRadius: 8),
          const SizedBox(height: KuberSpacing.md),
          // Date row
          const SkeletonBlock(
              width: double.infinity, height: 48, borderRadius: 8),
          const SizedBox(height: KuberSpacing.xl),
          // Action buttons
          Row(
            children: const [
              Expanded(
                  child: SkeletonBlock(
                      width: double.infinity, height: 48, borderRadius: 8)),
              SizedBox(width: KuberSpacing.md),
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
