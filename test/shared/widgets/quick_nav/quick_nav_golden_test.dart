// Quick navigation goldens: Signature light and dark, another theme, Pure
// black and the largest font. Regenerate with --update-goldens.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';

import '../../../helpers/golden_fonts.dart';
import 'quick_nav_test_utils.dart';

ThemeData _light(ThemeVariant v) => AppTheme.light(const Locale('en'), v, null, true);
ThemeData _dark(ThemeVariant v, {bool black = false}) => AppTheme.dark(const Locale('en'), v, black, null, true);

void main() {
  setUpAll(loadGoldenFonts);

  final looks = <(String, ThemeData Function(), double)>[
    ('signature_light', () => _light(ThemeVariant.signature), 1),
    ('signature_dark', () => _dark(ThemeVariant.signature), 1),
    ('ember_light', () => _light(ThemeVariant.ember), 1),
    ('pure_black', () => _dark(ThemeVariant.signature, black: true), 1),
    ('largest_font', () => _light(ThemeVariant.signature), 2),
  ];
  final states = {
    'theme': [qnPage('/more/settings'), qnPage('/more/settings/look'), qnPage('/more/settings/theme')],
    'loan': [qnPage('/more/loans'), qnVirtual('SBI Home Loan')],
  };

  for (final (name, theme, scale) in looks) {
    for (final e in states.entries) {
      testWidgets('quick nav ${e.key} · $name', (t) async {
        await pumpQuickNav(t,
            stack: e.value, theme: theme(), textScale: scale, size: const Size(360, 780));
        await settleFonts(t);
        await t.pumpAndSettle();
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/${e.key}_$name.png'));
      });
    }
  }
}
