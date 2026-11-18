import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/expressive_chart/expressive_chart.dart';

import 'expressive_chart_test.dart' show chartHarness, samplePeriods, useSmallPhone, chartPosition, tapColumn;

// One stable theme: a fresh ThemeData per rebuild would start MaterialApp's theme tween.
final _theme = AppTheme.light(const Locale('en'));

const _levels = [MotionLevel.expressive, MotionLevel.subtle, MotionLevel.off];

Widget _app(
  MotionLevel level, {
  ExpressiveChartMode mode = ExpressiveChartMode.bar,
  int window = 6,
  int n = 12,
}) =>
    MotionScope(
      level: level,
      systemOff: false,
      child: chartHarness(periods: samplePeriods(n, firstKey: 1006), mode: mode, window: window, theme: _theme),
    );

Future<void> _settle(WidgetTester t) async {
  await t.pumpAndSettle();
  expect(t.binding.hasScheduledFrame, isFalse);
}

void main() {
  tearDown(() {
    KuberHaptics.enabled = false;
    KuberHaptics.scrolling = false;
    KuberHaptics.reset();
  });

  for (final level in _levels) {
    group('motion ${level.name}', () {
      testWidgets('Bar to Line and a period change settle to the same final state', (t) async {
        await useSmallPhone(t);
        // Reference: built directly in Line / window 12.
        await t.pumpWidget(_app(level, mode: ExpressiveChartMode.line, window: 12));
        await _settle(t);
        final refMax = chartPosition(t).maxScrollExtent;
        final refPx = chartPosition(t).pixels;

        await t.pumpWidget(_app(level));
        await _settle(t);
        await t.pumpWidget(_app(level, mode: ExpressiveChartMode.line));
        await _settle(t);
        await t.pumpWidget(_app(level, mode: ExpressiveChartMode.line, window: 12));
        await _settle(t);
        expect(chartPosition(t).maxScrollExtent, refMax);
        expect(chartPosition(t).pixels, refPx);
        // Back to Bar, window 6: nothing left ticking.
        await t.pumpWidget(_app(level));
        await _settle(t);
        expect(find.byKey(kExpressiveChartScrollKey), findsOneWidget);
      });

      testWidgets('selecting a column shows the tooltip, tapping again hides it', (t) async {
        await useSmallPhone(t);
        await t.pumpWidget(_app(level));
        await _settle(t);
        await tapColumn(t, 2);
        expect(find.byKey(kExpressiveChartTooltipKey), findsOneWidget);
        await _settle(t);
        await tapColumn(t, 2);
        expect(find.byKey(kExpressiveChartTooltipKey), findsNothing);
        await _settle(t);
      });
    });
  }

  testWidgets('Off: a mode switch reaches its final state on the next frame', (t) async {
    await useSmallPhone(t);
    await t.pumpWidget(_app(MotionLevel.off));
    await _settle(t);
    await t.pumpWidget(_app(MotionLevel.off, mode: ExpressiveChartMode.line));
    await t.pump(); // build
    await t.pump(); // the one frame after
    expect(t.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('Off: a period change leaves no ticker after one pump', (t) async {
    await useSmallPhone(t);
    await t.pumpWidget(_app(MotionLevel.off));
    await _settle(t);
    await t.pumpWidget(_app(MotionLevel.off, window: 12));
    await t.pump();
    await t.pump();
    expect(t.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('Subtle: a mode switch settles within 250 ms', (t) async {
    await useSmallPhone(t);
    await t.pumpWidget(_app(MotionLevel.subtle));
    await _settle(t);
    await t.pumpWidget(_app(MotionLevel.subtle, mode: ExpressiveChartMode.line));
    await t.pump();
    await t.pump(const Duration(milliseconds: 250));
    await t.pump(const Duration(milliseconds: 16));
    expect(t.binding.hasScheduledFrame, isFalse);
  });

  group('edge haptic', () {
    late int ticks;
    setUp(() => ticks = 0);

    Future<void> mockHaptics(WidgetTester t) async {
      KuberHaptics.enabled = true;
      KuberHaptics.reset();
      t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (c) async {
        if (c.method == 'HapticFeedback.vibrate' && c.arguments == 'HapticFeedbackType.selectionClick') ticks++;
        return null;
      });
      addTearDown(() => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    }

    for (final level in _levels) {
      testWidgets('${level.name}: one tick at the end of scroll, none while mid-scroll', (t) async {
        await useSmallPhone(t);
        await mockHaptics(t);
        await t.pumpWidget(_app(level, n: 24));
        await _settle(t);
        ticks = 0;
        final pos = chartPosition(t);
        expect(pos.maxScrollExtent, greaterThan(0));
        // Mid-scroll: no tick.
        pos.jumpTo(pos.maxScrollExtent / 2);
        await t.pump(const Duration(milliseconds: 100));
        expect(ticks, 0);
        // Reach the older end: exactly one tick.
        pos.jumpTo(pos.maxScrollExtent);
        await t.pump(const Duration(milliseconds: 100));
        expect(ticks, 1);
        // Staying at the edge does not repeat.
        await t.pump(const Duration(milliseconds: 100));
        expect(ticks, 1);
        await _settle(t);
      });
    }

    testWidgets('the edge tick fires even while the app-wide scrolling mute is on', (t) async {
      await useSmallPhone(t);
      await mockHaptics(t);
      await t.pumpWidget(_app(MotionLevel.expressive, n: 24));
      await _settle(t);
      ticks = 0;
      KuberHaptics.scrolling = true;
      final pos = chartPosition(t);
      pos.jumpTo(pos.maxScrollExtent);
      await t.pump(const Duration(milliseconds: 100));
      expect(ticks, 1);
      expect(KuberHaptics.scrolling, isTrue); // restored
    });

    testWidgets('haptics switch off: no tick', (t) async {
      await useSmallPhone(t);
      await mockHaptics(t);
      KuberHaptics.enabled = false;
      await t.pumpWidget(_app(MotionLevel.expressive, n: 24));
      await _settle(t);
      final pos = chartPosition(t);
      pos.jumpTo(pos.maxScrollExtent);
      await t.pump(const Duration(milliseconds: 100));
      expect(ticks, 0);
    });
  });
}
