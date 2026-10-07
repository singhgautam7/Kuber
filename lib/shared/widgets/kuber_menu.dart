import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// One row of [showKuberMenu], or a divider.
@immutable
class KuberMenuEntry<T> {
  const KuberMenuEntry({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
    this.destructive = false,
    this.selected = false,
  })  : divider = false,
        header = false;

  const KuberMenuEntry.divider()
      : value = null,
        label = '',
        icon = null,
        subtitle = null,
        destructive = false,
        selected = false,
        divider = true,
        header = false;

  /// Non-tappable caps label that names the group of rows below it.
  const KuberMenuEntry.header(this.label)
      : value = null,
        icon = null,
        subtitle = null,
        destructive = false,
        selected = false,
        divider = false,
        header = true;

  final T? value;
  final String label;
  final IconData? icon;
  final String? subtitle;
  final bool destructive;

  /// secondaryContainer row + trailing check.
  final bool selected;
  final bool divider;
  final bool header;
}

/// The anchored overflow menu (components/overflow-menu.md, board 2e):
/// surfaceContainer, radius 20, 1dp outlineVariant, no shadow, padding 8, min
/// width 200; rows min 48, radius 12, icon 20 + gap 12, labelLarge with an
/// optional bodySmall line.
///
/// Copied from PostPurush `core/widgets/app_menu.dart` (anchoring to the
/// control that raised it) and restyled to the spec.
Future<T?> showKuberMenu<T>({
  required BuildContext context,
  required List<KuberMenuEntry<T>> entries,
  double minWidth = 200,
}) {
  final cs = Theme.of(context).colorScheme;
  final button = context.findRenderObject()! as RenderBox;
  final overlay = Navigator.of(context, rootNavigator: true)
      .overlay!
      .context
      .findRenderObject()! as RenderBox;
  final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
  final bottomRight =
      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay);

  // Opens below the anchor; when that would run off the bottom (a sheet's
  // action row), it opens above instead of sliding up over the anchor. The
  // height is estimated from the row metrics below.
  final menuHeight = 2 * KuberSpace.sm + 2 +
      entries.fold<double>(
        0,
        (h, e) => h +
            (e.divider
                ? 17
                : e.header
                    ? 32
                    : e.subtitle != null
                        ? 60
                        : KuberSpace.tapTarget),
      );
  final bottomLimit = overlay.size.height -
      MediaQuery.viewPaddingOf(context).bottom -
      KuberSpace.sm;
  final above = bottomRight.dy + KuberSpace.xs + menuHeight > bottomLimit &&
      topLeft.dy - KuberSpace.xs - menuHeight > 0;
  final top = above
      ? topLeft.dy - KuberSpace.xs - menuHeight
      : bottomRight.dy + KuberSpace.xs;

  return showMenu<T>(
    context: context,
    useRootNavigator: true,
    position: RelativeRect.fromLTRB(
      topLeft.dx,
      top,
      overlay.size.width - bottomRight.dx,
      overlay.size.height - top,
    ),
    color: cs.surfaceContainer,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    menuPadding: const EdgeInsets.all(KuberSpace.sm),
    shape: RoundedRectangleBorder(
      borderRadius: KuberShape.cardR,
      side: BorderSide(color: cs.outlineVariant),
    ),
    constraints: BoxConstraints(minWidth: minWidth, maxWidth: 320),
    items: [
      for (final e in entries)
        if (e.divider)
          PopupMenuItem<T>(
            enabled: false,
            height: 17,
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.md, vertical: KuberSpace.sm),
              child: Divider(color: cs.outlineVariant, height: 1),
            ),
          )
        else if (e.header)
          PopupMenuItem<T>(
            enabled: false,
            height: 32,
            padding: const EdgeInsets.fromLTRB(
                KuberSpace.md, KuberSpace.sm, KuberSpace.md, KuberSpace.xs),
            child: Text(
              e.label.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    letterSpacing: 0.8,
                    color: cs.onSurfaceVariant,
                  ),
            ),
          )
        else
          PopupMenuItem<T>(
            value: e.value,
            height: 0,
            padding: EdgeInsets.zero,
            child: _MenuRow<T>(entry: e),
          ),
    ],
  );
}

class _MenuRow<T> extends StatelessWidget {
  const _MenuRow({required this.entry});

  final KuberMenuEntry<T> entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = entry.destructive
        ? cs.error
        : (entry.selected ? cs.onSecondaryContainer : cs.onSurface);
    final iconColor = entry.destructive
        ? cs.error
        : (entry.selected ? cs.onSecondaryContainer : cs.onSurfaceVariant);
    return Container(
      constraints: const BoxConstraints(minHeight: KuberSpace.tapTarget),
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.md),
      decoration: BoxDecoration(
        color: entry.selected ? cs.secondaryContainer : Colors.transparent,
        borderRadius: KuberShape.mediumR,
      ),
      child: Row(
        children: [
          if (entry.icon != null) ...[
            Icon(entry.icon, size: 20, color: iconColor),
            const SizedBox(width: KuberSpace.md),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: KuberSpace.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.label,
                      style: theme.textTheme.labelLarge!.copyWith(color: fg)),
                  if (entry.subtitle != null)
                    Text(
                      entry.subtitle!,
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
          if (entry.selected) ...[
            const SizedBox(width: KuberSpace.md),
            Icon(Icons.check_rounded, size: 20, color: cs.onSecondaryContainer),
          ],
        ],
      ),
    );
  }
}
