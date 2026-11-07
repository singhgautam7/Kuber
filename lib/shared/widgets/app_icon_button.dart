import 'dart:async';

import 'package:flutter/material.dart';

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

    Widget button = SizedBox(
      width: target,
      height: target,
      child: Center(
        child: Opacity(
          opacity: disabled ? 0.38 : 1,
          child: Material(
            color: bg,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              onLongPress: onLongPress,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(icon, size: glyphSize, color: tint ?? fg),
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
