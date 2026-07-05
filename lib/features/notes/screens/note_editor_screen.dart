import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider;
import '../../tags/providers/tag_providers.dart';
import '../../tags/widgets/tag_selector_bottom_sheet.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/kuber_note.dart';
import '../engine/quill_number_highlighter.dart';
import '../data/notes_repository.dart';
import '../providers/notes_provider.dart';
import '../utils/note_format.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/note_dialogs.dart';
import '../widgets/note_editor_chrome.dart';
import '../widgets/number_highlight_style.dart';
import '../widgets/quick_actions_sheet.dart';

part 'note_editor_actions.dart';

/// Full-screen note editor (screen 1d). Deliberately NOT the universal
/// landing pattern — bespoke minimal chrome: back, centered save status,
/// read-only lock toggle, overflow menu.
class NoteEditorScreen extends ConsumerStatefulWidget {
  final int noteId;

  const NoteEditorScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  NotesRepository? _repo;
  KuberNote? _note;
  QuillController? _controller;
  final _titleController = TextEditingController();
  final _editorFocus = FocusNode();

  late QuillNumberHighlighter _highlighter;
  StreamSubscription? _docSub;
  Timer? _saveDebounce;
  Timer? _highlightDebounce;
  // Save-status flags live in ValueNotifiers, not `setState` — every keystroke
  // triggers `_markDirty`, and rebuilding the whole editor (including the
  // Quill tree and its LayoutBuilder+IntrinsicHeight) 60× while a user types
  // is prohibitively expensive. Only the top-bar's save indicator subscribes.
  final ValueNotifier<bool> _saving = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _dirty = ValueNotifier<bool>(false);

  /// A brand-new note is NOT written to the database until the first real
  /// edit, so backing out of a blank note never flashes + deletes on the
  /// landing list.
  bool _persisted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(notesRepositoryProvider);
    _repo = repo;

    final KuberNote note;
    if (widget.noteId > 0) {
      final existing = await repo.getById(widget.noteId);
      if (!mounted || existing == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      note = existing;
      _persisted = true;
    } else {
      // New note — kept in memory until the first save.
      final now = DateTime.now();
      note = KuberNote()
        ..title = ''
        ..content = r'[{"insert":"\n"}]'
        ..createdAt = now
        ..updatedAt = now;
      _persisted = false;
    }

    Document doc;
    try {
      doc = Document.fromJson(jsonDecode(note.content) as List);
    } catch (_) {
      doc = Document();
    }

    final formatter = ref.read(formatterProvider);
    _highlighter =
        QuillNumberHighlighter(formatAmount: (v) => formatter.formatCurrency(v));

    final controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    )..readOnly = note.isReadOnly;

    _titleController.text = note.title;
    _titleController.addListener(_markDirty);
    _docSub = controller.document.changes.listen((_) {
      if (_highlighter.isApplying) return;
      _markDirty();
      _highlightDebounce?.cancel();
      _highlightDebounce =
          Timer(const Duration(milliseconds: 220), _runHighlighter);
    });

    setState(() {
      _note = note;
      _controller = controller;
    });

