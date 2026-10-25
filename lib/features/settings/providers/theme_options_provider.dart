import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/theme_families.dart' show ThemeVariant, resolveVariant;
import '../../../core/utils/prefs_keys.dart';

/// Theme options (theme-surfaces-v1): Expressive colours, Pure black and
/// colour from the wallpaper. Read before the first frame (see main.dart) so
/// the app never flashes the wrong surfaces.
@immutable
class ThemeOptions {
  final bool expressive;

  /// Pure black (stored under the old `themeAmoled` key).
  final bool pureBlack;
  final bool dynamicColor;
  const ThemeOptions({this.expressive = true, this.pureBlack = false, this.dynamicColor = false});

  ThemeOptions copyWith({bool? expressive, bool? pureBlack, bool? dynamicColor}) => ThemeOptions(
    expressive: expressive ?? this.expressive,
    pureBlack: pureBlack ?? this.pureBlack,
    dynamicColor: dynamicColor ?? this.dynamicColor,
  );
}

/// Families whose true-black switch existed before theme-surfaces-v1.
const _hadTrueBlack = {
  ThemeVariant.mull, ThemeVariant.slate, ThemeVariant.perch, ThemeVariant.azure,
  ThemeVariant.tide, ThemeVariant.iris, ThemeVariant.neon,
};

/// The surfaces migration (open-decisions.md 1), run once: anyone whose dark
/// page was black before gets Pure black; existing Kuber Signature users
/// (black dark page, near-white light page) start with Expressive colours
/// off; everyone else, and new installs, start with it on.
({bool expressive, bool pureBlack}) migratedThemeSurfaces({
  required bool existingUser,
  required ThemeVariant variant,
  required bool dynamicColor,
  required bool trueBlack,
}) {
  if (!existingUser) return (expressive: true, pureBlack: false);
  final v = resolveVariant(variant);
  if (v == ThemeVariant.signature && !dynamicColor) {
    return (expressive: false, pureBlack: true);
  }
  final blackBefore = trueBlack && (dynamicColor || _hadTrueBlack.contains(variant));
  return (expressive: true, pureBlack: blackBefore);
}

/// Applies [migratedThemeSurfaces] to the stored prefs once.
Future<void> migrateThemeSurfaces(SharedPreferences prefs) async {
  if (prefs.getBool(PrefsKeys.themeSurfacesMigrated) ?? false) return;
  final index = prefs.getInt(PrefsKeys.themeVariant) ?? 0;
  final m = migratedThemeSurfaces(
    existingUser: prefs.getBool(PrefsKeys.onboarded) ?? false,
    variant: ThemeVariant.values[index.clamp(0, ThemeVariant.values.length - 1)],
    dynamicColor: prefs.getBool(PrefsKeys.themeDynamicColor) ?? false,
    trueBlack: prefs.getBool(PrefsKeys.themeAmoled) ?? false,
  );
  await prefs.setBool(PrefsKeys.themeExpressive, m.expressive);
  await prefs.setBool(PrefsKeys.themeAmoled, m.pureBlack);
  await prefs.setBool(PrefsKeys.themeSurfacesMigrated, true);
}

/// Overridden in main.dart with the persisted values.
final bootThemeOptionsProvider = Provider<ThemeOptions>(
  (ref) => const ThemeOptions(),
);

class ThemeOptionsNotifier extends Notifier<ThemeOptions> {
  @override
  ThemeOptions build() => ref.read(bootThemeOptionsProvider);

  Future<void> setExpressive(bool value) async {
    state = state.copyWith(expressive: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.themeExpressive, value);
  }

  Future<void> setPureBlack(bool value) async {
    state = state.copyWith(pureBlack: value);
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
