import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/home_v2/data/home_migration.dart';
import 'package:kuber/features/home_v2/data/home_v2_state.dart';
import 'package:kuber/features/home_v2/data/home_v2_widgets.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/widget_editor/data/widget_catalog.dart';
import 'package:kuber/features/widget_editor/data/widget_preference.dart';
import 'package:kuber/features/widget_editor/data/widget_preference_repository.dart';
import 'package:kuber/features/widget_editor/models/home_widget_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

Transaction txn(DateTime at) => Transaction()
  ..name = 'x'
  ..nameLower = 'x'
  ..amount = 100
  ..type = 'expense'
  ..categoryId = ''
  ..accountId = '1'
  ..createdAt = at
  ..updatedAt = at;

/// A v1 user's saved layout: Recent Transactions first, Quick Add hidden,
/// Budget Snapshot shown.
List<HomeWidgetConfig> customLayout() {
  final byId = {for (final c in kHomeWidgetCatalog) c.id: c};
  final order = [
    'recent_transactions',
    'balance_hero',
    'quick_add',
    'budget_snapshot',
    ...kHomeWidgetCatalog.map((c) => c.id).where(
      (id) => !{'recent_transactions', 'balance_hero', 'quick_add', 'budget_snapshot'}.contains(id),
    ),
  ];
  return [
    for (final id in order)
      byId[id]!.copyWith(
        enabled: switch (id) {
          'quick_add' => false,
          'recent_transactions' || 'budget_snapshot' => true,
          _ => byId[id]!.enabled,
        },
      ),
  ];
}

Future<List<WidgetPreference>> homeRows(Isar isar) =>
    isar.widgetPreferences.filter().scopeEqualTo('home').sortByOrder().findAll();

