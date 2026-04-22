import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/currency_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/prefs_keys.dart';

final formatterProvider = Provider((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  final system = settings?.numberSystem ?? NumberSystem.indian;
  return AppFormatter(system: system);
});

final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

final currencyProvider = Provider<KuberCurrency>((ref) {
  final settings = ref.watch(settingsProvider);
  final code = settings.valueOrNull?.currency ?? 'INR';
  return currencyFromCode(code);
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return settings?.themeMode ?? ThemeMode.system;
});

enum NumberSystem {
  indian,
  international,
}


enum SwipeMode {
  changeTabs,
  performActions,
}

class SettingsState {
  final ThemeMode themeMode;
  final String currency;
  final String dateFormat;
  final String userName;
  final SwipeMode swipeMode;
  final bool biometricsEnabled;
  final NumberSystem numberSystem;
  final String? defaultAccountId;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.currency = 'INR',
    this.dateFormat = 'dd/MM/yyyy',
    this.userName = '',
    this.swipeMode = SwipeMode.changeTabs,
    this.biometricsEnabled = false,
    this.numberSystem = NumberSystem.indian,
    this.defaultAccountId,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? dateFormat,
    String? userName,
    SwipeMode? swipeMode,
    bool? biometricsEnabled,
    NumberSystem? numberSystem,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      userName: userName ?? this.userName,
      swipeMode: swipeMode ?? this.swipeMode,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      numberSystem: numberSystem ?? this.numberSystem,
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
    final biometricsEnabled = prefs.getBool(PrefsKeys.biometricsEnabled) ?? false;
    final numberSystemIndex = prefs.getInt(PrefsKeys.numberSystem) ?? 0;
    final defaultAccountId = prefs.getString(PrefsKeys.defaultAccountId);

    return SettingsState(
      themeMode: ThemeMode.values[themeModeIndex],
      currency: currency,
      dateFormat: dateFormat,
      userName: userName,
      swipeMode: SwipeMode.values[swipeModeIndex],
      biometricsEnabled: biometricsEnabled,
      numberSystem: NumberSystem.values[numberSystemIndex],
      defaultAccountId: defaultAccountId,
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
    state = AsyncData(SettingsState(
      themeMode: cur.themeMode,
      currency: cur.currency,
      dateFormat: cur.dateFormat,
      userName: cur.userName,
      swipeMode: cur.swipeMode,
      biometricsEnabled: cur.biometricsEnabled,
      numberSystem: cur.numberSystem,
      defaultAccountId: id,
    ));
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
