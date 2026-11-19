import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart' show ThemeVariant;
import '../../../main.dart' show onOpenBatchReadyProvider;
import '../../settings/providers/settings_provider.dart';
import 'trial_checklist.dart';
import 'trial_state.dart';

/// Ticks features from existing data, once per app session, after the on-open
/// batch is ready (never before the first frame). Watched by the Home badge.
final trialReconcileProvider = FutureProvider<void>((ref) async {
  if (!ref.watch(onOpenBatchReadyProvider)) return;
  final active = ref.watch(proTrialProvider.select((t) => t.isActive));
  if (!active) return;
  final u = await ref.read(trialUsageProvider.future);
  final themed =
      ref.read(themeVariantProvider) != ThemeVariant.signature;
  for (final e in {
    ProTrialFeature.sms: u.sms > 0,
    ProTrialFeature.dashboards: u.dashboards > 0,
    ProTrialFeature.ask: u.asks > 0,
    ProTrialFeature.notes: u.notes > 0,
    ProTrialFeature.reminders: u.reminders > 0,
    ProTrialFeature.backups: u.backups > 0,
    ProTrialFeature.cards: u.cards > 0,
    ProTrialFeature.themes: themed,
  }.entries) {
    if (e.value) await ProTrialChecklist.markTried(e.key);
  }
});
