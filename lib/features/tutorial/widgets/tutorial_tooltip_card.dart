import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../models/tutorial_chapter.dart';
import '../providers/tutorial_provider.dart';

class TutorialTooltipCard extends ConsumerWidget {
  final Rect? spotlightRect;
  final Size screenSize;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const TutorialTooltipCard({
    super.key,
    required this.spotlightRect,
    required this.screenSize,
    required this.fadeAnim,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorialNotifierProvider);
    final notifier = ref.read(tutorialNotifierProvider.notifier);
    final chapter = state.currentChapter;
    final step = state.currentStep;
    final cs = Theme.of(context).colorScheme;

    const cardWidth = 320.0;
    final cardHeight = 210.0;

    // Position: below spotlight if in top 55%, above if in bottom 45%
    double cardTop;
    bool arrowPointsUp = true;

    if (spotlightRect != null) {
      final spotBottom = spotlightRect!.bottom;
      if (spotBottom < screenSize.height * 0.55) {
        // Spotlight in upper half — card below
        cardTop = spotBottom + 16;
        arrowPointsUp = true;
      } else {
        // Spotlight in lower half — card above
        cardTop = spotlightRect!.top - cardHeight - 16;
        arrowPointsUp = false;
      }
    } else {
      // Dim-only step — center vertically
      cardTop = (screenSize.height - cardHeight) / 2;
      arrowPointsUp = false;
    }

    final cardLeft = (screenSize.width - cardWidth) / 2;

    return Positioned(
      top: cardTop.clamp(
        MediaQueryData.fromView(View.of(context)).padding.top + 8,
        screenSize.height - cardHeight - 8,
      ),
      left: cardLeft,
      width: cardWidth,
      child: FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: slideAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (arrowPointsUp && spotlightRect != null)
                _Arrow(pointsUp: true, color: cs.outline),
              _Card(
                chapter: chapter,
                step: step,
                state: state,
                notifier: notifier,
                context: context,
              ),
              if (!arrowPointsUp && spotlightRect != null)
                _Arrow(pointsUp: false, color: cs.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final TutorialChapter chapter;
  final TutorialStep step;
  final TutorialState state;
  final TutorialNotifier notifier;
  final BuildContext context;

  const _Card({
    required this.chapter,
    required this.step,
    required this.state,
    required this.notifier,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    final chapterIndex = state.chapterIndex;
    final stepIndex = state.stepIndex;
    final totalSteps = chapter.steps.length;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(KuberRadius.full),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Chapter ${chapterIndex + 1} of 5 · ${chapter.title}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KuberSpacing.md),

          // Step title
          Text(
            step.title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),

          // Step description
          Text(
            step.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: KuberSpacing.md),

          // Step progress bar
          Row(
            children: List.generate(totalSteps, (i) {
              Color color;
              if (i == stepIndex) {
                color = cs.primary;
              } else if (i < stepIndex) {
                color = cs.primary.withValues(alpha: 0.4);
              } else {
                color = cs.outline;
              }
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 4.0 : 0),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(KuberRadius.full),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: KuberSpacing.md),

          // Action row
          Row(
            children: [
              TextButton(
                onPressed: () => notifier.skipTutorial(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Skip tour',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              if (!state.isFirstStep)
                OutlinedButton(
                  onPressed: () => notifier.prevStep(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    side: BorderSide(color: cs.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(KuberRadius.full),
                    ),
                  ),
                  child: Text(
                    '‹ Prev',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              if (!state.isFirstStep) const SizedBox(width: KuberSpacing.sm),
              FilledButton(
                onPressed: () {
                  if (state.isLastStep) {
                    notifier.completeTutorial(context);
                  } else {
                    notifier.nextStep();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.full),
                  ),
                ),
                child: Text(
                  state.isLastStep ? 'Done' : 'Next ›',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  final bool pointsUp;
  final Color color;

  const _Arrow({required this.pointsUp, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14, 7),
      painter: _ArrowPainter(pointsUp: pointsUp, color: color),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final bool pointsUp;
  final Color color;

  const _ArrowPainter({required this.pointsUp, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointsUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.pointsUp != pointsUp;
}
