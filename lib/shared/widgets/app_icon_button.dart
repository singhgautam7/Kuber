import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';

/// Visual weight of an [AppIconButton] (components/header.md, board 2b).
enum AppIconButtonKind {
  /// surfaceContainerHigh disc, onSurface glyph. The default header button.
  standard,

  /// secondaryContainer disc: an active toggle (privacy on, open menu).
  tonal,

  /// primary disc, onPrimary glyph.
  filled,

  /// No disc: a quiet action inside a field or a tinted row.
  plain,

  /// errorContainer disc: Delete in the contextual header.
  danger,
}

/// Every header action is this button: a 40dp disc with a 20dp glyph centred
/// in a 48dp tap target.
///
/// Copied from PostPurush `core/widgets/app_icon_button.dart` and adapted to
/// Kuber's ColorScheme roles, the spec's numeric badge (16dp, error) and a
/// long-press plain tooltip.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.kind = AppIconButtonKind.standard,
    this.size = 40,
    this.glyphSize = 20,
    this.tint,
    this.badge,
    this.badgeColor,
    this.onBadgeColor,
    this.onLongPress,
    this.longPressHint,
    this.tooltip = true,
    this.iconTurns,
    super.key,
  });

  final IconData icon;

  /// Null disables the button (38% opacity).
  final VoidCallback? onPressed;

  /// Required: an icon-only control is invisible to a screen reader without it.
  final String semanticLabel;
  final AppIconButtonKind kind;
  final double size;
  final double glyphSize;
  final Color? tint;

  /// A count badge (notifications). Empty string draws nothing.
  final String? badge;

  /// Badge colours; default error / onError.
  final Color? badgeColor;
  final Color? onBadgeColor;
  final VoidCallback? onLongPress;

  /// What [onLongPress] does, for screen readers and the tooltip.
  final String? longPressHint;

  /// Show [semanticLabel] as a plain tooltip on long-press.
  final bool tooltip;

  /// Glyph rotation in turns (0.5 = upside down), animated like a chevron
  /// (springFast; Subtle springSubtle; Off snaps). For expand / collapse
  /// buttons; null keeps the plain glyph.
  final double? iconTurns;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final disabled = onPressed == null;
    final (Color bg, Color fg) = switch (kind) {
      AppIconButtonKind.standard => (cs.surfaceContainerHigh, cs.onSurface),
      AppIconButtonKind.tonal => (cs.secondaryContainer, cs.onSecondaryContainer),
      AppIconButtonKind.filled => (cs.primary, cs.onPrimary),
      AppIconButtonKind.plain => (Colors.transparent, cs.onSurfaceVariant),
      AppIconButtonKind.danger => (cs.errorContainer, cs.onErrorContainer),
    };
    final target =
        size < KuberSpace.tapTarget ? KuberSpace.tapTarget : size;
    final hasBadge = badge != null && badge!.isNotEmpty;

    final level = KuberMotion.levelOf(context);
    final off = level == MotionLevel.off;
    final glyph = tint ?? fg;
    Widget button = SizedBox(
      width: target,
      height: target,
      child: Center(
        child: AnimatedOpacity(
          opacity: disabled ? 0.38 : 1,
          duration: off ? KuberMotion.fxInstant : KuberMotion.fxFast,
          curve: KuberMotion.curveEffects,
          child: Pressable(
            kind: PressKind.iconButton,
            enabled: !disabled,
            restRadius: size / 2,
            builder: (context, radius, pressed) => Material(
              color: kind == AppIconButtonKind.standard &&
                      level == MotionLevel.expressive
                  ? Color.lerp(
                      bg, cs.surfaceContainerHighest, pressed.clamp(0.0, 1.0))
                  : bg,
              animationDuration: Duration.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                onLongPress: onLongPress == null
                    ? null
                    : () {
                        KuberHaptics.longPress();
                        onLongPress!();
                      },
                child: SizedBox(
                  width: size,
                  height: size,
                  child: iconTurns == null
                      ? _IconSwap(icon: icon, size: glyphSize, color: glyph)
                      : Builder(builder: (context) {
                          final level = KuberMotion.levelOf(context);
                          final c = KuberMotion.spatialCurve(level, KuberMotion.fastCurve);
                          return AnimatedRotation(
                            turns: iconTurns!,
                            duration: level == MotionLevel.off ? Duration.zero : c.settle,
                            curve: c.clamped,
                            child: _IconSwap(icon: icon, size: glyphSize, color: glyph),
                          );
                        }),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Badge pops in / out and its count swaps with a quick scale (review
    // round 3). The Stack stays mounted whenever the caller styles a badge,
    // so removing it can animate too.
    if (hasBadge || badgeColor != null) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            top: 6,
            right: 6,
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: !hasBadge
                    ? const SizedBox.shrink(key: ValueKey('no-badge'))
                    : Container(
                        key: ValueKey(badge),
                        constraints: const BoxConstraints(minWidth: 16),
                        height: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badgeColor ?? cs.error,
                          borderRadius: KuberShape.fullR,
                        ),
                        child: Text(
                          badge!,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  color: onBadgeColor ?? cs.onError,
                                  height: 1.1,
                                  letterSpacing: 0),
                        ),
                      ),
              ),
            ),
          ),
        ],
      );
    }

    if (tooltip && onLongPress == null) {
      button = Tooltip(
        message: semanticLabel,
        triggerMode: TooltipTriggerMode.longPress,
        child: button,
      );
    } else if (longPressHint != null) {
      button = _HoldHint(message: longPressHint!, child: button);
    }

    return Semantics(
      button: true,
      enabled: !disabled,
      label: semanticLabel,
      hint: longPressHint,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: button,
    );
  }
}

