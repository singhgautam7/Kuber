// v7.0.0-c floating header goldens: rest, mid-morph (60 ms after crossing
// 32 dp), pill. Regenerate after an approved change:
//   flutter test --update-goldens test/shared/widgets/floating_header_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/models/overflow_config.dart';
import 'package:kuber/core/motion/motion_level.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/golden_fonts.dart';

void main() {
  setUpAll(loadGoldenFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  const en = Locale('en');
  final themes = <String, (ThemeData Function(), double)>{
    'signature_light': (() => AppTheme.light(en), 1.0),
    'signature_dark': (() => AppTheme.dark(en), 1.0),
    'fern_light': (() => AppTheme.light(en, ThemeVariant.fern), 1.0),
    'pure_black': (() => AppTheme.dark(en, ThemeVariant.signature, true), 1.0),
    'largest_font': (() => AppTheme.light(en), 2.0),
  };

  for (final e in themes.entries) {
    for (final state in ['rest', 'morph', 'pill']) {
      testWidgets('${e.key} · $state', (t) async {
        t.view.physicalSize = const Size(360, 200);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final sc = ScrollController();
        await t.pumpWidget(ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: e.value.$1(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(360, 200),
                padding: const EdgeInsets.only(top: 24),
                textScaler: TextScaler.linear(e.value.$2),
              ),
              child: Scaffold(
                body: KuberHeaderPage(
                  mode: FloatingHeaderMode.always,
                  header: KuberAppBar(
                    title: 'Categories',
                    showBack: true,
                    search: KuberHeaderSearch(
                        controller: TextEditingController(), onChanged: (_) {}),
                    overflowConfig: KuberOverflowConfig(items: [
                      KuberOverflowItem(icon: Icons.sort, label: 'Sort', onTap: () {}),
                    ]),
                  ),
                  body: ListView(controller: sc, children: [
                    KuberHeaderPage.gap(),
                    for (var i = 0; i < 30; i++)
                      Builder(
                        builder: (c) => Container(
                          height: 52,
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Theme.of(c).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Category $i'),
                        ),
                      ),
                  ]),
                ),
              ),
            ),
          ),
        ));
        await t.pumpAndSettle();
        if (state == 'morph') {
          sc.jumpTo(33);
          await t.pump();
          await t.pump(const Duration(milliseconds: 60));
        } else if (state == 'pill') {
          sc.jumpTo(100);
          await t.pumpAndSettle();
        }
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('../../goldens/v7c/${e.key}_$state.png'));
      });
    }
  }
}
