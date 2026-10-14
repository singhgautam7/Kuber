import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/data/account.dart';
import '../../widget_editor/data/widget_preference_repository.dart';
import '../../widget_editor/models/home_widget_config.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../why_kuber/why_kuber_store.dart';
import '../data/home_migration.dart';
import '../data/home_v2_state.dart';
import '../data/home_v2_widgets.dart';
import '../engine/suggestion_engine.dart';
import '../providers/get_started_provider.dart';
import '../providers/home_suggestion_provider.dart';
import '../providers/home_v2_gates_provider.dart';
import '../providers/home_v2_provider.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dev tools: make this install a fresh Home v2 install again (keeps data).
/// Cohort v2, v2 widget defaults, Get started back, suggestion state clear.
/// With existing data, Data-gated widgets turn on again by their triggers
/// and Get started may graduate at once (10+ transactions).
Future<void> resetHomeV2Onboarding(BuildContext context, WidgetRef ref) async {
  final isar = ref.read(isarProvider);
  final store = await HomeV2Store.open();
  await store.clearV2State();
  final seeded = await isar.accounts.where().idProperty().findAll();
  final snap = HomeV2Snapshot(
    cohort: HomeCohort.v2,
    installedAt: DateTime.now(),
    seededAccountIds: seeded.toSet(),
    widgets: homeV2InitialWidgetStates(),
  );
  await WidgetPreferenceRepository(
    isar,
  ).save(WidgetEditorScope.home, homeV2ConfigsFrom(snap.widgets));
  await ref.read(homeV2Provider.notifier).replace(snap);
  ref.invalidate(homeWidgetsProvider);
  ref.invalidate(getStartedProvider);
  ref.invalidate(homeSuggestionProvider);
  ref.read(homeV2GatesProvider).poke();
  if (context.mounted) {
    showKuberSnackBar(context, 'Home v2 onboarding reset. Open Home.');
  }
}

/// Dev tools: run the real rules on this install's data now. Skips the
/// waits that make this slow to test by hand: the 24 h after Get started,
/// the one-new-per-day cap, the 2-day cooldown after a dismiss and the
/// once-per-session run. Snoozed and dismissed instances stay as they are.
Future<void> runSuggestionRulesNow(BuildContext context, WidgetRef ref) async {
  if (!ref.read(homeV2Provider).isV2) {
    showKuberSnackBar(
      context,
      'This install is v1. Reset Home v2 onboarding first.',
      isError: true,
    );
    return;
  }
  final dayAgo = DateTime.now().subtract(const Duration(hours: 25));
  await ref.read(homeV2Provider.notifier).update(
    (s) => s.copyWith(
      gsGraduatedAt: () =>
          s.gsGraduatedAt == null || s.gsGraduatedAt!.isAfter(dayAgo)
          ? dayAgo
          : s.gsGraduatedAt,
      gsGraduationReason: () => s.gsGraduationReason ?? GsGraduation.completed,
      gsSuccessShown: true,
    ),
  );
  final p = await SharedPreferences.getInstance();
  await p.remove(PrefsKeys.sgLastNewShownDay);
  await p.remove(PrefsKeys.sgLastDismissAt);
  final notifier = ref.read(homeSuggestionProvider.notifier);
  await notifier.runNow();
  final card = ref.read(homeSuggestionProvider).card;
  if (context.mounted) {
    showKuberSnackBar(
      context,
      card == null
          ? 'No rule matched (or the promo banner is showing).'
          : 'Picked ${card.key}. Open Home.',
    );
  }
}

/// Dev tools › Reset Why Kuber: clears "seen" and the card dismissal, then
/// re-resolves the top slot so the card can show at once.
Future<void> resetWhyKuber(BuildContext context, WidgetRef ref) async {
  await WhyKuberStore.reset();
  await ref.read(homeSuggestionProvider.notifier).runNow();
  if (context.mounted) {
    showKuberSnackBar(context, 'Why Kuber reset. Open Home.');
  }
}

