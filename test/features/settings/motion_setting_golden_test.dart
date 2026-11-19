// v7.0.0 Motion setting goldens (design Screen 11 v7.S): Look and feel with the
// Motion and Haptics rows, and the Motion sheet (Auto on a normal phone, Auto
// on a low-end phone, the phone's Remove animations on). Looks: Signature
// light and dark, Ember, Pure black, largest font. Regenerate with
// --update-goldens.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/database/seed_service.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/settings/screens/settings_pages.dart';
import 'package:kuber/features/settings/widgets/motion_sheet.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/golden_fonts.dart';
import '../../helpers/isar_test_helper.dart';

ThemeData _light(ThemeVariant v) => AppTheme.light(const Locale('en'), v, null, true);
ThemeData _dark(ThemeVariant v, {bool black = false}) =>
    AppTheme.dark(const Locale('en'), v, black, null, true);

class _Device extends MotionDeviceNotifier {
  _Device(this.value);
  final DeviceClass value;
  @override
  DeviceClass build() => value;
}

late Isar _isar;

void main() {
  setUpAll(() async {
    await initialiseIsarForTests();
    await loadGoldenFonts();
    SharedPreferences.setMockInitialValues({});
    _isar = await openTestIsar();
    await SeedService().seedInitialData(_isar);
  });
  tearDownAll(() => closeAndCleanIsar(_isar).timeout(const Duration(seconds: 3), onTimeout: () {}));

  final looks = <(String, ThemeData Function(), double)>[
    ('signature_light', () => _light(ThemeVariant.signature), 1),
    ('signature_dark', () => _dark(ThemeVariant.signature), 1),
    ('ember_light', () => _light(ThemeVariant.ember), 1),
    ('pure_black', () => _dark(ThemeVariant.signature, black: true), 1),
    ('largest_font', () => _light(ThemeVariant.signature), 2),
  ];
  Widget sheet() => const Scaffold(body: Align(alignment: Alignment.bottomCenter, child: MotionSheet()));
  final states = <(String, Widget Function(), DeviceClass, bool)>[
    ('look_and_feel', () => const LookAndFeelScreen(), DeviceClass.normal, false),
    ('sheet_auto_expressive', sheet, DeviceClass.normal, false),
    ('sheet_auto_low_end', sheet, DeviceClass.low, false),
    ('sheet_phone_off', sheet, DeviceClass.normal, true),
  ];

  for (final (look, theme, scale) in looks) {
    for (final (name, page, device, phoneOff) in states) {
      testWidgets('motion setting $name · $look', (t) async {
        t.view.physicalSize = const Size(360, 780);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final c = ProviderContainer(overrides: [
          isarProvider.overrideWithValue(_isar),
          motionDeviceProvider.overrideWith(() => _Device(device)),
        ]);
        await t.runAsync(() async {
          await SharedPreferences.getInstance();
          await c.read(settingsProvider.future);
        });
        await t.pumpWidget(UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx)
                  .copyWith(textScaler: TextScaler.linear(scale), disableAnimations: phoneOff),
              child: child!,
            ),
            home: Builder(builder: (_) => page()),
          ),
        ));
        await settleFonts(t);
        await t.pump(const Duration(seconds: 2));
        await expectLater(
            find.byType(MaterialApp), matchesGoldenFile('../../goldens/motion/${name}_$look.png'));
        await t.pumpWidget(const SizedBox());
        c.dispose();
        await settleFonts(t);
      });
    }
  }
}
