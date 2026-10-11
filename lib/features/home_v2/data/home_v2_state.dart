import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';

/// Which Home an install gets (widget-inventory.md › Cohort).
enum HomeCohort { v1, v2 }

/// Stored visibility of one Home widget in the v2 cohort.
enum WidgetVis { auto, on, off }

/// Get started graduation reasons (suggestion-rules.md §2).
enum GsGraduation { completed, transactions, dismissed, timeout }

/// v2-only per-widget state: visibility and when it unlocked.
class HomeV2WidgetState {
  final WidgetVis vis;
  final DateTime? unlockedAt;

  const HomeV2WidgetState({required this.vis, this.unlockedAt});

  HomeV2WidgetState copyWith({WidgetVis? vis, DateTime? unlockedAt}) =>
      HomeV2WidgetState(
        vis: vis ?? this.vis,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  Map<String, dynamic> toJson() => {
    'v': vis.name,
    if (unlockedAt != null) 'u': unlockedAt!.toIso8601String(),
  };

  factory HomeV2WidgetState.fromJson(Map<String, dynamic> m) =>
      HomeV2WidgetState(
        vis: WidgetVis.values.asNameMap()[m['v']] ?? WidgetVis.off,
        unlockedAt: m['u'] == null ? null : DateTime.tryParse(m['u'] as String),
      );
}

/// Everything Home v2 persists, loaded once at boot and kept in memory.
/// Suggestion state lives in [SgStore] (engine side).
class HomeV2Snapshot {
  final HomeCohort cohort;
  final DateTime? installedAt;
  final Set<int> seededAccountIds;
  final Map<String, HomeV2WidgetState> widgets;
  final DateTime? gsGraduatedAt;
  final GsGraduation? gsGraduationReason;
  final DateTime? gsFirstShownAt;
  final bool gsSuccessShown;
  final bool gsSetting;
  final bool sgSetting;
  final bool balanceSet;
  final bool smsRequested;
  final bool askOpened;
  final bool voiceUsed;

  const HomeV2Snapshot({
    required this.cohort,
    this.installedAt,
    this.seededAccountIds = const {},
    this.widgets = const {},
    this.gsGraduatedAt,
    this.gsGraduationReason,
    this.gsFirstShownAt,
    this.gsSuccessShown = false,
    this.gsSetting = true,
    this.sgSetting = true,
    this.balanceSet = false,
    this.smsRequested = false,
    this.askOpened = false,
    this.voiceUsed = false,
  });

  static const v1 = HomeV2Snapshot(cohort: HomeCohort.v1);

  bool get isV2 => cohort == HomeCohort.v2;
  bool get gsGraduated => gsGraduatedAt != null;

  /// Get started card eligible (suggestion-rules.md §2 Eligibility).
  bool get gsEligible => isV2 && !gsGraduated && gsSetting;

  HomeV2Snapshot copyWith({
    HomeCohort? cohort,
    DateTime? installedAt,
    Set<int>? seededAccountIds,
    Map<String, HomeV2WidgetState>? widgets,
    DateTime? Function()? gsGraduatedAt,
    GsGraduation? Function()? gsGraduationReason,
    DateTime? gsFirstShownAt,
    bool? gsSuccessShown,
    bool? gsSetting,
    bool? sgSetting,
    bool? balanceSet,
    bool? smsRequested,
    bool? askOpened,
    bool? voiceUsed,
  }) => HomeV2Snapshot(
    cohort: cohort ?? this.cohort,
    installedAt: installedAt ?? this.installedAt,
    seededAccountIds: seededAccountIds ?? this.seededAccountIds,
    widgets: widgets ?? this.widgets,
    gsGraduatedAt: gsGraduatedAt != null ? gsGraduatedAt() : this.gsGraduatedAt,
    gsGraduationReason: gsGraduationReason != null
        ? gsGraduationReason()
        : this.gsGraduationReason,
    gsFirstShownAt: gsFirstShownAt ?? this.gsFirstShownAt,
    gsSuccessShown: gsSuccessShown ?? this.gsSuccessShown,
    gsSetting: gsSetting ?? this.gsSetting,
    sgSetting: sgSetting ?? this.sgSetting,
    balanceSet: balanceSet ?? this.balanceSet,
    smsRequested: smsRequested ?? this.smsRequested,
    askOpened: askOpened ?? this.askOpened,
    voiceUsed: voiceUsed ?? this.voiceUsed,
  );
}

/// Reads / writes [HomeV2Snapshot] with the app's SharedPreferences +
/// [PrefsKeys] pattern. Writes are per field so a crash mid-way never
/// corrupts unrelated state.
class HomeV2Store {
  final SharedPreferences prefs;
  const HomeV2Store(this.prefs);

  static Future<HomeV2Store> open() async =>
      HomeV2Store(await SharedPreferences.getInstance());

  HomeCohort? readCohort() => switch (prefs.getString(PrefsKeys.homeLayout)) {
    'v1' => HomeCohort.v1,
    'v2' => HomeCohort.v2,
    _ => null,
  };

