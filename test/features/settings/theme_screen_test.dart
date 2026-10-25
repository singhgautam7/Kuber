// Theme screen (theme-surfaces-v1 TS.2): Expressive colours and Pure black are
// always shown; Pure black is disabled in Light (no helper line, user review)
// and says when it applies in System.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/settings/providers/theme_options_provider.dart';
import 'package:kuber/features/settings/screens/theme_screen.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/l10n/app_localizations_en.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  setUpAll(initialiseIsarForTests);
  setUp(() async => isar = await openTestIsar());
  tearDown(() => closeAndCleanIsar(isar));
  final l = AppLocalizationsEn();

  Future<ProviderContainer> pump(WidgetTester t, ThemeMode mode) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1080, 4000);
    t.view.devicePixelRatio = 2.5;
    addTearDown(t.view.reset);
    final c = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(isar),
      bootThemeProvider.overrideWithValue((mode, ThemeVariant.signature)),
    ]);
    addTearDown(c.dispose);
    await t.runAsync(() async {
      await SharedPreferences.getInstance();
      await c.read(settingsProvider.future);
    });
    c.read(themeModeProvider.notifier).state = mode;
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: AppTheme.light(const Locale('en')),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ThemeScreen(),
      ),
    ));
    await t.pump(const Duration(milliseconds: 300));
    return c;
  }

  Switch switchOf(WidgetTester t, String title) => t.widget<Switch>(find.descendant(
      of: find.ancestor(of: find.text(title), matching: find.byType(Container)).first,
      matching: find.byType(Switch)));

  testWidgets('Light: Pure black disabled, no helper line', (t) async {
    await pump(t, ThemeMode.light);
    expect(find.text(l.themeExpressiveTitle), findsOneWidget);
    expect(find.text(l.themePureBlackTitle), findsOneWidget);
    expect(find.text('Works in dark mode'), findsNothing);
    expect(find.text(l.themePureBlackHelperSystem), findsNothing);
    expect(switchOf(t, l.themePureBlackTitle).onChanged, isNull);
    expect(find.text('True black (AMOLED)'), findsNothing);
    expect(find.textContaining('· true black'), findsNothing);
  });

  testWidgets('System: enabled, "Applies when your phone is in dark mode"', (t) async {
    await pump(t, ThemeMode.system);
    expect(find.text(l.themePureBlackHelperSystem), findsOneWidget);
    expect(switchOf(t, l.themePureBlackTitle).onChanged, isNotNull);
  });

  testWidgets('Dark: no helper; both switches save', (t) async {
    final c = await pump(t, ThemeMode.dark);
    expect(find.text(l.themePureBlackHelperSystem), findsNothing);
    await t.tap(find.text(l.themePureBlackTitle));
    switchOf(t, l.themePureBlackTitle).onChanged!(true);
    switchOf(t, l.themeExpressiveTitle).onChanged!(false);
    await t.pump();
    expect(c.read(themeOptionsProvider).pureBlack, isTrue);
    expect(c.read(themeOptionsProvider).expressive, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(PrefsKeys.themeAmoled), isTrue);
    expect(prefs.getBool(PrefsKeys.themeExpressive), isFalse);
  });

  test('migration runs once and writes both settings', () async {
    SharedPreferences.setMockInitialValues({PrefsKeys.onboarded: true, PrefsKeys.themeVariant: 0});
    final prefs = await SharedPreferences.getInstance();
    await migrateThemeSurfaces(prefs);
    expect(prefs.getBool(PrefsKeys.themeExpressive), isFalse);
    expect(prefs.getBool(PrefsKeys.themeAmoled), isTrue);
    // The user changes it; a later launch does not migrate again.
    await prefs.setBool(PrefsKeys.themeExpressive, true);
    await migrateThemeSurfaces(prefs);
    expect(prefs.getBool(PrefsKeys.themeExpressive), isTrue);
  });
}
