// The x axis never prints its last label right next to a regular one
// (the loan schedule showed '37'38 on a 22-year loan).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/tools/widgets/calculator_line_chart.dart';

Future<void> pump(WidgetTester t, int years) => t.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Outstanding',
                    points: [for (var i = 0; i < years; i++) (years - i) * 1000.0],
                    color: Colors.blue),
              ],
              xLabels: [for (var i = 0; i < years; i++) "'${(17 + i) % 100}"],
            ),
          ),
        ),
      ),
    ));

void main() {
  testWidgets('22 years: every 5th year, no crowded last label', (t) async {
    await pump(t, 22);
    for (final y in ["'17", "'22", "'27", "'32", "'37"]) {
      expect(find.text(y), findsOneWidget, reason: y);
    }
    expect(find.text("'38"), findsNothing);
  });

  testWidgets('the last year shows when it has room', (t) async {
    await pump(t, 24); // labels every 5th: '17 .. '37, last '40 is 3 away
    expect(find.text("'40"), findsOneWidget);
    await pump(t, 21); // '37 is the last point and a regular label
    expect(find.text("'37"), findsOneWidget);
  });
}
