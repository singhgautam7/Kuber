import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'trial_checklist.dart';
import 'trial_state.dart';

enum ProSuggestionPlace { home, history, analytics, more }

extension ProTrialFeaturePlace on ProTrialFeature {
  ProSuggestionPlace get place => switch (this) {
        ProTrialFeature.sms => ProSuggestionPlace.history,
        ProTrialFeature.dashboards ||
        ProTrialFeature.advancedAnalytics =>
          ProSuggestionPlace.analytics,
        ProTrialFeature.cards => ProSuggestionPlace.more,
        _ => ProSuggestionPlace.home,
      };
}

/// In-memory "session" flags (the process is the session).
class TrialSession {
  /// The trial sheet was shown in this session: suggestions wait.
  static bool sheetShown = false;
}

class TrialSuggestionState {
  final bool loaded;
  final Set<ProTrialFeature> dismissed;

  /// The one card of [dayKey] (at most one new card per day, app wide).
  final String? dayKey;
  final ProTrialFeature? dayFeature;

  /// Reminder variants dismissed: 'r3', 'last'.
  final Set<String> reminderDismissed;
  final bool claimDismissed;

  const TrialSuggestionState({
    this.loaded = false,
    this.dismissed = const {},
    this.dayKey,
    this.dayFeature,
    this.reminderDismissed = const {},
    this.claimDismissed = false,
  });

  TrialSuggestionState copyWith({
    bool? loaded,
    Set<ProTrialFeature>? dismissed,
    Set<String>? reminderDismissed,
    bool? claimDismissed,
  }) =>
      TrialSuggestionState(
        loaded: loaded ?? this.loaded,
        dismissed: dismissed ?? this.dismissed,
        dayKey: dayKey,
        dayFeature: dayFeature,
        reminderDismissed: reminderDismissed ?? this.reminderDismissed,
        claimDismissed: claimDismissed ?? this.claimDismissed,
      );
}

sealed class SlotContent {
  const SlotContent();
  String get id;
}

class SlotReminder extends SlotContent {
  final bool last;
  const SlotReminder(this.last);
  @override
  String get id => last ? 'last' : 'r3';
}

class SlotSuggestion extends SlotContent {
  final ProTrialFeature feature;
  const SlotSuggestion(this.feature);
  @override
  String get id => 's_${feature.name}';
}

String trialDayKey(DateTime now) {
  final n = now.toLocal();
  return '${n.year}-${n.month}-${n.day}';
}

ProTrialFeature? _pick(Set<ProTrialFeature> tried, TrialSuggestionState s, int day) {
  for (final f in ProTrialFeature.values) {
    if (tried.contains(f) || s.dismissed.contains(f)) continue;
    if (day >= 12 && f.place == ProSuggestionPlace.home) continue;
    return f;
  }
  return null;
}

/// The feature the day's card is about, or null. Pure.
ProTrialFeature? dayFeatureFor(TrialInfo t, Set<ProTrialFeature> tried, TrialSuggestionState s) =>
    s.dayKey == trialDayKey(t.now) ? s.dayFeature : _pick(tried, s, t.day);

/// What a slot shows. Pure: the rules of handoff Part 2 in one place.
SlotContent? resolveSlot({
  required ProSuggestionPlace place,
  required bool isPro,
  required TrialInfo trial,
  required Set<ProTrialFeature> tried,
  required TrialSuggestionState state,
  required bool sheetShownThisSession,
}) {
  if (isPro || !state.loaded) return null;
  if (!trial.isActive || sheetShownThisSession) return null;
  final day = trial.day;
  if (place == ProSuggestionPlace.home && day >= 12) {
    final last = day >= 14;
    return state.reminderDismissed.contains(last ? 'last' : 'r3')
        ? null
        : SlotReminder(last);
  }
  final f = dayFeatureFor(trial, tried, state);
  if (f == null ||
      tried.contains(f) ||
      state.dismissed.contains(f) ||
      f.place != place) {
    return null;
  }
  return SlotSuggestion(f);
}

class TrialSuggestionsNotifier extends Notifier<TrialSuggestionState> {
  static const _key = 'kuber_trial_sugg_v1';

  @override
  TrialSuggestionState build() {
    _load();
    return const TrialSuggestionState();
  }

  Future<void> _load() async {
    var s = const TrialSuggestionState(loaded: true);
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        ProTrialFeature? byName(Object? n) =>
            ProTrialFeature.values.where((f) => f.name == n).firstOrNull;
        s = TrialSuggestionState(
          loaded: true,
          dismissed: {
            for (final n in (m['dismissed'] as List? ?? const []))
              ?byName(n),
          },
          dayKey: m['dayKey'] as String?,
          dayFeature: byName(m['dayFeature']),
          reminderDismissed: {...(m['rem'] as List? ?? const []).cast<String>()},
          claimDismissed: m['claim'] == true,
        );
      }
    } catch (_) {}
    state = s;
  }

  Future<void> _save() async {
    try {
      await (await SharedPreferences.getInstance()).setString(
        _key,
        jsonEncode({
          'dismissed': [for (final f in state.dismissed) f.name],
          'dayKey': state.dayKey,
          'dayFeature': state.dayFeature?.name,
          'rem': state.reminderDismissed.toList(),
          'claim': state.claimDismissed,
        }),
      );
    } catch (_) {}
  }

  void dismiss(ProTrialFeature f) {
    state = state.copyWith(dismissed: {...state.dismissed, f});
    _save();
  }

  void dismissReminder(bool last) {
    state = state.copyWith(reminderDismissed: {...state.reminderDismissed, last ? 'last' : 'r3'});
    _save();
  }

  /// The Home claim suggestion was dismissed (or its Undo).
  void setClaimDismissed(bool v) {
    state = state.copyWith(claimDismissed: v);
    _save();
  }

  /// Fixes the day's card so it stays until used, dismissed or the day ends.
  void commitDay(String key, ProTrialFeature f) {
    if (state.dayKey == key) return;
    state = TrialSuggestionState(
      loaded: true,
      dismissed: state.dismissed,
      dayKey: key,
      dayFeature: f,
      reminderDismissed: state.reminderDismissed,
      claimDismissed: state.claimDismissed,
    );
    _save();
  }
}

final trialSuggestionsProvider =
    NotifierProvider<TrialSuggestionsNotifier, TrialSuggestionState>(TrialSuggestionsNotifier.new);
