import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/widget_sync_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../core/utils/locale_font.dart';

// Each derived settings provider narrows to just its field with `.select()` so
// toggling one setting (e.g. privacy mode) doesn't invalidate the others and
// force every consumer of them to rebuild. Riverpod short-circuits when the
// selected value is `==`-equal to the previous.

final formatterProvider = Provider<AppFormatter>((ref) {
  final system = ref.watch(settingsProvider
      .select((s) => s.valueOrNull?.numberSystem ?? NumberSystem.indian));
  return AppFormatter(system: system);
});

final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

final currencyProvider = Provider<KuberCurrency>((ref) {
  final code = ref.watch(
      settingsProvider.select((s) => s.valueOrNull?.currency ?? 'INR'));
  return currencyFromCode(code);
});

final localeProvider = Provider<Locale>((ref) {
  return ref.watch(settingsProvider
      .select((s) => s.valueOrNull?.locale ?? const Locale('en')));
});

/// Theme values read synchronously from SharedPreferences in `_bootstrap`
/// (before `runApp`) and injected as an override. They are the pre-hydration
/// fallback for [themeModeProvider] / [themeVariantProvider] / [designLanguageProvider], so the first
/// frame already renders the persisted theme with no flash while the async
/// [settingsProvider] loads.
final bootThemeProvider = Provider<(ThemeMode, ThemeVariant, KuberStyle)>(
  (ref) => (ThemeMode.system, ThemeVariant.signature, KuberStyle.signature),
);

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final boot = ref.watch(bootThemeProvider).$1;
  return ref
      .watch(settingsProvider.select((s) => s.valueOrNull?.themeMode ?? boot));
});

final themeVariantProvider = Provider<ThemeVariant>((ref) {
  final boot = ref.watch(bootThemeProvider).$2;
  return ref.watch(
      settingsProvider.select((s) => s.valueOrNull?.themeVariant ?? boot));
});

final designLanguageProvider = Provider<KuberStyle>((ref) {
  final boot = ref.watch(bootThemeProvider).$3;
  return ref.watch(
      settingsProvider.select((s) => s.valueOrNull?.designLanguage ?? boot));
});

final privacyModeProvider = Provider<bool>((ref) {
  return ref.watch(
      settingsProvider.select((s) => s.valueOrNull?.privacyMode ?? false));
});

final moreTabLayoutProvider = Provider<MoreTabLayout>((ref) {
  return ref.watch(settingsProvider
      .select((s) => s.valueOrNull?.moreTabLayout ?? MoreTabLayout.modern));
});

final thresholdFloorProvider = Provider<double>((ref) {
  return ref.watch(
      settingsProvider.select((s) => s.valueOrNull?.thresholdFloor ?? 500));
});

final thresholdCeilingProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider
      .select((s) => s.valueOrNull?.thresholdCeiling ?? 2000));
});

enum NumberSystem { indian, international }

enum SwipeMode { changeTabs, performActions }

enum MoreTabLayout { simple, modern }

/// Default Quick Actions grid (nav-bar long-press). Ids resolve against the
/// shortcut catalog. Order = grid order.
const List<String> kDefaultQuickActionShortcuts = [
  'accounts',
  'investments',
  'ledger',
  'emi-calculator', // tool ids are hyphenated in kShortcutCatalog
  'advanced_analytics',
  'ask_kuber',
  'categories',
];

/// Default Add menu (FAB long-press) — the full ordered list of add-entry
/// actions, all reorderable / hide-able via the Customize Add Menu screen. The
/// sheet renders exactly this list, so the setting and the FAB stay in sync.
const List<String> kDefaultAddMenuActions = [
  'add_expense',
  'add_income',
  'transfer',
  'add_note',
  'add_recurring',
  'add_loan',
  'add_investment',
  'lend_borrow',
];

final quickActionShortcutsProvider = Provider<List<String>>((ref) {
  return ref.watch(settingsProvider.select(
      (s) => s.valueOrNull?.quickActionShortcuts ?? kDefaultQuickActionShortcuts));
});

final addMenuActionsProvider = Provider<List<String>>((ref) {
  return ref.watch(settingsProvider
      .select((s) => s.valueOrNull?.addMenuActions ?? kDefaultAddMenuActions));
});

