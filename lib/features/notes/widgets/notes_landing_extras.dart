import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';

/// First-run empty state (screen 1c) with the "Create tutorial note" CTA.
class NotesEmptyState extends StatelessWidget {
  final VoidCallback onViewDemo;

  const NotesEmptyState({super.key, required this.onViewDemo});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(KuberRadius.xl),
                border:
                    Border.all(color: cs.primary.withValues(alpha: 0.22)),
              ),
              child: Icon(Icons.sticky_note_2_outlined,
                  size: 46, color: cs.primary),
            ),
            const SizedBox(height: 22),
            Text(
              'No notes yet',
              style: localeFont(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first note, or create a tutorial note to '
              'see how quick math and tap-to-convert work.',
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onViewDemo,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: Text(
                  'Create tutorial note',
                  style: localeFont(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom bulk-action bar shown in multi-select mode.
class NotesSelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback onCategory;

  const NotesSelectionBar({
    super.key,
    required this.count,
    required this.onDelete,
    required this.onPin,
    required this.onCategory,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$count selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Icon-only so all three actions (incl. Delete) always fit.
              _SelectionAction(
                icon: Icons.push_pin_outlined,
                label: 'Pin',
                onTap: onPin,
              ),
              const SizedBox(width: 8),
              _SelectionAction(
                icon: Icons.category_outlined,
                label: 'Category',
                onTap: onCategory,
              ),
              const SizedBox(width: 8),
              _SelectionAction(
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                destructive: true,
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _SelectionAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = destructive ? cs.error : cs.onSurface;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(
              color: destructive
                  ? cs.error.withValues(alpha: 0.5)
                  : cs.outline,
            ),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
