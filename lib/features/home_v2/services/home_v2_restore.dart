import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../transactions/data/transaction.dart';
import '../../widget_editor/data/widget_preference.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../data/home_migration.dart';
import '../data/home_v2_state.dart';
import '../providers/home_v2_provider.dart';

/// After a backup restore or CSV import (specs/home-v3.3/plan.md §2).
///
/// - JSON restore that brought a Home layout ([jsonRestore] and `home` rows
///   exist; restore clears Isar first, so any row came from the backup): run
///   the update migration's port step on it, for every cohort. The user sees
///   the backup's widgets in the backup's order on the widget model, with Get
///   started graduated. Settings and flags of this install are kept.
/// - Otherwise (CSV import, or a backup without a layout): the layout stays;
///   a v2 install still setting up graduates Get started once the import
///   brought transactions (no success card).
///
/// Call it before anything re-reads the Home layout (the dashboard reseeds
/// missing rows), i.e. before refreshing providers.
Future<void> onHomeV2DataRestored(
  Ref ref,
  Isar isar, {
  required bool jsonRestore,
}) async {
  final s = ref.read(homeV2Provider);
  final notifier = ref.read(homeV2Provider.notifier);
  final hasHomeRows =
      jsonRestore &&
      await isar.widgetPreferences.filter().scopeEqualTo('home').count() > 0;
  if (hasHomeRows) {
    final ported = await portExistingUser(isar, DateTime.now());
    await notifier.replace(
      s.isV2
          ? ported.copyWith(
              gsSetting: s.gsSetting,
              sgSetting: s.sgSetting,
              voiceUsed: s.voiceUsed,
              smsRequested: s.smsRequested,
              balanceSet: s.balanceSet,
              askOpened: ported.askOpened || s.askOpened,
            )
          : ported,
    );
    await (await HomeV2Store.open()).setMigrationVersion(kHomeMigrationVersion);
  } else if (s.isV2 && !s.gsGraduated && await isar.transactions.count() > 0) {
    await notifier.update(
      (s) => s.copyWith(
        gsGraduatedAt: () => DateTime.now(),
        gsGraduationReason: () => GsGraduation.transactions,
        gsSuccessShown: true,
      ),
    );
  }
  ref.invalidate(homeWidgetsProvider);
}
