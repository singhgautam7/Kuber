import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/models/overflow_config.dart';
import 'package:kuber/core/motion/motion_level.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/app_icon_button.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:kuber/shared/widgets/kuber_search_pill.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/golden_fonts.dart';

/// Behaviour of the floating header (v7c.F1 to F8): exact round trip, the
/// gap, show modes, setting changes without restart, no rebuilds, motion
/// levels, search from the pill, semantics.
int _markerBuilds = 0;

class _Marker extends StatefulWidget {
  const _Marker();
  @override
  State<_Marker> createState() => _MarkerState();
}

class _MarkerState extends State<_Marker> {
  @override
  Widget build(BuildContext context) {
    _markerBuilds++;
    return const SizedBox(height: 56, child: Text('Marker'));
  }
}

void main() {
  setUpAll(loadGoldenFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  late ScrollController sc;
  const hdr = ValueKey('fh-header');

  Future<void> pump(
    WidgetTester t, {
    FloatingHeaderMode? mode,
    MotionLevel? level,
    ProviderContainer? container,
  }) async {
    t.view.physicalSize = const Size(360, 780) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    sc = ScrollController();
    Widget app = MaterialApp(
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
            body: ListView(
              controller: sc,
              children: [
                KuberHeaderPage.gap(),
                const _Marker(),
                for (var i = 0; i < 60; i++)
                  SizedBox(height: 56, child: Text('Row $i')),
              ],
            ),
          ),
        ),
      ),
    );
    if (level != null) {
      app = MotionScope(level: level, systemOff: false, child: app);
    }
    app = container == null
        ? ProviderScope(child: app)
        : UncontrolledProviderScope(container: container, child: app);
    await t.pumpWidget(app);
    await t.pumpAndSettle();
  }

  Rect back(WidgetTester t) => t.getRect(find.descendant(
      of: find.byKey(const ValueKey('bar')),
      matching: find.byIcon(Icons.arrow_back_rounded)));
  Rect more(WidgetTester t) => t.getRect(find.byIcon(Icons.more_vert_rounded));
  Rect title(WidgetTester t) => t.getRect(find.text('Categories'));
  Rect region(WidgetTester t) => t.getRect(find.byKey(hdr));

  Future<void> jump(WidgetTester t, double y) async {
    sc.jumpTo(y);
    await t.pumpAndSettle();
  }

  /// Buttons and title, traversal order, from the header's semantics node.
  List<String> labels(WidgetTester t) {
    final out = <String>[];
    void walk(SemanticsNode n) {
      if (n.label.isNotEmpty) out.add(n.label);
      for (final c in n.debugListChildrenInOrder(DebugSemanticsDumpOrder.traversalOrder)) {
        walk(c);
      }
    }
    walk(t.getSemantics(find.byType(KuberAppBar)));
    return out;
  }

  testWidgets('round trip: rest, pill, rest are identical (geometry + pixels)',
      (t) async {
    await pump(t);
    final handle = t.ensureSemantics();
    final r = (back(t), title(t), more(t), region(t));
    await expectLater(find.byKey(hdr), matchesGoldenFile('../../goldens/v7c/roundtrip_rest.png'));

    await jump(t, 400);
    expect(back(t).top, closeTo(r.$1.top - 2, 0.01));
    await jump(t, 0);

    expect(back(t), r.$1);
    expect(title(t), r.$2);
    expect(more(t), r.$3);
    expect(region(t), r.$4);
    await expectLater(find.byKey(hdr), matchesGoldenFile('../../goldens/v7c/roundtrip_rest.png'));
    handle.dispose();
  });

  testWidgets('no flicker in the gap 8..32 on the way down and up', (t) async {
    await pump(t);
    final rest = back(t);
    await jump(t, 33);
    final up2 = rest.top - 2;
    expect(back(t).top, closeTo(up2, 0.01));
    for (final y in const <double>[31, 20, 9]) {
      await jump(t, y);
      expect(back(t).top, closeTo(up2, 0.01), reason: 'still the pill at $y');
    }
    await jump(t, 8);
    expect(back(t), rest);
    // And downwards from the top: below 32 stays header, however long it rests.
    for (final y in const <double>[9, 20, 31]) {
      await jump(t, y);
      expect(back(t), rest, reason: 'still the header at $y');
    }
  });

  group('show modes', () {
    testWidgets('When scrolling up: hide after > 16 down, show after > 8 up, shown at <= 8',
        (t) async {
      await pump(t, mode: FloatingHeaderMode.scrollUp);
      final rest = back(t);
      final shown = rest.top - 2;
      await jump(t, 20);
      await jump(t, 34); // pill, 14 down
      expect(back(t).top, closeTo(shown, 0.01));
      await jump(t, 36); // 16: not more than 16
      expect(back(t).top, closeTo(shown, 0.01));
      await jump(t, 37); // 17
      expect(back(t).top, lessThan(0), reason: 'hidden (slid up)');
      await jump(t, 29); // 8 up: not more than 8
      expect(back(t).top, lessThan(0));
      await jump(t, 28); // 9 up
      expect(back(t).top, closeTo(shown, 0.01));
      await jump(t, 100);
      expect(back(t).top, lessThan(0));
      await jump(t, 8); // at 8 it is the header again, shown
      expect(back(t), rest);
    });

    testWidgets('When scrolling stops: hidden while moving, shown 300 ms after the end',
        (t) async {
      await pump(t, mode: FloatingHeaderMode.scrollStop);
      final shown = back(t).top - 2;
      final g = await t.startGesture(const Offset(180, 500));
      for (var i = 0; i < 4; i++) {
        await g.moveBy(const Offset(0, -40));
        await t.pump(const Duration(milliseconds: 16));
      }
      await t.pump(const Duration(milliseconds: 500));
      expect(back(t).top, lessThan(0), reason: 'hidden while the finger is down');
      await g.up();
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
      expect(back(t).top, lessThan(0), reason: 'still hidden 200 ms after the end');
      await t.pump(const Duration(milliseconds: 200));
      await t.pumpAndSettle();
      expect(back(t).top, closeTo(shown, 0.01));
    });

    testWidgets('keyboard open keeps the header shown', (t) async {
      await pump(t, mode: FloatingHeaderMode.scrollUp);
      final shown = back(t).top - 2;
      t.view.viewInsets = const FakeViewPadding(bottom: 900);
      addTearDown(t.view.resetViewInsets);
      await jump(t, 20);
      await jump(t, 120);
      expect(back(t).top, closeTo(shown, 0.01));
      t.view.resetViewInsets();
      await jump(t, 240);
      expect(back(t).top, lessThan(0), reason: 'hides again without the keyboard');
    });
  });

  testWidgets('Floating header off: translates with the scroll, stops at its height, scrim on',
      (t) async {
    await pump(t, mode: FloatingHeaderMode.off);
    final rest = back(t);
    double scrim() => t
        .widget<FadeTransition>(find.descendant(
            of: find.byKey(const ValueKey('fh-scrim')),
            matching: find.byType(FadeTransition)))
        .opacity
        .value;
    expect(scrim(), 0);
    await jump(t, 50);
    expect(back(t).top, closeTo(rest.top - 50, 0.01));
    expect(scrim(), 1, reason: 'content is under the status bar');
    await jump(t, 400);
    expect(back(t).top, closeTo(rest.top - (24 + 74), 0.01), reason: 'stops at its height');
    await jump(t, 0);
    expect(back(t), rest);
    expect(scrim(), 0);
  });

  testWidgets('changing the setting updates the open page without a restart', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await pump(t, container: c);
    final rest = back(t);
    await jump(t, 400);
    expect(back(t).top, closeTo(rest.top - 2, 0.01));

    c.read(floatingHeaderProvider.notifier).set(FloatingHeaderMode.off);
    await t.pumpAndSettle();
    expect(back(t).top, closeTo(rest.top - 98, 0.01), reason: 'now scrolls away');
    await jump(t, 100);
    expect(back(t).top, closeTo(rest.top - 98, 0.01));
    await jump(t, 50);
    expect(back(t).top, closeTo(rest.top - 50, 0.01));

    c.read(floatingHeaderProvider.notifier).set(FloatingHeaderMode.always);
    await t.pumpAndSettle();
    expect(back(t).top, closeTo(rest.top - 2, 0.01), reason: 'pill rule again at 50 dp');
    await jump(t, 4);
    expect(back(t), rest);
  });

  for (final mode in [FloatingHeaderMode.always, FloatingHeaderMode.scrollUp]) {
    testWidgets('the body and the header do not rebuild because of the header ($mode)',
        (t) async {
      _markerBuilds = 0;
      await pump(t, mode: mode);
      final base = _markerBuilds;
      expect(base, greaterThan(0));
      var headerBuilds = 0;
      debugOnRebuildDirtyWidget = (e, _) {
        if (e.widget is KuberAppBar) headerBuilds++;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      for (final y in const <double>[10, 20, 40, 80, 200, 400, 30, 10, 4, 0, 33, 8]) {
        sc.jumpTo(y);
        await t.pump(const Duration(milliseconds: 16));
      }
      await t.pumpAndSettle();
      expect(_markerBuilds, base, reason: 'page rows are not rebuilt');
      expect(headerBuilds, 0);
    });
  }

  testWidgets('Subtle and Off settle to the same geometry as Expressive', (t) async {
    Future<List<Rect>> run(MotionLevel l) async {
      await pump(t, level: l);
      await jump(t, 400);
      final pill = [back(t), title(t), more(t), region(t)];
      await jump(t, 0);
      return [...pill, back(t), title(t), more(t), region(t)];
    }

    final ex = await run(MotionLevel.expressive);
    expect(await run(MotionLevel.subtle), ex, reason: 'Subtle');
    expect(await run(MotionLevel.off), ex, reason: 'Off');
  });

  testWidgets('search from the pill returns to rest, closing folds back after 160 ms',
      (t) async {
    await pump(t);
    final handle = t.ensureSemantics();
    final rest = back(t);
    Finder closeBtn() => find.descendant(
        of: find.byType(KuberSearchPill),
        matching: find.byIcon(Icons.arrow_back_rounded));

    // Reference: search open at rest.
    await t.tap(find.byIcon(Icons.search_rounded));
    await t.pumpAndSettle();
    final searchAtRest = t.getRect(find.byType(KuberSearchPill));
    await t.tap(closeBtn());
    await t.pumpAndSettle();
    expect(back(t), rest);

    await jump(t, 400);
    expect(back(t).top, closeTo(rest.top - 2, 0.01));
    await t.tap(find.byIcon(Icons.search_rounded));
    await t.pumpAndSettle();
    expect(find.byType(EditableText), findsOneWidget);
    expect(t.getRect(find.byType(KuberSearchPill)), searchAtRest,
        reason: 'the header went back to rest for search');

    await t.tap(closeBtn());
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(back(t), rest, reason: 'still at rest before the 160 ms delay');
    await t.pump(const Duration(milliseconds: 100));
    await t.pumpAndSettle();
    expect(find.byType(EditableText), findsNothing);
    expect(back(t).top, closeTo(rest.top - 2, 0.01), reason: 'the pill again');
    handle.dispose();
  });

  testWidgets('semantics: hidden pill excluded, 48 dp targets, same button order as rest',
      (t) async {
    await pump(t, mode: FloatingHeaderMode.scrollUp);
    final handle = t.ensureSemantics();
    final atRest = labels(t);
    expect(atRest.indexOf('Back'), lessThan(atRest.indexOf('Search')));
    expect(atRest.indexOf('Search'), lessThan(atRest.indexOf('More options')));

    await jump(t, 20);
    await jump(t, 34);
    for (final b in t.widgetList<AppIconButton>(find.byType(AppIconButton)).toList().asMap().keys) {
      final s = t.getSize(find.byType(AppIconButton).at(b));
      expect(s.width, greaterThanOrEqualTo(48));
      expect(s.height, greaterThanOrEqualTo(48));
    }
    expect(labels(t), atRest, reason: 'TalkBack order in the pill = at rest');

    await jump(t, 200);
    expect(find.semantics.byLabel('Back'), findsNothing);
    expect(find.semantics.byLabel('More options'), findsNothing);
    handle.dispose();
  });
}
