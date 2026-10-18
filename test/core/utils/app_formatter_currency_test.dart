import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';

void main() {
  final inr = AppFormatter(); // INR + Indian grouping (defaults)
  final usd = AppFormatter(system: NumberSystem.international, symbol: r'$');
  final eurIndian = AppFormatter(symbol: '€');

  test('formats with the selected symbol, not a hardcoded rupee', () {
    expect(inr.formatCurrency(100000), '₹1,00,000');
    expect(usd.formatCurrency(1000000), r'$1,000,000');
    expect(usd.formatCurrency(-1200.5), r'-$1,200.50');
    // The number-format setting is respected independently of currency.
    expect(eurIndian.formatCurrency(100000), '€1,00,000');
  });

  test('explicit symbol still overrides (currency converter)', () {
    expect(usd.formatCurrency(5, symbol: '£'), '£5');
  });

  test('compact forms follow the number format', () {
    expect(inr.formatCompactCurrency(5210000), '₹52.1L');
    expect(usd.formatCompactCurrency(5200000), r'$5.2M');
    expect(usd.formatCompactCurrency(0), r'$0');
  });

  test('amount tokens render at display time and mask in privacy mode', () {
    final body = 'You spent ${AppFormatter.amountToken(11200)} on fuel';
    expect(usd.renderAmountTokens(body), r'You spent $11,200 on fuel');
    expect(inr.renderAmountTokens(body), 'You spent ₹11,200 on fuel');
    expect(usd.renderAmountTokens(body, isPrivate: true),
        'You spent **** on fuel');
    // Older rows without a token are left as written.
    expect(usd.renderAmountTokens('EMI of ₹500 due'), 'EMI of ₹500 due');
  });

  test('formatterProvider follows the boot currency and updates current', () {
    final container = ProviderContainer(overrides: [
      bootNumberFormatProvider
          .overrideWithValue(('USD', NumberSystem.international)),
    ]);
    addTearDown(container.dispose);
    final f = container.read(formatterProvider);
    expect(f.formatCurrency(2500), r'$2,500');
    expect(AppFormatter.current.symbol, r'$');
  });
}
