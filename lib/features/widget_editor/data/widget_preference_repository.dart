import 'package:isar_community/isar.dart';

import '../models/home_widget_config.dart';
import 'widget_catalog.dart';
import 'widget_preference.dart';

class WidgetPreferenceRepository {
  final Isar isar;
  WidgetPreferenceRepository(this.isar);

  /// Read the ordered widget list for [scope]. Seeds defaults on first read
  /// (no rows) and reconciles against the catalog on subsequent reads —
  /// catalog-only widgets get appended at the end (enabled), stored widgets
  /// that have since been removed from the catalog are dropped.
  Future<List<HomeWidgetConfig>> readForScope(WidgetEditorScope scope) async {
    final key = scope.key;
    final stored = await isar.widgetPreferences
        .filter()
        .scopeEqualTo(key)
        .sortByOrder()
        .findAll();

    final defaults = defaultsForScope(scope);

    if (stored.isEmpty) {
      await _seed(scope, defaults);
      return defaults;
    }

    final catalogById = {for (final c in defaults) c.id: c};
    final result = <HomeWidgetConfig>[];
    final seen = <String>{};

    // 1. Keep stored rows in stored order, but drop orphans not in the catalog.
    for (final row in stored) {
      var widgetKey = row.widgetKey == 'smart_insights'
          ? 'insight_stories'
          : row.widgetKey;
      // One-time Recurring → Upcoming Events widget replacement: users who
      // had the Recurring widget enabled see the new widget enabled, in the
      // same position.
      if (widgetKey == 'upcoming_recurring') {
        widgetKey = 'upcoming_events_widget';
      }
      final catalog = catalogById[widgetKey];
      if (catalog == null) continue; // orphan: removed from catalog
      seen.add(widgetKey);
      result.add(
        HomeWidgetConfig(
          id: catalog.id,
          name: catalog.name,
          description: catalog.description,
          enabled: row.enabled,
        ),
      );
    }

    // 2. Append any catalog widgets that weren't stored (newly added).
    for (final c in defaults) {
      if (seen.contains(c.id)) continue;
      if (scope == WidgetEditorScope.home && c.id == 'insight_stories') {
        final insertAt = result.isNotEmpty ? 1 : 0;
        result.insert(insertAt, c);
      } else {
        result.add(c);
      }
    }

    // If we mutated the shape (added/removed), persist the reconciled order
    // so a future read is a straight pass.
    if (seen.length != stored.length || result.length != stored.length) {
      await save(scope, result);
    }
    return result;
  }

  Future<void> _seed(
    WidgetEditorScope scope,
    List<HomeWidgetConfig> defaults,
  ) async {
    await save(scope, defaults);
  }

  /// Persist the new configuration atomically. Replaces all rows for the
  /// scope so the in-memory order matches stored order exactly.
  Future<void> save(
    WidgetEditorScope scope,
    List<HomeWidgetConfig> configs,
  ) async {
    final key = scope.key;
    await isar.writeTxn(() async {
      await isar.widgetPreferences.filter().scopeEqualTo(key).deleteAll();
      final rows = <WidgetPreference>[
        for (var i = 0; i < configs.length; i++)
          (WidgetPreference()
            ..scope = key
            ..widgetKey = configs[i].id
            ..order = i
            ..enabled = configs[i].enabled),
      ];
      await isar.widgetPreferences.putAll(rows);
    });
  }
}
