import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/models/overflow_config.dart';
import 'package:kuber/core/motion/motion_level.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/app_icon_button.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/golden_fonts.dart';

/// Every header combination of board v7c.C (COMBOS) that KuberAppBar supports:
/// rest and pill at 360 dp, text scale 1.0 and 2.0, no overflow errors.
typedef _Combo = (String, KuberAppBar Function());

KuberAppBar _bar({
  String? title,
  String? sub,
  bool back = false,
  bool close = false,
  bool home = false,
  bool search = false,
  bool more = false,
  int extra = 0,
}) =>
    KuberAppBar(
      title: title,
      subtitle: sub,
      showBack: back || close,
      closeIcon: close,
      showHome: home,
      showBrand: false,
      search: search
          ? KuberHeaderSearch(controller: TextEditingController(), onChanged: (_) {})
          : null,
      actions: [
        for (var i = 0; i < extra; i++)
          AppIconButton(icon: Icons.add_rounded, semanticLabel: 'Extra $i', onPressed: () {}),
      ],
      overflowConfig: more
          ? KuberOverflowConfig(items: [
              KuberOverflowItem(icon: Icons.sort, label: 'Sort', onTap: () {}),
            ])
          : null,
    );

final List<_Combo> _combos = [
  ('Back title search overflow', () => _bar(back: true, title: 'Categories', search: true, more: true)),
  ('Back title overflow', () => _bar(back: true, title: 'Loans', more: true)),
  ('Back title search', () => _bar(back: true, title: 'Tags', search: true)),
  ('Back title extra overflow', () => _bar(back: true, title: 'Loans', extra: 1, more: true)),
  ('Back title 2 extra search overflow', () => _bar(back: true, title: 'Budgets', extra: 2, search: true, more: true)),
  ('Back title only', () => _bar(back: true, title: 'About')),
  ('Back home title overflow', () => _bar(back: true, home: true, title: 'EMI Calculator', more: true)),
  ('Close title', () => _bar(close: true, title: 'Add loan')),
  ('Close title extra', () => _bar(close: true, title: 'Edit loan', extra: 1)),
  ('None title search overflow', () => _bar(title: 'Settings', search: true, more: true)),
  ('None title only', () => _bar(title: 'Permissions')),
  ('Back title subtitle overflow', () => _bar(back: true, title: 'HDFC Savings', sub: 'Savings · 214 transactions', more: true)),
  ('Back long title search overflow', () => _bar(back: true, title: 'Interest earned on fixed deposits', search: true, more: true)),
  ('Back no title search overflow', () => _bar(back: true, title: '', search: true, more: true)),
];

void main() {
  setUpAll(loadGoldenFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ScrollController> pump(WidgetTester t, KuberAppBar bar, double scale) async {
    t.view.physicalSize = const Size(360, 780) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final sc = ScrollController();
    await t.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(const Locale('en')),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(360, 780),
            padding: const EdgeInsets.only(top: 24),
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(
            body: KuberHeaderPage(
              mode: FloatingHeaderMode.always,
              header: bar,
              body: ListView(controller: sc, children: [
                KuberHeaderPage.gap(),
                for (var i = 0; i < 40; i++) SizedBox(height: 56, child: Text('Row $i')),
              ]),
            ),
          ),
        ),
      ),
    ));
    await t.pumpAndSettle();
    return sc;
  }

  for (final scale in const [1.0, 2.0]) {
    group('text scale $scale', () {
      for (final c in _combos) {
        testWidgets(c.$1, (t) async {
          final handle = t.ensureSemantics();
          final bar = c.$2();
          final sc = await pump(t, bar, scale);
          expect(t.takeException(), isNull, reason: 'rest');
          final title = bar.title ?? '';
          final textF = find.descendant(
              of: find.byType(KuberAppBar), matching: find.text(title));
          sc.jumpTo(400);
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: 'pill');
          if (title.isNotEmpty) {
            final op = t.widget<Opacity>(find
                .ancestor(of: textF, matching: find.byType(Opacity))
                .first);
            if (scale >= 1.5) {
              expect(op.opacity, 0, reason: 'title faded out in the pill');
              expect(find.semantics.byLabel(title), findsOneWidget,
                  reason: 'but still in semantics');
            }
            if (title.length > 20 && scale == 1.0) {
              final txt = t.widget<Text>(textF);
              expect(txt.overflow, TextOverflow.ellipsis);
              expect(txt.maxLines, 1);
            }
          }
          sc.jumpTo(0);
          await t.pumpAndSettle();
          expect(t.takeException(), isNull, reason: 'back to rest');
          handle.dispose();
        });
      }
    });
  }
}