class SettingsState {
  final ThemeMode themeMode;
  final ThemeVariant themeVariant;
  final KuberStyle designLanguage;
  final String currency;
  final String dateFormat;
  final String userName;
  final SwipeMode swipeMode;
  final bool biometricsEnabled;
  final NumberSystem numberSystem;
  final String? defaultAccountId;
  final bool privacyMode;
  final double thresholdFloor;
  final double thresholdCeiling;
  final MoreTabLayout moreTabLayout;
  final Locale locale;
  final List<String> quickActionShortcuts;
  final List<String> addMenuActions;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.themeVariant = ThemeVariant.signature,
    this.designLanguage = KuberStyle.signature,
    this.currency = 'INR',
    this.dateFormat = 'dd/MM/yyyy',
    this.userName = '',
    this.swipeMode = SwipeMode.changeTabs,
    this.biometricsEnabled = false,
    this.numberSystem = NumberSystem.indian,
    this.defaultAccountId,
    this.privacyMode = false,
    this.thresholdFloor = 500,
    this.thresholdCeiling = 2000,
    this.moreTabLayout = MoreTabLayout.modern,
    this.locale = const Locale('en'),
    this.quickActionShortcuts = kDefaultQuickActionShortcuts,
    this.addMenuActions = kDefaultAddMenuActions,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    ThemeVariant? themeVariant,
    KuberStyle? designLanguage,
    String? currency,
    String? dateFormat,
    String? userName,
    SwipeMode? swipeMode,
    bool? biometricsEnabled,
    NumberSystem? numberSystem,
    bool? privacyMode,
    double? thresholdFloor,
    double? thresholdCeiling,
    MoreTabLayout? moreTabLayout,
    Locale? locale,
    List<String>? quickActionShortcuts,
    List<String>? addMenuActions,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      themeVariant: themeVariant ?? this.themeVariant,
      designLanguage: designLanguage ?? this.designLanguage,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      userName: userName ?? this.userName,
      swipeMode: swipeMode ?? this.swipeMode,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      numberSystem: numberSystem ?? this.numberSystem,
      defaultAccountId: this.defaultAccountId, // ignore: unnecessary_this
      privacyMode: privacyMode ?? this.privacyMode,
      thresholdFloor: thresholdFloor ?? this.thresholdFloor,
      thresholdCeiling: thresholdCeiling ?? this.thresholdCeiling,
      moreTabLayout: moreTabLayout ?? this.moreTabLayout,
      locale: locale ?? this.locale,
      quickActionShortcuts: quickActionShortcuts ?? this.quickActionShortcuts,
      addMenuActions: addMenuActions ?? this.addMenuActions,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  FutureOr<SettingsState> build() async {
    ref.keepAlive();
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(PrefsKeys.themeMode) ?? 0;
    final themeVariantIndex = prefs.getInt(PrefsKeys.themeVariant) ?? 0;
    final designLanguageIndex =
        prefs.getInt(PrefsKeys.designLanguage) ?? KuberStyle.signature.index;
    final currency = prefs.getString(PrefsKeys.currency) ?? 'INR';
    final dateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';
    final userName = prefs.getString(PrefsKeys.userName) ?? '';
    final swipeModeIndex = prefs.getInt(PrefsKeys.swipeMode) ?? 0;
    final biometricsEnabled =
        prefs.getBool(PrefsKeys.biometricsEnabled) ?? false;
    final numberSystemIndex = prefs.getInt(PrefsKeys.numberSystem) ?? 0;
    final defaultAccountId = prefs.getString(PrefsKeys.defaultAccountId);
    final privacyMode = prefs.getBool(PrefsKeys.privacyMode) ?? false;
    final thresholdFloor = prefs.getDouble(PrefsKeys.thresholdFloor) ?? 500;
    final thresholdCeiling =
        prefs.getDouble(PrefsKeys.thresholdCeiling) ?? 2000;
    // Clean up legacy nav_bar_style key if present
    if (prefs.containsKey(PrefsKeys.navBarStyle)) {
      await prefs.remove(PrefsKeys.navBarStyle);
    }
    final moreTabLayoutIndex =
        prefs.getInt(PrefsKeys.moreTabLayout) ?? MoreTabLayout.modern.index;
    final languageCode = prefs.getString(PrefsKeys.language) ?? 'en';
    final locale = Locale(languageCode);
    AppLocale.current = locale;
    final quickActionShortcuts =
        prefs.getStringList(PrefsKeys.quickActionShortcuts) ??
            kDefaultQuickActionShortcuts;
    final addMenuActions =
        prefs.getStringList(PrefsKeys.addMenuActions) ?? kDefaultAddMenuActions;

    return SettingsState(
      themeMode: ThemeMode.values[themeModeIndex],
      themeVariant: ThemeVariant
          .values[themeVariantIndex.clamp(0, ThemeVariant.values.length - 1)],
      designLanguage: KuberStyle
          .values[designLanguageIndex.clamp(0, KuberStyle.values.length - 1)],
      currency: currency,
      dateFormat: dateFormat,
      userName: userName,
      swipeMode: SwipeMode.values[swipeModeIndex],
      biometricsEnabled: biometricsEnabled,
      numberSystem: NumberSystem.values[numberSystemIndex],
      defaultAccountId: defaultAccountId,
      privacyMode: privacyMode,
      thresholdFloor: thresholdFloor,
      thresholdCeiling: thresholdCeiling,
      moreTabLayout: MoreTabLayout.values[moreTabLayoutIndex],
      locale: locale,
      quickActionShortcuts: quickActionShortcuts,
      addMenuActions: addMenuActions,
    );
  }

