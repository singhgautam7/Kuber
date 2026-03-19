import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsState {
  final ThemeMode themeMode;
  final String currency;
  final String dateFormat;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.currency = 'INR',
    this.dateFormat = 'dd/MM/yyyy',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? dateFormat,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  FutureOr<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
    final currency = prefs.getString('currency') ?? 'INR';
    final dateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';

    return SettingsState(
      themeMode: ThemeMode.values[themeModeIndex],
      currency: currency,
      dateFormat: dateFormat,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    state = AsyncData(state.requireValue.copyWith(currency: currency));
  }

  Future<void> setDateFormat(String format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('date_format', format);
    state = AsyncData(state.requireValue.copyWith(dateFormat: format));
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
