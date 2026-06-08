import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/ask_kuber/models/thinking_info.dart';
import 'package:kuber/features/ask_kuber/screen/thinking_panel.dart';

void main() {
  Future<void> pump(WidgetTester tester, ThinkingInfo info) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(const Locale('en')),
      home: Scaffold(body: ThinkingPanel(thinking: info)),
    ));
    await tester.pump();
  }

  testWidgets('renders one numbered row per step with bold tokens', (tester) async {
    await pump(
      tester,
      const ThinkingInfo(
        dateFilter: 'this month',
        scanned: ['Transactions', 'Categories'],
        steps: [
          ThinkingStep('Detected intent: **top expense category**.'),
          ThinkingStep('Scanned **87 transactions**.'),
          ThinkingStep('**Rent** ranks first at **₹18,000**.'),
        ],
      ),
    );

    // Numbered indices 1..3.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    // Bold token text is present (inside RichText spans).
    expect(find.textContaining('Rent', findRichText: true), findsWidgets);
    expect(find.textContaining('₹18,000', findRichText: true), findsWidgets);
  });

  testWidgets('old payload with no steps synthesizes a fallback trace',
      (tester) async {
    await pump(
      tester,
      const ThinkingInfo(dateFilter: 'this month', scanned: ['Transactions']),
    );
    // Two synthesized steps from dateFilter + scanned.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.textContaining('this month', findRichText: true), findsWidgets);
  });
}
