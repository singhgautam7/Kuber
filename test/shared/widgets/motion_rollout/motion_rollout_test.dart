import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/shared/widgets/app_button.dart';
import 'package:kuber/shared/widgets/kuber_chips.dart';
import 'package:kuber/shared/widgets/kuber_expandable_card.dart';
import 'package:kuber/shared/widgets/kuber_list.dart';
import 'package:kuber/shared/widgets/kuber_segmented_control.dart';

Widget host(MotionLevel level, Widget child) => MaterialApp(
      home: MotionScope(
        level: level,
        systemOff: level == MotionLevel.off,
        child: Scaffold(body: Center(child: child)),
      ),
    );

double scaleOf(WidgetTester t, Finder within) => t
    .widget<Transform>(find
        .descendant(of: within, matching: find.byType(Transform))
        .first)
    .transform
    .storage[0];

/// Corner radius of the first Material under [within] (button / chip shape).
double radiusOf(WidgetTester t, Finder within) {
  final m = t.widget<Material>(
      find.descendant(of: within, matching: find.byType(Material)).first);
  final b = (m.shape! as RoundedRectangleBorder).borderRadius as BorderRadius;
  return b.topLeft.x;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final haptics = <String>[];
  setUp(() {
    haptics.clear();
    KuberHaptics.enabled = true;
    KuberHaptics.scrolling = false;
    KuberHaptics.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (c) async {
      // Material's own long-press feedback calls vibrate() with no argument.
      if (c.method == 'HapticFeedback.vibrate' && c.arguments != null) {
        haptics.add(c.arguments as String);
      }
      return null;
    });
  });
  tearDown(() => KuberHaptics.enabled = false);

  for (final l in MotionLevel.values) {
    group('at ${l.name}', () {
      testWidgets('AppButton: corners morph only at Expressive, idle at rest',
          (t) async {
        await t.pumpWidget(host(
            l, AppButton(label: 'Save', height: 40, onPressed: () {})));
        final f = find.byType(AppButton);
        expect(radiusOf(t, f), 20);
        final g = await t.startGesture(t.getCenter(f));
        await t.pump();
        await t.pump(const Duration(milliseconds: 60));
        final r = radiusOf(t, f);
        if (l == MotionLevel.expressive) {
          expect(r, lessThan(20));
        } else {
          expect(r, 20);
        }
        final s = scaleOf(t, f);
        if (l == MotionLevel.off) expect(s, 1.0);
        if (l == MotionLevel.subtle) expect(s, lessThan(1.0));
        await g.up();
        await t.pumpAndSettle();
        expect(radiusOf(t, f), 20);
        expect(t.binding.hasScheduledFrame, isFalse);
      });

      testWidgets('KuberChip: press scale, tick on tap', (t) async {
        var taps = 0;
        await t.pumpWidget(host(
            l, KuberChip(label: 'Food', selected: false, onTap: () => taps++)));
        final f = find.byType(KuberChip);
        final g = await t.startGesture(t.getCenter(f));
        await t.pump();
        await t.pump(const Duration(milliseconds: 60));
        final s = scaleOf(t, f);
        if (l == MotionLevel.expressive) expect(s, lessThan(1.0));
        if (l == MotionLevel.off) expect(s, 1.0);
        await g.up();
        await t.pumpAndSettle();
        expect(taps, 1);
        expect(haptics, ['HapticFeedbackType.selectionClick']);
        expect(t.binding.hasScheduledFrame, isFalse);
      });

      testWidgets('KuberSegmentedControl: tick on selection, settles',
          (t) async {
        var sel = 'a';
        await t.pumpWidget(host(
            l,
            StatefulBuilder(
              builder: (c, set) => SizedBox(
                width: 300,
                child: KuberSegmentedControl<String>(
                  values: const ['a', 'b'],
                  labels: const ['One', 'Two'],
                  selected: sel,
                  onSelected: (v) => set(() => sel = v),
                ),
              ),
            )));
        final c = t.getCenter(find.byType(KuberSegmentedControl<String>));
        await t.tapAt(c + const Offset(70, 0));
        await t.pumpAndSettle();
        expect(sel, 'b');
        expect(haptics, ['HapticFeedbackType.selectionClick']);
        expect(t.binding.hasScheduledFrame, isFalse);
      });

      testWidgets('KuberListRow: press scale, long press haptic', (t) async {
        var longs = 0;
        await t.pumpWidget(host(
            l,
            SizedBox(
              width: 320,
              child: KuberListRow(
                  title: 'Row', onTap: () {}, onLongPress: () => longs++),
            )));
        final f = find.byType(KuberListRow);
        final g = await t.startGesture(t.getCenter(f));
        await t.pump();
        await t.pump(const Duration(milliseconds: 60));
        final s = scaleOf(t, f);
        if (l == MotionLevel.expressive) expect(s, lessThan(1.0));
        if (l == MotionLevel.off) expect(s, 1.0);
        await t.pump(const Duration(seconds: 1));
        await g.up();
        await t.pumpAndSettle();
        expect(longs, 1);
        expect(haptics, ['HapticFeedbackType.mediumImpact']);
        expect(t.binding.hasScheduledFrame, isFalse);
      });

      testWidgets('KuberExpandableCard expands and settles', (t) async {
        await t.pumpWidget(host(
            l,
            const SizedBox(
                width: 320,
                child: KuberExpandableCard(title: 'Q', body: 'Answer'))));
        await t.tap(find.text('Q'));
        await t.pumpAndSettle();
        expect(find.text('Answer').hitTestable(), findsOneWidget);
        await t.tap(find.text('Q'));
        await t.pumpAndSettle();
        expect(find.text('Answer').hitTestable(), findsNothing);
        expect(t.binding.hasScheduledFrame, isFalse);
      });
    });
  }
}
