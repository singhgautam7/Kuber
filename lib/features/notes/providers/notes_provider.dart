import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/utils/prefs_keys.dart';
import '../data/kuber_note.dart';
import '../data/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(ref.watch(isarProvider));
});

/// Live list of every note, unsorted (sorting is a pure view concern).
final notesStreamProvider = StreamProvider<List<KuberNote>>((ref) {
  return ref.watch(notesRepositoryProvider).watchAll();
});

enum NotesViewMode { list, grid }

enum NotesSort { modified, created, title }

/// Advanced filter state for Notes (opened from the filter button, like the
/// History tab's advanced filter). Empty = no filter.
class NotesFilterState {
  final Set<String> categoryIds;
  final Set<String> tagIds;
  final DateTime? createdFrom;
  final DateTime? createdTo;

  const NotesFilterState({
    this.categoryIds = const {},
    this.tagIds = const {},
    this.createdFrom,
    this.createdTo,
  });

  bool get isActive =>
      categoryIds.isNotEmpty ||
      tagIds.isNotEmpty ||
      createdFrom != null ||
      createdTo != null;

  int get activeCount =>
      categoryIds.length +
      tagIds.length +
      ((createdFrom != null || createdTo != null) ? 1 : 0);

  NotesFilterState copyWith({
    Set<String>? categoryIds,
    Set<String>? tagIds,
    DateTime? createdFrom,
    DateTime? createdTo,
    bool clearDates = false,
  }) {
    return NotesFilterState(
      categoryIds: categoryIds ?? this.categoryIds,
      tagIds: tagIds ?? this.tagIds,
      createdFrom: clearDates ? null : (createdFrom ?? this.createdFrom),
      createdTo: clearDates ? null : (createdTo ?? this.createdTo),
    );
  }
}

/// Persisted list/grid preference (`notes_view_mode`).
final notesViewModeProvider =
    StateNotifierProvider<NotesViewModeNotifier, NotesViewMode>(
        (ref) => NotesViewModeNotifier());

class NotesViewModeNotifier extends StateNotifier<NotesViewMode> {
  NotesViewModeNotifier() : super(NotesViewMode.list) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(PrefsKeys.notesViewMode);
    if (stored == 'grid' && mounted) state = NotesViewMode.grid;
  }

  Future<void> set(NotesViewMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        PrefsKeys.notesViewMode, mode == NotesViewMode.grid ? 'grid' : 'list');
  }
}

final notesSortProvider = StateProvider<NotesSort>((ref) => NotesSort.modified);

final notesFilterProvider =
    StateProvider<NotesFilterState>((ref) => const NotesFilterState());

final notesSearchProvider = StateProvider<String>((ref) => '');

/// Sorted + filtered + searched notes for the landing screen.
final visibleNotesProvider = Provider<List<KuberNote>>((ref) {
  final notes =
      List.of(ref.watch(notesStreamProvider).valueOrNull ?? const <KuberNote>[]);
  final sort = ref.watch(notesSortProvider);
  final filter = ref.watch(notesFilterProvider);
  final query = ref.watch(notesSearchProvider).trim().toLowerCase();

  Iterable<KuberNote> result = notes;

  if (filter.categoryIds.isNotEmpty) {
    result = result.where(
        (n) => n.categoryId != null && filter.categoryIds.contains(n.categoryId));
  }
  if (filter.tagIds.isNotEmpty) {
    result = result
        .where((n) => n.tagIds.any((t) => filter.tagIds.contains(t)));
  }
  if (filter.createdFrom != null) {
    result = result.where((n) => !n.createdAt.isBefore(filter.createdFrom!));
  }
  if (filter.createdTo != null) {
    final end = DateTime(filter.createdTo!.year, filter.createdTo!.month,
        filter.createdTo!.day, 23, 59, 59);
    result = result.where((n) => !n.createdAt.isAfter(end));
  }

  if (query.isNotEmpty) {
    result = result.where((n) =>
        n.title.toLowerCase().contains(query) ||
        notePlainText(n).toLowerCase().contains(query));
  }

  final list = result.toList();
  switch (sort) {
    case NotesSort.modified:
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      break;
    case NotesSort.created:
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case NotesSort.title:
      list.sort((a, b) =>
          a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      break;
  }
  return list;
});

/// In-memory "unlocked this session" flag for the Notes biometric gate.
/// Cleared only by a full process restart, mirroring the app-wide biometric
/// session semantics in AuthNotifier.
final notesUnlockedThisSessionProvider = StateProvider<bool>((ref) => false);

/// Whether the "Require biometric to open Notes" setting is on.
final notesBiometricRequiredProvider =
    StateNotifierProvider<NotesBiometricRequiredNotifier, bool>(
        (ref) => NotesBiometricRequiredNotifier());

class NotesBiometricRequiredNotifier extends StateNotifier<bool> {
  NotesBiometricRequiredNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(PrefsKeys.notesBiometricRequired) ?? false;
    if (mounted) state = stored;
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.notesBiometricRequired, enabled);
  }
}

/// Multi-select state on the Notes landing (empty = not in selection mode).
final notesSelectionProvider = StateProvider<Set<int>>((ref) => {});
