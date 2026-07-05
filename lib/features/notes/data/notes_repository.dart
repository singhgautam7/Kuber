import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';
import '../engine/number_parser.dart';
import 'kuber_note.dart';
import 'notes_constants.dart';

/// All reads and writes for [KuberNote]. Never touch Isar from a widget —
/// always go through this repository.
class NotesRepository {
  final Isar isar;
  NotesRepository(this.isar);

  Stream<List<KuberNote>> watchAll() =>
      isar.kuberNotes.where().watch(fireImmediately: true);

  Future<List<KuberNote>> getAll() => isar.kuberNotes.where().findAll();

  Future<KuberNote?> getById(int id) => isar.kuberNotes.get(id);

  Future<int> put(KuberNote note) async {
    note.updatedAt = DateTime.now();
    return isar.writeTxn(() => isar.kuberNotes.put(note));
  }

  /// Saves editor content without bumping the id.
  Future<void> updateContent(int id, String title, String content) async {
    await isar.writeTxn(() async {
      final note = await isar.kuberNotes.get(id);
      if (note == null) return;
      note
        ..title = title
        ..content = content
        ..updatedAt = DateTime.now();
      await isar.kuberNotes.put(note);
    });
  }

  Future<KuberNote> createBlank() async {
    final now = DateTime.now();
    final note = KuberNote()
      ..title = ''
      ..content = r'[{"insert":"\n"}]'
      ..createdAt = now
      ..updatedAt = now;
    await isar.writeTxn(() async {
      note.id = await isar.kuberNotes.put(note);
    });
    return note;
  }

  Future<void> delete(int id) =>
      isar.writeTxn(() => isar.kuberNotes.delete(id));

  Future<void> deleteMany(List<int> ids) =>
      isar.writeTxn(() => isar.kuberNotes.deleteAll(ids));

  Future<void> setPinned(List<int> ids, bool pinned) async {
    await isar.writeTxn(() async {
      final notes = await isar.kuberNotes.getAll(ids);
      final updated = <KuberNote>[];
      for (final n in notes) {
        if (n == null) continue;
        updated.add(n..pinned = pinned);
      }
      await isar.kuberNotes.putAll(updated);
    });
  }

  Future<void> setCategory(List<int> ids, String? categoryId) async {
    await isar.writeTxn(() async {
      final notes = await isar.kuberNotes.getAll(ids);
      final updated = <KuberNote>[];
      for (final n in notes) {
        if (n == null) continue;
        updated.add(n..categoryId = categoryId);
      }
      await isar.kuberNotes.putAll(updated);
    });
  }

  Future<KuberNote> duplicate(KuberNote source) async {
    final now = DateTime.now();
    final copy = KuberNote()
      ..title = source.title.isEmpty ? '' : '${source.title} (copy)'
      ..content = source.content
      ..categoryId = source.categoryId
      ..tagIds = List.of(source.tagIds)
      ..createdAt = now
      ..updatedAt = now;
    await isar.writeTxn(() async {
      copy.id = await isar.kuberNotes.put(copy);
    });
    return copy;
  }

  /// Creates the onboarding demo note once per install. The persisted flag
  /// alone gates creation — deleting the note never recreates it automatically.
  Future<KuberNote?> maybeCreateOnboardingDemoNote() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(PrefsKeys.notesOnboardingSeen) ?? false) return null;
    await prefs.setBool(PrefsKeys.notesOnboardingSeen, true);
    return createTutorialNote();
  }

  /// Always creates a fresh tutorial note (used by the empty-state
  /// "Create tutorial note" button, which works even after the demo was
  /// deleted). Also sets the onboarding flag so first-run doesn't add a
  /// duplicate later.
  Future<KuberNote> createTutorialNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.notesOnboardingSeen, true);

    final now = DateTime.now();
    final note = KuberNote()
      ..title = kNotesDemoTitle
      ..content = kNotesOnboardingDemoContent
      ..createdAt = now
      ..updatedAt = now;
    await isar.writeTxn(() async {
      note.id = await isar.kuberNotes.put(note);
    });
    return note;
  }
}

/// Plain text of a note's Quill Delta JSON (best effort — embeds skipped).
String notePlainText(KuberNote note) {
  try {
    final ops = jsonDecode(note.content) as List<dynamic>;
    final buf = StringBuffer();
    for (final op in ops) {
      final insert = (op as Map<String, dynamic>)['insert'];
      if (insert is String) buf.write(insert);
    }
    return buf.toString();
  } catch (_) {
    return '';
  }
}

/// True when the note's Delta contains a checklist line.
bool noteHasChecklist(KuberNote note) =>
    note.content.contains('"list":"checked"') ||
    note.content.contains('"list":"unchecked"');

/// Numeric tokens in the note body, excluding resolved arithmetic results.
List<NumberToken> noteNumberTokens(KuberNote note) {
  try {
    final ops = jsonDecode(note.content) as List<dynamic>;
    final buf = StringBuffer();
    final excluded = <PlainTextRange>[];
    for (final op in ops) {
      final map = op as Map<String, dynamic>;
      final insert = map['insert'];
      if (insert is! String) continue;
      final start = buf.length;
      buf.write(insert);
      final attrs = map['attributes'];
      if (attrs is Map && attrs.containsKey('kuber-arith')) {
        excluded.add(PlainTextRange(start, start + insert.length));
      }
    }
    return const NumberParser().parse(buf.toString(), excluded: excluded);
  } catch (_) {
    return const [];
  }
}
