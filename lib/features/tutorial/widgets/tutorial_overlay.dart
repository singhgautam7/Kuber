import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/utils/l10n_ext.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_loader.dart';
import '../models/tutorial_chapter.dart';
import '../models/tutorial_l10n.dart';
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _dimController;
  late final AnimationController _spotController;
  Rect? _currentRect;
  Rect? _fromRect;
  Rect? _toRect;

  /// Bumped on every step change. Used to cancel any in-flight
  /// [_updateSpotlight] when the user advances quickly.
  int _spotlightToken = 0;

  /// We will resolve dialogs through our own [context] since we will wrap
  /// this overlay with a Navigator in app.dart.
  /// For routing (GoRouter), we still need the rootNavigatorKey's context.
  BuildContext? get _routerCtx => rootNavigatorKey.currentContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _dimController.dispose();
    _spotController.dispose();
    super.dispose();
  }

  /// Framework-level back button handler. Runs when no PopScope further down
  /// the tree consumed the back gesture. Returning `true` consumes it.
  /// This avoids the `BackButtonListener` / `PopScope` widgets, both of which
  /// require a Router/ModalRoute ancestor that doesn't exist above the
  /// Navigator.
  @override
  Future<bool> didPopRoute() async {
    if (!mounted) return false;
    final isActive = ref.read(tutorialNotifierProvider).isActive;
    if (!isActive) return false;
    _confirmExit();
    return true;
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

    // Back button is intercepted via WidgetsBindingObserver.didPopRoute,
    // which works regardless of widget-tree position. We can't use PopScope
    // or BackButtonListener here because both need a Router/ModalRoute
    // ancestor — and TutorialOverlay sits above the Router.
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
                        onSkip: _confirmExit,
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

  Future<void> _updateSpotlight() async {
    if (!mounted) return;
    final token = ++_spotlightToken;
    final state = ref.read(tutorialNotifierProvider);
    if (!state.isActive) return;
    final step = state.step;

    Rect? rect;
    if (step.spotlight && step.key != null) {
      // Wait for the target widget to mount AND be laid out (hasSize true)
      // after navigation. Up to ~3 s. Just checking `currentContext != null`
      // isn't enough — the widget may be attached but not laid out yet, which
      // makes `_getTargetRect` return null.
      for (var i = 0; i < 60; i++) {
        if (!mounted || token != _spotlightToken) return;
        if (_getTargetRect(step.key) != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      final ctx = step.key?.currentContext;
      if (ctx != null && ctx.mounted) {
        // Scroll target into the middle of its scrollable ancestor (if any),
        // so the spotlight rect lands on a visible widget.
        final scrollable = Scrollable.maybeOf(ctx);
        if (scrollable != null && ctx.mounted) {
          // ignore: use_build_context_synchronously
          await Scrollable.ensureVisible(
            ctx,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        if (!mounted || token != _spotlightToken) return;
        rect = _getTargetRect(step.key);
      }
    }

    if (!mounted || token != _spotlightToken) return;
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
    // Prev never crosses chapters, so no navigation is needed.
  }

  Future<void> _next() async {
    final state = ref.read(tutorialNotifierProvider);
    final stepCount = state.chapter.steps.length;
    final isLastStepOfChapter = state.stepIndex == stepCount - 1;
    final isFinalChapter =
        state.chapterIndex == tutorialChapters.length - 1;

    if (isLastStepOfChapter && isFinalChapter) {
      await _endTutorial();
      return;
    }
    if (isLastStepOfChapter) {
      await _showChapterCompleteSheet(state);
      return;
    }
    ref.read(tutorialNotifierProvider.notifier).nextStep();
    _navigateToCurrentChapter();
  }

  Future<void> _showChapterCompleteSheet(TutorialState state) async {
    final nextChapterIndex = state.chapterIndex + 1;
    final l = context.l10n;
    final doneTitle = l.chapterDoneTitle('${state.chapterIndex + 1}');
    final nextTitle = tutChapterTitle(context, nextChapterIndex);

    final proceed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetCtx) {
        final cs = Theme.of(sheetCtx).colorScheme;
        return KuberBottomSheet(
          title: doneTitle,
          actions: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(sheetCtx, rootNavigator: true).pop(false),
                    child: Text(l.endTutorial),
                  ),
                ),
              ),
              SizedBox(width: KuberSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(sheetCtx, rootNavigator: true).pop(true),
                    child: Text('$nextTitle →'),
                  ),
                ),
              ),
            ],
          ),
          child: Text(
            l.readyToStart(nextTitle),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (proceed == true) {
      ref.read(tutorialNotifierProvider.notifier).nextStep();
      _navigateToCurrentChapter();
    } else {
      await _endTutorial();
    }
  }

  void _navigateToCurrentChapter() {
    final routerCtx = _routerCtx;
    if (routerCtx == null) return;
    final route = ref.read(tutorialNotifierProvider).chapter.route;
    routerCtx.go(route);
  }

  /// Shared confirm-and-exit flow used by both the device back button
  /// (via [BackButtonListener]) and the tooltip's "Skip tour" button.
  Future<void> _confirmExit() async {
    final l = context.l10n;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetCtx) {
        final cs = Theme.of(sheetCtx).colorScheme;
        return KuberBottomSheet(
          title: l.exitTutorialConfirm,
          actions: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(sheetCtx, rootNavigator: true).pop(false),
                    child: Text(l.keepGoing),
                  ),
                ),
              ),
              SizedBox(width: KuberSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(sheetCtx, rootNavigator: true).pop(true),
                    child: Text(l.exitLabel),
                  ),
                ),
              ),
            ],
          ),
          child: Text(
            l.replayHintApp,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        );
      },
    );
    if (confirmed == true) await _endTutorial();
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
        final endCtx = _routerCtx;
        if (endCtx != null && endCtx.mounted) {
          endCtx.go('/tutorial');
        }
      }
    }
  }
}