void main() {
  late Isar isar;
  final now = DateTime(2026, 10, 14, 10);
  setUpAll(() async => initialiseIsarForTests());
  setUp(() async {
    isar = await openTestIsar();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async => closeAndCleanIsar(isar));

  Future<HomeV2Store> store() => HomeV2Store.open();

  test('fresh install: v2 day-1 defaults, version stamped, no migration', () async {
    final s = await resolveHomeCohort(isar, onboarded: false, now: now);
    expect(s.cohort, HomeCohort.v2);
    expect(s.gsGraduated, isFalse);
    expect((await store()).migrationVersion, kHomeMigrationVersion);
    // A later launch keeps it as is.
    final again = await resolveHomeCohort(isar, onboarded: true, now: now, waitForWrites: true);
    expect(again.gsGraduated, isFalse);
  });

  test('update with data: same widgets, same order, Get started graduated', () async {
    await WidgetPreferenceRepository(isar).save(WidgetEditorScope.home, customLayout());
    final before = [for (final r in await homeRows(isar)) '${r.widgetKey}:${r.enabled}'];
    await isar.writeTxn(() => isar.transactions.putAll([
      txn(DateTime(2025, 3, 2)),
      txn(DateTime(2026, 9, 1)),
    ]));
    SharedPreferences.setMockInitialValues({PrefsKeys.homeLayout: 'v1'});

    final s = await resolveHomeCohort(isar, onboarded: true, now: now, waitForWrites: true);
    expect(s.cohort, HomeCohort.v2);
    expect(s.gsGraduationReason, GsGraduation.migrated);
    expect(s.gsSuccessShown, isTrue);
    expect(s.gsEligible, isFalse); // never sees Get started
    expect(now.difference(s.gsGraduatedAt!).inHours, greaterThanOrEqualTo(24));
    expect(s.installedAt, DateTime(2025, 3, 2)); // oldest transaction
    // Rows untouched, states mirror them.
    final after = [for (final r in await homeRows(isar)) '${r.widgetKey}:${r.enabled}'];
    expect(after, before);
    for (final r in await homeRows(isar)) {
      expect(s.widgets[r.widgetKey]!.vis, r.enabled ? WidgetVis.on : WidgetVis.off);
    }
    expect(s.widgets.values.any((w) => w.vis == WidgetVis.auto), isFalse);
    final st = await store();
    expect(st.migrationVersion, kHomeMigrationVersion);
    expect(st.read().gsGraduationReason, GsGraduation.migrated);
  });

  test('update with no data and no saved layout: catalog defaults ported', () async {
    SharedPreferences.setMockInitialValues({PrefsKeys.homeLayout: 'v1'});
    final s = await resolveHomeCohort(isar, onboarded: true, now: now, waitForWrites: true);
    expect(s.cohort, HomeCohort.v2);
    final rows = await homeRows(isar);
    expect([for (final r in rows) r.widgetKey], [for (final c in kHomeWidgetCatalog) c.id]);
    for (final c in kHomeWidgetCatalog) {
      expect(s.widgets[c.id]!.vis, c.enabled ? WidgetVis.on : WidgetVis.off);
    }
    expect(s.installedAt, now); // no transactions: today
  });

  test('onboarded install with no cohort yet is treated as existing', () async {
    final s = await resolveHomeCohort(isar, onboarded: true, now: now, waitForWrites: true);
    expect(s.cohort, HomeCohort.v2);
    expect(s.gsGraduationReason, GsGraduation.migrated);
  });

  test('runs once: a second launch changes nothing', () async {
    await WidgetPreferenceRepository(isar).save(WidgetEditorScope.home, customLayout());
    SharedPreferences.setMockInitialValues({PrefsKeys.homeLayout: 'v1'});
    final first = await resolveHomeCohort(isar, onboarded: true, now: now, waitForWrites: true);
    final rows1 = [for (final r in await homeRows(isar)) '${r.widgetKey}:${r.enabled}'];
    final second = await resolveHomeCohort(
      isar,
      onboarded: true,
      now: now.add(const Duration(days: 3)),
      waitForWrites: true,
    );
    expect(second.gsGraduatedAt, first.gsGraduatedAt); // read back, not re-run
    expect(
      [for (final r in await homeRows(isar)) '${r.widgetKey}:${r.enabled}'],
      rows1,
    );
    // Porting the same rows again gives the same states (idempotent step).
    final again = await portExistingUser(isar, now);
    expect(
      {for (final e in again.widgets.entries) e.key: e.value.vis},
      {for (final e in first.widgets.entries) e.key: e.value.vis},
    );
  });

  test('failure keeps the old layout, records the error, retries next launch', () async {
    await WidgetPreferenceRepository(isar).save(WidgetEditorScope.home, customLayout());
    SharedPreferences.setMockInitialValues({PrefsKeys.homeLayout: 'v1'});
    final st = await store();
    final failed = await migrateExistingUser(
      isar,
      st,
      now: now,
      port: (_, _) async => throw StateError('disk full'),
    );
    expect(failed.cohort, HomeCohort.v1);
    expect(st.readCohort(), HomeCohort.v1);
    expect(st.migrationVersion, 0);
    expect(st.migrationError, contains('disk full'));
    expect(await homeRows(isar), hasLength(kHomeWidgetCatalog.length)); // untouched

    final retry = await resolveHomeCohort(isar, onboarded: true, now: now, waitForWrites: true);
    expect(retry.cohort, HomeCohort.v2);
    expect((await store()).migrationError, isNull);
  });

  test('restoring an older backup ports its layout the same way', () async {
    // A v2 install restores a backup whose rows are a v1 layout.
    await resolveHomeCohort(isar, onboarded: false, now: now);
    await isar.writeTxn(() => isar.clear()); // what JSON restore does first
    final backup = customLayout();
    await isar.writeTxn(() => isar.widgetPreferences.putAll([
      for (var i = 0; i < backup.length; i++)
        WidgetPreference.fromMap({
          'scope': 'home',
          'widgetKey': backup[i].id,
          'order': i,
          'enabled': backup[i].enabled,
        }),
    ]));
    final s = await portExistingUser(isar, now);
    final rows = await homeRows(isar);
    expect([for (final r in rows) r.widgetKey], [for (final c in backup) c.id]);
    expect(s.widgets['quick_add']!.vis, WidgetVis.off);
    expect(s.widgets['recent_transactions']!.vis, WidgetVis.on);
    expect(s.gsGraduationReason, GsGraduation.migrated);
  });

  test('layout porting: enabled on, disabled off, missing ids off', () {
    final states = homeV2StatesFromLayout([
      kHomeWidgetCatalog.first.copyWith(enabled: true),
      kHomeWidgetCatalog[1].copyWith(enabled: false),
    ]);
    expect(states.keys.toSet(), {for (final c in kHomeWidgetCatalog) c.id});
    expect(states[kHomeWidgetCatalog.first.id]!.vis, WidgetVis.on);
    expect(states[kHomeWidgetCatalog[1].id]!.vis, WidgetVis.off);
    expect(states[kHomeWidgetCatalog.last.id]!.vis, WidgetVis.off);
  });

  test('widget classification covers every Home widget', () {
    expect(kWidgetDataNeeds.keys.toSet(), {for (final c in kHomeWidgetCatalog) c.id});
    expect(
      {for (final c in kHomeWidgetCatalog) if (needsTransactions(c.id)) c.id},
      {'balance_hero', 'spending_stats', 'quick_add', 'seven_day_chart', 'recent_transactions'},
    );
    expect(kWidgetDataNeeds['sms_import_widget'], WidgetDataNeed.always);
    expect(kWidgetDataNeeds['upcoming_events_widget'], WidgetDataNeed.otherData);
  });
}
