import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:isar_community/isar.dart';

import '../../accounts/data/account.dart';
import '../../transactions/data/transaction.dart';
import '../../widget_editor/data/widget_catalog.dart';
import '../../widget_editor/data/widget_preference.dart';
import '../../widget_editor/data/widget_preference_repository.dart';
import '../../widget_editor/models/home_widget_config.dart';
import 'home_migration.dart';
import 'home_v2_state.dart';

/// Home v2 widget classes (widget-inventory.md › Inventory).
enum HomeWidgetClass { defaultOn, dataGated, optIn }

/// Class per catalog id. `kHomeWidgetCatalog` itself is unchanged, so v1
/// keeps today's defaults.
const Map<String, HomeWidgetClass> kHomeV2Classes = {
  'balance_hero': HomeWidgetClass.defaultOn,
  // On from day 1 and first on Home (user review): the Welcome story is
  // there before any transaction.
  'insight_stories': HomeWidgetClass.defaultOn,
  'spending_stats': HomeWidgetClass.dataGated,
  'quick_add': HomeWidgetClass.defaultOn,
  'ask_kuber_widget': HomeWidgetClass.optIn,
  // Default, not Data-gated (user review): SMS import is a key feature and
  // stays reachable if Get started or suggestions are turned off.
  'sms_import_widget': HomeWidgetClass.defaultOn,
  'home_accounts': HomeWidgetClass.dataGated,
  'seven_day_chart': HomeWidgetClass.dataGated,
  // More widgets (user review): off until turned on by hand or by a
  // tracking choice.
  'budget_snapshot': HomeWidgetClass.optIn,
  'upcoming_events_widget': HomeWidgetClass.optIn,
  'kuber_notes_widget': HomeWidgetClass.optIn,
  // Opt-in, not Default (user review).
  'recent_transactions': HomeWidgetClass.optIn,
};

/// What a Home widget needs before it can show anything
/// (specs/home-v3.3/plan.md §3).
enum WidgetDataNeed { transactions, otherData, always }

const Map<String, WidgetDataNeed> kWidgetDataNeeds = {
  'balance_hero': WidgetDataNeed.transactions,
  'insight_stories': WidgetDataNeed.otherData,
  'spending_stats': WidgetDataNeed.transactions,
  // Hidden until the first transaction (user review); its intro card comes
  // at 2 transactions.
  'quick_add': WidgetDataNeed.transactions,
  'ask_kuber_widget': WidgetDataNeed.always,
  'sms_import_widget': WidgetDataNeed.always,
  'home_accounts': WidgetDataNeed.otherData,
  'seven_day_chart': WidgetDataNeed.transactions,
  'budget_snapshot': WidgetDataNeed.otherData,
  'upcoming_events_widget': WidgetDataNeed.otherData,
  'kuber_notes_widget': WidgetDataNeed.otherData,
  'recent_transactions': WidgetDataNeed.transactions,
};

/// Transaction gate: hidden while the install has no transaction, whatever
/// its state (on, a tracking choice, Show all widgets, a ported layout).
bool needsTransactions(String id) =>
    kWidgetDataNeeds[id] == WidgetDataNeed.transactions;

/// Home v2 order for new installs and for placing a widget that turns on:
/// the catalog order with Money Stories first (above the Balance Card).
final List<String> kHomeV2Order = [
  'insight_stories',
  for (final c in kHomeWidgetCatalog)
    if (c.id != 'insight_stories') c.id,
];

HomeWidgetClass homeV2ClassOf(String id) =>
    kHomeV2Classes[id] ?? HomeWidgetClass.optIn;

/// Initial v2 visibility per class: Default on, Data-gated auto, Opt-in off.
Map<String, HomeV2WidgetState> homeV2InitialWidgetStates() => {
  for (final c in kHomeWidgetCatalog)
    c.id: HomeV2WidgetState(
      vis: switch (homeV2ClassOf(c.id)) {
        HomeWidgetClass.defaultOn => WidgetVis.on,
        HomeWidgetClass.dataGated => WidgetVis.auto,
        HomeWidgetClass.optIn => WidgetVis.off,
      },
    ),
};

/// [kHomeV2Order] configs for a v2 install, `enabled` = the stored state is
/// `on`. Used to seed (and reseed after Erase all data) the `home` rows, so
/// the dashboard's normal render path shows exactly the v2 set.
List<HomeWidgetConfig> homeV2ConfigsFrom(
  Map<String, HomeV2WidgetState> states,
) {
  final initial = homeV2InitialWidgetStates();
  final byId = {for (final c in kHomeWidgetCatalog) c.id: c};
  return [
    for (final id in kHomeV2Order)
      byId[id]!.copyWith(
        enabled: (states[id] ?? initial[id]!).vis == WidgetVis.on,
      ),
  ];
}

/// Decides the Home layout before the first frame (it picks the first Home
/// layout), and runs the update migration once per install.
///
/// - Cohort v2: returned as stored (the migration has nothing to port).
/// - No cohort yet, fresh install (not onboarded, no Home rows, no
///   transactions): v2 with day-1 defaults, as in Home v2.
/// - Existing user (cohort v1, or no cohort but onboarded / data / rows):
///   migrated onto the widget model with their own layout
///   (`home_migration.dart`). A failed run keeps v1 and retries next launch.
///
/// Later launches: prefs reads only.
Future<HomeV2Snapshot> resolveHomeCohort(
  Isar isar, {
  required bool onboarded,
  DateTime? now,
  @visibleForTesting bool waitForWrites = false,
}) async {
  final store = await HomeV2Store.open();
  final cohort = store.readCohort();
  if (cohort == HomeCohort.v2) {
    if (store.migrationVersion < kHomeMigrationVersion) {
      await store.setMigrationVersion(kHomeMigrationVersion);
    }
    return store.read();
  }

  if (cohort == null) {
    final hasHomeRows =
        await isar.widgetPreferences.filter().scopeEqualTo('home').count() > 0;
    final hasTransactions = await isar.transactions.count() > 0;
    if (!onboarded && !hasHomeRows && !hasTransactions) {
      // New install: remember what was seeded (Cash / Bank / Credit Card
      // today) so the Bank Accounts trigger can ignore those accounts.
      final seeded = await isar.accounts.where().idProperty().findAll();
      final snapshot = HomeV2Snapshot(
        cohort: HomeCohort.v2,
        installedAt: now ?? DateTime.now(),
        seededAccountIds: seeded.toSet(),
        widgets: homeV2InitialWidgetStates(),
      );
      await WidgetPreferenceRepository(
        isar,
      ).save(WidgetEditorScope.home, homeV2ConfigsFrom(snapshot.widgets));
      await store.write(snapshot);
      await store.setMigrationVersion(kHomeMigrationVersion);
      return snapshot;
    }
    await store.writeCohort(HomeCohort.v1);
  }

  if (store.migrationVersion >= kHomeMigrationVersion) return HomeV2Snapshot.v1;
  return migrateExistingUser(
    isar,
    store,
    now: now,
    waitForWrites: waitForWrites,
  );
}
