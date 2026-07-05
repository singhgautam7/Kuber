import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ref.watch(settingsProvider
      .select((s) => s.valueOrNull?.themeMode ?? ThemeMode.system));
});

final privacyModeProvider = Provider<bool>((ref) {
  return ref.watch(
      settingsProvider.select((s) => s.valueOrNull?.privacyMode ?? false));
});

final navBarStyleProvider = Provider<NavBarStyle>((ref) {
  return ref.watch(settingsProvider
      .select((s) => s.valueOrNull?.navBarStyle ?? NavBarStyle.modern));
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

enum NavBarStyle { classic, modern }

enum MoreTabLayout { simple, modern }

class SettingsState {
  final ThemeMode themeMode;
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
  final NavBarStyle navBarStyle;
  final MoreTabLayout moreTabLayout;
  final Locale locale;

  const SettingsState({
    this.themeMode = ThemeMode.system,
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
    this.navBarStyle = NavBarStyle.classic,
    this.moreTabLayout = MoreTabLayout.modern,
    this.locale = const Locale('en'),
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? dateFormat,
    String? userName,
    SwipeMode? swipeMode,
    bool? biometricsEnabled,
    NumberSystem? numberSystem,
    bool? privacyMode,
    double? thresholdFloor,
    double? thresholdCeiling,
    NavBarStyle? navBarStyle,
    MoreTabLayout? moreTabLayout,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
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
      navBarStyle: navBarStyle ?? this.navBarStyle,
      moreTabLayout: moreTabLayout ?? this.moreTabLayout,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  FutureOr<SettingsState> build() async {
    ref.keepAlive();
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(PrefsKeys.themeMode) ?? 0;
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
    final navBarStyleIndex =
        prefs.getInt(PrefsKeys.navBarStyle) ?? NavBarStyle.modern.index;
    final moreTabLayoutIndex =
        prefs.getInt(PrefsKeys.moreTabLayout) ?? MoreTabLayout.modern.index;
    final languageCode = prefs.getString(PrefsKeys.language) ?? 'en';
    final locale = Locale(languageCode);
    AppLocale.current = locale;

    return SettingsState(
      themeMode: ThemeMode.values[themeModeIndex],
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
      navBarStyle: NavBarStyle.values[navBarStyleIndex],
      moreTabLayout: MoreTabLayout.values[moreTabLayoutIndex],
      locale: locale,
    );
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
        currency: cur.currency,
        dateFormat: cur.dateFormat,
        userName: cur.userName,
        swipeMode: cur.swipeMode,
        biometricsEnabled: cur.biometricsEnabled,
        numberSystem: cur.numberSystem,
        defaultAccountId: id,
        privacyMode: cur.privacyMode,
        navBarStyle: cur.navBarStyle,
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

  Future<void> setNavBarStyle(NavBarStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.navBarStyle, style.index);
    state = AsyncData(state.requireValue.copyWith(navBarStyle: style));
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