  /// Persists the Quick Actions grid order/membership (nav-bar long-press).
  Future<void> setQuickActionShortcuts(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(PrefsKeys.quickActionShortcuts, ids);
    state = AsyncData(state.requireValue.copyWith(quickActionShortcuts: ids));
  }

  /// Persists the Add menu order/membership (FAB long-press).
  Future<void> setAddMenuActions(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(PrefsKeys.addMenuActions, ids);
    state = AsyncData(state.requireValue.copyWith(addMenuActions: ids));
  }

  Future<void> setDefaultAccountId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(PrefsKeys.defaultAccountId);
    } else {
      await prefs.setString(PrefsKeys.defaultAccountId, id);
    }
    final cur = state.requireValue;
    state = AsyncData(
      SettingsState(
        themeMode: cur.themeMode,
        themeVariant: cur.themeVariant,
        currency: cur.currency,
        dateFormat: cur.dateFormat,
        userName: cur.userName,
        swipeMode: cur.swipeMode,
        biometricsEnabled: cur.biometricsEnabled,
        numberSystem: cur.numberSystem,
        defaultAccountId: id,
        privacyMode: cur.privacyMode,
        designLanguage: cur.designLanguage,
        moreTabLayout: cur.moreTabLayout,
        locale: cur.locale,
      ),
    );
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.language, locale.languageCode);
    AppLocale.current = locale;
    state = AsyncData(state.requireValue.copyWith(locale: locale));
  }

  Future<void> setDesignLanguage(KuberStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.designLanguage, style.index);
    state = AsyncData(state.requireValue.copyWith(designLanguage: style));
  }

  Future<void> setMoreTabLayout(MoreTabLayout layout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.moreTabLayout, layout.index);
    state = AsyncData(state.requireValue.copyWith(moreTabLayout: layout));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.themeMode, mode.index);
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
    _syncWidgetsForTheme();
  }

  Future<void> setThemeVariant(ThemeVariant variant) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.themeVariant, variant.index);
    state = AsyncData(state.requireValue.copyWith(themeVariant: variant));
    _syncWidgetsForTheme();
  }

  Timer? _widgetSyncDebounce;

  /// Pushes the new palette to the native home-screen widgets shortly after a
  /// theme change so they re-tint within ~2s. Debounced: the Theme sheet is
  /// built for tapping through families back to back, and a full syncAll
  /// (all-transactions scan + chart bitmap renders) per tap would stack up on
  /// the UI isolate right while the whole app is re-theming. Only the last
  /// selection within the window triggers a sync.
  void _syncWidgetsForTheme() {
    _widgetSyncDebounce?.cancel();
    _widgetSyncDebounce = Timer(const Duration(milliseconds: 800), () {
      ref.read(widgetSyncServiceProvider).syncAll().catchError((Object e) {
        debugPrint('Kuber: widget sync after theme change failed: $e');
      });
    });
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.currency, currency);
    state = AsyncData(state.requireValue.copyWith(currency: currency));
  }

  Future<void> setDateFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('date_format', format);
    state = AsyncData(state.requireValue.copyWith(dateFormat: format));
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.userName, name);
    state = AsyncData(state.requireValue.copyWith(userName: name));
  }

  Future<void> setSwipeMode(SwipeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.swipeMode, mode.index);
    state = AsyncData(state.requireValue.copyWith(swipeMode: mode));
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.biometricsEnabled, enabled);
    state = AsyncData(state.requireValue.copyWith(biometricsEnabled: enabled));
  }

  Future<void> setThresholds(double floor, double ceiling) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(PrefsKeys.thresholdFloor, floor);
    await prefs.setDouble(PrefsKeys.thresholdCeiling, ceiling);
    state = AsyncData(
      state.requireValue.copyWith(
        thresholdFloor: floor,
        thresholdCeiling: ceiling,
      ),
    );
  }

  Future<void> togglePrivacyMode() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !state.requireValue.privacyMode;
    await prefs.setBool(PrefsKeys.privacyMode, next);
    state = AsyncData(state.requireValue.copyWith(privacyMode: next));
  }

  Future<void> setNumberSystem(NumberSystem system) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.numberSystem, system.index);
    state = AsyncData(state.requireValue.copyWith(numberSystem: system));
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
