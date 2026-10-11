import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../transactions/data/transaction.dart';
import '../../widget_editor/data/widget_preference.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../data/home_v2_state.dart';
import '../providers/home_v2_provider.dart';

/// After a backup restore or CSV import into a Home v2 install
/// (open-decisions 9). v1 installs return immediately.
///
/// - The backup brought its own Home layout (widget rows restored): adopt it
///   and switch this install to v1, which also retires Get started.
/// - No layout in the backup: stay v2 and Data-gated widgets turn on by
///   their triggers. Get started graduates (reason `transactions`, no
///   success card) once the restore brought transactions: a restored user
///   is not setting up (Home v2 brief; spec §9 kept it running).
Future<void> onHomeV2DataRestored(Ref ref, Isar isar) async {
  final s = ref.read(homeV2Provider);
  if (!s.isV2) return;
  final hasHomeRows =
      await isar.widgetPreferences.filter().scopeEqualTo('home').count() > 0;
  if (hasHomeRows) {
    await ref.read(homeV2Provider.notifier).replace(HomeV2Snapshot.v1);
  } else if (!s.gsGraduated && await isar.transactions.count() > 0) {
    await ref.read(homeV2Provider.notifier).update(
      (s) => s.copyWith(
        gsGraduatedAt: () => DateTime.now(),
        gsGraduationReason: () => GsGraduation.transactions,
        gsSuccessShown: true,
      ),
    );
  }
  ref.invalidate(homeWidgetsProvider);
}
