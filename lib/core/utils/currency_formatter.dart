import 'package:intl/intl.dart';

import 'currency_data.dart';

class CurrencyFormatter {
  static String format(double amount, {String currency = 'INR'}) {
    final symbol = currencyFromCode(currency).symbol;
    final formatter = NumberFormat('#,##0.00');
    return '$symbol${formatter.format(amount.abs())}';
  }
}
