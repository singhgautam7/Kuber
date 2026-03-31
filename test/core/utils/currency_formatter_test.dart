import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('formats INR with rupee symbol', () {
      expect(CurrencyFormatter.format(1234.56), '₹1,234.56');
    });

    test('uses absolute value', () {
      expect(CurrencyFormatter.format(-500.00), '₹500.00');
    });

    test('handles zero', () {
      expect(CurrencyFormatter.format(0), '₹0.00');
    });

    test('formats USD with dollar symbol', () {
      expect(CurrencyFormatter.format(1234.56, currency: 'USD'), '\$1,234.56');
    });

    test('formats EUR with euro symbol', () {
      expect(CurrencyFormatter.format(1234.56, currency: 'EUR'), '€1,234.56');
    });

    test('falls back to INR for unknown currency', () {
      expect(CurrencyFormatter.format(100, currency: 'UNKNOWN'), '₹100.00');
    });

    test('formats large amounts', () {
      expect(CurrencyFormatter.format(1234567.89), '₹1,234,567.89');
    });

    test('always shows 2 decimal places', () {
      expect(CurrencyFormatter.format(100), '₹100.00');
    });
  });
}
