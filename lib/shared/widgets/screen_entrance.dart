import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';

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
  Animation<Offset>? _slide;
  MotionLevel _level = MotionLevel.expressive;
  bool _checked = false;

  // The level is an inherited value, so the first play is decided here
  // rather than in initState.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    _level = KuberMotion.levelOf(context);
    if (ScreenEntrance._played.contains(widget.id)) return;
    ScreenEntrance._played.add(widget.id);
    // Expressive: the existing rise. Subtle: 4 dp. Off: no slide, 90 ms fade.
    final off = _level == MotionLevel.off;
    final controller = AnimationController(
      vsync: this,
      duration: off ? KuberMotion.fxInstant : widget.duration,
    );
    final rise = _level == MotionLevel.subtle ? 0.005 : 0.015;
    _slide = Tween<Offset>(begin: Offset(0, off ? 0 : rise), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    _controller = controller;
    controller.forward();
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

    // Expressive / Subtle: slide-only (no FadeTransition). A fade forces a
    // saveLayer that composites the whole screen at <1 opacity every frame of
    // the entrance, measured to add ~15 ms raster while a heavy screen (e.g.
    // the Analytics chart) does its first cold build. SlideTransition is a
    // cheap transform layer. Off has no slide, so it fades (90 ms, once).
    if (_level == MotionLevel.off) {
      return FadeTransition(opacity: controller, child: widget.child);
    }
    return SlideTransition(position: _slide!, child: widget.child);
  }
}
