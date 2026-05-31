import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../models/story_icons.dart';
import '../models/story_models.dart';
import '../providers/story_providers.dart';
import 'story_viewer.dart';

class StoryRingSection extends ConsumerWidget {
  const StoryRingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);
    return storiesAsync.when(
      loading: () => const _StoryRingSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stories) => StoryRing(
        stories: stories,
        onOpen: (index) => Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => StoryViewer(
              stories: stories,
              initialIndex: index,
              onSeen: (id, slideIndex) {
                ref.read(storiesProvider.notifier).markSeen(int.parse(id), slideIndex);
              },
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}

class StoryRing extends StatelessWidget {
  final List<StoryViewData> stories;
  final void Function(int index) onOpen;

  const StoryRing({super.key, required this.stories, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KuberHomeWidgetTitle(title: 'MONEY STORIES'),
          Container(
            height: 84,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Keep spending to see your money stories soon.',
              textAlign: TextAlign.center,
              style: AppTextStyles.inter.copyWith(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KuberHomeWidgetTitle(title: 'MONEY STORIES'),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            cacheExtent: 360,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) =>
                _StoryAvatar(story: stories[i], onTap: () => onOpen(i)),
          ),
        ),
      ],
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final StoryViewData story;
  final VoidCallback onTap;

  const _StoryAvatar({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final discTint = story.seen
        ? cs.surfaceContainerHigh
        : Color.alphaBlend(
            StoryPalette.ring[story.color]!.withValues(alpha: 0.16),
            cs.surfaceContainerHigh,
          );
    final iconColor = story.seen
        ? cs.onSurfaceVariant
        : StoryPalette.ring[story.color]!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            CustomPaint(
              painter: _SegmentedRingPainter(
                segments: story.slides.length,
                seenSegments: List.generate(story.slides.length, (i) => story.seenSlides.contains(i)),
                activeColor: StoryPalette.ring[story.color]!,
                inactiveColor: cs.outlineVariant,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: discTint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    storyIcon(story.icon),
                    size: 24,
                    color: iconColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              story.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.inter.copyWith(
                fontSize: 11,
                fontWeight: story.seen ? FontWeight.w500 : FontWeight.w600,
                color: story.seen ? cs.onSurfaceVariant : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedRingPainter extends CustomPainter {
  final int segments;
  final List<bool> seenSegments;
  final Color activeColor;
  final Color inactiveColor;

  const _SegmentedRingPainter({
    required this.segments,
    required this.seenSegments,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;

    if (segments <= 1) {
      final paint = Paint()
        ..color = seenSegments.isNotEmpty && seenSegments.first ? inactiveColor : activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    const gapRad = 0.18;
    final sweep = (2 * math.pi / segments) - gapRad;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // We want the first segment to start at the top (-pi/2)
    // and draw clockwise.
    for (var i = 0; i < segments; i++) {
      final paint = Paint()
        ..color = seenSegments.length > i && seenSegments[i] ? inactiveColor : activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      
      final start = -math.pi / 2 + i * (2 * math.pi / segments) + gapRad / 2;
      canvas.drawArc(rect, start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_SegmentedRingPainter oldDelegate) {
    if (oldDelegate.segments != segments) return true;
    if (oldDelegate.activeColor != activeColor) return true;
    if (oldDelegate.inactiveColor != inactiveColor) return true;
    for (var i = 0; i < segments; i++) {
      if (oldDelegate.seenSegments.length <= i || seenSegments.length <= i) return true;
      if (oldDelegate.seenSegments[i] != seenSegments[i]) return true;
    }
    return false;
  }
}

class _StoryRingSkeleton extends StatelessWidget {
  const _StoryRingSkeleton();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KuberHomeWidgetTitle(title: 'MONEY STORIES'),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, __) => SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainerHigh,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: cs.surfaceContainerHigh,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
