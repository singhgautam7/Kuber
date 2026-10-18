import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';
import '../../../l10n/app_localizations.dart';
import '../../widget_editor/models/home_widget_config.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../providers/home_v2_gates_provider.dart';
import '../providers/home_v2_provider.dart';
import 'home_v2_state.dart';

/// "What do you want to track?" (home-v3 V3-13, chips per v3.1 V31-06).
/// Chip order and the widgets each one turns on from day 1.
const kTrackingChoices = ['budgets', 'loans', 'investments', 'ledger', 'subscriptions'];

const Map<String, String> kTrackingWidget = {
  'budgets': 'budget_snapshot',
  'loans': 'upcoming_events_widget',
  'investments': 'upcoming_events_widget',
  'ledger': 'upcoming_events_widget',
  'subscriptions': 'upcoming_events_widget',
};

String trackingLabel(AppLocalizations l, String key) => switch (key) {
  'budgets' => l.homeV31TrkBudgets,
  'loans' => l.homeV3TrkLoans,
  'investments' => l.homeV3TrkInvest,
  'ledger' => l.homeV3TrkLedger,
  _ => l.homeV3TrkSubs,
};

/// Widget ids turned on by [choices].
Set<String> trackingWidgetsFor(Iterable<String> choices) => {
  for (final c in choices) ?kTrackingWidget[c],
};

Future<Set<String>> readTrackingChoices() async =>
    ((await SharedPreferences.getInstance()).getStringList(
              PrefsKeys.trackingChoices,
            ) ??
            const <String>[])
        .toSet();

Future<void> saveTrackingChoices(Set<String> choices, {required bool skipped}) async {
  final p = await SharedPreferences.getInstance();
  await p.setStringList(PrefsKeys.trackingChoices, [
    for (final c in kTrackingChoices)
      if (choices.contains(c)) c,
  ]);
  await p.setString(PrefsKeys.trackingAnswer, skipped ? 'skipped' : 'picked');
}

/// Welcome: saves the picks and turns their widgets on (state `on`, row
/// enabled at its catalog position), unless the user switched one off. The
/// transaction gate still decides when a widget can show.
Future<void> applyWelcomeTracking(WidgetRef ref, Set<String> choices) async {
  await saveTrackingChoices(choices, skipped: false);
  final ids = trackingWidgetsFor(choices);
  final snap = ref.read(homeV2Provider);
  if (ids.isEmpty || !snap.isV2) return;
  final turnOn = {
    for (final id in ids)
      if (snap.widgets[id]?.vis != WidgetVis.off) id,
  };
  if (turnOn.isEmpty) return;
  final now = DateTime.now();
  await ref.read(homeV2Provider.notifier).update(
    (s) => s.copyWith(
      widgets: {
        ...s.widgets,
        for (final id in turnOn)
          id: (s.widgets[id] ?? const HomeV2WidgetState(vis: WidgetVis.auto))
              .copyWith(vis: WidgetVis.on, unlockedAt: now),
      },
    ),
  );
  final repo = ref.read(widgetPreferenceRepositoryProvider);
  final configs = await repo.readForScope(WidgetEditorScope.home);
  await repo.save(WidgetEditorScope.home, insertUnlocked(configs, turnOn));
  ref.invalidate(homeWidgetsProvider);
}
