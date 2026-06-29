import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kuber/features/tools/widgets/calculator_hero_result.dart';
import 'package:kuber/features/tools/widgets/calculator_schedule_table.dart';

/// Regression guard for the "BoxConstraints forces an infinite height" crash:
/// ToolStatCols uses a Row with CrossAxisAlignment.stretch, which previously
/// blew up when placed in an unbounded-height context (a scroll view). It must
/// lay out cleanly there now (IntrinsicHeight bounds it).
void main() {
  testWidgets('ToolStatCols lays out inside an unbounded-height list',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  ToolStatCols(items: [
                    StatCol('Total Interest', '₹27,06,939'),
                    StatCol('Total Payable', '₹52,06,939'),
                    StatCol('Interest / Principal', '108%'),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('₹27,06,939'), findsOneWidget);
  });

  testWidgets('ToolScheduleTable virtualizes a long (360-row) schedule',
      (tester) async {
    final rows = [
      for (var i = 1; i <= 360; i++) ['M$i', '₹$i', '₹$i', '₹$i'],
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ToolScheduleTable(
                  columns: const [
                    ScheduleColumn('Period', numeric: false),
                    ScheduleColumn('Opening'),
                    ScheduleColumn('Paid'),
                    ScheduleColumn('Closing'),
                  ],
                  rows: rows,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    // First rows are built; far-off rows are lazily NOT built (virtualized).
    expect(find.text('M1'), findsOneWidget);
    expect(find.text('M360'), findsNothing);
  });
}
