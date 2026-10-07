import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_menu.dart';
import '../../categories/data/category.dart';
import '../../tags/data/tag.dart';

/// Note editor header (board 3.23): back, the quiet save-status pill in the
/// title slot (Draft / Saving... / Saved), read-only lock and overflow.
class NoteEditorTopBar extends StatelessWidget {
  final bool saving;

  /// False for a brand-new note that hasn't been written to the DB yet — the
  /// status reads "Draft" rather than "Saved".
  final bool persisted;
  final bool readOnly;
  final VoidCallback onToggleReadOnly;
  final VoidCallback onShare;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const NoteEditorTopBar({
    super.key,
    required this.saving,
    required this.persisted,
    required this.readOnly,
    required this.onToggleReadOnly,
    required this.onShare,
    required this.onDuplicate,
    required this.onDelete,
  });

  Future<void> _openMenu(BuildContext anchor) async {
    final v = await showKuberMenu<String>(
      context: anchor,
      entries: [
        KuberMenuEntry(
          value: 'readonly',
          icon: readOnly ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
          label: readOnly ? 'Turn off read-only' : 'Turn on read-only',
        ),
        const KuberMenuEntry(
          value: 'share',
          icon: Icons.share_outlined,
          label: 'Share',
        ),
        const KuberMenuEntry(
          value: 'duplicate',
          icon: Icons.copy_outlined,
          label: 'Duplicate',
        ),
        const KuberMenuEntry.divider(),
        const KuberMenuEntry(
          value: 'delete',
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          destructive: true,
        ),
      ],
    );
    switch (v) {
      case 'readonly':
        onToggleReadOnly();
      case 'share':
        onShare();
      case 'duplicate':
        onDuplicate();
      case 'delete':
        onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = !persisted
        ? 'Draft'
        : saving
        ? 'Saving...'
        : 'Saved';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            semanticLabel: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: KuberShape.fullR,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  !persisted
                      ? Icons.edit_note_rounded
                      : saving
                      ? Icons.schedule_rounded
                      : Icons.check_rounded,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Spacer(),
          AppIconButton(
            icon: readOnly ? Icons.lock_rounded : Icons.lock_open_rounded,
            kind: readOnly
                ? AppIconButtonKind.filled
                : AppIconButtonKind.standard,
            semanticLabel: readOnly
                ? 'Turn off read-only'
                : 'Turn on read-only',
            onPressed: onToggleReadOnly,
          ),
          const SizedBox(width: KuberSpace.sm),
          Builder(
            builder: (anchor) => AppIconButton(
              icon: Icons.more_vert_rounded,
              semanticLabel: 'More options',
              onPressed: () => _openMenu(anchor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category chip + tag chips + "+ Tag" (board 3.23). In read-only mode the
/// chips dim and lose their tap targets; "+ Tag" disappears.
class NoteMetadataRow extends StatelessWidget {
  final Category? category;
  final List<Tag> tags;
  final bool readOnly;
  final VoidCallback onCategoryTap;
  final VoidCallback onTagTap;

  const NoteMetadataRow({
    super.key,
    required this.category,
    required this.tags,
    required this.readOnly,
    required this.onCategoryTap,
    required this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: readOnly ? 0.6 : 1,
      child: Wrap(
        spacing: KuberSpace.sm,
        runSpacing: KuberSpace.sm,
        children: [
          KuberChip(
            label: category?.name ?? 'Category',
            icon: category != null
                ? IconMapper.fromString(category!.icon)
                : Icons.category_outlined,
            onTap: readOnly ? null : onCategoryTap,
          ),
          for (final tag in tags)
            KuberChip(label: '#${tag.name}', onTap: readOnly ? null : onTagTap),
          if (!readOnly)
            KuberChip(label: 'Tag', icon: Icons.add_rounded, onTap: onTagTap),
        ],
      ),
    );
  }
}
