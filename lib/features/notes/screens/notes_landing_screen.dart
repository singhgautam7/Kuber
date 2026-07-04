import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/kuber_note.dart';
import '../providers/notes_provider.dart';
import '../widgets/about_notes_info_sheet.dart';
import '../widgets/note_cards.dart';
import '../widgets/note_dialogs.dart' show showNoteDeleteConfirmDialog;
import '../widgets/notes_landing_sections.dart';
import '../widgets/notes_landing_extras.dart';

/// Kuber Notes landing page (screens 1a list / 1b grid / 1c empty).
/// Universal landing pattern: KuberAppBar + KuberPageHeader (FAB right).
class NotesLandingScreen extends ConsumerStatefulWidget {
  const NotesLandingScreen({super.key});

  @override
  ConsumerState<NotesLandingScreen> createState() =>
      _NotesLandingScreenState();
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
    final confirmed =
        await showNoteDeleteConfirmDialog(context, count: selection.length);
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

  void _showSortMenu(BuildContext anchorContext) {
    final cs = Theme.of(context).colorScheme;
    final box = anchorContext.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final current = ref.read(notesSortProvider);
    showMenu<NotesSort>(
      context: context,
      position: position,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KuberRadius.md),
        side: BorderSide(color: cs.outline),
      ),
      items: [
        for (final (sort, label) in [
          (NotesSort.modified, 'Modified'),
          (NotesSort.created, 'Created'),
          (NotesSort.title, 'Title A-Z'),
        ])
          PopupMenuItem<NotesSort>(
            value: sort,
            child: Row(
              children: [
                Icon(
                  sort == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 16,
                  color: sort == current ? cs.primary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(label,
                    style: localeFont(
                        fontSize: 13.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value != null) {
        ref.read(notesSortProvider.notifier).state = value;
      }
    });
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
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true,
        showHome: true,
        showBrand: false,
        infoConfig: kAboutNotesInfoConfig,
        onBack: selectionMode
            ? () => ref.read(notesSelectionProvider.notifier).state = {}
            : null,
      ),
      body: Column(
        children: [
          KuberPageHeader(
            title: 'Kuber Notes',
            description:
                'Jot expenses, do quick math, convert to transactions',
            actionTooltip: 'New note',
            onAction: _createNote,
          ),
          Expanded(
            child: allNotes == null
                ? const SizedBox.shrink()
                : allNotes.isEmpty
                    ? NotesEmptyState(onViewDemo: _openDemoNote)
                    : _buildBody(cs, notes, selectionMode, selection),
          ),
          if (selectionMode)
            NotesSelectionBar(
              count: selection.length,
              onDelete: _bulkDelete,
              onPin: _bulkPin,
              onCategory: _bulkAssignCategory,
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, List<KuberNote> notes, bool selectionMode,
      Set<int> selection) {
    final viewMode = ref.watch(notesViewModeProvider);
    final filter = ref.watch(notesFilterProvider);
    final sort = ref.watch(notesSortProvider);

    final pinned = notes.where((n) => n.pinned).toList();
    final others = notes.where((n) => !n.pinned).toList();

    return ListView(
      padding: EdgeInsets.only(
        left: KuberSpacing.lg,
        right: KuberSpacing.lg,
        bottom: navBarBottomPadding(context),
      ),
      children: [
        NotesSearchRow(
          controller: _searchController,
          filterActive: filter.isActive,
          onChanged: (v) =>
              ref.read(notesSearchProvider.notifier).state = v,
          onFilterTap: () => context.push('/more/notes/filter'),
        ),
        const SizedBox(height: 14),
        NotesSortViewRow(
          sortLabel: switch (sort) {
            NotesSort.modified => 'Modified',
            NotesSort.created => 'Created',
            NotesSort.title => 'Title A-Z',
          },
          viewMode: viewMode,
          onSortTap: _showSortMenu,
          onViewModeChanged: (m) =>
              ref.read(notesViewModeProvider.notifier).set(m),
        ),
        // Breathing room between the sort/view row and the note list.
        const SizedBox(height: 6),
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(
              child: Text(
                'No notes match. Tap + to add one.',
                style: localeFont(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          )
        else ...[
          if (pinned.isNotEmpty) ...[
            const NotesSectionCaption('PINNED'),
            _notesGroup(pinned, viewMode, selectionMode, selection),
            if (others.isNotEmpty) const NotesSectionCaption('OTHERS'),
          ],
          _notesGroup(others, viewMode, selectionMode, selection),
        ],
      ],
    );
  }

  Widget _notesGroup(List<KuberNote> notes, NotesViewMode viewMode,
      bool selectionMode, Set<int> selection) {
    if (viewMode == NotesViewMode.grid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 9,
          crossAxisSpacing: 9,
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
    return Column(
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
