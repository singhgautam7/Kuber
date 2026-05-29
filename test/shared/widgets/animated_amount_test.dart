import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/shared/widgets/animated_amount.dart';

void main() {
  String plain(double v) => v.round().toString();

  testWidgets('shows the mask and does not animate when private', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedAmount(value: 1234, isPrivate: true, format: plain),
        ),
      ),
    );

    expect(find.text('****'), findsOneWidget);
  });

  testWidgets('counts up to the final formatted value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AnimatedAmount(value: 1000, format: plain)),
      ),
    );

    // First frame starts near the tween's begin (0), not the final value.
    expect(find.text('1000'), findsNothing);

    await tester.pumpAndSettle();

    // Once the animation settles it lands exactly on the target value.
    expect(find.text('1000'), findsOneWidget);
  });

  testWidgets('tweens to a new value when value changes', (tester) async {
    Widget build(double v) => MaterialApp(
      home: Scaffold(body: AnimatedAmount(value: v, format: plain)),
    );

    await tester.pumpWidget(build(100));
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);

    await tester.pumpWidget(build(500));
    await tester.pumpAndSettle();
    expect(find.text('500'), findsOneWidget);
  });
}
