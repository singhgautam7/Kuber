import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/app_theme.dart';
import 'motion_level.dart';

/// Theme change reveal (handoff decision 15). Wrap the app once; every theme
/// control calls `ThemeRipple.of(context).run(tapPosition, () => change())`.
///
/// run() snapshots the current frame (one GPU image, no await), applies the
/// change underneath, then draws the snapshot on top with a circular hole
/// growing from the tap to the farthest corner: springSlow at Expressive,
/// springSubtle at Subtle, a 90 ms cross-fade of the snapshot at Off. Only a
/// clip and one image draw per frame. A second change mid-way snapshots the
/// frame as it is (ripple included) and replaces the first, so nothing jumps.
/// The overlay ignores pointers. If the snapshot fails (no layer yet, web),
/// the change is applied with no ripple.
class ThemeRipple extends StatefulWidget {
  const ThemeRipple({super.key, required this.child});
  final Widget child;

  /// Null when there is no [ThemeRipple] above (tests): callers then just apply.
  static ThemeRippleHandle? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_RippleScope>()?.handle;

  static ThemeRippleHandle of(BuildContext context) =>
      maybeOf(context) ?? const _NoRipple();

  @override
  State<ThemeRipple> createState() => _ThemeRippleState();
}

abstract interface class ThemeRippleHandle {
  /// [globalPosition] is where the control was tapped (pointer-down).
  void run(Offset globalPosition, VoidCallback apply);
}

class _NoRipple implements ThemeRippleHandle {
  const _NoRipple();
  @override
  void run(Offset globalPosition, VoidCallback apply) => apply();
}

class _RippleScope extends InheritedWidget {
  const _RippleScope({required this.handle, required super.child});
  final ThemeRippleHandle handle;
  @override
  bool updateShouldNotify(_RippleScope old) => false;
}

class _Ripple {
  _Ripple(this.image, this.center, this.controller);
  final ui.Image image;
  final Offset center;
  final AnimationController controller;
}

class _ThemeRippleState extends State<ThemeRipple>
    with TickerProviderStateMixin
    implements ThemeRippleHandle {
  final GlobalKey _boundary = GlobalKey();
  final List<_Ripple> _ripples = [];
  MotionLevel _level = MotionLevel.expressive;

  /// Ripples currently drawn (tests).
  @visibleForTesting
  int get active => _ripples.length;

  @override
  void run(Offset globalPosition, VoidCallback apply) {
    ui.Image? image;
    try {
      final box = _boundary.currentContext?.findRenderObject();
      if (box is RenderRepaintBoundary) {
        image = box.toImageSync(
            pixelRatio: View.of(context).devicePixelRatio);
      }
    } catch (e) {
      debugPrint('Kuber: theme snapshot failed, no ripple: $e');
    }
    apply();
    if (image == null || !mounted) {
      image?.dispose();
      return;
    }
    // Everything before this is baked into the new snapshot.
    for (final r in _ripples) {
      r.controller.dispose();
      r.image.dispose();
    }
    _ripples.clear();

    final off = _level == MotionLevel.off;
    final curve = _level == MotionLevel.subtle
        ? KuberMotion.subtleCurve
        : KuberMotion.slowCurve;
    final c = AnimationController(
      vsync: this,
      duration: off ? KuberMotion.fxInstant : curve.settle,
    );
    final box = context.findRenderObject() as RenderBox;
    final ripple = _Ripple(image, box.globalToLocal(globalPosition), c);
    setState(() => _ripples.add(ripple));
    c.forward().whenComplete(() {
      if (!mounted || !_ripples.remove(ripple)) return;
      c.dispose();
      image!.dispose();
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (final r in _ripples) {
      r.controller.dispose();
      r.image.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _level = KuberMotion.levelOf(context);
    final curve = (_level == MotionLevel.subtle
            ? KuberMotion.subtleCurve
            : KuberMotion.slowCurve)
        .clamped;
    return _RippleScope(
      handle: this,
      child: RepaintBoundary(
        key: _boundary,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            widget.child,
            for (final r in _ripples)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _RipplePainter(
                      r,
                      off: _level == MotionLevel.off,
                      curve: curve,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.r, {required this.off, required this.curve})
      : super(repaint: r.controller);
  final _Ripple r;
  final bool off;
  final Curve curve;

  @override
  void paint(Canvas canvas, Size size) {
    final t = r.controller.value;
    final src = Rect.fromLTWH(
        0, 0, r.image.width.toDouble(), r.image.height.toDouble());
    final dst = Offset.zero & size;
    if (off) {
      canvas.drawImageRect(r.image, src, dst,
          Paint()..color = Color.fromRGBO(0, 0, 0, 1 - t));
      return;
    }
    final c = r.center;
    final far = math.max(
      math.max((c - dst.topLeft).distance, (c - dst.topRight).distance),
      math.max((c - dst.bottomLeft).distance, (c - dst.bottomRight).distance),
    );
    final radius = far * curve.transform(t);
    final hole = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(dst)
      ..addOval(Rect.fromCircle(center: c, radius: radius));
    canvas.save();
    canvas.clipPath(hole);
    canvas.drawImageRect(r.image, src, dst, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RipplePainter o) => o.r != r || o.off != off;
}