/// The hint on a long-press action: hover, focus, and the start of a hold (the
/// long-press itself then acts). A held button gets a soft ring.
class _HoldHint extends StatefulWidget {
  final String message;
  final Widget child;
  const _HoldHint({required this.message, required this.child});

  @override
  State<_HoldHint> createState() => _HoldHintState();
}

class _HoldHintState extends State<_HoldHint> {
  final _tip = GlobalKey<TooltipState>();
  Timer? _timer;
  bool _held = false;

  void _down(PointerDownEvent _) {
    // A plain tap never sees it.
    _timer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => _held = true);
      _tip.currentState?.ensureTooltipVisible();
    });
  }

  void _up(PointerEvent _) {
    _timer?.cancel();
    if (_held) setState(() => _held = false);
    Tooltip.dismissAllToolTips();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Listener(
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: _up,
      child: Tooltip(
        key: _tip,
        message: widget.message,
        triggerMode: TooltipTriggerMode.manual,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_held)
              Container(
                width: KuberSpace.tapTarget,
                height: KuberSpace.tapTarget,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            widget.child,
          ],
        ),
      ),
    );
  }
}


/// Icon swap: old scales 1 to 0.6 and fades (fx.instant), new 0.6 to 1 on
/// springFast. Subtle / Off: cross-fade.
class _IconSwap extends StatelessWidget {
  const _IconSwap(
      {required this.icon, required this.size, required this.color});
  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final level = KuberMotion.levelOf(context);
    final expressive = level == MotionLevel.expressive;
    return AnimatedSwitcher(
      duration: expressive
          ? KuberMotion.fastCurve.settle
          : (level == MotionLevel.off
              ? KuberMotion.fxInstant
              : KuberMotion.fxFast),
      reverseDuration: KuberMotion.fxInstant,
      switchInCurve: expressive ? KuberMotion.fastCurve : Curves.linear,
      switchOutCurve: Curves.linear,
      transitionBuilder: (child, anim) {
        final fade = FadeTransition(opacity: anim, child: child);
        if (!expressive) return fade;
        return ScaleTransition(
            scale: anim.drive(Tween(begin: 0.6, end: 1.0)), child: fade);
      },
      child: Icon(icon, key: ValueKey(icon), size: size, color: color),
    );
  }
}
