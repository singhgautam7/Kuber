import 'package:isar_community/isar.dart';

part 'pinned_shortcut_pref.g.dart';

/// One row per pinned home-tab shortcut. Mirrors `WidgetPreference`'s shape:
/// the row set is fully rewritten on every save, and [order] is the display
/// order (0-based, ascending) so no separate sort field or reconciliation is
/// needed. The user's chosen accent is stored as a raw ARGB int
/// ([colorValue]), the same convention `Category.colorValue` uses.
@collection
class PinnedShortcutPref {
  Id id = Isar.autoIncrement;

  /// Stable catalog id — matches an entry in `kShortcutCatalog`
  /// (`shortcut_catalog.dart`). A stored id no longer in the catalog is
  /// dropped on read.
  late String shortcutId;

  /// Position within the pinned row, 0-based ascending.
  late int order;

  /// User-picked accent, stored as `Color.toARGB32()`.
  late int colorValue;
}
