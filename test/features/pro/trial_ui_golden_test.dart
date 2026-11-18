// v7.0.0-b trial UI goldens (design v7b.TS / v7b.T1 / v7b.T3). Regenerate with
// --update-goldens. Motion is Off so the celebration is at rest.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/pro/trial/trial_checklist.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';
import 'package:kuber/features/pro/trial/trial_suggestions.dart';
import 'package:kuber/features/pro/trial/widgets/trial_ended_sheet.dart';
import 'package:kuber/features/pro/trial/widgets/trial_sheet.dart';

import '../../helpers/golden_fonts.dart';
import 'trial_ui_harness.dart';

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
ThemeData _dark(ThemeVariant v, {bool black = false}) => AppTheme.dark(const Locale('en'), v, black);

void main() {
  setUpAll(loadGoldenFonts);
  goldenFileComparator = _Tolerant(goldenFileComparator as LocalFileComparator);
  setUp(() async {
    await resetTrialPrefs();
    TrialSession.sheetShown = false;
  });

  Future<void> shot(WidgetTester t, String name) => expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../goldens/v7b/trial/$name.png'),
      );

  Future<void> sheet(
    WidgetTester t,
    String name,
    ThemeData theme, {
    TrialStartOutcome outcome = TrialStartOutcome.started,
    bool expand = false,
    double scale = 1,
    Size size = const Size(412, 892),
    TrialInfo? info,
  }) async {
    await setView(t, size);
    await t.pumpWidget(trialApp(
      theme: theme,
      textScale: scale,
      trial: info ?? activeTrial(),
      body: (_) => openButton((c) => showTrialSheet(c, outcome)),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    if (expand) {
      await t.ensureVisible(find.text('WHAT KUBER PRO OFFERS'));
      await t.pumpAndSettle();
      await t.tap(find.text('WHAT KUBER PRO OFFERS'));
      await t.pumpAndSettle();
    }
    await shot(t, name);
  }

  final looks = <(String, ThemeData Function())>[
    ('signature_light', () => _light(ThemeVariant.signature)),
    ('signature_dark', () => _dark(ThemeVariant.signature)),
  ];
  for (final (look, theme) in looks) {
    testWidgets('$look started collapsed', (t) => sheet(t, '${look}_started', theme()));
    testWidgets('$look started expanded', (t) => sheet(t, '${look}_started_expanded', theme(), expand: true));
    testWidgets('$look ended sheet', (t) async {
      await ProTrialChecklist.markTried(ProTrialFeature.sms);
      await ProTrialChecklist.markTried(ProTrialFeature.notes);
      await setView(t);
      await t.pumpWidget(trialApp(
        theme: theme(),
        trial: endedTrial(),
        overrides: [
          trialUsageProvider.overrideWith((_) async => const TrialUsage(sms: 42, dashboards: 2, asks: 11, notes: 6)),
        ],
        body: (_) => openButton((c) => showTrialEndedSheet(c)),
      ));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await shot(t, '${look}_ended');
    });
  }
  testWidgets('signature_light continued', (t) => sheet(t, 'signature_light_continued', _light(ThemeVariant.signature), outcome: TrialStartOutcome.continued, info: activeTrial(daysAgo: 5)));
  testWidgets('signature_light already used', (t) => sheet(t, 'signature_light_used', _light(ThemeVariant.signature), outcome: TrialStartOutcome.alreadyUsed));
  testWidgets('ember_light started', (t) => sheet(t, 'ember_light_started', _light(ThemeVariant.ember)));
  testWidgets('pure_black started', (t) => sheet(t, 'pure_black_started', _dark(ThemeVariant.signature, black: true)));
  testWidgets('largest font collapsed', (t) => sheet(t, 'largest_font_started', _light(ThemeVariant.signature), scale: 2, size: const Size(360, 640)));
  testWidgets('largest font expanded', (t) => sheet(t, 'largest_font_started_expanded', _light(ThemeVariant.signature), scale: 2, size: const Size(360, 640), expand: true));
  testWidgets('largest font already used', (t) => sheet(t, 'largest_font_used', _light(ThemeVariant.signature), scale: 2, size: const Size(360, 640), outcome: TrialStartOutcome.alreadyUsed));
}
