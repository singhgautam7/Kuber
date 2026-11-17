import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'motion_level.dart';
import 'spring_curve.dart';

/// One list row that grows in and shrinks out (motion.md "Lists").
///
/// Insert (Expressive): fade fx.fast, scale .92 to 1 on springDefault, height
/// 0 to h on springStandard. Remove: fade fx.instant + scale .96, then height
/// to 0 on springStandard, then [onRemoved]. Subtle: fade + height on
/// springSubtle. Off: fade 90 ms.
///
/// Lazy: works in SliverList.builder / SliverAnimatedList. Pass
/// [animateIn] true only for a row that was just inserted (existing rows
/// stay plain). To remove, keep the row in your list, set [present] false,
/// and drop it in [onRemoved]. Never use it to animate the layout of a long
/// list: only the rows on screen move.
class KuberAnimatedListItem extends StatefulWidget {
  const KuberAnimatedListItem({
    super.key,
    required this.child,
    this.present = true,
    this.animateIn = false,
    this.onRemoved,
  });

  final Widget child;
  final bool present;
  final bool animateIn;
  final VoidCallback? onRemoved;

  @override
  State<KuberAnimatedListItem> createState() => _ItemState();
}

class _ItemState extends State<KuberAnimatedListItem>
    with TickerProviderStateMixin {
  double _size = 1, _scale = 1, _fade = 1;
  AnimationController? _sizeC, _scaleC, _fadeC;
  bool _started = false;
  bool _removing = false;

  AnimationController _make(double from, void Function(double) set,
      {bool unbounded = true}) {
    final c = unbounded
        ? AnimationController.unbounded(vsync: this, value: from)
        : AnimationController(vsync: this, value: from);
    c.addListener(() => setState(() => set(c.value)));
    return c;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.animateIn) _insert(KuberMotion.levelOf(context));
    if (!widget.present) _remove(KuberMotion.levelOf(context));
  }

  @override
  void didUpdateWidget(KuberAnimatedListItem old) {
    super.didUpdateWidget(old);
    if (old.present && !widget.present) _remove(KuberMotion.levelOf(context));
  }

  void _insert(MotionLevel l) {
    _fade = 0;
    _fadeC = _make(0, (v) => _fade = v, unbounded: false);
    if (l == MotionLevel.off) {
      _fadeC!.animateTo(1,
          duration: KuberMotion.fxInstant, curve: KuberMotion.curveEffects);
      return;
    }
    _fadeC!.animateTo(1,
        duration: KuberMotion.fxFast, curve: KuberMotion.curveEffects);
    _size = 0;
    _sizeC = _make(0, (v) => _size = v.clamp(0.0, 1.0));
    _sizeC!.springTo(
        1, KuberMotion.spatial(l, KuberMotion.springStandard));
    if (l == MotionLevel.expressive) {
      _scale = .92;
      _scaleC = _make(.92, (v) => _scale = v);
      _scaleC!.springTo(1, KuberMotion.springDefault);
    }
  }

  Future<void> _remove(MotionLevel l) async {
    if (_removing) return;
    _removing = true;
    _fadeC ??= _make(_fade, (v) => _fade = v, unbounded: false);
    if (l == MotionLevel.off) {
      await _fadeC!
          .animateTo(0,
              duration: KuberMotion.fxInstant, curve: KuberMotion.curveEffects)
          .orCancel
          .catchError((_) {});
      if (mounted) widget.onRemoved?.call();
      return;
    }
    final fade = _fadeC!.animateTo(0,
        duration: l == MotionLevel.subtle
            ? KuberMotion.fxFast
            : KuberMotion.fxInstant,
        curve: KuberMotion.curveEffects);
    if (l == MotionLevel.expressive) {
      _scaleC ??= _make(_scale, (v) => _scale = v);
      _scaleC!.springTo(.96, KuberMotion.springFast);
      await fade.orCancel.catchError((_) {});
    }
    if (!mounted) return;
    _sizeC ??= _make(_size, (v) => _size = v.clamp(0.0, 1.0));
    await _sizeC!
        .springTo(0, KuberMotion.spatial(l, KuberMotion.springStandard))
        .orCancel
        .catchError((_) {});
    if (mounted) widget.onRemoved?.call();
  }

  @override
  void dispose() {
    _sizeC?.dispose();
    _scaleC?.dispose();
    _fadeC?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settled = _size == 1 && _scale == 1 && _fade == 1;
    return ClipRect(
      clipBehavior: settled ? Clip.none : Clip.hardEdge,
      child: Align(
        heightFactor: _size,
        alignment: Alignment.topCenter,
        child: Opacity(
          opacity: _fade.clamp(0.0, 1.0),
          child: Transform.scale(scale: _scale, child: widget.child),
        ),
      ),
    );
  }
}

/// First-load entrance: fade fx.fast + an 8 dp rise (4 dp at Subtle), delayed
/// by [KuberMotion.staggerDelay] of [index] (30 ms steps, the 7th and later
/// share the 6th's 150 ms). Never at Off. Once per page: pass [animate] false
/// for a refresh, a row that scrolled in, or while scrolling; it is read once,
/// when the row first builds. Lazy and cheap in SliverList.builder.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.animate = true,
  });

  final int index;
  final Widget child;
  final bool animate;

  @override
  State<StaggeredEntrance> createState() => _StaggerState();
}

class _StaggerState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;
  double _rise = 0;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final l = KuberMotion.levelOf(context);
    if (!widget.animate || l == MotionLevel.off) return;
    _rise = l == MotionLevel.subtle ? 4 : 8;
    final delay = KuberMotion.staggerDelay(widget.index);
    final total = delay + KuberMotion.fxFast;
    _c = AnimationController(vsync: this, duration: total)
      ..animateTo(1,
          curve: Interval(
              delay.inMicroseconds / total.inMicroseconds, 1,
              curve: KuberMotion.curveEffects));
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.child;
    return AnimatedBuilder(
      animation: c,
      child: widget.child,
      builder: (context, child) {
        final t = c.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
              offset: Offset(0, (1 - t) * _rise), child: child),
        );
      },
    );
  }
}
