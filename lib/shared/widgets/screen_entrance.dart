import 'package:flutter/material.dart';

/// Plays a one-time, subtle fade + rise when a screen first appears in a
/// session, then becomes a passthrough. "Once per session" (keyed by [id])
/// means it animates on first visit to a tab and never replays on later tab
/// switches or swipes — so it never fights the tab PageView's horizontal
/// motion. Fade-dominant (tiny vertical offset) for the same reason.
///
/// Uses a single short-lived controller that is disposed when done; after the
/// first play it returns [child] directly with zero animation overhead.
class ScreenEntrance extends StatefulWidget {
  final String id;
  final Widget child;
  final Duration duration;

  const ScreenEntrance({
    super.key,
    required this.id,
    required this.child,
    this.duration = const Duration(milliseconds: 320),
  });

  /// Screens that have already animated this session.
  static final Set<String> _played = <String>{};

  /// Test hook — lets widget tests re-arm the entrance.
  @visibleForTesting
  static void resetForTest() => _played.clear();

  @override
  State<ScreenEntrance> createState() => _ScreenEntranceState();
}

class _ScreenEntranceState extends State<ScreenEntrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _fade;
  Animation<Offset>? _slide;

  @override
  void initState() {
    super.initState();
    final shouldAnimate = !ScreenEntrance._played.contains(widget.id);
    if (shouldAnimate) {
      ScreenEntrance._played.add(widget.id);
      final controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      _fade = CurvedAnimation(parent: controller, curve: Curves.easeOut);
      _slide =
          Tween<Offset>(
            begin: const Offset(0, 0.015),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          );
      _controller = controller;
      controller.forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return widget.child;

    return FadeTransition(
      opacity: _fade!,
      child: SlideTransition(position: _slide!, child: widget.child),
    );
  }
}
