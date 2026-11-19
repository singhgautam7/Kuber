// Quick navigation motion: stagger on open only, expand / collapse per level.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/core/motion/motion_level.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_path.dart';

import 'quick_nav_test_utils.dart';

Future<void> _open(WidgetTester t, MotionLevel level) async {
  await t.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(ProviderScope(
    child: MotionScope(
      level: level,
      systemOff: level == MotionLevel.off,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: KuberPathSheet(
              stack: [qnPage('/more/settings/theme')],
              tab: 3,
              router: GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())]),
              fromNotification: false,
            ),
          ),
        ),
      ),
    ),
  ));
}

/// Opacity of the stagger wrapper around the row showing [text].
double _rowOpacity(WidgetTester t, String text) => t
    .widget<Opacity>(find
        .ancestor(of: find.text(text), matching: find.byType(Opacity))
        .first)
    .opacity;

void main() {
  testWidgets('Expressive: rows stagger in on open, then settle', (t) async {
    await _open(t, MotionLevel.expressive);
    await t.pump(const Duration(milliseconds: 60));
    final first = _rowOpacity(t, 'Home');
    final later = _rowOpacity(t, 'Look and feel');
    expect(first, greaterThan(later), reason: 'staggered');
    await t.pumpAndSettle();
    expect(find.byType(Opacity).evaluate().where((e) => (e.widget as Opacity).opacity < 1), isEmpty);
  });

  testWidgets('Subtle: no stagger (rows fade together)', (t) async {
    await _open(t, MotionLevel.subtle);
    await t.pump(const Duration(milliseconds: 60));
    expect(_rowOpacity(t, 'Home'), _rowOpacity(t, 'Look and feel'));
    await t.pumpAndSettle();
  });

  testWidgets('Off: no entrance animation at all', (t) async {
    await _open(t, MotionLevel.off);
    await t.pump();
    expect(find.byType(Opacity).evaluate().where((e) => (e.widget as Opacity).opacity < 1), isEmpty);
  });

  Future<void> collapse(WidgetTester t) async {
    await t.pumpAndSettle();
    expect(find.text('Home widgets'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Collapse Look and feel'));
  }

  testWidgets('Expressive collapse animates, then the rows are gone; expand again', (t) async {
    await _open(t, MotionLevel.expressive);
    await collapse(t);
    await t.pump(const Duration(milliseconds: 30));
    expect(find.text('Home widgets'), findsOneWidget, reason: 'still collapsing');
    await t.pumpAndSettle();
    expect(find.text('Home widgets'), findsNothing);
    await t.tap(find.bySemanticsLabel('Expand Look and feel'));
    await t.pumpAndSettle();
    expect(find.text('Home widgets'), findsOneWidget);
  });

  testWidgets('Subtle collapse settles', (t) async {
    await _open(t, MotionLevel.subtle);
    await collapse(t);
    await t.pumpAndSettle();
    expect(find.text('Home widgets'), findsNothing);
  });

  testWidgets('expanding does not replay the open stagger', (t) async {
    await _open(t, MotionLevel.expressive);
    await collapse(t);
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('Expand Look and feel'));
    await t.pump(const Duration(milliseconds: 5));
    // Existing rows stay fully opaque: only the new rows fade (ExpandCollapse).
    expect(
        find.ancestor(of: find.text('Home'), matching: find.byType(Opacity)),
        findsNothing);
  });
}
