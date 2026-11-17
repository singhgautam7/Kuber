import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';
import 'kuber_menu.dart';

/// M3 chip (components/controls.md): h32, radius 8. Unselected = 1dp
/// outlineVariant; selected = secondaryContainer (+ an 18 check unless
/// [showCheck] is false). Optional leading [icon], trailing close ([onDeleted])
/// or drop-down arrow ([dropdown]), and a count [badge].
class KuberChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool showCheck;
  final IconData? icon;
  final Color? iconColor;
  final bool dropdown;
  final String? badge;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  /// Let the label ellipsize inside a flexible row.
  final bool shrink;

  /// Tighter side padding (12 instead of 16) for small quick filters
  /// (History Exp / Inc, amount presets).
  final bool compact;

  /// Selected on primary / onPrimary instead of secondaryContainer (tag
  /// picker, where selection is the whole point of the sheet).
  final bool emphasis;

  /// Label at 38 % for an option that can't be picked (a disabled tag); the
  /// tap still fires so the caller can explain why.
  final bool dimmed;

  const KuberChip({
    super.key,
    required this.label,
    this.selected = false,
    this.showCheck = true,
    this.icon,
    this.iconColor,
    this.dropdown = false,
    this.badge,
    this.onTap,
    this.onDeleted,
    this.shrink = false,
    this.compact = false,
    this.emphasis = false,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onSel = emphasis ? cs.onPrimary : cs.onSecondaryContainer;
    final base = selected ? onSel : cs.onSurfaceVariant;
    final fg = dimmed ? base.withValues(alpha: 0.38) : base;
    final level = KuberMotion.levelOf(context);
    final checkable = showCheck && onDeleted == null && !dropdown;
    // No own icon: the check grows 0 to 18 dp (springStandard) and the chip
    // widens. With an icon the check replaces it as before.
    final animCheck = checkable && icon == null;
    final lead = selected && checkable && icon != null
        ? Icon(Icons.check_rounded, size: 18, color: onSel)
        : (icon == null
            ? null
            : Icon(icon,
                size: 18,
                color: iconColor ??
                    (selected ? onSel : cs.primary)));
    final hasTrail = dropdown || onDeleted != null;

    final style = theme.textTheme.labelLarge!.copyWith(color: fg);
    final text = AnimatedWeight(
      label,
      isActive: selected,
      rest: 500,
      active: 650,
      style: style,
    );
    final curve = KuberMotion.spatialCurve(level, KuberMotion.standardCurve);
    final off = level == MotionLevel.off;
    final fade = off ? KuberMotion.fxInstant : KuberMotion.fxFast;
    final pad = compact ? 12.0 : 16.0;

    Widget body(double k) => Container(
          constraints: const BoxConstraints(minHeight: 32),
          padding: EdgeInsets.only(
            left: animCheck ? pad - 8 * k : (lead != null ? 8 : pad),
            right: hasTrail ? 8 : pad,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (animCheck)
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: k,
                    child: Opacity(
                      opacity: k,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.check_rounded,
                            size: 18, color: onSel),
                      ),
                    ),
                  ),
                ),
              if (lead != null) ...[lead, const SizedBox(width: 8)],
              shrink ? Flexible(child: text) : text,
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: KuberShape.fullR,
                  ),
                  child: Text(
                    badge!,
                    style: theme.textTheme.labelSmall!
                        .copyWith(color: onSel),
                  ),
                ),
              ],
              if (dropdown) ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_drop_down_rounded, size: 18, color: fg),
              ],
              if (onDeleted != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDeleted,
                  behavior: HitTestBehavior.opaque,
                  child: Icon(Icons.close_rounded, size: 18, color: fg),
                ),
              ],
            ],
          ),
        );

    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        kind: PressKind.chip,
        enabled: onTap != null,
        // The shape follows selection, not the press: unselected chips are
        // full pills, the selected one is a 12 dp squircle (the same rule as
        // the button groups). Press keeps the scale only.
        morphCorners: false,
        builder: (context, _, _) => TweenAnimationBuilder<double>(
          tween: Tween(end: selected ? 1 : 0),
          duration: off ? Duration.zero : KuberMotion.spatialCurve(level, KuberMotion.fastCurve).settle,
          curve: KuberMotion.spatialCurve(level, KuberMotion.fastCurve).clamped,
          builder: (context, sq, child) => TweenAnimationBuilder<Color?>(
          tween: ColorTween(
              end: selected
                  ? (emphasis ? cs.primary : cs.secondaryContainer)
                  : Colors.transparent),
          duration: fade,
          curve: KuberMotion.curveEffects,
          builder: (context, fill, child) => Material(
            color: fill,
            animationDuration: Duration.zero,
            shape: _chipShape(sq, cs.outlineVariant, selected),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap == null
                  ? null
                  : () {
                      if (!dropdown && onDeleted == null) KuberHaptics.tick();
                      onTap!();
                    },
              child: child,
            ),
          ),
          child: child,
          ),
          child: animCheck
              ? TweenAnimationBuilder<double>(
                  tween: Tween(end: selected ? 1 : 0),
                  duration: off ? Duration.zero : curve.settle,
                  curve: curve.clamped,
                  builder: (context, k, _) => body(k),
                )
              : body(0),
        ),
      ),
    );
  }
}

/// One option of a [KuberDropdownChip].
class KuberDropdownOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  const KuberDropdownOption(this.value, this.label, {this.subtitle, this.icon});
}

/// A dropdown chip that opens an anchored menu (feedback round 1: chart
/// period, Analytics type). Selected while its menu is open.
class KuberDropdownChip<T> extends StatefulWidget {
  final T value;
  final List<KuberDropdownOption<T>> options;
  final ValueChanged<T> onChanged;

  /// Overrides the chip label (defaults to the selected option's label).
  final String? label;
  final IconData? icon;
  final bool shrink;

  const KuberDropdownChip({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
    this.icon,
    this.shrink = false,
  });

  @override
  State<KuberDropdownChip<T>> createState() => _KuberDropdownChipState<T>();
}

class _KuberDropdownChipState<T> extends State<KuberDropdownChip<T>> {
  bool _open = false;

  Future<void> _show(BuildContext anchor) async {
    setState(() => _open = true);
    final picked = await showKuberMenu<T>(
      context: anchor,
      minWidth: 184,
      entries: [
        for (final o in widget.options)
          KuberMenuEntry<T>(
            value: o.value,
            label: o.label,
            subtitle: o.subtitle,
            icon: o.icon,
            selected: o.value == widget.value,
          ),
      ],
    );
    if (mounted) setState(() => _open = false);
    if (picked != null && picked != widget.value) widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.options
        .where((o) => o.value == widget.value)
        .map((o) => o.label)
        .firstOrNull;
    return Builder(
      builder: (anchor) => KuberChip(
        label: widget.label ?? current ?? '',
        icon: widget.icon,
        selected: _open,
        dropdown: true,
        shrink: widget.shrink,
        onTap: () => _show(anchor),
      ),
    );
  }
}

/// Unselected: a full pill; selected: a 12 dp squircle; in between the two
/// morph (only while the selection animates).
OutlinedBorder _chipShape(double t, Color outline, bool selected) {
  final pill = StadiumBorder(side: BorderSide(color: outline));
  final squircle = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: selected ? Colors.transparent : outline),
  );
  if (t <= 0) return pill;
  if (t >= 1) return squircle;
  return ShapeBorder.lerp(pill, squircle, t)! as OutlinedBorder;
}
