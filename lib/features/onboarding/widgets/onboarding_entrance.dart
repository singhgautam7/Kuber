import 'package:flutter/material.dart';

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
  var _reduced = false;
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
    _reduced = KuberMotion.reduced(context);
    if (_reduced) _controller.duration = KuberMotion.reducedFade;
    Future<void>.delayed(_reduced ? Duration.zero : widget.delay, () {
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
    final begin = _reduced ? Offset.zero : widget.beginOffset;
    final rise = _reduced ? 0.0 : widget.rise;
    final scale = _reduced ? 1.0 : widget.scale;
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
