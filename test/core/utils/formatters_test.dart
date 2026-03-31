import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';

void main() {
  group('AppFormatter - Indian system', () {
    final formatter = AppFormatter(system: NumberSystem.indian);

    test('formatCurrency formats with Indian grouping', () {
      expect(formatter.formatCurrency(1234567), '₹12,34,567');
    });

    test('formatCurrency shows decimals only when fractional', () {
      expect(formatter.formatCurrency(1000), '₹1,000');
      expect(formatter.formatCurrency(1000.50), '₹1,000.50');
    });

    test('formatCurrency handles negative values', () {
      expect(formatter.formatCurrency(-1200), '-₹1,200');
    });

    test('formatCurrency handles zero', () {
      expect(formatter.formatCurrency(0), '₹0');
    });

    test('formatCurrency uses custom symbol', () {
      expect(formatter.formatCurrency(100, symbol: '\$'), '\$100');
    });

    test('formatCompactCurrency uses K/L/Cr for Indian system', () {
      expect(formatter.formatCompactCurrency(0), '₹0');
      expect(formatter.formatCompactCurrency(500), '₹500');
      expect(formatter.formatCompactCurrency(1500), '₹1.5K');
      expect(formatter.formatCompactCurrency(10000), '₹10K');
      expect(formatter.formatCompactCurrency(150000), '₹1.5L');
      expect(formatter.formatCompactCurrency(1500000), '₹15L');
      expect(formatter.formatCompactCurrency(15000000), '₹1.5Cr');
    });

    test('formatCompactCurrency handles negative values', () {
      expect(formatter.formatCompactCurrency(-5000), '-₹5K');
    });

    test('formatCompactCurrency strips trailing .0', () {
      expect(formatter.formatCompactCurrency(1000), '₹1K');
      expect(formatter.formatCompactCurrency(100000), '₹1L');
      expect(formatter.formatCompactCurrency(10000000), '₹1Cr');
    });

    test('formatPercentage formats correctly', () {
      expect(formatter.formatPercentage(75), '75%');
      expect(formatter.formatPercentage(33.3), '33.3%');
      expect(formatter.formatPercentage(100.0), '100%');
      expect(formatter.formatPercentage(0), '0%');
    });

    test('formatNumber uses Indian grouping', () {
      expect(formatter.formatNumber(1234567), '12,34,567');
    });

    test('formatNumber respects decimalDigits', () {
      expect(formatter.formatNumber(1234.5, decimalDigits: 2), '1,234.50');
    });
  });

  group('AppFormatter - International system', () {
    final formatter = AppFormatter(system: NumberSystem.international);

    test('formatCurrency formats with standard grouping', () {
      expect(formatter.formatCurrency(1234567), '₹1,234,567');
    });

    test('formatCompactCurrency uses K/M/B for International system', () {
      expect(formatter.formatCompactCurrency(0), '₹0');
      expect(formatter.formatCompactCurrency(500), '₹500');
      expect(formatter.formatCompactCurrency(1500), '₹1.5K');
      expect(formatter.formatCompactCurrency(1500000), '₹1.5M');
      expect(formatter.formatCompactCurrency(1500000000), '₹1.5B');
    });

    test('formatCompactCurrency strips trailing .0', () {
      expect(formatter.formatCompactCurrency(1000), '₹1K');
      expect(formatter.formatCompactCurrency(1000000), '₹1M');
      expect(formatter.formatCompactCurrency(1000000000), '₹1B');
    });

    test('formatNumber uses standard grouping', () {
      expect(formatter.formatNumber(1234567), '1,234,567');
    });
  });

  group('CurrencyInputFormatter', () {
    TextEditingValue format(CurrencyInputFormatter f, String text) {
      return f.formatEditUpdate(
        const TextEditingValue(),
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      );
    }

    test('Indian formatter adds commas correctly', () {
      final f = CurrencyInputFormatter(isIndian: true);
      expect(format(f, '1234567').text, '12,34,567');
    });

    test('International formatter adds commas correctly', () {
      final f = CurrencyInputFormatter(isIndian: false);
      expect(format(f, '1234567').text, '1,234,567');
    });

    test('handles empty input', () {
      final f = CurrencyInputFormatter();
      expect(format(f, '').text, '');
    });

    test('handles decimal input', () {
      final f = CurrencyInputFormatter(isIndian: true);
      expect(format(f, '1234.56').text, '1,234.56');
    });

    test('handles lone dot as 0.', () {
      final f = CurrencyInputFormatter();
      final result = format(f, '.');
      expect(result.text, '0.');
    });

    test('returns old value for invalid input', () {
      final f = CurrencyInputFormatter();
      final old = const TextEditingValue(text: '123');
      final result = f.formatEditUpdate(
        old,
        const TextEditingValue(text: 'abc'),
      );
      expect(result.text, '123');
    });
  });
}
