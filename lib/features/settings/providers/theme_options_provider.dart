import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';

/// Theme options from the Mull theme screen: true black (AMOLED) and colour
/// from the wallpaper. Read before the first frame (see main.dart) so the app
/// never flashes the wrong surfaces.
@immutable
class ThemeOptions {
  final bool amoled;
  final bool dynamicColor;
  const ThemeOptions({this.amoled = false, this.dynamicColor = false});

  ThemeOptions copyWith({bool? amoled, bool? dynamicColor}) => ThemeOptions(
    amoled: amoled ?? this.amoled,
    dynamicColor: dynamicColor ?? this.dynamicColor,
  );
}

/// Overridden in main.dart with the persisted values.
final bootThemeOptionsProvider = Provider<ThemeOptions>(
  (ref) => const ThemeOptions(),
);

class ThemeOptionsNotifier extends Notifier<ThemeOptions> {
  @override
  ThemeOptions build() => ref.read(bootThemeOptionsProvider);

  Future<void> setAmoled(bool value) async {
    state = state.copyWith(amoled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.themeAmoled, value);
  }

  Future<void> setDynamicColor(bool value) async {
    state = state.copyWith(dynamicColor: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.themeDynamicColor, value);
  }
}

final themeOptionsProvider =
    NotifierProvider<ThemeOptionsNotifier, ThemeOptions>(
      ThemeOptionsNotifier.new,
    );

/// The Material You seed Android derives from the wallpaper (Android 12+).
/// Copied from Mull `core/utils/wallpaper_seed.dart`: only the seed is taken,
/// every role is derived like a bundled family. Null below Android 12.
final wallpaperSeedProvider = FutureProvider<Color?>((ref) async {
  try {
    // ignore: deprecated_member_use
    final palette = await DynamicColorPlugin.getCorePalette();
    return palette == null ? null : Color(palette.primary.get(40));
  } catch (_) {
    return null;
  }
});
