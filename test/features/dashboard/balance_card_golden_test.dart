// v7.0.0-b Home balance card goldens (design v7b.B): net, expense focused,
// income focused. Regenerate with --update-goldens. The month name comes from
// the real clock, so up to 3 % of pixels may differ.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';

import '../../helpers/golden_fonts.dart';
import 'balance_card_harness.dart';

class _Tolerant extends LocalFileComparator {
  _Tolerant(LocalFileComparator base) : super(base.basedir.resolve('x_test.dart'));

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (result.passed || result.diffPercent <= 0.03) return true;
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}

ThemeData _light(ThemeVariant v) => AppTheme.light(const Locale('en'), v);
ThemeData _dark(ThemeVariant v, {bool black = false}) =>
    AppTheme.dark(const Locale('en'), v, black);

void main() {
  setUpAll(loadGoldenFonts);
  goldenFileComparator = _Tolerant(goldenFileComparator as LocalFileComparator);

  final looks = <(String, ThemeData Function(), double, Size)>[
    ('signature_light', () => _light(ThemeVariant.signature), 1, const Size(412, 300)),
    ('signature_dark', () => _dark(ThemeVariant.signature), 1, const Size(412, 300)),
    ('ember_light', () => _light(ThemeVariant.ember), 1, const Size(412, 300)),
    ('pure_black', () => _dark(ThemeVariant.signature, black: true), 1, const Size(412, 300)),
    ('largest_font', () => _light(ThemeVariant.signature), 2, const Size(360, 640)),
  ];
  for (final (look, theme, scale, size) in looks) {
    final states = (look == 'signature_light' || look == 'signature_dark' || look == 'largest_font')
        ? ['net', 'expense', 'income']
        : ['expense'];
    for (final state in states) {
      testWidgets('$look $state', (t) async {
        await pumpBalance(t, balanceApp(theme: theme(), textScale: scale, scroll: false), size: size);
        if (state != 'net') {
          await t.tap(find.byKey(Key(state == 'expense' ? 'balBarExpense' : 'balBarIncome')));
          await t.pumpAndSettle();
        }
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile('../../goldens/v7b/balance/${look}_$state.png'),
        );
      });
    }
  }
}
