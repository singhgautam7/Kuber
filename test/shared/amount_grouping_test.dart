import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/shared/widgets/kuber_form_widgets.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.dark(const Locale('en')),
        home: Scaffold(body: child),
      );

  Widget amount(TextEditingController c, bool indian) => host(KuberAmountField(
      label: 'Amount', controller: c, symbol: '₹', indianGrouping: indian));

  testWidgets('code-set text is grouped Indian', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(amount(c, true));
    c.text = '2500000';
    await tester.pump();
    expect(c.text, '25,00,000');
  });

  testWidgets('code-set text is grouped Western', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(amount(c, false));
    c.text = '2500000';
    await tester.pump();
    expect(c.text, '2,500,000');
  });

  testWidgets('prefilled text is grouped on open', (tester) async {
    final c = TextEditingController(text: '2500000');
    await tester.pumpWidget(amount(c, true));
    await tester.pump();
    expect(c.text, '25,00,000');
  });

  testWidgets('mid-typing "12." is left alone', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(amount(c, true));
    c.text = '12.';
    await tester.pump();
    expect(c.text, '12.');
  });

  testWidgets('KuberHeroAmountInput regroups code-set text', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(host(KuberHeroAmountInput(
      label: 'Balance',
      currencySymbol: '₹',
      controller: c,
      inputFormatters: [CurrencyInputFormatter(isIndian: true)],
    )));
    c.text = '2500000';
    await tester.pump();
    expect(c.text, '25,00,000');
  });
}
