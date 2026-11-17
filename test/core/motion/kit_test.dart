import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/shared/widgets/animated_amount.dart';
import 'package:kuber/shared/widgets/kuber_button_group.dart';
import 'package:kuber/shared/widgets/kuber_shape_loader.dart';

Widget host(MotionLevel level, Widget child) => MaterialApp(
      home: MotionScope(
        level: level,
        systemOff: level == MotionLevel.off,
        child: Scaffold(body: Center(child: child)),
      ),
    );

const levels = MotionLevel.values;

double scaleOf(WidgetTester t) => t
    .widget<Transform>(find
        .descendant(of: find.byType(Pressable), matching: find.byType(Transform))
        .first)
    .transform
    .storage[0];

void main() {
  group('Pressable', () {
    final expected = {
      MotionLevel.expressive: 0.98,
      MotionLevel.subtle: 0.99,
      MotionLevel.off: 1.0,
    };
    for (final l in levels) {
      testWidgets('card scale mid-press at ${l.name}', (t) async {
        await t.pumpWidget(host(
            l, const Pressable(child: SizedBox(width: 120, height: 80))));
        final g = await t.startGesture(t.getCenter(find.byType(Pressable)));
        await t.pump();
        await t.pump(const Duration(milliseconds: 40));
        final s = scaleOf(t);
        if (l == MotionLevel.off) {
          expect(s, 1.0, reason: 'Off: no transform');
        } else {
          expect(s, lessThan(1.0));
          expect(s, greaterThan(expected[l]! - 0.02));
        }
        await g.up();
        await t.pumpAndSettle();
        expect(scaleOf(t), closeTo(1.0, 1e-6));
        expect(t.binding.hasScheduledFrame, isFalse, reason: 'no ticker at rest');
      });
    }

    testWidgets('card settles at .98 while held (Expressive)', (t) async {
      await t.pumpWidget(host(MotionLevel.expressive,
          const Pressable(child: SizedBox(width: 120, height: 80))));
      final g = await t.startGesture(t.getCenter(find.byType(Pressable)));
      await t.pumpAndSettle();
      expect(scaleOf(t), closeTo(0.98, 0.001));
      await g.up();
      await t.pumpAndSettle();
    });

    testWidgets('onTap and onLongPress still fire', (t) async {
      var taps = 0, longs = 0;
      await t.pumpWidget(host(
          MotionLevel.expressive,
          Pressable(
              onTap: () => taps++,
              onLongPress: () => longs++,
              child: const SizedBox(width: 120, height: 80))));
      await t.tap(find.byType(Pressable));
      await t.pumpAndSettle();
      await t.longPress(find.byType(Pressable));
      await t.pumpAndSettle();
      expect([taps, longs], [1, 1]);
    });

    testWidgets('button corners morph only at Expressive', (t) async {
      Future<double> radiusAt(MotionLevel l) async {
        double r = -1;
        await t.pumpWidget(host(
            l,
            Pressable(
              kind: PressKind.button,
              restRadius: 20,
              builder: (c, radius, p) {
                r = radius;
                return const SizedBox(width: 120, height: 40);
              },
            )));
        final g = await t.startGesture(t.getCenter(find.byType(Pressable)));
        await t.pumpAndSettle();
        await g.up();
        await t.pumpAndSettle();
        return r;
      }

      // After release the radius is back at rest; press it and read mid-way.
      expect(await radiusAt(MotionLevel.subtle), 20);
      expect(await radiusAt(MotionLevel.off), 20);
      double held = 0;
      await t.pumpWidget(host(
          MotionLevel.expressive,
          Pressable(
            kind: PressKind.button,
            restRadius: 20,
            builder: (c, r, p) {
              held = r;
              return const SizedBox(width: 120, height: 40);
            },
          )));
      final g = await t.startGesture(t.getCenter(find.byType(Pressable)));
      await t.pumpAndSettle();
      expect(held, closeTo(8, 0.01));
      await g.up();
      await t.pumpAndSettle();
    });
  });

  group('KuberShapeLoader', () {
    testWidgets('Expressive and Subtle tick, Off is still', (t) async {
      for (final l in levels) {
        await t.pumpWidget(host(l, const KuberShapeLoader()));
        await t.pump(const Duration(milliseconds: 100));
        expect(t.binding.hasScheduledFrame, l != MotionLevel.off, reason: l.name);
      }
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('contained renders', (t) async {
      await t.pumpWidget(host(
          MotionLevel.expressive, const KuberShapeLoader(contained: true, size: 64)));
      await t.pump(const Duration(milliseconds: 700));
      expect(find.byType(KuberShapeLoader), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    });
  });

  group('AnimatedAmount', () {
    String plain(double v) => v.round().toString();
    Widget amount(MotionLevel l, double v) =>
        host(l, AnimatedAmount(value: v, format: plain, animateIn: false));

    testWidgets('Off swaps instantly', (t) async {
      await t.pumpWidget(amount(MotionLevel.off, 100));
      await t.pumpWidget(amount(MotionLevel.off, 500));
      await t.pump();
      expect(find.text('500'), findsOneWidget);
      expect(t.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('Expressive rolls, then settles to one Text', (t) async {
      await t.pumpWidget(amount(MotionLevel.expressive, 100));
      await t.pumpWidget(amount(MotionLevel.expressive, 500));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('500'), findsNothing, reason: 'mid-roll is per digit');
      await t.pumpAndSettle();
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('Expressive handles a length change', (t) async {
      await t.pumpWidget(amount(MotionLevel.expressive, 999));
      await t.pumpWidget(amount(MotionLevel.expressive, 1000));
      await t.pump(const Duration(milliseconds: 100));
      await t.pumpAndSettle();
      expect(find.text('1000'), findsOneWidget);
      await t.pumpWidget(amount(MotionLevel.expressive, 5));
      await t.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Subtle cross-fades', (t) async {
      await t.pumpWidget(amount(MotionLevel.subtle, 100));
      await t.pumpWidget(amount(MotionLevel.subtle, 500));
      await t.pump(const Duration(milliseconds: 50));
      expect(find.text('100'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      await t.pumpAndSettle();
      expect(find.text('100'), findsNothing);
    });
  });

  group('ExpandCollapse', () {
    Widget w(MotionLevel l, bool open) => host(
        l,
        ExpandCollapse(
            expanded: open, child: const SizedBox(height: 100, width: 100)));

    for (final l in levels) {
      testWidgets('${l.name}: height follows, settles with no ticker', (t) async {
        await t.pumpWidget(w(l, false));
        expect(t.getSize(find.byType(ExpandCollapse)).height, 0);
        await t.pumpWidget(w(l, true));
        await t.pump(const Duration(milliseconds: 30));
        final mid = t.getSize(find.byType(ExpandCollapse)).height;
        if (l == MotionLevel.off) {
          expect(mid, 100);
        } else {
          expect(mid, inInclusiveRange(1, 120));
        }
        await t.pumpAndSettle();
        expect(t.getSize(find.byType(ExpandCollapse)).height, closeTo(100, 0.5));
        expect(t.binding.hasScheduledFrame, isFalse);
        await t.pumpWidget(w(l, false));
        await t.pumpAndSettle();
        expect(t.getSize(find.byType(ExpandCollapse)).height, 0);
      });
    }
  });

  group('KuberAnimatedListItem / StaggeredEntrance', () {
    testWidgets('insert grows, remove shrinks then reports', (t) async {
      var removed = 0;
      Widget w(bool present) => host(
          MotionLevel.expressive,
          KuberAnimatedListItem(
              animateIn: true,
              present: present,
              onRemoved: () => removed++,
              child: const SizedBox(height: 60, width: 100)));
      await t.pumpWidget(w(true));
      await t.pump(const Duration(milliseconds: 20));
      expect(t.getSize(find.byType(KuberAnimatedListItem)).height, lessThan(60));
      await t.pumpAndSettle();
      expect(t.getSize(find.byType(KuberAnimatedListItem)).height, 60);
      await t.pumpWidget(w(false));
      await t.pumpAndSettle();
      expect(removed, 1);
      expect(t.getSize(find.byType(KuberAnimatedListItem)).height, 0);
    });

    testWidgets('Off: fade only, still reports removal', (t) async {
      var removed = 0;
      Widget w(bool present) => host(
          MotionLevel.off,
          KuberAnimatedListItem(
              animateIn: true,
              present: present,
              onRemoved: () => removed++,
              child: const SizedBox(height: 60, width: 100)));
      await t.pumpWidget(w(true));
      expect(t.getSize(find.byType(KuberAnimatedListItem)).height, 60);
      await t.pumpAndSettle();
      await t.pumpWidget(w(false));
      await t.pumpAndSettle();
      expect(removed, 1);
    });

    for (final l in levels) {
      testWidgets('stagger at ${l.name}', (t) async {
        await t.pumpWidget(host(
            l,
            const StaggeredEntrance(
                index: 3, child: SizedBox(key: Key('c'), height: 20, width: 20))));
        // Never on Off: no animation scheduled beyond the first frame.
        await t.pump(const Duration(milliseconds: 10));
        expect(t.binding.hasScheduledFrame, l != MotionLevel.off, reason: l.name);
        await t.pumpAndSettle();
        expect(find.byKey(const Key('c')), findsOneWidget);
      });
    }

    testWidgets('animate:false never animates', (t) async {
      await t.pumpWidget(host(
          MotionLevel.expressive,
          const StaggeredEntrance(
              index: 0, animate: false, child: SizedBox(height: 20, width: 20))));
      await t.pump();
      expect(t.binding.hasScheduledFrame, isFalse);
    });
  });

  group('KuberButtonGroup', () {
    Widget w(MotionLevel l, String sel, ValueChanged<String> on) => host(
        l,
        SizedBox(
          width: 300,
          child: KuberButtonGroup<String>(
            options: const [
              KuberButtonOption(value: 'a', label: 'Week'),
              KuberButtonOption(value: 'b', label: 'Month'),
              KuberButtonOption(value: 'c', label: 'Year'),
            ],
            selected: sel,
            onChanged: on,
          ),
        ));

    double width(WidgetTester t, String label) => t
        .getSize(find.ancestor(
                of: find.text(label).first, matching: find.byType(InkWell))
            .first)
        .width;

    testWidgets('selecting calls back; the selected item is not re-fired', (t) async {
      var got = '';
      await t.pumpWidget(w(MotionLevel.expressive, 'b', (v) => got = v));
      await t.tap(find.text('Year').last);
      await t.pumpAndSettle();
      expect(got, 'c');
      got = '';
      await t.tap(find.text('Month').last);
      expect(got, '');
    });

    testWidgets('Expressive: pressed widens 15 %, total holds, then eases back',
        (t) async {
      await t.pumpWidget(w(MotionLevel.expressive, 'b', (_) {}));
      await t.pumpAndSettle();
      final base = width(t, 'Year');
      final total = base + width(t, 'Week') + width(t, 'Month');
      final g = await t.startGesture(t.getCenter(find.text('Year').last));
      await t.pumpAndSettle();
      expect(width(t, 'Year'), closeTo(base * 1.15, 1.0));
      expect(width(t, 'Year') + width(t, 'Week') + width(t, 'Month'),
          closeTo(total, 0.5));
      await g.up();
      await t.pumpAndSettle();
      expect(width(t, 'Year'), closeTo(base, 0.5));
      expect(t.binding.hasScheduledFrame, isFalse);
    });

    for (final l in [MotionLevel.subtle, MotionLevel.off]) {
      testWidgets('${l.name}: no widening', (t) async {
        await t.pumpWidget(w(l, 'b', (_) {}));
        await t.pumpAndSettle();
        final base = width(t, 'Year');
        final g = await t.startGesture(t.getCenter(find.text('Year').last));
        await t.pumpAndSettle();
        expect(width(t, 'Year'), closeTo(base, 0.5));
        await g.up();
        await t.pumpAndSettle();
      });
    }
  });

  testWidgets('SkeletonCrossFade keeps the child and drops the placeholder', (t) async {
    Widget w(bool loading) => host(
        MotionLevel.expressive,
        SkeletonCrossFade(
            loading: loading,
            shrinkOut: true,
            placeholder: const SizedBox(key: Key('p'), height: 20, width: 20),
            child: const SizedBox(key: Key('c'), height: 20, width: 20)));
    await t.pumpWidget(w(true));
    expect(find.byKey(const Key('p')), findsOneWidget);
    expect(find.byKey(const Key('c')), findsNothing);
    await t.pumpWidget(w(false));
    await t.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('p')), findsOneWidget);
    expect(find.byKey(const Key('c')), findsOneWidget);
    await t.pumpAndSettle();
    expect(find.byKey(const Key('p')), findsNothing);
  });

  testWidgets('ChartDrawIn: t runs 0 to 1 at Expressive, jumps at Off', (t) async {
    final seen = <double>[];
    Widget w(MotionLevel l) => host(
        l,
        ChartDrawIn(
            kind: ChartKind.donut,
            builder: (c, p) {
              seen.add(p.t);
              return const SizedBox();
            }));
    await t.pumpWidget(w(MotionLevel.expressive));
    await t.pumpAndSettle();
    expect(seen.first, 0);
    expect(seen.last, 1);
    seen.clear();
    await t.pumpWidget(w(MotionLevel.off));
    expect(seen.single, 1);
  });

  testWidgets('AnimatedWeight reserves width and swaps at Off', (t) async {
    Widget w(bool a) => host(
        MotionLevel.off, AnimatedWeight('Home', isActive: a, style: const TextStyle(fontSize: 14)));
    await t.pumpWidget(w(false));
    final before = t.getSize(find.byType(AnimatedWeight));
    await t.pumpWidget(w(true));
    await t.pump();
    expect(t.getSize(find.byType(AnimatedWeight)), before);
  });
}
