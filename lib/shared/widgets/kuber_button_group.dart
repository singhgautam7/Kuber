import 'package:flutter/material.dart';

import '../../core/motion/animated_weight.dart';
import '../../core/motion/kuber_haptics.dart';
import '../../core/motion/motion_level.dart';
import '../../core/motion/spring_curve.dart';
import '../../core/theme/app_theme.dart';
import 'kuber_list.dart' show kuberPressedLayer;

/// One choice of a [KuberButtonGroup].
class KuberButtonOption<T> {
  const KuberButtonOption({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

/// Single-choice selector with the v7.0.0 button-group motion; every
/// single-choice selector (type pickers, Week / Month / Year, theme mode)
/// uses it. Standard M3 Expressive group: pills with 8 dp gaps.
///
/// Expressive: the pressed item widens 15 % and its neighbours squeeze so the
/// total width holds (springFast down, springDefault up), corners go to 8 dp;
/// the selected item has 12 dp corners, secondaryContainer fill (fx.fast), a
/// check that grows 0 to 18 dp on springStandard and a label that goes
/// 600 to 700 (variable weight, fx.default). Subtle: no widening or corner
/// morph, fill and weight only. Off: no movement. Selecting plays the tick
/// haptic. [expand] false hugs the content.
class KuberButtonGroup<T> extends StatefulWidget {
  const KuberButtonGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    this.height = 40,
    this.showCheck = true,
    this.expand = true,
  }) : assert(options.length > 0);

  final List<KuberButtonOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final double height;

  /// Draw the check on the selected item (skip it for 4+ options).
  final bool showCheck;
  final bool expand;

  @override
  State<KuberButtonGroup<T>> createState() => _KuberButtonGroupState<T>();
}

class _KuberButtonGroupState<T> extends State<KuberButtonGroup<T>>
    with SingleTickerProviderStateMixin {
  static const double _gap = 8;
  final ValueNotifier<double> _v = ValueNotifier(0);
  AnimationController? _c;
  int _pressed = -1; // stays set during the release so widths ease back
  bool _down = false;
  Offset? _downAt;

  AnimationController get _ctrl => _c ??= AnimationController.unbounded(vsync: this)
    ..addListener(() => _v.value = _c!.value);

  @override
  void dispose() {
    _c?.dispose();
    _v.dispose();
    super.dispose();
  }

  void _press(int i, PointerDownEvent e) {
    if (!widget.enabled) return;
    setState(() {
      _pressed = i;
      _down = true;
    });
    _downAt = e.position;
    if (KuberMotion.levelOf(context) == MotionLevel.expressive) {
      _ctrl.springTo(1, KuberMotion.springFast);
    }
  }

  void _release([PointerEvent? e]) {
    if (!_down) return;
    setState(() => _down = false);
    _downAt = null;
    if (KuberMotion.levelOf(context) == MotionLevel.expressive) {
      _ctrl.springTo(0, KuberMotion.springDefault);
    }
  }

  void _select(T v) {
    if (!widget.enabled || v == widget.selected) return;
    KuberHaptics.tick();
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final level = KuberMotion.levelOf(context);
    final n = widget.options.length;
    final expressive = level == MotionLevel.expressive;
    final checkCurve = KuberMotion.spatialCurve(level, KuberMotion.standardCurve);

    Widget item(int i, double flex) {
      final o = widget.options[i];
      final sel = o.value == widget.selected;
      final isPressed = _down && _pressed == i;
      // Selected is primary / onPrimary, not the design's secondaryContainer:
      // secondaryContainer sits about 1.1:1 against the unselected pills in
      // most themes (Pure black included), so only the check told them
      // apart. Disabled (a locked type on Edit) stays readable: no 38 % dim
      // of the whole group, the others just use the muted label colour.
      // Guarded by test/core/theme/v7_contrast_test.dart.
      final fill = sel ? cs.primary : cs.surfaceContainerHighest;
      final fg = sel
          ? cs.onPrimary
          : (widget.enabled ? cs.onSurface : cs.onSurfaceVariant);
      final restR = sel ? 12.0 : widget.height / 2;
      return Flexible(
        flex: (flex * 1000).round().clamp(1, 1 << 30),
        fit: widget.expand ? FlexFit.tight : FlexFit.loose,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) => _press(i, e),
          onPointerMove: (e) {
            final d = _downAt;
            if (d != null && (e.position - d).distance > 18) _release();
          },
          onPointerUp: _release,
          onPointerCancel: _release,
          child: Semantics(
            button: true,
            selected: sel,
            inMutuallyExclusiveGroup: true,
            enabled: widget.enabled,
            label: o.label,
            excludeSemantics: true,
            onTap: () => _select(o.value),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: restR),
              duration: level == MotionLevel.off ? Duration.zero : KuberMotion.fxFast,
              curve: KuberMotion.curveEffects,
              builder: (context, rest, _) => AnimatedBuilder(
                animation: _v,
                builder: (context, _) {
                  final pr = (expressive && _pressed == i) ? _v.value : 0.0;
                  final r = (rest + (8 - rest) * pr).clamp(0.0, 999.0);
                  return TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: fill),
                    duration:
                        level == MotionLevel.off ? KuberMotion.fxInstant : KuberMotion.fxFast,
                    curve: KuberMotion.curveEffects,
                    builder: (context, color, _) => Material(
                      color: color,
                      animationDuration: Duration.zero,
                      borderRadius: BorderRadius.circular(r),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: widget.enabled ? () => _select(o.value) : null,
                        overlayColor: kuberPressedLayer(cs),
                        child: SizedBox(
                          height: widget.height,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.showCheck)
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(end: sel ? 1 : 0),
                                    duration: level == MotionLevel.off
                                        ? Duration.zero
                                        : checkCurve.settle,
                                    curve: checkCurve.clamped,
                                    builder: (context, k, child) => ClipRect(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: k,
                                        child: Opacity(opacity: k, child: child),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Icon(Icons.check_rounded, size: 18, color: fg),
                                    ),
                                  ),
                                if (o.icon != null) ...[
                                  Icon(o.icon, size: 18, color: fg),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: AnimatedWeight(
                                    o.label,
                                    isActive: sel || isPressed,
                                    rest: 600,
                                    active: 700,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: fg),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    final group = AnimatedBuilder(
      animation: _v,
      builder: (context, _) {
        // Pressed item: 1 + .15v of its share; the rest split what is left.
        final grow = expressive && _pressed >= 0 && n > 1
            ? 1 + KuberMotion.buttonGroupWiden * _v.value
            : 1.0;
        final other = n > 1 ? (n - grow) / (n - 1) : 1.0;
        return Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (var i = 0; i < n; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              item(i, i == _pressed ? grow : other),
            ],
          ],
        );
      },
    );
    return widget.expand ? group : IntrinsicWidth(child: group);
  }
}
