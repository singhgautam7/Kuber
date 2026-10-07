import 'package:flutter/material.dart';

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

  /// Stadium corners, like the app's other pill buttons (History Exp / Inc).
  final bool pill;

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
    this.pill = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    final lead = selected && showCheck && onDeleted == null && !dropdown
        ? Icon(Icons.check_rounded, size: 18, color: cs.onSecondaryContainer)
        : (icon == null
            ? null
            : Icon(icon,
                size: 18,
                color: iconColor ??
                    (selected ? cs.onSecondaryContainer : cs.primary)));
    final hasTrail = dropdown || onDeleted != null;

    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.labelLarge!.copyWith(color: fg),
    );

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? cs.secondaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: pill ? KuberShape.fullR : KuberShape.smallR,
          side: selected
              ? BorderSide.none
              : BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 32,
            padding: EdgeInsets.only(
              left: lead != null ? 8 : 16,
              right: hasTrail ? 8 : 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                          .copyWith(color: cs.onSecondaryContainer),
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
          ),
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
