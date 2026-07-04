import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/locale_font.dart';
import '../../categories/providers/category_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../data/kuber_note.dart';
import '../data/notes_repository.dart';
import '../utils/note_format.dart';

/// List-view note card (screen 1a): pinned icon + one-line bold title +
/// two-line muted preview + relative date / category chip / tag chip /
/// read-only chip row.
class NoteListCard extends ConsumerWidget {
  final KuberNote note;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteListCard({
    super.key,
    required this.note,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final preview = notePlainText(note).replaceAll('\n', ' ').trim();

    final category = ref.watch(categoryListProvider.select(
      (async) => async.valueOrNull
          ?.firstWhereOrNull((c) => c.id.toString() == note.categoryId),
    ));
    final allTags = ref.watch(tagListProvider).valueOrNull ?? [];
    final firstTag = allTags
        .firstWhereOrNull((t) => note.tagIds.contains(t.id.toString()));

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: selected ? cs.primary : cs.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (selectionMode) ...[
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                ],
                if (note.pinned) ...[
                  Icon(Icons.push_pin_rounded, size: 13, color: cs.primary),
                  const SizedBox(width: 7),
                ],
                Expanded(
                  child: Text(
                    note.title.isEmpty ? 'Untitled note' : note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                if (note.isReadOnly)
                  Icon(Icons.lock_outline_rounded,
                      size: 13, color: cs.onSurfaceVariant),
              ],
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: localeFont(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 9),
            Row(
              children: [
                Text(
                  noteRelativeTime(note.updatedAt),
                  style: localeFont(
                    fontSize: 11,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                if (category != null || firstTag != null || note.isReadOnly)
                  Container(
                    width: 3,
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: cs.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (category != null) ...[
                  _Chip(
                    label: category.name,
                    color: harmonizeCategory(
                        context, Color(category.colorValue)),
                    tinted: true,
                  ),
                  const SizedBox(width: 6),
                ],
                if (firstTag != null) ...[
                  _Chip(label: '#${firstTag.name}', color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                ],
                if (note.isReadOnly)
                  _Chip(label: 'Read-only', color: cs.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid-view note card (screen 1b): title + preview + a compact meta row
/// (relative time, category and first tag) like the list card.
class NoteGridCard extends ConsumerWidget {
  final KuberNote note;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NoteGridCard({
    super.key,
    required this.note,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final preview = notePlainText(note).trim();
    final category = ref.watch(categoryListProvider.select(
      (async) => async.valueOrNull
          ?.firstWhereOrNull((c) => c.id.toString() == note.categoryId),
    ));
    final allTags = ref.watch(tagListProvider).valueOrNull ?? [];
    final firstTag = allTags
        .firstWhereOrNull((t) => note.tagIds.contains(t.id.toString()));

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: selected ? cs.primary : cs.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (selectionMode) ...[
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 15,
                    color: selected ? cs.primary : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                ],
                if (note.pinned) ...[
                  Icon(Icons.push_pin_rounded, size: 11, color: cs.primary),
                  const SizedBox(width: 5),
                ],
                Expanded(
                  child: Text(
                    note.title.isEmpty ? 'Untitled note' : note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  preview,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              ),
            ] else
              const Spacer(),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  noteRelativeTime(note.updatedAt),
                  style: localeFont(
                    fontSize: 10,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                if (category != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: _Chip(
                      label: category.name,
                      color: harmonizeCategory(
                          context, Color(category.colorValue)),
                      tinted: true,
                    ),
                  ),
                ] else if (firstTag != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: _Chip(
                        label: '#${firstTag.name}',
                        color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool tinted;

  const _Chip({required this.label, required this.color, this.tinted = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: tinted ? color.withValues(alpha: 0.12) : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.sm),
        border: tinted ? null : Border.all(color: cs.outline),
      ),
      child: Text(
        label,
        style: localeFont(
          fontSize: 10,
          fontWeight: tinted ? FontWeight.w600 : FontWeight.w400,
          color: tinted ? color : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
