import 'package:isar_community/isar.dart';

import '../../accounts/data/account.dart';
import '../../transactions/data/transaction.dart';
import '../../widget_editor/data/widget_catalog.dart';
import '../../widget_editor/data/widget_preference.dart';
import '../../widget_editor/data/widget_preference_repository.dart';
import '../../widget_editor/models/home_widget_config.dart';
import 'home_v2_state.dart';

/// Home v2 widget classes (widget-inventory.md › Inventory).
enum HomeWidgetClass { defaultOn, dataGated, optIn }

/// Class per catalog id. `kHomeWidgetCatalog` itself is unchanged, so v1
/// keeps today's defaults.
const Map<String, HomeWidgetClass> kHomeV2Classes = {
  'balance_hero': HomeWidgetClass.defaultOn,
  'insight_stories': HomeWidgetClass.dataGated,
  'spending_stats': HomeWidgetClass.dataGated,
  'quick_add': HomeWidgetClass.defaultOn,
  'ask_kuber_widget': HomeWidgetClass.optIn,
  // Default, not Data-gated (user review): SMS import is a key feature and
  // stays reachable if Get started or suggestions are turned off.
  'sms_import_widget': HomeWidgetClass.defaultOn,
  'home_accounts': HomeWidgetClass.dataGated,
  'seven_day_chart': HomeWidgetClass.dataGated,
  'budget_snapshot': HomeWidgetClass.dataGated,
  'upcoming_events_widget': HomeWidgetClass.dataGated,
  'kuber_notes_widget': HomeWidgetClass.dataGated,
  // Opt-in, not Default (user review).
  'recent_transactions': HomeWidgetClass.optIn,
};

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

/// Catalog-order configs for a v2 install, `enabled` = the stored state is
/// `on`. Used to seed (and reseed after Erase all data) the `home` rows, so
/// the dashboard's normal render path shows exactly the v2 set.
List<HomeWidgetConfig> homeV2ConfigsFrom(
  Map<String, HomeV2WidgetState> states,
) {
  final initial = homeV2InitialWidgetStates();
  return [
    for (final c in kHomeWidgetCatalog)
      c.copyWith(
        enabled: (states[c.id] ?? initial[c.id]!).vis == WidgetVis.on,
      ),
  ];
}

/// Decides the cohort on the first launch of the Home v2 build and, for a
/// new install, seeds the v2 rows. Runs in `_bootstrap` because the answer
/// decides the first Home layout; on every later launch it is a single
/// prefs read. Inputs on the first launch: the onboarded flag (already read)
/// and two Isar `count()` calls.
Future<HomeV2Snapshot> resolveHomeCohort(
  Isar isar, {
  required bool onboarded,
}) async {
  final store = await HomeV2Store.open();
  if (store.readCohort() != null) return store.read();

  final hasHomeRows =
      await isar.widgetPreferences.filter().scopeEqualTo('home').count() > 0;
  final hasTransactions = await isar.transactions.count() > 0;
  if (onboarded || hasHomeRows || hasTransactions) {
    await store.writeCohort(HomeCohort.v1);
    return HomeV2Snapshot.v1;
  }

  // New install: remember what was seeded (Cash / Bank / Credit Card today)
  // so the Bank Accounts trigger can ignore those accounts.
  final seeded = await isar.accounts.where().idProperty().findAll();
  final snapshot = HomeV2Snapshot(
    cohort: HomeCohort.v2,
    installedAt: DateTime.now(),
    seededAccountIds: seeded.toSet(),
    widgets: homeV2InitialWidgetStates(),
  );
  await WidgetPreferenceRepository(
    isar,
  ).save(WidgetEditorScope.home, homeV2ConfigsFrom(snapshot.widgets));
  await store.write(snapshot);
  return snapshot;
}
