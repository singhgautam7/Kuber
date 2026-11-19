import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/app_theme.dart';

/// One-shot fade with a slide ([beginOffset], a fraction of the child), a rise
/// in dp ([rise]) or a scale from [scale]. Reduced motion: a quick fade.
class OnboardingEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset beginOffset;
  final Duration duration;
  final double rise;
  final double scale;
  final Curve curve;

  const OnboardingEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, 0.08),
    this.duration = const Duration(milliseconds: 500),
    this.rise = 0,
    this.scale = 1,
    this.curve = Curves.easeOut,
  });

  @override
  State<OnboardingEntrance> createState() => _OnboardingEntranceState();
}

class _OnboardingEntranceState extends State<OnboardingEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _value;
  var _reduced = false; // Off
  var _subtle = false;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _value = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final level = KuberMotion.levelOf(context);
    _reduced = level == MotionLevel.off;
    _subtle = level == MotionLevel.subtle;
    if (_reduced) _controller.duration = KuberMotion.reducedFade;
    // Subtle: no stagger, half the distance, short fade.
    if (_subtle) _controller.duration = KuberMotion.fxDefault;
    Future<void>.delayed(_reduced || _subtle ? Duration.zero : widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = _subtle ? 0.5 : 1.0;
    final begin = _reduced ? Offset.zero : widget.beginOffset * k;
    final rise = _reduced ? 0.0 : widget.rise * k;
    final scale = _reduced ? 1.0 : 1 - (1 - widget.scale) * k;
    return FadeTransition(
      opacity: _value,
      child: AnimatedBuilder(
        animation: _value,
        child: widget.child,
        builder: (_, c) {
          final t = _value.value;
          return FractionalTranslation(
            translation: begin * (1 - t),
            child: Transform.translate(
              offset: Offset(0, rise * (1 - t)),
              child: Transform.scale(scale: scale + (1 - scale) * t, child: c),
            ),
          );
        },
      ),
    );
  }
}