    // Re-verify saved highlights/results against current numbers on open.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runHighlighter());
  }

  void _runHighlighter() {
    final c = _controller;
    if (c == null || !mounted) return;
    _highlighter.apply(c);
  }

  void _markDirty() {
    _dirty.value = true;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 500), _save);
  }

  Future<void> _save() async {
    final c = _controller;
    final note = _note;
    if (c == null || note == null) return;
    // Never persist a brand-new note that is still empty.
    if (!_persisted && _isEmptyNote()) return;
    _saving.value = true;
    note
      ..title = _titleController.text.trim()
      ..content = jsonEncode(c.document.toDelta().toJson());
    // put() upserts — inserts a new note (assigning its id) or updates.
    note.id = await ref.read(notesRepositoryProvider).put(note);
    _persisted = true;
    if (!mounted) return;
    _saving.value = false;
    _dirty.value = false;
  }

  /// Ensures a new note exists in the DB (with a real id) before an action
  /// that needs one — e.g. tapping a number to convert, which records
  /// sourceNoteId, or setting a category/tag.
  Future<void> ensurePersisted() async {
    if (_persisted) return;
    final c = _controller;
    final note = _note;
    if (c == null || note == null) return;
    note
      ..title = _titleController.text.trim()
      ..content = jsonEncode(c.document.toDelta().toJson());
    note.id = await ref.read(notesRepositoryProvider).put(note);
    _persisted = true;
  }

  /// Rebuilds the editor after an action mutates note metadata (used from
  /// the actions part file, which cannot call the protected setState).
  void refreshEditor() {
    if (mounted) setState(() {});
  }

  /// Focuses the body and moves the caret to the end — used when tapping the
  /// empty space below a short note.
  void _focusEditorEnd() {
    final c = _controller;
    if (c == null) return;
    _editorFocus.requestFocus();
    final end = (c.document.length - 1).clamp(0, 1 << 30);
    c.updateSelection(
      TextSelection.collapsed(offset: end),
      ChangeSource.local,
    );
  }

  /// True when the note has no title, no body text, no category and no tags.
  bool _isEmptyNote() {
    final note = _note;
    final c = _controller;
    if (note == null || c == null) return false;
    final bodyEmpty = c.document.toPlainText().trim().isEmpty;
    return _titleController.text.trim().isEmpty &&
        bodyEmpty &&
        note.categoryId == null &&
        note.tagIds.isEmpty;
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _highlightDebounce?.cancel();
    _docSub?.cancel();
    final c = _controller;
    final note = _note;
    if (note != null) {
      if (_isEmptyNote()) {
        // Empty note: delete it if it had been persisted; if it was never
        // written (lazy new note), there's nothing to clean up.
        if (_persisted) _repo?.delete(note.id).ignore();
      } else if (_dirty.value && c != null) {
        // Flush any pending edit the 500ms debounce hadn't written yet.
        note
          ..title = _titleController.text.trim()
          ..content = jsonEncode(c.document.toDelta().toJson());
        _repo?.put(note).ignore();
      }
    }
    _controller?.dispose();
    _titleController.dispose();
    _editorFocus.dispose();
    _saving.dispose();
    _dirty.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final note = _note;
    final controller = _controller;

    if (note == null || controller == null) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final readOnly = note.isReadOnly;
    final category = ref.watch(categoryListProvider.select(
      (async) => async.valueOrNull
          ?.firstWhereOrNull((c) => c.id.toString() == note.categoryId),
    ));
    final allTags = ref.watch(tagListProvider).valueOrNull ?? [];
    final tags =
        allTags.where((t) => note.tagIds.contains(t.id.toString())).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Subscribes to the two save-status ValueNotifiers so only this
            // top-bar rebuilds while typing. The Quill editor tree, its
            // LayoutBuilder + IntrinsicHeight, and the toolbar all skip the
            // rebuild pass on each keystroke.
            _NoteEditorTopBarSaveIndicator(
              saving: _saving,
              dirty: _dirty,
              persisted: _persisted,
              readOnly: readOnly,
              onToggleReadOnly: _toggleReadOnly,
              onShare: _shareNote,
              onDuplicate: _duplicateNote,
              onDelete: _deleteNote,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (ctx, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  child: ConstrainedBox(
                    // Fill the viewport so the metadata/footer sit at the
                    // bottom even for an empty note; scroll when content grows.
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 30),
                    child: IntrinsicHeight(
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      enabled: !readOnly,
                      maxLines: null,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      style: localeFont(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: readOnly
                            ? cs.onSurface.withValues(alpha: 0.75)
                            : cs.onSurface,
                        letterSpacing: -0.4,
                      ),
                      // Override the global themed input borders — the title is
                      // a plain field with no box (not in the design spec).
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        filled: false,
                        hintText: 'Untitled note',
                        hintStyle: localeFont(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    Divider(height: 28, thickness: 1, color: cs.outline),
                    QuillEditor.basic(
                      controller: controller,
                      focusNode: _editorFocus,
                      config: QuillEditorConfig(
                        scrollable: false,
                        placeholder: 'Start writing. Numbers become tappable.',
                        customStyleBuilder: _styleFor,
                        customRecognizerBuilder: _recognizerFor,
                        contextMenuBuilder: _buildContextMenu,
                        customStyles: DefaultStyles(
                          paragraph: DefaultTextBlockStyle(
                            localeFont(
                              fontSize: 14.5,
                              color: cs.onSurface,
                              height: 1.9,
                            ),
                            HorizontalSpacing.zero,
                            const VerticalSpacing(4, 0),
                            VerticalSpacing.zero,
                            null,
                          ),
                        ),
                      ),
                    ),
                    // Fill the gap below a short note; tapping it focuses the
                    // editor so the whole area is writable.
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: readOnly ? null : _focusEditorEnd,
                        child: const SizedBox(width: double.infinity),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Divider between the note body and its metadata — the
                    // note ends here (matches the title/body divider above).
                    Divider(height: 1, thickness: 1, color: cs.outline),
                    const SizedBox(height: 16),
                    NoteMetadataRow(
                      category: category,
                      tags: tags,
                      readOnly: readOnly,
                      onCategoryTap: _pickCategory,
                      onTagTap: _pickTags,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Created ${noteShortDate(note.createdAt)} · '
                      'Modified ${noteRelativeTime(note.updatedAt)}',
                      style: localeFont(
                        fontSize: 11,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!readOnly) KuberEditorToolbar(controller: controller),
          ],
        ),
      ),
    );
  }
}

/// Scoped subscriber: only this widget rebuilds when `_saving` or `_dirty`
/// changes. Wraps `NoteEditorTopBar` so keystroke-driven dirty flips do NOT
/// invalidate the editor body / Quill tree above.
class _NoteEditorTopBarSaveIndicator extends StatelessWidget {
  final ValueListenable<bool> saving;
  final ValueListenable<bool> dirty;
  final bool persisted;
  final bool readOnly;
  final VoidCallback onToggleReadOnly;
  final VoidCallback onShare;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _NoteEditorTopBarSaveIndicator({
    required this.saving,
    required this.dirty,
    required this.persisted,
    required this.readOnly,
    required this.onToggleReadOnly,
    required this.onShare,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: saving,
      builder: (context, savingValue, _) => ValueListenableBuilder<bool>(
        valueListenable: dirty,
        builder: (context, dirtyValue, _) => NoteEditorTopBar(
          saving: savingValue || dirtyValue,
          persisted: persisted,
          readOnly: readOnly,
          onToggleReadOnly: onToggleReadOnly,
          onShare: onShare,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
        ),
      ),
    );
  }
}
