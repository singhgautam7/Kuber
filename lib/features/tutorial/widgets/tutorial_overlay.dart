import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';

import '../../../shared/widgets/kuber_loader.dart';
import '../providers/tutorial_provider.dart';
import '../providers/tutorial_sandbox_provider.dart';
import '../services/tutorial_mock_data_service.dart';
import 'tutorial_spotlight_painter.dart';
import 'tutorial_tooltip_card.dart';

class TutorialOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const TutorialOverlay({super.key, required this.child});

  @override
  ConsumerState<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends ConsumerState<TutorialOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _dimController;
  late final AnimationController _spotController;
  Rect? _currentRect;
  Rect? _fromRect;
  Rect? _toRect;

  @override
  void initState() {
    super.initState();
    _dimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _spotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _dimController.dispose();
    _spotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(tutorialNotifierProvider, (previous, next) {
      if (next.isActive) {
        _dimController.forward();
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateSpotlight());
      } else {
        _dimController.reverse();
      }

      if (previous?.chapterIndex != next.chapterIndex ||
          previous?.stepIndex != next.stepIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateSpotlight());
      }
    });

    final state = ref.watch(tutorialNotifierProvider);
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          ignoring: !state.isActive,
          child: AnimatedBuilder(
            animation: Listenable.merge([_dimController, _spotController]),
            builder: (context, _) {
              final rect = _animatedRect();
              return Opacity(
                opacity: state.isActive ? 1 : 0,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TutorialSpotlightPainter(
                          spotlightRect: rect,
                          dimOpacity: 0.75 * _dimController.value,
                          borderOpacity: 0.6 * _dimController.value,
                          primaryColor: cs.primary,
                        ),
                      ),
                    ),
                    if (state.isActive)
                      TutorialTooltipCard(
                        spotlightRect: rect,
                        onPrev: _previous,
                        onNext: _next,
                        onSkip: _confirmSkip,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Rect? _animatedRect() {
    if (_fromRect == null || _toRect == null) return _currentRect;
    return Rect.lerp(
      _fromRect,
      _toRect,
      Curves.easeInOut.transform(_spotController.value),
    );
  }

  void _updateSpotlight() {
    if (!mounted) return;
    final state = ref.read(tutorialNotifierProvider);
    if (!state.isActive) return;
    final step = state.step;
    final rect = step.spotlight ? _getTargetRect(step.key) : null;
    _fromRect = _currentRect;
    _toRect = rect;
    _currentRect = rect;
    _spotController
      ..reset()
      ..forward();
  }

  Rect? _getTargetRect(GlobalKey? key) {
    final ctx = key?.currentContext;
    if (ctx == null) return null;
    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final pos = renderObject.localToGlobal(Offset.zero);
    return pos & renderObject.size;
  }

  void _previous() {
    ref.read(tutorialNotifierProvider.notifier).prevStep();
    _navigateToCurrentChapter();
  }

  Future<void> _next() async {
    final notifier = ref.read(tutorialNotifierProvider.notifier);
    final state = ref.read(tutorialNotifierProvider);
    if (state.isLastStep) {
      await _endTutorial();
      return;
    }
    notifier.nextStep();
    _navigateToCurrentChapter();
  }

  void _navigateToCurrentChapter() {
    final route = ref.read(tutorialNotifierProvider).chapter.route;
    context.go(route);
  }

  Future<void> _confirmSkip() async {
    final skip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip tutorial?'),
        content: const Text('You can always replay it from More → Tutorial.'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
    if (skip == true) await _endTutorial();
  }

  Future<void> _endTutorial() async {
    final state = ref.read(tutorialNotifierProvider);
    final sandbox = ref.read(tutorialSandboxIsarProvider);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const KuberLoader(label: 'Closing tutorial...'),
    );

    try {
      final Isar isar = sandbox ?? ref.read(tutorialAwareIsarProvider);
      await TutorialMockDataService().clearMockData(isar);
      if (state.isSandboxMode && sandbox != null) {
        await closeSandboxIsar(sandbox);
        ref.read(tutorialSandboxIsarProvider.notifier).state = null;
      }
      ref.read(tutorialNotifierProvider.notifier).completeTutorial();
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        context.go('/');
      }
    }
  }
}
