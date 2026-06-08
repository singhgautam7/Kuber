import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/ask_kuber/screen/welcome_view.dart';

void main() {
  testWidgets('tapping a starter card sends its prompt', (tester) async {
    String? sent;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(const Locale('en')),
      home: Scaffold(
        body: WelcomeView(
          greeting: 'Good morning.',
          pulse: const AlwaysStoppedAnimation(0.0),
          onSend: (p) => sent = p,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Greeting renders.
    expect(find.text('Good morning.'), findsOneWidget);

    // Six starter cards are shown.
    final cards = find.descendant(
      of: find.byType(WelcomeView),
      matching: find.byType(GestureDetector),
    );
    expect(cards, findsNWidgets(6));

    await tester.tap(cards.first);
    expect(sent, isNotNull);
    expect(sent!.isNotEmpty, isTrue);
  });
}
