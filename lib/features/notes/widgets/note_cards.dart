import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../categories/providers/category_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../data/kuber_note.dart';
import '../data/notes_repository.dart';
import '../utils/note_format.dart';

final _numberRe = RegExp(r'\d(?:[\d,]*\d)?(?:\.\d+)?');

/// Preview text with numbers tinted primary (board 3.23) so quick math reads
/// at a glance.
TextSpan _previewSpan(String text, TextStyle base, Color numberColor) {
  final spans = <TextSpan>[];
  var last = 0;
  for (final m in _numberRe.allMatches(text)) {
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start)));
    }
    spans.add(
      TextSpan(
        text: m.group(0),
        style: TextStyle(color: numberColor, fontWeight: FontWeight.w600),
      ),
    );
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return TextSpan(style: base, children: spans);
}

/// Title line shared by list rows and grid cards: selection circle, pin,
/// title, lock.
class _NoteTitle extends StatelessWidget {
  final KuberNote note;
  final bool selectionMode;
  final bool selected;
  final TextStyle style;

  const _NoteTitle({
    required this.note,
    required this.selectionMode,
    required this.selected,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onSecondaryContainer : cs.onSurface;
    return Row(
      children: [
        if (selectionMode) ...[
          Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
          const SizedBox(width: KuberSpace.md),
        ],
        if (note.pinned) ...[
          Icon(Icons.push_pin_rounded, size: 14, color: fg),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            note.title.isEmpty ? 'Untitled note' : note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(color: fg),
          ),
        ),
      ],
    );
  }
}

/// Date + category pill + tag / read-only pills.
class _NoteMeta extends ConsumerWidget {
  final KuberNote note;
  final bool compact;

  const _NoteMeta({required this.note, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final category = ref.watch(
      categoryListProvider.select(
        (async) => async.valueOrNull?.firstWhereOrNull(
          (c) => c.id.toString() == note.categoryId,
        ),
      ),
    );
    final allTags = ref.watch(tagListProvider).valueOrNull ?? [];
    final firstTag = allTags.firstWhereOrNull(
      (t) => note.tagIds.contains(t.id.toString()),
    );

    Widget pill(String label, Color bg, Color fg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(color: bg, borderRadius: KuberShape.fullR),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tt.labelSmall!.copyWith(color: fg),
      ),
    );

    final pills = <Widget>[
      if (category != null)
        () {
          final t = categoryTones(context, Color(category.colorValue));
          return pill(category.name, t.container, t.fg);
        }(),
      if (firstTag != null && (!compact || category == null))
        pill('#${firstTag.name}', cs.surfaceContainerHigh, cs.onSurfaceVariant),
      if (note.isReadOnly && !compact)
        pill('Read-only', cs.surfaceContainerHigh, cs.onSurfaceVariant),
    ];

    return Row(
      children: [
        Text(
          noteRelativeTime(note.updatedAt),
          style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
        for (final p in pills) ...[
          const SizedBox(width: KuberSpace.sm),
          Flexible(child: p),
        ],
      ],
    );
  }
}

/// List-view note row (board 3.23): pin + title, two-line preview with
/// tinted numbers, date + pills. Lives inside a [KuberGroup]; selected rows
/// fill secondaryContainer.
class NoteListCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final preview = notePlainText(note).replaceAll('\n', ' ').trim();
    final inset = selectionMode ? 20.0 + KuberSpace.md : 0.0;

    return Material(
      color: selected ? cs.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NoteTitle(
                note: note,
                selectionMode: selectionMode,
                selected: selected,
                style: tt.titleMedium!,
              ),
              Padding(
                padding: EdgeInsets.only(left: inset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text.rich(
                        _previewSpan(
                          preview,
                          tt.bodyMedium!.copyWith(
                            color: selected
                                ? cs.onSecondaryContainer
                                : cs.onSurfaceVariant,
                          ),
                          cs.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    _NoteMeta(note: note),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid-view note card (board 3.23): title, preview with tinted numbers,
/// date + one pill at the bottom.
class NoteGridCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final preview = notePlainText(note).trim();

    return Material(
      color: selected ? cs.secondaryContainer : cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.cardR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(KuberSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NoteTitle(
                note: note,
                selectionMode: selectionMode,
                selected: selected,
                style: tt.titleSmall!,
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text.rich(
                  _previewSpan(
                    preview,
                    tt.bodySmall!.copyWith(
                      color: selected
                          ? cs.onSecondaryContainer
                          : cs.onSurfaceVariant,
                    ),
                    cs.primary,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: KuberSpace.sm),
              _NoteMeta(note: note, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}
