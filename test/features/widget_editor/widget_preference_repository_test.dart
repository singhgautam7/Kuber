import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/widget_editor/data/widget_catalog.dart';
import 'package:kuber/features/widget_editor/data/widget_preference.dart';
import 'package:kuber/features/widget_editor/data/widget_preference_repository.dart';
import 'package:kuber/features/widget_editor/models/home_widget_config.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late WidgetPreferenceRepository repo;

  setUpAll(initialiseIsarForTests);

  setUp(() async {
    isar = await openTestIsar();
    repo = WidgetPreferenceRepository(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  group('readForScope — seeding', () {
    test('first read seeds defaults for home', () async {
      final list = await repo.readForScope(WidgetEditorScope.home);
      expect(list.map((c) => c.id).toList(),
          kHomeWidgetCatalog.map((c) => c.id).toList());
      
      final disabledIds = {'budget_snapshot', 'upcoming_recurring', 'recent_transactions'};
      for (final c in list) {
        if (disabledIds.contains(c.id)) {
          expect(c.enabled, isFalse);
        } else {
          expect(c.enabled, isTrue);
        }
      }

      // Rows are persisted.
      final stored = await isar.widgetPreferences.where().findAll();
      expect(stored.length, kHomeWidgetCatalog.length);
    });

    test('first read seeds defaults for analytics', () async {
      final list = await repo.readForScope(WidgetEditorScope.analytics);
      expect(list.map((c) => c.id).toList(),
          kAnalyticsWidgetCatalog.map((c) => c.id).toList());
    });
  });

  group('save + readForScope — ordering and toggles', () {
    test('order is preserved on round-trip', () async {
      final initial = await repo.readForScope(WidgetEditorScope.home);
      final reordered = [...initial.reversed];
      await repo.save(WidgetEditorScope.home, reordered);

      final next = await repo.readForScope(WidgetEditorScope.home);
      expect(next.map((c) => c.id).toList(),
          reordered.map((c) => c.id).toList());
    });

    test('disabled flag survives a round-trip', () async {
      final initial = await repo.readForScope(WidgetEditorScope.home);
      final toggled = [...initial];
      toggled[2] = toggled[2].copyWith(enabled: false);
      await repo.save(WidgetEditorScope.home, toggled);

      final next = await repo.readForScope(WidgetEditorScope.home);
      expect(next[2].enabled, isFalse);
      expect(next.where((c) => c.enabled).length,
          initial.where((c) => c.enabled).length - 1);
    });
  });

  group('reconciliation against catalog', () {
    test('orphan stored widget is dropped', () async {
      // Seed defaults, then poison the store with an orphan id.
      await repo.readForScope(WidgetEditorScope.home);
      await isar.writeTxn(() async {
        await isar.widgetPreferences.put(WidgetPreference()
          ..scope = 'home'
          ..widgetKey = 'ancient_widget_removed_from_catalog'
          ..order = 99
          ..enabled = true);
      });

      final reconciled = await repo.readForScope(WidgetEditorScope.home);
      expect(
        reconciled.any((c) => c.id == 'ancient_widget_removed_from_catalog'),
        isFalse,
      );
      // After read, the orphan is also dropped from storage.
      final stored = await isar.widgetPreferences
          .filter()
          .scopeEqualTo('home')
          .findAll();
      expect(
        stored
            .any((r) => r.widgetKey == 'ancient_widget_removed_from_catalog'),
        isFalse,
      );
    });

    test('catalog widget missing from store is appended (enabled)', () async {
      // Seed defaults, then simulate "older" storage where one widget is absent.
      await repo.readForScope(WidgetEditorScope.home);
      await isar.writeTxn(() async {
        // Remove the FIRST catalog widget from storage.
        await isar.widgetPreferences
            .filter()
            .scopeEqualTo('home')
            .and()
            .widgetKeyEqualTo(kHomeWidgetCatalog.first.id)
            .deleteAll();
      });

      final reconciled = await repo.readForScope(WidgetEditorScope.home);
      // It's back — and at the end of the order, enabled.
      expect(reconciled.last.id, kHomeWidgetCatalog.first.id);
      expect(reconciled.last.enabled, isTrue);
    });
  });

  group('scope isolation', () {
    test('home and analytics scopes are independent', () async {
      final home = await repo.readForScope(WidgetEditorScope.home);
      final analytics =
          await repo.readForScope(WidgetEditorScope.analytics);

      // Mutate home only.
      final toggled = [...home];
      toggled[0] = toggled[0].copyWith(enabled: false);
      await repo.save(WidgetEditorScope.home, toggled);

      final analyticsAgain =
          await repo.readForScope(WidgetEditorScope.analytics);
      expect(analyticsAgain.map((c) => c.id).toList(),
          analytics.map((c) => c.id).toList());
      expect(analyticsAgain.every((c) => c.enabled), isTrue);
    });
  });
}
