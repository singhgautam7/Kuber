import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/locale_font.dart';
import 'app_button.dart';

/// A single action in a [SheetButtonSection].
class SheetAction {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  /// Renders red: an [AppButtonType.danger] button in the action row, or
  /// error-tinted text in the overflow menu. Use for the destructive action
  /// (Delete).
  final bool destructive;

  const SheetAction({
    required this.label,
    required this.icon,
    this.onPressed,
    this.destructive = false,
  });
}

/// The unified button area for the redesigned view sheets:
///
///  1. An optional full-width filled [primary] [AppButton].
///  2. An [actions] row of up to three compact [AppButton]s. When there are
///     more than three actions, the row shows the first two plus an overflow
///     (⋯) button that opens a popup menu of the rest. The destructive action
///     is an [AppButtonType.danger] button in the row (error-tinted in the
///     menu).
///
/// The whole section is kept to at most two rows.
class SheetButtonSection extends StatelessWidget {
  final SheetAction? primary;
  final List<SheetAction> actions;

  /// Overrides the section padding. Pass [EdgeInsets.zero] when the section is
  /// the pinned `actions` of a [KuberBottomSheet] (which already provides its
  /// own padding and SafeArea). Defaults to `top: 24, bottom: 16 + nav-bar
  /// inset` for in-flow use.
  final EdgeInsets? padding;

  const SheetButtonSection({
    super.key,
    this.primary,
    this.actions = const [],
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final navInset = MediaQuery.of(context).viewPadding.bottom;
    final pad = padding ??
        EdgeInsets.only(top: KuberSpacing.xl, bottom: KuberSpacing.lg + navInset);

    // Decide visible vs. overflow actions.
    final List<SheetAction> visible;
    final List<SheetAction> overflow;
    if (actions.length <= 3) {
      visible = actions;
      overflow = const [];
    } else {
      visible = actions.take(2).toList();
      overflow = actions.skip(2).toList();
    }

    return Padding(
      padding: pad,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (primary != null)
            AppButton(
              label: primary!.label,
              icon: primary!.icon,
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: primary!.onPressed,
            ),
          if (primary != null && (visible.isNotEmpty || overflow.isNotEmpty))
            const SizedBox(height: 11),
          if (visible.isNotEmpty || overflow.isNotEmpty)
            Row(
              children: [
                for (var i = 0; i < visible.length; i++) ...[
                  if (i > 0) const SizedBox(width: 11),
                  Expanded(child: _CompactButton(action: visible[i])),
                ],
                if (overflow.isNotEmpty) ...[
                  const SizedBox(width: 11),
                  _OverflowButton(actions: overflow, cs: cs),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _CompactButton extends StatelessWidget {
  final SheetAction action;
  const _CompactButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: action.label,
      icon: action.icon,
      type: action.destructive ? AppButtonType.danger : AppButtonType.normal,
      height: 46,
      fullWidth: true,
      onPressed: action.onPressed,
    );
  }
}

class _OverflowButton extends StatelessWidget {
  final List<SheetAction> actions;
  final ColorScheme cs;
  const _OverflowButton({required this.actions, required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 46,
      child: PopupMenuButton<int>(
        tooltip: '',
        position: PopupMenuPosition.over,
        color: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: BorderSide(color: cs.outline),
        ),
        onSelected: (i) => actions[i].onPressed?.call(),
        itemBuilder: (context) => [
          for (var i = 0; i < actions.length; i++)
            PopupMenuItem<int>(
              value: i,
              child: Row(
                children: [
                  Icon(
                    actions[i].icon,
                    size: 16,
                    color: actions[i].destructive ? cs.error : cs.onSurface,
                  ),
                  const SizedBox(width: 11),
                  Text(
                    actions[i].label,
                    style: localeFont(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: actions[i].destructive ? cs.error : cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
        ],
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.more_horiz_rounded, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
