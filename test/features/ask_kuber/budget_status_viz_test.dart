import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/ask_kuber/models/viz_payload.dart';
import 'package:kuber/features/ask_kuber/screen/budget_status_viz.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final theme = AppTheme.dark(const Locale('en'));
  final cs = theme.colorScheme;
  final warning = theme.extension<KuberSemanticColors>()!.warning;

  Future<void> pumpViz(WidgetTester tester, BudgetStatusViz data) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: theme,
        home: Scaffold(body: BudgetStatusVizView(data: data)),
      ),
    ));
    await tester.pump();
  }

  Color percentColor(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!.color!;

  testWidgets('within budget uses the primary colour', (tester) async {
    await pumpViz(
      tester,
      const BudgetStatusViz(
          spent: 50,
          budgeted: 100,
          status: BudgetStatus.withinBudget,
          caption: '₹50 of ₹100 (50%)'),
    );
    expect(percentColor(tester, '50%'), cs.primary);
  });

  testWidgets('approaching uses the warning colour', (tester) async {
    await pumpViz(
      tester,
      const BudgetStatusViz(
          spent: 90,
          budgeted: 100,
          status: BudgetStatus.approaching,
          caption: '₹90 of ₹100 (90%)'),
    );
    expect(percentColor(tester, '90%'), warning);
  });

  testWidgets('over budget uses the error colour and an over suffix',
      (tester) async {
    await pumpViz(
      tester,
      const BudgetStatusViz(
          spent: 120,
          budgeted: 100,
          status: BudgetStatus.over,
          caption: '₹120 of ₹100 (120%)'),
    );
    expect(percentColor(tester, '120%'), cs.error);
    // The over-suffix lives in a RichText span on the caption.
    expect(find.textContaining('over', findRichText: true), findsWidgets);
  });
}
