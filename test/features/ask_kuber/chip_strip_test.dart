import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/ask_kuber/models/chip_action.dart';
import 'package:kuber/features/ask_kuber/screen/chip_strip.dart';

void main() {
  Widget host({
    required List<ChipAction> actions,
    required void Function(String) onAsk,
    required void Function(String) onNavigate,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(const Locale('en')),
      home: Scaffold(
        body: ChipStrip(
            actions: actions, onAsk: onAsk, onNavigate: onNavigate),
      ),
    );
  }

  testWidgets('ask chip tap sends its query', (tester) async {
    String? asked;
    await tester.pumpWidget(host(
      actions: const [AskChipAction('How much did I spend this month?')],
      onAsk: (q) => asked = q,
      onNavigate: (_) {},
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('How much did I spend this month?'));
    expect(asked, 'How much did I spend this month?');
  });

  testWidgets('navigate chip tap routes to its target', (tester) async {
    String? route;
    await tester.pumpWidget(host(
      actions: const [NavChipAction(label: 'View budget', route: '/more/budgets')],
      onAsk: (_) {},
      onNavigate: (r) => route = r,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View budget'));
    expect(route, '/more/budgets');
  });
}
