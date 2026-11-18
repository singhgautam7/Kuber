import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/models/overflow_config.dart';
import 'package:kuber/core/motion/motion_level.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Core checks for the floating header (v7c.F1): thresholds, the 8..32 dp
/// gap, the exact landing after a round trip, and no rebuild per frame.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  late ScrollController sc;
  var headerBuilds = 0;

  Future<void> pump(WidgetTester t, {FloatingHeaderMode? mode}) async {
    t.view.physicalSize = const Size(360, 780) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    sc = ScrollController();
    headerBuilds = 0;
    await t.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(const Locale('en')),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 780),
            padding: EdgeInsets.only(top: 24),
          ),
          child: Scaffold(
            body: KuberHeaderPage(
              mode: mode,
              header: KuberAppBar(
                title: 'Categories',
                showBack: true,
                search: KuberHeaderSearch(
                  controller: TextEditingController(),
                  onChanged: (_) {},
                ),
                overflowConfig: KuberOverflowConfig(items: [
                  KuberOverflowItem(icon: Icons.sort, label: 'Sort', onTap: () {}),
                ]),
              ),
              body: Builder(builder: (c) {
                return ListView(
                  controller: sc,
                  children: [
                    KuberHeaderPage.gap(),
                    for (var i = 0; i < 60; i++)
                      SizedBox(height: 56, child: Text('Row $i')),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    ));
    await t.pumpAndSettle();
    debugOnRebuildDirtyWidget = (e, _) {
      if (e.widget is KuberAppBar) headerBuilds++;
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);
  }

  Rect back(WidgetTester t) => t.getRect(find.bySemanticsLabel('Back').first);

  Future<void> scrollTo(WidgetTester t, double y) async {
    sc.jumpTo(y);
    await t.pumpAndSettle();
  }

  testWidgets('first item sits below the header at rest', (t) async {
    await pump(t);
    // status bar 24 + header 74
    expect(t.getTopLeft(find.text('Row 0')).dy, 24 + 74);
    expect(back(t).top, 24 + 14); // the 48 dp target at y 14
  });

  testWidgets('pill at 32, gap holds, back at 8, lands exactly', (t) async {
    await pump(t);
    final rest = back(t);
    final restTitle = t.getRect(find.text('Categories'));

    await scrollTo(t, 31);
    expect(back(t), rest, reason: 'below 32 dp nothing changes');
    await scrollTo(t, 32);
    expect(back(t).top, closeTo(rest.top - 2, 0.01), reason: 'pill: 2 dp up');
    final pillTitle = t.getRect(find.text('Categories'));
    expect(pillTitle.height, lessThan(restTitle.height));

    // Inside the gap the pill stays.
    await scrollTo(t, 20);
    expect(back(t).top, closeTo(rest.top - 2, 0.01));
    await scrollTo(t, 9);
    expect(back(t).top, closeTo(rest.top - 2, 0.01));

    await scrollTo(t, 8);
    expect(back(t), rest, reason: 'lands on the exact rest position');
    expect(t.getRect(find.text('Categories')), restTitle);
  });

  testWidgets('interrupt mid-morph retargets without a jump', (t) async {
    await pump(t);
    final rest = back(t);
    sc.jumpTo(40);
    await t.pump();
    await t.pump(const Duration(milliseconds: 60));
    final mid = back(t).top;
    expect(mid, lessThan(rest.top));
    expect(mid, greaterThan(rest.top - 2.2));
    sc.jumpTo(0);
    await t.pump();
    final after = back(t).top;
    expect((after - mid).abs(), lessThan(0.5), reason: 'no jump on retarget');
    await t.pumpAndSettle();
    expect(back(t), rest);
  });

  testWidgets('header does not rebuild on scroll frames', (t) async {
    await pump(t);
    for (final y in const <double>[10, 20, 40, 80, 200, 400, 30, 10, 4, 0]) {
      sc.jumpTo(y);
      await t.pump(const Duration(milliseconds: 16));
    }
    await t.pumpAndSettle();
    expect(headerBuilds, 0);
  });

  testWidgets('When scrolling up hides after 16 dp down, shows after 8 up',
      (t) async {
    await pump(t, mode: FloatingHeaderMode.scrollUp);
    await scrollTo(t, 100); // a 100 dp jump down already hides it
    const shownTop = 24.0 + 14 - 2;
    await t.drag(find.text('Row 5'), const Offset(0, -80));
    await t.pumpAndSettle();
    expect(back(t).top, lessThan(0), reason: 'slid up out of view');
    expect(find.semantics.byLabel('Back'), findsNothing,
        reason: 'hidden pill is excluded from semantics');
    await t.drag(find.text('Row 9'), const Offset(0, 40));
    await t.pumpAndSettle();
    expect(back(t).top, closeTo(shownTop, 0.01));
  });

  testWidgets('Floating header off: header scrolls away', (t) async {
    await pump(t, mode: FloatingHeaderMode.off);
    final rest = back(t);
    await scrollTo(t, 50);
    expect(back(t).top, closeTo(rest.top - 50, 0.01));
    await scrollTo(t, 0);
    expect(back(t), rest);
  });
}
