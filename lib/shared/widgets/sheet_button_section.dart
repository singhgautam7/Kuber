import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_button.dart';
import 'kuber_menu.dart';

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

/// The unified button area for the view sheets (board 2f): 56 pill buttons,
/// 12 apart; Edit tonal, Delete danger tonal.
///
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
        EdgeInsets.only(top: KuberSpace.xl, bottom: KuberSpace.lg + navInset);

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
            const SizedBox(height: KuberSpace.md),
          if (visible.isNotEmpty || overflow.isNotEmpty)
            Row(
              children: [
                for (var i = 0; i < visible.length; i++) ...[
                  if (i > 0) const SizedBox(width: KuberSpace.md),
                  Expanded(child: _CompactButton(action: visible[i])),
                ],
                if (overflow.isNotEmpty) ...[
                  const SizedBox(width: KuberSpace.md),
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
    // Two buttons beside the overflow are ~150 wide: a long label ("Add
    // payment", "Mark settled") drops its icon and tightens the side
    // padding to 16 instead of truncating.
    return LayoutBuilder(
      builder: (context, constraints) {
        final label = TextPainter(
          text: TextSpan(
            text: action.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        // 24 + 24 side padding, 20 icon + 8 gap.
        final fitsIcon = label.width + 48 + 28 <= constraints.maxWidth;
        label.dispose();
        return AppButton(
          label: action.label,
          icon: fitsIcon ? action.icon : null,
          horizontalPadding: fitsIcon ? null : 16,
          type: action.destructive
              ? AppButtonType.danger
              : AppButtonType.normal,
          fullWidth: true,
          onPressed: action.onPressed,
        );
      },
    );
  }
}

class _OverflowButton extends StatelessWidget {
  final List<SheetAction> actions;
  final ColorScheme cs;
  const _OverflowButton({required this.actions, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (anchor) => SizedBox(
        width: 56,
        height: 56,
        child: Material(
          color: cs.surfaceContainerHigh,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              final i = await showKuberMenu<int>(
                context: anchor,
                entries: [
                  for (var i = 0; i < actions.length; i++)
                    KuberMenuEntry(
                      value: i,
                      label: actions[i].label,
                      icon: actions[i].icon,
                      destructive: actions[i].destructive,
                    ),
                ],
              );
              if (i != null) actions[i].onPressed?.call();
            },
            child: Icon(Icons.more_horiz_rounded,
                size: 24, color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
