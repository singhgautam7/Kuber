import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A reusable bottom sheet shell component.
///
/// Provides a consistent structure: drag handle, header (title + optional
/// subtitle + close button), a thin divider boundary, and a scrollable
/// content area. Follows the same visual language as AccountDetailSheet.
class KuberBottomSheet extends StatelessWidget {
  /// Primary title shown large and bold.
  final String title;

  /// Optional uppercase caption below the title (e.g. category name).
  final String? subtitle;

  /// Optional leading icon Widget in the header.
  final Widget? leadingIcon;

  /// Body content placed inside the scrollable area.
  final Widget child;

  /// Optional actions widget pinned at the bottom.
  final Widget? actions;

  const KuberBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KuberRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // ── Header row ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      if (leadingIcon != null) ...[
                        leadingIcon!,
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: localeFont(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!.toUpperCase(),
                                textAlign: TextAlign.start,
                                style: localeFont(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurfaceVariant,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for close button
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: SizedBox.square(
                        dimension: 40,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.center,
                          constraints: const BoxConstraints.tightFor(
                            width: 40,
                            height: 40,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: cs.surfaceContainerHigh,
                            shape: const CircleBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Boundary divider ─────────────────────────────────────────
            Divider(height: 1, thickness: 0.5, color: cs.outline),

            // ── Scrollable body ──────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: child,
              ),
            ),

            if (actions != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
