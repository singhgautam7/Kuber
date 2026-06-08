import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/ask_kuber/models/viz_payload.dart';
import 'package:kuber/features/ask_kuber/screen/top_categories_viz.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('bar widths are proportional to the largest row', (tester) async {
    const data = TopCategoriesViz([
      CategoryVizRow(
          name: 'Food', color: Color(0xFFEF4444), amount: 300, percentOfTotal: 0.75),
      CategoryVizRow(
          name: 'Travel', color: Color(0xFF3B82F6), amount: 100, percentOfTotal: 0.25),
    ]);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark(const Locale('en')),
        home: const Scaffold(body: TopCategoriesVizView(data: data)),
      ),
    ));
    await tester.pump();

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);

    final boxes = tester
        .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .toList();
    expect(boxes.length, 2);
    // Largest category fills the track; the rest are proportional.
    expect(boxes[0].widthFactor, 1.0);
    expect(boxes[1].widthFactor, closeTo(1 / 3, 0.01));
  });
}
