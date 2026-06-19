import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/sheet_button_section.dart';

void main() {
  Widget host(SheetButtonSection section) {
    return MaterialApp(
      theme: AppTheme.dark(const Locale('en')),
      home: Scaffold(body: SingleChildScrollView(child: section)),
    );
  }

  testWidgets('primary only renders the primary action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(host(SheetButtonSection(
      primary: SheetAction(
        label: 'View Transactions',
        icon: Icons.receipt_long_rounded,
        onPressed: () => tapped = true,
      ),
    )));
    await tester.pumpAndSettle();

    expect(find.text('View Transactions'), findsOneWidget);
    await tester.tap(find.text('View Transactions'));
    expect(tapped, true);
  });

  testWidgets('primary + action row with destructive renders all three',
      (tester) async {
    await tester.pumpWidget(host(SheetButtonSection(
      primary: SheetAction(label: 'View', icon: Icons.list, onPressed: () {}),
      actions: [
        SheetAction(label: 'Edit', icon: Icons.edit, onPressed: () {}),
        SheetAction(label: 'Balance', icon: Icons.wallet, onPressed: () {}),
        SheetAction(
            label: 'Delete',
            icon: Icons.delete,
            destructive: true,
            onPressed: () {}),
      ],
    )));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    // No overflow with exactly three actions.
    expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);
  });

  testWidgets('more than three actions collapse extras into overflow menu',
      (tester) async {
    var deleted = false;
    await tester.pumpWidget(host(SheetButtonSection(
      primary: SheetAction(label: 'Pay', icon: Icons.payment, onPressed: () {}),
      actions: [
        SheetAction(label: 'Extra', icon: Icons.add, onPressed: () {}),
        SheetAction(label: 'Edit', icon: Icons.edit, onPressed: () {}),
        SheetAction(label: 'Close', icon: Icons.lock, onPressed: () {}),
        SheetAction(
            label: 'Delete',
            icon: Icons.delete,
            destructive: true,
            onPressed: () => deleted = true),
      ],
    )));
    await tester.pumpAndSettle();

    // First two visible, the rest behind the overflow button.
    expect(find.text('Extra'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(find.text('Close'), findsNothing);

    // Open the menu and pick Delete.
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(deleted, true);
  });
}
