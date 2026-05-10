import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tutorial_provider.dart';
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
  OverlayEntry? _entry;
  late AnimationController _dimController;
  late AnimationController _spotController;
  late AnimationController _cardController;

  late Animation<double> _dimAnim;
  late Animation<double> _borderAnim;
  late Animation<double> _cardFadeAnim;
  late Animation<Offset> _cardSlideAnim;

  Rect? _currentRect;
  Rect? _previousRect;
  late Animation<Rect?> _spotAnim;


  @override
  void initState() {
    super.initState();

    _dimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dimAnim = Tween<double>(begin: 0, end: 0.78).animate(
      CurvedAnimation(parent: _dimController, curve: Curves.easeOut),
    );
    _borderAnim = Tween<double>(begin: 0, end: 0.6).animate(
      CurvedAnimation(parent: _dimController, curve: Curves.easeOut),
    );

    _spotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _cardFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );

    _spotAnim = RectTween(begin: null, end: null).animate(_spotController);
  }

  @override
  void dispose() {
    _dimController.dispose();
    _spotController.dispose();
    _cardController.dispose();
    _entry?.remove();
    super.dispose();
  }

  Rect? _getTargetRect(GlobalKey? key) {
    if (key == null) return null;
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final pos = box.localToGlobal(Offset.zero);
    return pos & box.size;
  }

  void _insertOverlay(TutorialState state) {
    _updateSpotlight(state, animate: false);
    _dimController.forward();
    _cardController.forward();

    _entry = OverlayEntry(builder: (_) => _buildOverlay(state));
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _removeOverlay() {
    _dimController.reverse().then((_) {
      _entry?.remove();
      _entry = null;
    });
  }

  void _updateSpotlight(TutorialState state, {bool animate = true}) {
    final targetKey = state.currentStep.targetKey;
    final newRect = _getTargetRect(targetKey);

    // Fallback: try again after a frame if key not yet built
    if (newRect == null && targetKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateSpotlight(state, animate: animate);
      });
      return;
    }

    _previousRect = _currentRect;
    _currentRect = newRect;

    _spotAnim = RectTween(
      begin: _previousRect ?? _currentRect,
      end: _currentRect,
    ).animate(CurvedAnimation(
      parent: _spotController,
      curve: Curves.easeInOut,
    ));

    if (animate) {
      _spotController.reset();
      _spotController.forward();
      _cardController.reset();
      _cardController.forward();
    }

    _entry?.markNeedsBuild();
  }

  Widget _buildOverlay(TutorialState state) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _dimController,
        _spotController,
        _cardController,
      ]),
      builder: (context, _) {
        final size = MediaQuery.sizeOf(context);
        final rect = _spotAnim.value;

        return Material(
          type: MaterialType.transparency,
          child: SizedBox.expand(
            child: Stack(
              children: [
                // Dim + spotlight cutout
                CustomPaint(
                  size: size,
                  painter: TutorialSpotlightPainter(
                    spotlightRect: rect,
                    dimOpacity: _dimAnim.value,
                    borderOpacity: _borderAnim.value,
                    primaryColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                // Tooltip card
                _TooltipWrapper(
                  spotlightRect: rect,
                  screenSize: size,
                  fadeAnim: _cardFadeAnim,
                  slideAnim: _cardSlideAnim,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TutorialState>(tutorialNotifierProvider, (prev, next) {
      if (!next.isActive && prev?.isActive == true) {
        _removeOverlay();
        return;
      }

      if (next.isActive && prev?.isActive != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _insertOverlay(next);
        });
        return;
      }

      if (next.isActive && prev != null) {
        final chapterChanged = next.chapterIndex != prev.chapterIndex;
        final stepChanged = next.stepIndex != prev.stepIndex;

        if (chapterChanged || stepChanged) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _updateSpotlight(next);
          });
        }
      }
    });

    return widget.child;
  }
}

class _TooltipWrapper extends ConsumerWidget {
  final Rect? spotlightRect;
  final Size screenSize;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _TooltipWrapper({
    required this.spotlightRect,
    required this.screenSize,
    required this.fadeAnim,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TutorialTooltipCard(
      spotlightRect: spotlightRect,
      screenSize: screenSize,
      fadeAnim: fadeAnim,
      slideAnim: slideAnim,
    );
  }
}
