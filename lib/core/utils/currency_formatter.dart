import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String currency = 'INR'}) {
    final symbols = {
      'INR': '₹',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
    };
    final symbol = symbols[currency] ?? currency;
    final formatter = NumberFormat('#,##0.00');
    return '$symbol${formatter.format(amount.abs())}';
  }
}
