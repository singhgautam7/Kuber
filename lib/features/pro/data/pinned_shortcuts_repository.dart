import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/utils/color_palette.dart';
import 'pinned_shortcut_pref.dart';

/// One pinned shortcut: which catalog id, plus the accent color the user
/// picked for it (defaults to the app accent, same pattern as picking a
/// category color).
class PinnedShortcut {
  final String id;
  final Color color;
  const PinnedShortcut({required this.id, required this.color});

  PinnedShortcut copyWith({Color? color}) =>
      PinnedShortcut(id: id, color: color ?? this.color);
}

/// The first-run pinned set, shown until the user configures their own. Ids
/// match `kShortcutCatalog` (tool ids are the `ToolCatalog` route keys).
/// Colors are drawn from `kShortcutColorSwatches` (`shortcut_catalog.dart`).
const _defaultPins = <PinnedShortcut>[
  PinnedShortcut(id: 'ask_kuber', color: Color(AppColorPalette.kVibrantPurple)),
  PinnedShortcut(id: 'kuber_notes', color: Color(AppColorPalette.kVibrantGreen)),
  PinnedShortcut(id: 'ledger', color: Color(AppColorPalette.kVibrantPink)),
  PinnedShortcut(id: 'reminders', color: Color(AppColorPalette.kVibrantAmber)),
  PinnedShortcut(
      id: 'salary-calculator', color: Color(AppColorPalette.kVibrantBlue)),
  PinnedShortcut(
      id: 'split-calculator', color: Color(AppColorPalette.kVibrantTeal)),
  PinnedShortcut(
      id: 'currency-converter', color: Color(AppColorPalette.kVibrantIndigo)),
];

/// Tiny Isar-backed store for the pinned home shortcuts, mirroring
/// `WidgetPreferenceRepository`: the whole ordered set is rewritten on every
/// save, so list order IS the display order (no reconciliation needed). Uses
/// Isar Community's synchronous API so the Notifier can hydrate on `build()`
/// without an async gap — the row count is tiny.
class PinnedShortcutsRepository {
  final Isar isar;
  PinnedShortcutsRepository(this.isar);

  /// Reads the ordered pins. Returns null when the user has never configured
  /// them (no rows), so the caller can seed defaults; an explicitly empty set
  /// (the user removed every pin) is stored as a single sentinel and returns
  /// an empty list, not null.
  List<PinnedShortcut>? readAll() {
    final rows = isar.pinnedShortcutPrefs.where().sortByOrder().findAllSync();
    if (rows.isEmpty) return null;
    return [
      for (final r in rows)
        if (r.shortcutId != _emptySentinel)
          PinnedShortcut(id: r.shortcutId, color: Color(r.colorValue)),
    ];
  }

  /// Replaces all rows so stored order matches [shortcuts] exactly. An empty
  /// list is persisted as a sentinel row so a later read returns empty rather
  /// than re-seeding the defaults.
  void saveAll(List<PinnedShortcut> shortcuts) {
    isar.writeTxnSync(() {
      isar.pinnedShortcutPrefs.clearSync();
      final rows = shortcuts.isEmpty
          ? [
              PinnedShortcutPref()
                ..shortcutId = _emptySentinel
                ..order = 0
                ..colorValue = 0,
            ]
          : [
              for (var i = 0; i < shortcuts.length; i++)
                PinnedShortcutPref()
                  ..shortcutId = shortcuts[i].id
                  ..order = i
                  ..colorValue = shortcuts[i].color.toARGB32(),
            ];
      isar.pinnedShortcutPrefs.putAllSync(rows);
    });
  }

  /// Marks "user chose to pin nothing", distinct from "never configured".
  static const _emptySentinel = '__none__';
}

final pinnedShortcutsRepositoryProvider =
    Provider<PinnedShortcutsRepository>((ref) {
  return PinnedShortcutsRepository(ref.read(isarProvider));
});

/// Persisted, ordered choice of pinned shortcuts (id + color each). Order in
/// this list is the display order — the configure sheet lets the user drag to
/// reorder directly, so this list's order IS the source of truth. Hydrates
/// synchronously from Isar on first read and seeds [_defaultPins] on a fresh
/// install.
class PinnedShortcutsNotifier extends Notifier<List<PinnedShortcut>> {
  PinnedShortcutsRepository get _repo =>
      ref.read(pinnedShortcutsRepositoryProvider);

  @override
  List<PinnedShortcut> build() {
    final stored = _repo.readAll();
    if (stored == null) {
      // First run: seed and persist the defaults so subsequent reads are a
      // straight pass.
      _repo.saveAll(_defaultPins);
      return List.of(_defaultPins);
    }
    return stored;
  }

  /// Persists and publishes a new pinned set (from the configure sheet).
  void save(List<PinnedShortcut> shortcuts) {
    final next = List.of(shortcuts);
    _repo.saveAll(next);
    state = next;
  }
}

final pinnedShortcutsProvider =
    NotifierProvider<PinnedShortcutsNotifier, List<PinnedShortcut>>(
  PinnedShortcutsNotifier.new,
);
