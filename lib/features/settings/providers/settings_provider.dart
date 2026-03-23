import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/currency_data.dart';
import '../../../core/utils/prefs_keys.dart';

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

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.currency = 'INR',
    this.dateFormat = 'dd/MM/yyyy',
    this.userName = '',
    this.swipeMode = SwipeMode.changeTabs,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? dateFormat,
    String? userName,
    SwipeMode? swipeMode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      userName: userName ?? this.userName,
      swipeMode: swipeMode ?? this.swipeMode,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  FutureOr<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(PrefsKeys.themeMode) ?? 0;
    final currency = prefs.getString(PrefsKeys.currency) ?? 'INR';
    final dateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';
    final userName = prefs.getString(PrefsKeys.userName) ?? '';
    final swipeModeIndex = prefs.getInt(PrefsKeys.swipeMode) ?? 0;

    return SettingsState(
      themeMode: ThemeMode.values[themeModeIndex],
      currency: currency,
      dateFormat: dateFormat,
      userName: userName,
      swipeMode: SwipeMode.values[swipeModeIndex],
    );
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

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