/// Dev tools › Re-run update migration: makes this install look like an
/// existing (pre-update) user with its current Home layout, then runs the
/// migration exactly as the first launch after the update does.
Future<void> rerunUpdateMigration(BuildContext context, WidgetRef ref) async {
  final store = await HomeV2Store.open();
  await store.writeCohort(HomeCohort.v1);
  await store.prefs.remove(PrefsKeys.homeMigrationVersion);
  final sw = Stopwatch()..start();
  final snap = await migrateExistingUser(
    ref.read(isarProvider),
    store,
    waitForWrites: true,
  );
  final ms = sw.elapsedMilliseconds;
  await ref.read(homeV2Provider.notifier).replace(snap);
  ref.invalidate(homeWidgetsProvider);
  ref.invalidate(homeSuggestionProvider);
  if (!context.mounted) return;
  showKuberSnackBar(
    context,
    snap.isV2
        ? 'Migration ran in $ms ms. Open Home.'
        : 'Migration failed: ${store.migrationError}',
    isError: !snap.isV2,
  );
}

/// Sample instance per type for "Force suggestion".
List<SgCandidate> forceSamples() => [
  const SgCandidate(
    type: SgType.loans,
    key: 'loans',
    data: {'lender': 'HDFC', 'amount': 12400.0, 'day': 5},
  ),
  const SgCandidate(
    type: SgType.creditCard,
    key: 'cc:0',
    data: {'card': 'Credit Card', 'accountId': 0},
  ),
  SgCandidate(
    type: SgType.recurring,
    key: 'recurring:netflix',
    data: {
      'merchant': 'Netflix',
      'amount': 649.0,
      'nextDate': DateTime.now().add(const Duration(days: 20)),
    },
  ),
  const SgCandidate(
    type: SgType.investments,
    key: 'investments',
    data: {'amount': 5000.0, 'amc': 'Parag Parikh', 'day': 10},
  ),
  const SgCandidate(
    type: SgType.budget,
    key: 'budget:0',
    data: {
      'categoryId': '',
      'category': 'Food',
      'total': 4820.0,
      'amount': 5000.0,
    },
  ),
  const SgCandidate(
    type: SgType.ledger,
    key: 'ledger',
    data: {'variant': 'transfer', 'name': 'Rahul', 'amount': 2500.0},
  ),
  const SgCandidate(type: SgType.askKuber, key: 'ask_kuber'),
  const SgCandidate(type: SgType.voice, key: 'voice'),
  const SgCandidate(type: SgType.homeWidget, key: 'home_widget'),
  const SgCandidate(type: SgType.kuberCards, key: 'kuber_cards'),
];

/// Dev tools: pick any rule and show its card now, skipping eligibility,
/// caps and cooldowns. Graduates Get started so the slot can show it.
void showForceSuggestionSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => KuberBottomSheet(
      title: 'Force suggestion',
      description: 'Shows the card on Home now with sample data.',
      child: KuberGroup(
        children: [
          for (final c in forceSamples())
            KuberListRow(
              title: c.type.name,
              subtitle: c.type.isDiscovery
                  ? 'Discovery'
                  : 'Data rule ${c.type.priority}',
              trailing: const KuberChevron(),
              onTap: () async {
                Navigator.of(sheetCtx).pop();
                if (!ref.read(homeV2Provider).isV2) {
                  showKuberSnackBar(
                    context,
                    'This install is v1. Reset Home v2 onboarding first.',
                    isError: true,
                  );
                  return;
                }
                await ref
                    .read(homeV2Provider.notifier)
                    .update(
                      (s) => s.copyWith(
                        gsGraduatedAt: () =>
                            s.gsGraduatedAt ??
                            DateTime.now().subtract(const Duration(days: 2)),
                        gsGraduationReason: () =>
                            s.gsGraduationReason ?? GsGraduation.completed,
                        gsSuccessShown: true,
                      ),
                    );
                await ref.read(homeSuggestionProvider.notifier).force(c);
                if (context.mounted) {
                  showKuberSnackBar(context, 'Suggestion forced. Open Home.');
                }
              },
            ),
        ],
      ),
    ),
  );
}
