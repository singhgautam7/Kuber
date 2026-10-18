import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import '../../ask_kuber/data/ask_kuber_message.dart';
import '../../transactions/data/transaction.dart';
import '../../widget_editor/data/widget_catalog.dart';
import '../../widget_editor/data/widget_preference_repository.dart';
import '../../widget_editor/models/home_widget_config.dart';
import 'home_v2_state.dart';

/// Update migration (specs/home-v3.3/plan.md §2): moves an existing user
/// (cohort v1) onto the widget model with their own layout. Bump when a
/// later build needs another step.
const kHomeMigrationVersion = 1;

/// v2 state for an existing layout: enabled → on, everything else off. No
/// widget is `auto`, so nothing appears or disappears by the Data-gated
/// rules; only the transaction gate (plan §3) applies.
Map<String, HomeV2WidgetState> homeV2StatesFromLayout(
  List<HomeWidgetConfig> layout,
) => {
  for (final c in kHomeWidgetCatalog)
    c.id: const HomeV2WidgetState(vis: WidgetVis.off),
  for (final c in layout)
    c.id: HomeV2WidgetState(vis: c.enabled ? WidgetVis.on : WidgetVis.off),
};

/// Snapshot for an existing user, built from the Home layout as v1 renders
/// it (stored rows + catalog reconciliation, or catalog defaults). Reads
/// only; the layout rows stay as they are.
Future<HomeV2Snapshot> portExistingUser(Isar isar, DateTime now) async {
  final layout = await WidgetPreferenceRepository(
    isar,
  ).readForScope(WidgetEditorScope.home);
  // createdAt is indexed: the oldest row comes straight off the index.
  final oldest = await isar.transactions
      .where()
      .anyCreatedAt()
      .createdAtProperty()
      .findFirst();
  return HomeV2Snapshot(
    cohort: HomeCohort.v2,
    // Install-age discovery rules (Home widget 7 days, Kuber Cards 14) see
    // the real age, not "installed today".
    installedAt: oldest ?? now,
    widgets: homeV2StatesFromLayout(layout),
    // Graduated so the user never sees Get started; 25 h ago so the
    // suggestion engine's 24 h wait after graduation is already met.
    gsGraduatedAt: now.subtract(const Duration(hours: 25)),
    gsGraduationReason: GsGraduation.migrated,
    gsSuccessShown: true,
    askOpened: await isar.askKuberMessages.count() > 0,
  );
}

/// Runs migration v1 for an existing user.
///
/// The port (reads only) runs before the first frame; the snapshot it
/// returns is what this session uses. Persisting it is ~15 prefs commits,
/// which the Android plugin writes one after another (~120 ms cold), so it
/// runs right after, in order: every field, then the cohort, then the
/// version. Killed half way, the stored cohort is still v1 and the next
/// launch simply runs the migration again (it is idempotent and the layout
/// rows are never written). Any failure puts the cohort back to v1, records
/// the error and leaves the version unset, so the next launch retries.
Future<HomeV2Snapshot> migrateExistingUser(
  Isar isar,
  HomeV2Store store, {
  DateTime? now,
  /// Dev tools and tests wait for the save; the boot path does not.
  bool waitForWrites = false,
  @visibleForTesting
  Future<HomeV2Snapshot> Function(Isar isar, DateTime now) port =
      portExistingUser,
}) async {
  final at = now ?? DateTime.now();
  final sw = Stopwatch()..start();
  Future<void> fail(Object e) async {
    try {
      await store.writeCohort(HomeCohort.v1);
      await store.recordMigrationError(at, e);
    } catch (_) {}
    debugPrint('Kuber homeV3.3: migration failed, will retry: $e');
  }

  final HomeV2Snapshot snap;
  try {
    snap = await port(isar, at);
  } catch (e) {
    await fail(e);
    return HomeV2Snapshot.v1;
  }
  final ported = sw.elapsedMilliseconds;
  Future<void> persist() async {
    try {
      await store.write(snap.copyWith(cohort: HomeCohort.v1));
      await store.writeCohort(HomeCohort.v2);
      await store.setMigrationVersion(kHomeMigrationVersion);
      // Once per install, in every build mode (performance-review.md).
      debugPrint(
        'Kuber homeV3.3: migration port $ported ms (before first frame), '
        'saved after ${sw.elapsedMilliseconds} ms',
      );
    } catch (e) {
      await fail(e);
    }
  }

  final saving = persist();
  if (waitForWrites) await saving;
  return snap;
}