  Future<void> writeCohort(HomeCohort c) =>
      prefs.setString(PrefsKeys.homeLayout, c.name);

  HomeV2Snapshot read() {
    final cohort = readCohort() ?? HomeCohort.v1;
    if (cohort == HomeCohort.v1) return HomeV2Snapshot.v1;
    DateTime? date(String k) {
      final s = prefs.getString(k);
      return s == null ? null : DateTime.tryParse(s);
    }

    final widgets = <String, HomeV2WidgetState>{};
    final raw = prefs.getString(PrefsKeys.homeV2Widgets);
    if (raw != null) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        m.forEach((k, v) {
          widgets[k] = HomeV2WidgetState.fromJson(v as Map<String, dynamic>);
        });
      } catch (_) {
        // Corrupt JSON: start clean rather than crash Home.
      }
    }
    return HomeV2Snapshot(
      cohort: cohort,
      installedAt: date(PrefsKeys.homeV2InstalledAt),
      seededAccountIds: {
        for (final s
            in prefs.getStringList(PrefsKeys.homeV2SeededAccountIds) ?? const [])
          ?int.tryParse(s),
      },
      widgets: widgets,
      gsGraduatedAt: date(PrefsKeys.gsGraduatedAt),
      gsGraduationReason: GsGraduation.values
          .asNameMap()[prefs.getString(PrefsKeys.gsGraduationReason)],
      gsFirstShownAt: date(PrefsKeys.gsFirstShownAt),
      gsSuccessShown: prefs.getBool(PrefsKeys.gsSuccessShown) ?? false,
      gsSetting: prefs.getBool(PrefsKeys.settingHomeGetStarted) ?? true,
      sgSetting: prefs.getBool(PrefsKeys.settingHomeSuggestions) ?? true,
      balanceSet: prefs.getBool(PrefsKeys.homeV2BalanceSet) ?? false,
      smsRequested: prefs.getBool(PrefsKeys.homeV2SmsRequested) ?? false,
      askOpened: prefs.getBool(PrefsKeys.homeV2AskOpened) ?? false,
      voiceUsed: prefs.getBool(PrefsKeys.homeV2VoiceUsed) ?? false,
    );
  }

  /// Persists every field of [s] (cheap: a dozen small writes, only on
  /// state changes, never per frame).
  Future<void> write(HomeV2Snapshot s) async {
    Future<void> date(String k, DateTime? v) =>
        v == null ? prefs.remove(k) : prefs.setString(k, v.toIso8601String());
    await writeCohort(s.cohort);
    await date(PrefsKeys.homeV2InstalledAt, s.installedAt);
    await prefs.setStringList(
      PrefsKeys.homeV2SeededAccountIds,
      [for (final id in s.seededAccountIds) '$id'],
    );
    await prefs.setString(
      PrefsKeys.homeV2Widgets,
      jsonEncode({for (final e in s.widgets.entries) e.key: e.value.toJson()}),
    );
    await date(PrefsKeys.gsGraduatedAt, s.gsGraduatedAt);
    final reason = s.gsGraduationReason;
    if (reason == null) {
      await prefs.remove(PrefsKeys.gsGraduationReason);
    } else {
      await prefs.setString(PrefsKeys.gsGraduationReason, reason.name);
    }
    await date(PrefsKeys.gsFirstShownAt, s.gsFirstShownAt);
    await prefs.setBool(PrefsKeys.gsSuccessShown, s.gsSuccessShown);
    await prefs.setBool(PrefsKeys.settingHomeGetStarted, s.gsSetting);
    await prefs.setBool(PrefsKeys.settingHomeSuggestions, s.sgSetting);
    await prefs.setBool(PrefsKeys.homeV2BalanceSet, s.balanceSet);
    await prefs.setBool(PrefsKeys.homeV2SmsRequested, s.smsRequested);
    await prefs.setBool(PrefsKeys.homeV2AskOpened, s.askOpened);
    await prefs.setBool(PrefsKeys.homeV2VoiceUsed, s.voiceUsed);
  }

  /// Dev tools reset: drop every v2 key (suggestion state included).
  Future<void> clearV2State() async {
    for (final k in [
      PrefsKeys.homeV2Widgets,
      PrefsKeys.homeV2BalanceSet,
      PrefsKeys.homeV2SmsRequested,
      PrefsKeys.homeV2AskOpened,
      PrefsKeys.homeV2VoiceUsed,
      PrefsKeys.gsGraduatedAt,
      PrefsKeys.gsGraduationReason,
      PrefsKeys.gsFirstShownAt,
      PrefsKeys.gsSuccessShown,
      PrefsKeys.settingHomeGetStarted,
      PrefsKeys.settingHomeSuggestions,
      PrefsKeys.sgInstances,
      PrefsKeys.sgLastNewShownDay,
      PrefsKeys.sgLastDismissAt,
      PrefsKeys.sgTypeSuppressedUntil,
    ]) {
      await prefs.remove(k);
    }
  }
}
