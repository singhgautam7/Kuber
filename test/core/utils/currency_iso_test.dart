import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/currency_data.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';

AppFormatter _auto(String code, {bool showCode = false}) => AppFormatter(
    system: NumberSystem.automatic,
    currency: currencyFromCode(code),
    showCode: showCode);

void main() {
  test('the table is the active ISO 4217 list, unique, with sane data', () {
    final codes = kCurrencies.map((c) => c.code).toList();
    expect(codes.toSet().length, codes.length);
    expect(codes.length, greaterThanOrEqualTo(150));
    for (final c in kCurrencies) {
      expect(RegExp(r'^[A-Z]{3}$').hasMatch(c.code), isTrue, reason: c.code);
      expect(c.name, isNotEmpty);
      expect(c.symbol, isNotEmpty);
      expect([0, 2, 3], contains(c.decimals), reason: c.code);
      expect(c.name.contains('—'), isFalse);
    }
  });

  test('every currency formats and parses back without error', () {
    for (final c in kCurrencies) {
      for (final grouping in NumberSystem.values) {
        for (final showCode in [false, true]) {
          final f = AppFormatter(system: grouping, currency: c, showCode: showCode);
          for (final v in [0.0, 1.0, 999.5, 1234567.891, -42.25, 100000.0]) {
            final s = f.formatCurrency(v);
            final back = f.parseAmount(s);
            expect(back, isNotNull, reason: '${c.code} $s');
            final unit = c.decimals == 0 ? 1.0 : (c.decimals == 2 ? 0.01 : 0.001);
            final expected = v % 1 == 0 || c.decimals == 0
                ? v.roundToDouble()
                : v;
            expect((back! - expected).abs() <= unit / 2 + 1e-9, isTrue,
                reason: '${c.code} $v -> $s -> $back');
            expect(f.formatCompactCurrency(v), isNotEmpty);
          }
        }
      }
    }
  });

  test('decimals follow ISO minor units (JPY 0, INR 2, KWD 3)', () {
    expect(_auto('JPY').formatCurrency(1234.6), '¥1,235');
    expect(_auto('JPY').formatCurrency(1234), '¥1,234');
    expect(_auto('INR').formatCurrency(1234.5), '₹1,234.50');
    expect(_auto('INR').formatCurrency(1234), '₹1,234');
    expect(_auto('KWD').formatCurrency(1234.5), 'KD 1,234.500');
    expect(_auto('KWD').formatCurrency(1234), 'KD 1,234');
    expect(_auto('BHD').formatCurrency(0.125), 'BD 0.125');
  });

  test('grouping: lakh for INR, standard otherwise (Automatic)', () {
    expect(_auto('INR').formatCurrency(12500000), '₹1,25,00,000');
    expect(_auto('USD').formatCurrency(12500000), r'$12,500,000');
    expect(_auto('INR').formatCompactCurrency(5210000), '₹52.1L');
    expect(_auto('USD').formatCompactCurrency(5200000), r'$5.2M');
    // An explicit choice is kept.
    expect(
        AppFormatter(system: NumberSystem.indian, currency: currencyFromCode('USD'))
            .formatCurrency(100000),
        r'$1,00,000');
  });

  test('symbol position and spacing', () {
    expect(_auto('KES').formatCurrency(1500), 'KSh 1,500');
    expect(_auto('SEK').formatCurrency(1500), '1,500 kr');
    expect(_auto('CHF').formatCurrency(-1500), '-CHF 1,500');
    expect(_auto('AUD').formatCurrency(1500), r'A$1,500');
    expect(_auto('EUR').formatCurrency(1500.5), '€1,500.50');
    expect(_auto('VND').formatCurrency(1500000), '1,500,000 ₫');
  });

  test('show currency code instead of symbol', () {
    expect(_auto('CAD', showCode: true).formatCurrency(1200), 'CAD 1,200');
    expect(_auto('AUD', showCode: true).formatCompactCurrency(1200000), 'AUD 1.2M');
  });

  test('the 26 pre-vNext currencies keep their symbols', () {
    const before = {
      'INR': '₹', 'USD': r'$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'CNY': '¥',
      'KRW': '₩', 'AUD': r'A$', 'CAD': r'C$', 'CHF': 'CHF', 'SEK': 'kr',
      'NOK': 'kr', 'DKK': 'kr', 'SGD': r'S$', 'HKD': r'HK$', 'MYR': 'RM',
      'THB': '฿', 'PHP': '₱', 'IDR': 'Rp', 'BRL': r'R$', 'MXN': r'MX$',
      'ZAR': 'R', 'AED': 'د.إ', 'SAR': '﷼', 'TRY': '₺',
    };
    for (final e in before.entries) {
      expect(currencyFromCode(e.key).symbol, e.value, reason: e.key);
    }
    expect(currencyFromCode('XXX').code, 'INR');
    expect(_auto('INR').formatCurrency(100000), AppFormatter().formatCurrency(100000));
  });

  test('phone region suggestion', () {
    expect(currencyForRegion('KE')!.code, 'KES');
    expect(currencyForRegion('de')!.code, 'EUR');
    expect(currencyForRegion('IN')!.code, 'INR');
    expect(currencyForRegion('ZZ'), isNull);
  });

  test('search by name, code or country', () {
    List<String> find(String q) =>
        kCurrencies.where((c) => c.matches(q)).map((c) => c.code).toList();
    expect(find('kenya'), ['KES']);
    expect(find('yen'), contains('JPY'));
    expect(find('kwd'), ['KWD']);
    expect(find('germany'), ['EUR']);
  });

  test('amount input respects the currency decimals', () {
    TextEditingValue type(CurrencyInputFormatter f, String old, String next) =>
        f.formatEditUpdate(TextEditingValue(text: old),
            TextEditingValue(text: next, selection: TextSelection.collapsed(offset: next.length)));
    final jpy = CurrencyInputFormatter(isIndian: false, decimals: 0);
    expect(type(jpy, '12', '12.').text, '12');
    final kwd = CurrencyInputFormatter(isIndian: false, decimals: 3);
    expect(type(kwd, '1.23', '1.234').text, '1.234');
    expect(type(kwd, '1.234', '1.2345').text, '1.234');
    final inr = CurrencyInputFormatter(isIndian: true, decimals: 2);
    expect(type(inr, '100000', '1000000').text, '10,00,000');
    expect(type(inr, '1.25', '1.255').text, '1.25');
  });
}
