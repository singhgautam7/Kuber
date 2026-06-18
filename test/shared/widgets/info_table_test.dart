import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/info_table.dart';

void main() {
  Widget host(List<InfoTableRow> rows, {bool light = false}) {
    return MaterialApp(
      theme: light ? AppTheme.light(const Locale('en')) : AppTheme.dark(const Locale('en')),
      home: Scaffold(body: SingleChildScrollView(child: InfoTable(rows: rows))),
    );
  }

  testWidgets('renders standard and highlight rows in both themes',
      (tester) async {
    for (final light in [false, true]) {
      await tester.pumpWidget(host(const [
        InfoTableDataRow(label: 'Frequency', value: 'Monthly'),
        InfoTableHighlightRow(
            label: 'Status', value: 'Active', valueColor: Colors.green),
      ], light: light));
      await tester.pumpAndSettle();

      // Labels render as supplied (sentence case).
      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    }
  });

  testWidgets('icon-value row shows the leading icon', (tester) async {
    await tester.pumpWidget(host(const [
      InfoTableDataRow(
        label: 'Account',
        value: 'HDFC Savings',
        valueLeadingIcon: Icons.account_balance_wallet_rounded,
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('HDFC Savings'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
  });

  testWidgets('tappable row shows chevron and invokes onTap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(host([
      InfoTableDataRow(
        label: '',
        value: 'View original SMS',
        tappable: true,
        onTap: () => tapped++,
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    await tester.tap(find.text('View original SMS'));
    expect(tapped, 1);
  });

  testWidgets('label-only row renders label and value stacked',
      (tester) async {
    await tester.pumpWidget(host(const [
      InfoTableLabelOnlyRow(label: 'Activity', value: 'Last transaction 1 hour ago'),
    ]));
    await tester.pumpAndSettle();

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Last transaction 1 hour ago'), findsOneWidget);
  });
}
