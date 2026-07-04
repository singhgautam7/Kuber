part of 'note_editor_screen.dart';

/// Number-tap handling, the custom selection menu, and the editor's action
/// methods. Split into a part file to keep the screen under the 400-line cap.
extension _NoteEditorActions on _NoteEditorScreenState {
  // ── Number tap → Quick Actions ────────────────────────────────────────────

  Future<void> _onNumberTapped(double amount) async {
    final note = _note;
    if (note == null) return;
    // A converted number records sourceNoteId, so ensure the note has a real
    // id first (persists a lazy new note).
    await ensurePersisted();
    if (!mounted) return;
    QuickActionsSheet.show(
      context,
      amount: amount.abs(),
      noteTitle:
          _titleController.text.trim().isEmpty ? 'Untitled note' : _titleController.text.trim(),
      fromNoteId: note.id,
      inheritedCategoryId: note.categoryId,
    );
  }

  /// Custom text-selection toolbar: prepends a Bold toggle to the default
  /// cut / copy / paste / select-all set. Positioned via Quill's anchors so
  /// it sits above the selection (not over it).
  Widget _buildContextMenu(
      BuildContext context, QuillRawEditorState rawState) {
    final controller = _controller;
    if (controller == null) {
      return AdaptiveTextSelectionToolbar.buttonItems(
        anchors: rawState.contextMenuAnchors,
        buttonItems: rawState.contextMenuButtonItems,
      );
    }
    final boldActive = controller
            .getSelectionStyle()
            .attributes[Attribute.bold.key]
            ?.value ==
        true;
    // Nudge the toolbar's primary (above) anchor upward so it sits clearly
    // above the selection instead of overlapping the selected text.
    final anchors = rawState.contextMenuAnchors;
    final lifted = TextSelectionToolbarAnchors(
      primaryAnchor: anchors.primaryAnchor - const Offset(0, 14),
      secondaryAnchor: anchors.secondaryAnchor,
    );
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: lifted,
      buttonItems: [
        ContextMenuButtonItem(
          label: boldActive ? 'Unbold' : 'Bold',
          onPressed: () {
            controller.formatSelection(boldActive
                ? Attribute.clone(Attribute.bold, null)
                : Attribute.bold);
            rawState.hideToolbar();
          },
        ),
        ...rawState.contextMenuButtonItems,
      ],
    );
  }

  GestureRecognizer? _recognizerFor(Attribute attribute, Leaf leaf) {
    if (attribute.key == NumberHighlightAttribute.kKey &&
        attribute.value != null) {
      final text = leaf.toPlainText().replaceAll('₹', '').replaceAll(',', '');
      final value = double.tryParse(text);
      if (value == null) return null;
      return TapGestureRecognizer()..onTap = () => _onNumberTapped(value);
    }
    if (attribute.key == ArithResultAttribute.kKey && attribute.value != null) {
      final value = double.tryParse('${attribute.value}');
      if (value == null) return null;
      return TapGestureRecognizer()..onTap = () => _onNumberTapped(value);
    }
    return null;
  }

  TextStyle _styleFor(Attribute attribute) {
    if (attribute.key == NumberHighlightAttribute.kKey &&
        attribute.value != null) {
      return NumberHighlightStyle.regular(context,
          negative: attribute.value == 'neg');
    }
    if (attribute.key == ArithResultAttribute.kKey && attribute.value != null) {
      return NumberHighlightStyle.result(context);
    }
    return const TextStyle();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _toggleReadOnly() async {
    final note = _note;
    if (note == null) return;
    note.isReadOnly = !note.isReadOnly;
    _controller?.readOnly = note.isReadOnly;
    await ref.read(notesRepositoryProvider).put(note);
    if (mounted) refreshEditor();
  }

  Future<void> _shareNote() async {
    final note = _note;
    final c = _controller;
    if (note == null || c == null) return;
    final title =
        _titleController.text.trim().isEmpty ? 'Untitled note' : _titleController.text.trim();
    final body = c.document.toPlainText().trimRight();
    await SharePlus.instance.share(ShareParams(text: '$title\n\n$body'));
  }

  Future<void> _duplicateNote() async {
    final note = _note;
    if (note == null) return;
    await _save();
    final fresh = await ref.read(notesRepositoryProvider).getById(note.id);
    if (fresh == null) return;
    await ref.read(notesRepositoryProvider).duplicate(fresh);
    if (mounted) showKuberSnackBar(context, 'Note duplicated');
  }

  Future<void> _deleteNote() async {
    final note = _note;
    if (note == null) return;
    final confirmed = await showNoteDeleteConfirmDialog(context, count: 1);
    if (confirmed != true || !mounted) return;
    await ref.read(notesRepositoryProvider).delete(note.id);
    if (mounted) {
      Navigator.of(context).pop();
      showKuberSnackBar(context, 'Note deleted');
    }
  }

  Future<void> _pickCategory() async {
    final note = _note;
    if (note == null || note.isReadOnly) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: int.tryParse(note.categoryId ?? ''),
        onSelected: (id) async {
          Navigator.pop(context);
          note.categoryId = id.toString();
          await ref.read(notesRepositoryProvider).put(note);
          if (mounted) refreshEditor();
        },
      ),
    );
  }

  Future<void> _pickTags() async {
    final note = _note;
    if (note == null || note.isReadOnly) return;
    final allTags = ref.read(tagListProvider).valueOrNull ?? [];
    final selected = allTags
        .where((t) => note.tagIds.contains(t.id.toString()))
        .toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => TagSelectorBottomSheet(
        initialSelectedTags: selected,
        onDone: (tags) async {
          note.tagIds = tags.map((t) => t.id.toString()).toList();
          await ref.read(notesRepositoryProvider).put(note);
          if (mounted) refreshEditor();
        },
      ),
    );
  }
}
