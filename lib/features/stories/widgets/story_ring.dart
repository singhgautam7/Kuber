import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../models/story_icons.dart';
import '../models/story_models.dart';
import '../providers/story_providers.dart';
import 'story_viewer.dart';

class StoryRingSection extends ConsumerStatefulWidget {
  const StoryRingSection({super.key});

  @override
  ConsumerState<StoryRingSection> createState() => _StoryRingSectionState();
}

class _StoryRingSectionState extends ConsumerState<StoryRingSection> {
  @override
  void initState() {
    super.initState();
    // Story generation is kicked off only AFTER the home first frame paints, so
    // it can never block cold start. The Welcome bubble (first launch) is the
    // single exception and is inserted synchronously during bootstrap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(storyGenerationProvider.notifier).ensureGenerated();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bubblesAsync = ref.watch(storyBubblesProvider);
    final isGenerating = ref.watch(storyGenerationProvider);
    return bubblesAsync.when(
      loading: () => const _StoryRingSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (bubbles) {
        if (bubbles.isEmpty) {
          // Skeleton while generation is in progress; gentle prompt otherwise.
          return isGenerating
              ? const _StoryRingSkeleton()
              : const _StoryRingEmpty();
        }
        return StoryRing(
          bubbles: bubbles,
          onOpen: (index) => _open(context, bubbles, index),
        );
      },
    );
  }

  void _open(BuildContext context, List<StoryBubble> bubbles, int index) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewer(
          // Pass the whole ring so finishing one bubble auto-advances to the
          // next bubble that still has unread, instead of closing.
          bubbles: bubbles,
          initialBubbleIndex: index,
          advanceUnreadOnly: true,
          onSeen: (id, slideIndex) {
            ref
                .read(storiesProvider.notifier)
                .markSeen(int.parse(id), slideIndex);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }
}

class StoryRing extends StatelessWidget {
  final List<StoryBubble> bubbles;
  final void Function(int index) onOpen;

  const StoryRing({super.key, required this.bubbles, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    // Resolve the theme once and pass it down — the bubble row is horizontally
    // scrollable, so resolving per child would repeat on every item build.
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KuberHomeWidgetTitle(
          title: 'MONEY STORIES',
          infoConfig: InfoConstants.moneyStories,
        ),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            cacheExtent: 360,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: bubbles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) => _StoryAvatar(
              bubble: bubbles[i],
              colorScheme: cs,
              onTap: () => onOpen(i),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final StoryBubble bubble;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _StoryAvatar({
    required this.bubble,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final seen = bubble.seen;
    final ringColor = StoryPalette.ring[bubble.color]!;
    final discTint = seen
        ? cs.surfaceContainerHigh
        : Color.alphaBlend(
            ringColor.withValues(alpha: 0.16),
            cs.surfaceContainerHigh,
          );
    final iconColor = seen ? cs.onSurfaceVariant : ringColor;

    // One ring arc per slide across all stories in the bubble (Instagram-style);
    // an arc is "seen" when that slide has been viewed.
    final seenSegments = <bool>[
      for (final s in bubble.stories)
        for (var i = 0; i < s.slides.length; i++) s.seenSlides.contains(i),
    ];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            CustomPaint(
              painter: _SegmentedRingPainter(
                segments: seenSegments.length,
                seenSegments: seenSegments,
                activeColor: ringColor,
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
                    storyIcon(bubble.icon),
                    size: 24,
                    color: iconColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              bubble.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.inter.copyWith(
                fontSize: 11,
                fontWeight: seen ? FontWeight.w500 : FontWeight.w600,
                color: seen ? cs.onSurfaceVariant : cs.onSurface,
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
        ..color = seenSegments.isNotEmpty && seenSegments.first
            ? inactiveColor
            : activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    const gapRad = 0.18;
    final sweep = (2 * math.pi / segments) - gapRad;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // First segment starts at the top (-pi/2), drawn clockwise.
    for (var i = 0; i < segments; i++) {
      final paint = Paint()
        ..color = seenSegments.length > i && seenSegments[i]
            ? inactiveColor
            : activeColor
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
      if (oldDelegate.seenSegments.length <= i || seenSegments.length <= i) {
        return true;
      }
      if (oldDelegate.seenSegments[i] != seenSegments[i]) return true;
    }
    return false;
  }
}

class _StoryRingEmpty extends StatelessWidget {
  const _StoryRingEmpty();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KuberHomeWidgetTitle(
          title: 'MONEY STORIES',
          infoConfig: InfoConstants.moneyStories,
        ),
        Container(
          height: 84,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
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
}

class _StoryRingSkeleton extends StatelessWidget {
  const _StoryRingSkeleton();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KuberHomeWidgetTitle(
          title: 'MONEY STORIES',
          infoConfig: InfoConstants.moneyStories,
        ),
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
