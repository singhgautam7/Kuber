import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../trial_checklist.dart';
import '../trial_state.dart';
import 'trial_sheet.dart';

/// "2 Dec": the day Pro stops, from [TrialInfo.endAt].
String trialDate(BuildContext context, DateTime d) =>
    DateFormat('d MMM', context.l10n.localeName).format(d.toLocal());

String trialTime(BuildContext context, DateTime d) =>
    DateFormat.jm(context.l10n.localeName).format(d.toLocal());

/// Claim (Home card or Pro page) then the trial sheet.
Future<void> claimTrial(BuildContext context, WidgetRef ref) async {
  // The claim entry leaves the tree as soon as the trial starts (the Pro page
  // switches to its trial state), so open the sheet from the root navigator.
  final nav = Navigator.of(context, rootNavigator: true);
  final outcome = await ref.read(proTrialProvider.notifier).claim();
  if (!nav.mounted) return;
  await showTrialSheet(nav.context, outcome);
}

extension ProTrialFeatureText on ProTrialFeature {
  String featureName(AppLocalizations l) => switch (this) {
        ProTrialFeature.ask => l.trialFeatAsk,
        ProTrialFeature.sms => l.trialFeatSms,
        ProTrialFeature.dashboards => l.trialFeatDash,
        ProTrialFeature.reminders => l.trialFeatRem,
        ProTrialFeature.themes => l.trialFeatTheme,
        ProTrialFeature.notes => l.trialFeatNotes,
        ProTrialFeature.advancedAnalytics => l.trialFeatAdv,
        ProTrialFeature.backups => l.trialFeatBackup,
        ProTrialFeature.cards => l.trialFeatCards,
        ProTrialFeature.multiCurrency => l.trialFeatCurrency,
      };

  String placeName(AppLocalizations l) => switch (this) {
        ProTrialFeature.sms => l.trialPlaceHistory,
        ProTrialFeature.dashboards || ProTrialFeature.advancedAnalytics => l.trialPlaceAnalytics,
        ProTrialFeature.cards => l.trialPlaceMore,
        ProTrialFeature.backups => l.trialPlaceSettings,
        ProTrialFeature.multiCurrency => l.trialPlaceAccounts,
        ProTrialFeature.themes => l.trialPlaceLook,
        _ => l.trialPlaceHome,
      };

  String usedLabel(AppLocalizations l) => switch (this) {
        ProTrialFeature.ask => l.trialUsedAsk,
        ProTrialFeature.sms => l.trialUsedSms,
        ProTrialFeature.dashboards => l.trialUsedDash,
        ProTrialFeature.reminders => l.trialUsedRem,
        ProTrialFeature.themes => l.trialUsedTheme,
        ProTrialFeature.notes => l.trialUsedNotes,
        ProTrialFeature.advancedAnalytics => l.trialUsedAdv,
        ProTrialFeature.backups => l.trialUsedBackup,
        ProTrialFeature.cards => l.trialUsedCards,
        ProTrialFeature.multiCurrency => l.trialUsedCurrency,
      };

  String suggTitle(AppLocalizations l) => switch (this) {
        ProTrialFeature.ask => l.trialSuggAskTitle,
        ProTrialFeature.sms => l.trialSuggSmsTitle,
        ProTrialFeature.dashboards => l.trialSuggDashTitle,
        ProTrialFeature.reminders => l.trialSuggRemTitle,
        ProTrialFeature.themes => l.trialSuggThemeTitle,
        ProTrialFeature.notes => l.trialSuggNotesTitle,
        ProTrialFeature.advancedAnalytics => l.trialSuggAdvTitle,
        ProTrialFeature.backups => l.trialSuggBackupTitle,
        ProTrialFeature.cards => l.trialSuggCardsTitle,
        ProTrialFeature.multiCurrency => l.trialSuggCurrencyTitle,
      };

  String suggBody(AppLocalizations l) => switch (this) {
        ProTrialFeature.ask => l.trialSuggAskBody,
        ProTrialFeature.sms => l.trialSuggSmsBody,
        ProTrialFeature.dashboards => l.trialSuggDashBody,
        ProTrialFeature.reminders => l.trialSuggRemBody,
        ProTrialFeature.themes => l.trialSuggThemeBody,
        ProTrialFeature.notes => l.trialSuggNotesBody,
        ProTrialFeature.advancedAnalytics => l.trialSuggAdvBody,
        ProTrialFeature.backups => l.trialSuggBackupBody,
        ProTrialFeature.cards => l.trialSuggCardsBody,
        ProTrialFeature.multiCurrency => l.trialSuggCurrencyBody,
      };

  String suggCta(AppLocalizations l) => switch (this) {
        ProTrialFeature.ask => l.trialSuggAskCta,
        ProTrialFeature.sms => l.trialSuggSmsCta,
        ProTrialFeature.dashboards => l.trialSuggDashCta,
        ProTrialFeature.reminders => l.trialSuggRemCta,
        ProTrialFeature.themes => l.trialSuggThemeCta,
        ProTrialFeature.notes => l.trialSuggNotesCta,
        ProTrialFeature.advancedAnalytics => l.trialSuggAdvCta,
        ProTrialFeature.backups => l.trialSuggBackupCta,
        ProTrialFeature.cards => l.trialSuggCardsCta,
        ProTrialFeature.multiCurrency => l.trialSuggCurrencyCta,
      };
}
