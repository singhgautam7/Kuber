import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/kuber_nav_bar.dart';
import 'package:kuber/shared/widgets/timed_snackbar.dart';
import 'package:kuber/l10n/app_localizations.dart';

Widget scoped(MotionLevel level, Widget child, {GlobalKey<NavigatorState>? key}) =>
    MaterialApp(
      navigatorKey: key,
      theme: AppTheme.light(const Locale('en')),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          MotionScope(level: level, systemOff: false, child: child!),
      home: Scaffold(body: child),
    );

void main() {
  group('nav indicator', () {
    Future<List<double>> widthsDuringMove(
        WidgetTester tester, MotionLevel level) async {
      var index = 0;
      late StateSetter set;
      await tester.pumpWidget(scoped(
        level,
        Center(
          child: StatefulBuilder(builder: (c, s) {
            set = s;
            return KuberNavPill(index: index, onSelect: (_) {});
          }),
        ),
      ));
      await tester.pumpAndSettle();
      double width() {
        final p = tester
            .widgetList<CustomPaint>(find.descendant(
                of: find.byType(NavIndicator), matching: find.byType(CustomPaint)))
            .last
            .painter as dynamic;
        return (p.r.value as double) - (p.l.value as double);
      }

      final rest = width();
      set(() => index = 3);
      final seen = <double>[rest];
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        seen.add(width());
      }
      await tester.pumpAndSettle();
      seen.add(width());
      return seen;
    }

    testWidgets('Expressive stretches mid-way', (tester) async {
      final w = await widthsDuringMove(tester, MotionLevel.expressive);
      expect(w.reduce((a, b) => a > b ? a : b), greaterThan(w.first * 1.15));
      expect(w.reduce((a, b) => a > b ? a : b), lessThan(w.first * 2.2));
    });

    testWidgets('Subtle does not stretch', (tester) async {
      final w = await widthsDuringMove(tester, MotionLevel.subtle);
      expect(w.reduce((a, b) => a > b ? a : b), lessThan(w.first * 1.05));
    });

    testWidgets('Off does not slide (and settles at once)', (tester) async {
      final w = await widthsDuringMove(tester, MotionLevel.off);
      // The first frame after the change already shows the final pill.
      expect((w[1] - w.last).abs(), lessThan(0.5));
    });
  });

  group('snackbar enter', () {
    Future<(double, double)> at(WidgetTester tester, MotionLevel level,
        Duration t) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(scoped(level, const SizedBox.expand(), key: key));
      showKuberSnackBar(key.currentContext!, 'Saved');
      await tester.pump();
      await tester.pump(t);
      final f = find.text('Saved');
      final y = tester.getTopLeft(f).dy;
      final o = tester
          .widgetList<Opacity>(find.ancestor(of: f, matching: find.byType(Opacity)))
          .map((e) => e.opacity)
          .fold<double>(1, (a, b) => a * b);
      // let it leave
      await tester.pump(const Duration(seconds: 8));
      await tester.pump(const Duration(seconds: 1));
      return (y, o);
    }

    testWidgets('Expressive slides in from above', (tester) async {
      final (y0, o0) = await at(tester, MotionLevel.expressive, const Duration(milliseconds: 20));
      final (y1, o1) = await at(tester, MotionLevel.expressive, const Duration(seconds: 1));
      expect(y0, lessThan(y1 - 20));
      expect(o0, lessThan(1));
      expect(o1, 1);
    });

    testWidgets('Subtle moves 4 dp at most', (tester) async {
      final (y0, _) = await at(tester, MotionLevel.subtle, const Duration(milliseconds: 1));
      final (y1, _) = await at(tester, MotionLevel.subtle, const Duration(seconds: 1));
      expect(y1 - y0, lessThanOrEqualTo(4.01));
    });

    testWidgets('Off fades in place within 90 ms', (tester) async {
      final (y0, o0) = await at(tester, MotionLevel.off, const Duration(milliseconds: 30));
      final (y1, o1) = await at(tester, MotionLevel.off, const Duration(milliseconds: 100));
      expect(y0, y1);
      expect(o0, lessThan(1));
      expect(o1, 1);
    });
  });

  group('route styles', () {
    Future<BuildContext> ctx(WidgetTester tester, MotionLevel l) async {
      late BuildContext c;
      await tester.pumpWidget(MotionScope(
        level: l,
        systemOff: false,
        child: Builder(builder: (b) {
          c = b;
          return const SizedBox();
        }),
      ));
      return c;
    }

    testWidgets('sheet', (tester) async {
      final e = kuberSheetStyle(await ctx(tester, MotionLevel.expressive));
      expect(e.duration, KuberMotion.slowCurve.settle);
      expect(e.reverseDuration, KuberMotion.standardCurve.settle);
      final s = kuberSheetStyle(await ctx(tester, MotionLevel.subtle));
      expect(s.duration, KuberMotion.subtleCurve.settle);
      final o = kuberSheetStyle(await ctx(tester, MotionLevel.off));
      expect(o.duration, KuberMotion.fxInstant);
      expect(o.reverseDuration, KuberMotion.fxInstant);
    });

    testWidgets('dialog', (tester) async {
      final e = kuberDialogStyle(await ctx(tester, MotionLevel.expressive));
      expect(e.duration, KuberMotion.defaultCurve.settle);
      final s = kuberDialogStyle(await ctx(tester, MotionLevel.subtle));
      expect(s.duration, KuberMotion.subtleCurve.settle);
      final o = kuberDialogStyle(await ctx(tester, MotionLevel.off));
      expect(o.duration, KuberMotion.fxInstant);
    });
  });

  group('theme ripple', () {
    Future<ValueNotifier<Color>> pumpApp(
        WidgetTester tester, MotionLevel level) async {
      final color = ValueNotifier(const Color(0xFF112233));
      await tester.pumpWidget(MotionScope(
        level: level,
        systemOff: false,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ThemeRipple(
            child: Builder(
              builder: (context) => GestureDetector(
                onTapDown: (d) => ThemeRipple.of(context).run(
                    d.globalPosition,
                    () => color.value = const Color(0xFFEEDDCC)),
                child: ValueListenableBuilder<Color>(
                  valueListenable: color,
                  builder: (_, c, __) => ColoredBox(color: c),
                ),
              ),
            ),
          ),
        ),
      ));
      return color;
    }

    int overlays(WidgetTester tester) => find
        .descendant(
            of: find.byType(ThemeRipple), matching: find.byType(IgnorePointer))
        .evaluate()
        .length;

    testWidgets('Expressive: overlay during, gone after settle', (tester) async {
      final color = await pumpApp(tester, MotionLevel.expressive);
      await tester.tapAt(const Offset(100, 100));
      // The reveal starts once the new theme has rendered (two frames).
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(color.value, const Color(0xFFEEDDCC));
      final during = overlays(tester);
      expect(during, 1);
      await tester.pump(KuberMotion.themeReveal + const Duration(milliseconds: 50));
      await tester.pump();
      expect(overlays(tester), 0);
    });

    testWidgets('a second change replaces the first, never stacks images',
        (tester) async {
      await pumpApp(tester, MotionLevel.expressive);
      await tester.tapAt(const Offset(100, 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tapAt(const Offset(300, 300));
      await tester.pump(const Duration(milliseconds: 50));
      expect(overlays(tester), 1);
      await tester.pumpAndSettle();
      expect(overlays(tester), 0);
    });

    testWidgets('Off: cross-fade within 90 ms', (tester) async {
      await pumpApp(tester, MotionLevel.off);
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 45));
      expect(overlays(tester), 1);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      expect(overlays(tester), 0);
    });
  });
}
