// Regression (specs/vcal/regressions.md G2): while Back animated open after
// "Get started", its label row overflowed the growing slot (debug error on
// every fresh install; clipped, so not visible).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/onboarding/widgets/onboarding_nav_bar.dart';

void main() {
  testWidgets('Back animates open without a layout overflow', (t) async {
    Widget bar(int page) => MaterialApp(
          home: Scaffold(
            body: OnboardingNavBar(
              currentPage: page,
              pageCount: 8,
              compactBack: false,
              showBack: page != 0,
              busy: false,
              primaryEnabled: true,
              onBack: () {},
              primaryLabel: 'Next',
              onPrimary: () {},
            ),
          ),
        );
    await t.pumpWidget(bar(0));
    await t.pumpWidget(bar(1));
    for (var i = 0; i < 20; i++) {
      await t.pump(const Duration(milliseconds: 16));
      expect(t.takeException(), isNull, reason: 'frame $i');
    }
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('a long label stays inside the button at the largest font', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => t.binding.setSurfaceSize(null));
    t.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: OnboardingNavBar(
          currentPage: 1,
          pageCount: 9,
          compactBack: true,
          onBack: () {},
          primaryLabel: 'Agree and continue',
          onPrimary: () {},
        ),
      ),
    ));
    await t.pump(const Duration(milliseconds: 400));
    final button = t.getRect(find.byType(FilledButton));
    final label = t.getRect(find.text('Agree and continue'));
    expect(t.takeException(), isNull);
    expect(label.right, lessThanOrEqualTo(button.right));
    expect(label.left, greaterThanOrEqualTo(button.left));
  });
}
