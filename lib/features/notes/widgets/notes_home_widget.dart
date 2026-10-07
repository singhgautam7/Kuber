import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../../pro/feature_gates/gate_sheet_notes_limit.dart';
import '../../pro/paywall/pro_state.dart';
import '../data/notes_repository.dart';
import '../providers/notes_provider.dart';

/// Home tab widget for Kuber Notes (screens 1j latest-note preview / 1n
/// empty state). Registered in the home widget editor as
/// `kuber_notes_widget`.
class NotesHomeWidget extends ConsumerWidget {
  const NotesHomeWidget({super.key});

  void _addNote(BuildContext context, WidgetRef ref) {
    // Free tier keeps at most 2 notes; the 3rd triggers the Pro gate. Pro and
    // trial users are unlimited.
    final unlimited = ref.read(kuberProStateProvider).hasProAccess;
    final count = ref.read(notesStreamProvider).valueOrNull?.length ?? 0;
    if (!unlimited && count >= 2) {
      showNotesLimitGateSheet(context);
      return;
    }
    // Lazy new note — persisted only on first edit (see NoteEditorScreen).
    context.push('/notes/editor?id=new');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final notesAsync = ref.watch(notesStreamProvider);
    final notes = notesAsync.valueOrNull;
    if (notes == null) return const SizedBox.shrink();

    final sorted = List.of(notes)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final latest = sorted.firstOrNull;

    final theme = Theme.of(context);
    // Board 3.2a: latest note + View all (outlined) and New note (tonal).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberHomeWidgetTitle(
          title: 'Kuber Notes',
          trailing: latest == null
              ? null
              : Text(
                  notes.length == 1 ? '1 note' : '${notes.length} notes',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
        ),
        KuberCard(
          child: latest == null
              ? _EmptyBody(onAdd: () => _addNote(context, ref))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          context.push('/notes/editor?id=${latest.id}'),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const KuberIconTile(
                            icon: Icons.sticky_note_2_outlined,
                          ),
                          const SizedBox(width: KuberSpace.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sentenceCase('LATEST'),
                                  style: theme.textTheme.bodySmall!.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  latest.title.isEmpty
                                      ? 'Untitled note'
                                      : latest.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    color: cs.onSurface,
                                  ),
                                ),
                                Text(
                                  notePlainText(
                                    latest,
                                  ).replaceAll('\n', ' · ').trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: KuberSpace.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'View notes',
                            icon: Icons.visibility_outlined,
                            type: AppButtonType.outline,
                            height: 40,
                            fullWidth: true,
                            onPressed: () => context.push('/more/notes'),
                          ),
                        ),
                        const SizedBox(width: KuberSpace.sm),
                        Expanded(
                          child: AppButton(
                            label: 'Add a note',
                            icon: Icons.add_rounded,
                            height: 40,
                            fullWidth: true,
                            onPressed: () => _addNote(context, ref),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptyBody extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyBody({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const KuberIconTile(icon: Icons.sticky_note_2_outlined),
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No notes yet',
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    'Jot your first expense, list or quick calculation.',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: KuberSpace.lg),
        AppButton(
          label: 'Add a note',
          icon: Icons.add_rounded,
          height: 40,
          fullWidth: true,
          onPressed: onAdd,
        ),
      ],
    );
  }
}
