// v7.0.0-b chart goldens. Regenerate after an approved change:
//   flutter test --update-goldens test/shared/expressive_chart/expressive_chart_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/expressive_chart/expressive_chart.dart';

import '../../helpers/golden_fonts.dart';
import 'expressive_chart_test.dart' show chartHarness, samplePeriods, tapColumn;

void main() {
  setUpAll(loadGoldenFonts);
  const en = Locale('en');
  final themes = <String, ThemeData Function()>{
    'signature_light': () => AppTheme.light(en),
    'signature_dark': () => AppTheme.dark(en),
    'fern_light': () => AppTheme.light(en, ThemeVariant.fern),
    'pure_black': () => AppTheme.dark(en, ThemeVariant.signature, true),
    'largest_font': () => AppTheme.light(en),
  };

  for (final e in themes.entries) {
    final scale = e.key == 'largest_font' ? 1.3 : 1.0;
    for (final state in ['bar', 'line', 'selected']) {
      testWidgets('${e.key} · $state', (t) async {
        t.view.physicalSize = const Size(412, 460);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(chartHarness(
          periods: samplePeriods(12, firstKey: 1006),
          mode: state == 'line' ? ExpressiveChartMode.line : ExpressiveChartMode.bar,
          topGap: 180,
          theme: e.value(),
          textScale: scale,
        ));
        await t.pumpAndSettle();
        if (state == 'selected') await tapColumn(t, 1);
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('../../goldens/v7b/chart/${e.key}_$state.png'));
      });
    }
  }
}
