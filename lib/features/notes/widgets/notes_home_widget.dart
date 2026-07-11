import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberHomeWidgetTitle(
          title: 'Kuber Notes',
          trailing: latest == null
              ? null
              : Text(
                  notes.length == 1 ? '1 note' : '${notes.length} notes',
                  style: localeFont(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
        ),
        Container(
          padding: EdgeInsets.all(latest == null ? 20 : 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: cs.outline),
          ),
          child: latest == null
              ? _EmptyBody(onAdd: () => _addNote(context, ref))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          context.push('/notes/editor?id=${latest.id}'),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(KuberRadius.md),
                              border: Border.all(
                                  color:
                                      cs.primary.withValues(alpha: 0.28)),
                            ),
                            child: Icon(Icons.sticky_note_2_outlined,
                                size: 17, color: cs.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LATEST',
                                  style: localeFont(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  latest.title.isEmpty
                                      ? 'Untitled note'
                                      : latest.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: localeFont(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  notePlainText(latest)
                                      .replaceAll('\n', ' · ')
                                      .trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: localeFont(
                                    fontSize: 11.5,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _WidgetButton(
                            label: 'View notes',
                            icon: Icons.visibility_outlined,
                            filled: false,
                            onTap: () => context.push('/more/notes'),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _WidgetButton(
                            label: 'Add a note',
                            icon: Icons.add_rounded,
                            filled: true,
                            onTap: () => _addNote(context, ref),
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
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: cs.primary.withValues(alpha: 0.24)),
              ),
              child: Icon(Icons.sticky_note_2_outlined,
                  size: 20, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No notes yet',
                    style: localeFont(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Jot your first expense, list or quick calculation.',
                    style: localeFont(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _WidgetButton(
          label: 'Add a note',
          icon: Icons.add_rounded,
          filled: true,
          height: 44,
          onTap: onAdd,
        ),
      ],
    );
  }
}

class _WidgetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final double height;
  final VoidCallback onTap;

  const _WidgetButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: filled ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: filled ? null : Border.all(color: cs.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 15,
                color: filled ? Colors.white : cs.onSurfaceVariant),
            const SizedBox(width: 7),
            Text(
              label,
              style: localeFont(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
