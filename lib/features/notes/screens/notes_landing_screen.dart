import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/overflow_config.dart';
import '../../../core/services/shortcut_pin_service.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_search_filter_bar.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../pro/feature_gates/gate_sheet_notes_limit.dart';
import '../../pro/paywall/pro_state.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/kuber_note.dart';
import '../providers/notes_provider.dart';
import '../widgets/about_notes_info_sheet.dart';
import '../widgets/note_cards.dart';
import '../widgets/note_dialogs.dart' show showNoteDeleteConfirmDialog;

/// Kuber Notes landing page (board 3.23: list / grid / multi-select / empty).
/// Header with info + overflow (view mode), a summary row with search,
/// filter and sort, grouped Pinned / Others, the New note FAB.
class NotesLandingScreen extends ConsumerStatefulWidget {
  const NotesLandingScreen({super.key});

  @override
  ConsumerState<NotesLandingScreen> createState() => _NotesLandingScreenState();
}

class _NotesLandingScreenState extends ConsumerState<NotesLandingScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // A previous visit may have left multi-select state behind.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(notesSelectionProvider.notifier).state = {};
      ref.read(notesSearchProvider.notifier).state = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _createNote() {
    // Free tier keeps at most 2 notes; creating a 3rd triggers the Pro gate.
    // Pro and trial users are unlimited.
    final unlimited = ref.read(kuberProStateProvider).hasProAccess;
    final count = ref.read(notesStreamProvider).valueOrNull?.length ?? 0;
    if (!unlimited && count >= 2) {
      showNotesLimitGateSheet(context);
      return;
    }
    // id=new → the editor holds the note in memory and only persists it on
    // the first real edit (no blank-note flash when backing out).
    context.push('/notes/editor?id=new');
  }

  Future<void> _openDemoNote() async {
    // Always creates a fresh tutorial note (works even after all notes were
    // deleted).
    final note = await ref.read(notesRepositoryProvider).createTutorialNote();
    if (!mounted) return;
    context.push('/notes/editor?id=${note.id}');
  }

  void _openNote(KuberNote note) {
    final selection = ref.read(notesSelectionProvider);
    if (selection.isNotEmpty) {
      _toggleSelected(note.id);
      return;
    }
    context.push('/notes/editor?id=${note.id}');
  }

  void _toggleSelected(int id) {
    final selection = {...ref.read(notesSelectionProvider)};
    if (!selection.remove(id)) selection.add(id);
    ref.read(notesSelectionProvider.notifier).state = selection;
  }

  Future<void> _bulkDelete() async {
    final selection = ref.read(notesSelectionProvider);
    if (selection.isEmpty) return;
    final confirmed = await showNoteDeleteConfirmDialog(
      context,
      count: selection.length,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(notesRepositoryProvider).deleteMany(selection.toList());
    ref.read(notesSelectionProvider.notifier).state = {};
    if (mounted) showKuberSnackBar(context, 'Notes deleted');
  }

  Future<void> _bulkPin() async {
    final selection = ref.read(notesSelectionProvider);
    if (selection.isEmpty) return;
    final notes = ref.read(visibleNotesProvider);
    final anyUnpinned = notes
        .where((n) => selection.contains(n.id))
        .any((n) => !n.pinned);
    await ref
        .read(notesRepositoryProvider)
        .setPinned(selection.toList(), anyUnpinned);
    ref.read(notesSelectionProvider.notifier).state = {};
  }

  Future<void> _bulkAssignCategory() async {
    final selection = ref.read(notesSelectionProvider);
    if (selection.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: null,
        onSelected: (id) async {
          Navigator.pop(context);
          await ref
              .read(notesRepositoryProvider)
              .setCategory(selection.toList(), id.toString());
          ref.read(notesSelectionProvider.notifier).state = {};
        },
      ),
    );
  }

  static String _sortLabel(NotesSort sort) => switch (sort) {
    NotesSort.modified => 'Modified',
    NotesSort.created => 'Created',
    NotesSort.title => 'Title A-Z',
  };

  PreferredSizeWidget _selectionHeader(ColorScheme cs, int count) {
    return KuberAppBar(
      title: '$count selected',
      showBack: true,
      closeIcon: true,
      background: cs.surfaceContainer,
      onBack: () => ref.read(notesSelectionProvider.notifier).state = {},
      actions: [
        AppIconButton(
          icon: Icons.push_pin_outlined,
          semanticLabel: 'Pin',
          onPressed: _bulkPin,
        ),
        AppIconButton(
          icon: Icons.category_outlined,
          semanticLabel: 'Category',
          onPressed: _bulkAssignCategory,
        ),
        AppIconButton(
          icon: Icons.delete_outline_rounded,
          kind: AppIconButtonKind.danger,
          semanticLabel: 'Delete',
          onPressed: _bulkDelete,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allNotes = ref.watch(notesStreamProvider).valueOrNull;
    final notes = ref.watch(visibleNotesProvider);
    final selection = ref.watch(notesSelectionProvider);
    final selectionMode = selection.isNotEmpty;

    return PopScope(
      // Back button cancels selection mode first (History-tab behaviour).
      canPop: !selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selectionMode) {
          ref.read(notesSelectionProvider.notifier).state = {};
        }
      },
      child: Scaffold(
        floatingActionButton: selectionMode
            ? null
            : KuberExtendedFab(
                icon: Icons.add_rounded,
                label: 'New note',
                onPressed: _createNote,
              ),
        floatingActionButtonLocation: kuberFabLocation,
        backgroundColor: cs.surface,
        // The header scrolls away with the list (no sticky headers); while
        // multi-selecting, the contextual header overlays the top instead.
        body: Stack(
          children: [
            KuberScrollAwayHeader(
              header: KuberAppBar(
                title: 'Kuber Notes',
                showBack: true,
                pinShortcut: const PinShortcutSpec(
                  shortcutId: 'kuber_notes',
                  shortLabel: 'Notes',
                  longLabel: 'Kuber Notes',
                  iconDrawable: 'ic_shortcut_notes',
                  deepLink: 'kuber://app/notes',
                ),
                infoConfig: kAboutNotesInfoConfig,
                search: allNotes == null || allNotes.isEmpty
                    ? null
                    : KuberHeaderSearch(
                        controller: _searchController,
                        hint: 'Search notes',
                        onChanged: (v) =>
                            ref.read(notesSearchProvider.notifier).state = v,
                      ),
                // Sort lives in the overflow, Mull style (review round 3).
                overflowConfig: KuberOverflowConfig(
                  items: [
                    for (final (i, sort) in NotesSort.values.indexed)
                      KuberOverflowItem(
                        icon: switch (sort) {
                          NotesSort.modified => Icons.update_rounded,
                          NotesSort.created => Icons.event_note_rounded,
                          NotesSort.title => Icons.sort_by_alpha_rounded,
                        },
                        label: 'Sort: ${_sortLabel(sort)}',
                        selected: ref.watch(notesSortProvider) == sort,
                        dividerBefore: i == 0,
                        onTap: () =>
                            ref.read(notesSortProvider.notifier).state = sort,
                      ),
                  ],
                ),
              ),
              body: allNotes == null
                  ? const SizedBox.shrink()
                  : allNotes.isEmpty
                  ? KuberEmptyState(
                      icon: Icons.sticky_note_2_outlined,
                      title: 'No notes yet',
                      description:
                          'Tap + to create your first note, or create a '
                          'tutorial note to see how quick math and '
                          'tap-to-convert work.',
                      actionLabel: 'Create tutorial note',
                      onAction: _openDemoNote,
                    )
                  : _buildBody(
                      cs,
                      allNotes.length,
                      notes,
                      selectionMode,
                      selection,
                    ),
            ),
            if (selectionMode)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _selectionHeader(cs, selection.length),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ColorScheme cs,
    int total,
    List<KuberNote> notes,
    bool selectionMode,
    Set<int> selection,
  ) {
    final tt = Theme.of(context).textTheme;
    final viewMode = ref.watch(notesViewModeProvider);
    final filter = ref.watch(notesFilterProvider);
    final sort = ref.watch(notesSortProvider);

    final pinned = notes.where((n) => n.pinned).toList();
    final others = notes.where((n) => !n.pinned).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KuberSpace.screenMargin,
        0,
        KuberSpace.screenMargin,
        KuberExtendedFab.clearance,
      ),
      children: [
        // Same top as Kuber Cards: the summary line with filter and change
        // view buttons; search is in the header (round 4).
        Padding(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$total ${total == 1 ? 'note' : 'notes'} · sorted by '
                  '${_sortLabel(sort)}',
                  style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              KuberFilterButton(
                onPressed: () => context.push('/more/notes/filter'),
                active: filter.isActive,
              ),
              KuberViewModeButton<NotesViewMode>(
                value: viewMode,
                options: const [
                  (NotesViewMode.list, Icons.view_list_rounded, 'List view'),
                  (NotesViewMode.grid, Icons.grid_view_rounded, 'Grid view'),
                ],
                onChanged: (m) =>
                    ref.read(notesViewModeProvider.notifier).set(m),
              ),
            ],
          ),
        ),
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(
              child: Text(
                'No notes match. Tap + to add one.',
                style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          )
        else
          // List <-> grid cross-fades (review round 3).
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: Column(
              key: ValueKey(viewMode),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pinned.isNotEmpty) ...[
                  const SizedBox(height: KuberSpace.md),
                  const KuberSectionHeader(title: 'Pinned'),
                  _notesGroup(pinned, viewMode, selectionMode, selection),
                ],
                if (others.isNotEmpty) ...[
                  const SizedBox(height: KuberSpace.md),
                  if (pinned.isNotEmpty)
                    const KuberSectionHeader(title: 'Others'),
                  _notesGroup(others, viewMode, selectionMode, selection),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _notesGroup(
    List<KuberNote> notes,
    NotesViewMode viewMode,
    bool selectionMode,
    Set<int> selection,
  ) {
    if (viewMode == NotesViewMode.grid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: KuberSpace.sm,
          crossAxisSpacing: KuberSpace.sm,
          childAspectRatio: 0.92,
        ),
        itemCount: notes.length,
        itemBuilder: (_, i) => NoteGridCard(
          note: notes[i],
          selectionMode: selectionMode,
          selected: selection.contains(notes[i].id),
          onTap: () => _openNote(notes[i]),
          onLongPress: () => _toggleSelected(notes[i].id),
        ),
      );
    }
    return KuberGroup(
      children: [
        for (final note in notes)
          NoteListCard(
            note: note,
            selectionMode: selectionMode,
            selected: selection.contains(note.id),
            onTap: () => _openNote(note),
            onLongPress: () => _toggleSelected(note.id),
          ),
      ],
    );
  }
}
