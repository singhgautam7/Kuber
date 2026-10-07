import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_icon_button.dart';

/// The shell for every bottom sheet (components/bottom-sheets.md, board 2f).
///
/// surfaceContainerLow, top radius 28, a 32x4 handle in a 24 band; header
/// padding L20 R16 B12 with an optional 48 leading, a caps overline
/// ([subtitle]), the titleLarge [title], a bodyMedium [description] and the
/// close button; body padding 20 with a divider under the header once the body
/// scrolls; pinned [actions] padded 16 / 20 / 24.
///
/// Structure adapted from Mull `shared/widgets/app_bottom_sheet.dart`.
class KuberBottomSheet extends StatefulWidget {
  /// Primary title (titleLarge).
  final String title;

  /// Optional caps overline above the title (e.g. "Expense", category name).
  final String? subtitle;

  /// Optional one-line bodyMedium under the title.
  final String? description;

  /// Optional leading widget in the header (48 tile).
  final Widget? leadingIcon;

  /// Body content placed inside the scrollable area.
  final Widget child;

  /// Optional actions widget pinned at the bottom.
  final Widget? actions;

  const KuberBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.leadingIcon,
    required this.child,
    this.actions,
  });

  @override
  State<KuberBottomSheet> createState() => _KuberBottomSheetState();
}

class _KuberBottomSheetState extends State<KuberBottomSheet> {
  final ValueNotifier<bool> _scrolled = ValueNotifier(false);

  @override
  void dispose() {
    _scrolled.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      _scrolled.value = n.metrics.pixels > 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: KuberShape.sheetR,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 24,
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: KuberShape.fullR,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
              child: Row(
                children: [
                  if (widget.leadingIcon != null) ...[
                    widget.leadingIcon!,
                    const SizedBox(width: KuberSpace.lg),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium!.copyWith(
                              letterSpacing: 0.8,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge!
                              .copyWith(color: cs.onSurface),
                        ),
                        if (widget.description != null)
                          Text(
                            widget.description!,
                            style: theme.textTheme.bodyMedium!
                                .copyWith(color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KuberSpace.sm),
                  AppIconButton(
                    icon: Icons.close_rounded,
                    semanticLabel: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _scrolled,
              builder: (context, scrolled, _) => Divider(
                height: 1,
                thickness: 1,
                color: scrolled ? cs.outlineVariant : Colors.transparent,
              ),
            ),
            Flexible(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: widget.child,
                ),
              ),
            ),
            if (widget.actions != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: widget.actions!,
              ),
          ],
        ),
      ),
    );
  }
}
