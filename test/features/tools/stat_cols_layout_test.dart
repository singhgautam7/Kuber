import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kuber/features/tools/widgets/calculator_hero_result.dart';

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
}
