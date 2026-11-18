import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../advanced_history/data/saved_filter.dart';
import '../../ask_kuber/data/ask_kuber_message.dart';
import '../../backups/data/backup_config.dart';
import '../../kuber_cards/data/stored_card.dart';
import '../../notes/data/kuber_note.dart';
import '../../reminders/data/reminder.dart';
import '../../transactions/data/transaction.dart';
import 'trial_state.dart';

/// The ten Pro features the trial nudges toward, in priority order.
enum ProTrialFeature {
  ask,
  sms,
  dashboards,
  reminders,
  themes,
  notes,
  advancedAnalytics,
  backups,
  cards,
  multiCurrency;

  IconData get icon => switch (this) {
        ask => Icons.auto_awesome_rounded,
        sms => Icons.sms_outlined,
        dashboards => Icons.dashboard_customize_outlined,
        reminders => Icons.notifications_active_outlined,
        themes => Icons.palette_outlined,
        notes => Icons.sticky_note_2_outlined,
        advancedAnalytics => Icons.insert_chart_outlined_rounded,
        backups => Icons.cloud_sync_outlined,
        cards => Icons.credit_card_rounded,
        multiCurrency => Icons.currency_exchange_rounded,
      };

  /// Where "Try" and the card action go.
  String get route => switch (this) {
        ask => '/more/ask-kuber',
        sms => '/more/sms-import',
        dashboards => '/advanced-history',
        reminders => '/reminders/add',
        themes => '/more/settings/theme',
        notes => '/notes/editor',
        advancedAnalytics => '/advanced-analytics',
        backups => '/more/data/automatic-backups',
        cards => '/cards/add',
        multiCurrency => '/accounts/add',
      };
}

/// Which features were tried during the trial. Ticks live in SharedPreferences
/// (never in a backup). [markTried] is static so any screen can call it.
class ProTrialChecklist {
  static const _key = 'kuber_trial_tried_v1';
  static final ValueNotifier<Set<ProTrialFeature>> tried = ValueNotifier(const {});
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final p = await SharedPreferences.getInstance();
      final names = p.getStringList(_key) ?? const [];
      final s = {
        for (final f in ProTrialFeature.values)
          if (names.contains(f.name)) f,
        ...tried.value,
      };
      if (s.length != tried.value.length) tried.value = s;
    } catch (_) {}
  }

  static Future<void> markTried(ProTrialFeature f) async {
    await load();
    if (tried.value.contains(f)) return;
    tried.value = {...tried.value, f};
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(_key, [for (final x in tried.value) x.name]);
    } catch (_) {}
  }

  @visibleForTesting
  static void reset() {
    _loaded = false;
    tried.value = const {};
  }
}

class _TriedNotifier extends Notifier<Set<ProTrialFeature>> {
  @override
  Set<ProTrialFeature> build() {
    void l() => state = ProTrialChecklist.tried.value;
    ProTrialChecklist.tried.addListener(l);
    ref.onDispose(() => ProTrialChecklist.tried.removeListener(l));
    ProTrialChecklist.load();
    return ProTrialChecklist.tried.value;
  }
}

final triedFeaturesProvider =
    NotifierProvider<_TriedNotifier, Set<ProTrialFeature>>(_TriedNotifier.new);

/// What the user did since the trial started (one cheap pass of count queries).
class TrialUsage {
  final int sms, dashboards, asks, notes, reminders, backups, cards;
  const TrialUsage({
    this.sms = 0,
    this.dashboards = 0,
    this.asks = 0,
    this.notes = 0,
    this.reminders = 0,
    this.backups = 0,
    this.cards = 0,
  });
}

/// Counts from the trial window. Autodisposed: read when a sheet opens or by
/// the once-per-session reconcile.
final trialUsageProvider = FutureProvider.autoDispose<TrialUsage>((ref) async {
  final since = ref.read(proTrialProvider).startAt;
  if (since == null) return const TrialUsage();
  final isar = ref.read(isarProvider);
  final backup = await isar.backupConfigs.where().findFirst();
  return TrialUsage(
    sms: await isar.transactions
        .filter()
        .importSourceEqualTo('sms')
        .updatedAtGreaterThan(since)
        .count(),
    dashboards: await isar.savedFilters.filter().createdAtGreaterThan(since).count(),
    asks: await isar.askKuberMessages
        .filter()
        .isUserEqualTo(true)
        .timeGreaterThan(since)
        .count(),
    notes: await isar.kuberNotes.filter().createdAtGreaterThan(since).count(),
    reminders: await isar.reminders.filter().createdAtGreaterThan(since).count(),
    backups: backup?.lastBackupAt?.isAfter(since) == true ? 1 : 0,
    cards: await isar.storedCards.filter().createdAtGreaterThan(since).count(),
  );
});
