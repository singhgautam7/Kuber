import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/tutorial_chapter.dart';
import '../models/tutorial_l10n.dart';
import '../providers/tutorial_provider.dart';

class TutorialTooltipCard extends ConsumerWidget {
  final Rect? spotlightRect;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSkip;

  const TutorialTooltipCard({
    super.key,
    required this.spotlightRect,
    required this.onNext,
    required this.onPrev,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tutorialNotifierProvider);
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final cardWidth = (size.width - KuberSpacing.xl * 2).clamp(280.0, 420.0);
    final target = spotlightRect;
    final below = target == null || target.center.dy < size.height * 0.55;
    final top = target == null
        ? (size.height - 260) / 2
        : below
        ? (target.bottom + KuberSpacing.xl).clamp(96.0, size.height - 310)
        : (target.top - 286).clamp(48.0, size.height - 310);

    return Positioned(
      top: top,
      left: (size.width - cardWidth) / 2,
      width: cardWidth,
      child: _AnimatedTooltipBody(
        key: ValueKey('${state.chapterIndex}-${state.stepIndex}'),
        showArrow: target != null,
        arrowDown: !below,
        child: _TooltipContent(
          state: state,
          colorScheme: cs,
          onNext: onNext,
          onPrev: onPrev,
          onSkip: onSkip,
        ),
      ),
    );
  }
}

class _AnimatedTooltipBody extends StatefulWidget {
  final Widget child;
  final bool showArrow;
  final bool arrowDown;

  const _AnimatedTooltipBody({
    super.key,
    required this.child,
    required this.showArrow,
    required this.arrowDown,
  });

  @override
  State<_AnimatedTooltipBody> createState() => _AnimatedTooltipBodyState();
}

class _AnimatedTooltipBodyState extends State<_AnimatedTooltipBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showArrow && !widget.arrowDown)
              _TooltipArrow(color: cs.outline, down: false),
            widget.child,
            if (widget.showArrow && widget.arrowDown)
              _TooltipArrow(color: cs.outline, down: true),
          ],
        ),
      ),
    );
  }
}

class _TooltipContent extends StatelessWidget {
  final TutorialState state;
  final ColorScheme colorScheme;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSkip;

  const _TooltipContent({
    required this.state,
    required this.colorScheme,
    required this.onNext,
    required this.onPrev,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final chapter = state.chapter;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(KuberRadius.full),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Text(
              '● ${context.l10n.chapterXofY('${state.chapterIndex + 1}', '${tutorialChapters.length}')} · ${tutChapterTitle(context, state.chapterIndex)}',
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.md),
          Text(
            tutStepTitle(context, state.chapterIndex, state.stepIndex),
            style: localeFont(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          Text(
            tutStepDesc(context, state.chapterIndex, state.stepIndex),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: localeFont(
              fontSize: 13,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          Row(
            children: List.generate(chapter.steps.length, (index) {
              final color = index == state.stepIndex
                  ? colorScheme.primary
                  : index < state.stepIndex
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : colorScheme.outline;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(
                    right: index == chapter.steps.length - 1 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(KuberRadius.full),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: KuberSpacing.lg),
          Row(
            children: [
              TextButton(
                onPressed: onSkip,
                child: Text(
                  context.l10n.skipTour,
                  style: localeFont(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const Spacer(),
              if (state.stepIndex > 0) ...[
                OutlinedButton(onPressed: onPrev, child: const Text('‹ Prev')),
                const SizedBox(width: KuberSpacing.sm),
              ],
              FilledButton(
                onPressed: onNext,
                child: Text(state.isLastStep ? context.l10n.doneLabel : context.l10n.nextArrow),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TooltipArrow extends StatelessWidget {
  final Color color;
  final bool down;

  const _TooltipArrow({required this.color, required this.down});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 10),
      painter: _ArrowPainter(color: color, down: down),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool down;

  const _ArrowPainter({required this.color, required this.down});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (down) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    } else {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.down != down;
  }
}