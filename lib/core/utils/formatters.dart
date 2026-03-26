import 'package:intl/intl.dart';
import '../../features/settings/providers/settings_provider.dart';

class AppFormatter {
  final NumberSystem system;

  AppFormatter({this.system = NumberSystem.indian});

  static final Map<String, NumberFormat> _cache = {};

  NumberFormat _getFormatter({
    required String locale,
    String? symbol,
    int? decimalDigits,
  }) {
    final key = '$locale-$symbol-$decimalDigits';
    if (!_cache.containsKey(key)) {
      _cache[key] = NumberFormat.currency(
        locale: locale,
        symbol: symbol ?? '',
        decimalDigits: decimalDigits,
      );
    }
    return _cache[key]!;
  }

  String formatCurrency(num amount, {String symbol = '₹'}) {
    final locale = system == NumberSystem.indian ? 'en_IN' : 'en_US';
    final formatter = _getFormatter(
      locale: locale,
      symbol: symbol,
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );

    // Handle negative values: -₹1,200 instead of ₹-1,200
    final formatted = formatter.format(amount.abs());
    return amount < 0 ? '-$formatted' : formatted;
  }

  String formatCompactCurrency(num amount, {String symbol = '₹'}) {
    if (amount == 0) return '${symbol}0';
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String result;
    if (system == NumberSystem.indian) {
      if (absAmount < 1000) {
        result = absAmount.toStringAsFixed(0);
      } else if (absAmount < 100000) {
        result = '${(absAmount / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
      } else if (absAmount < 10000000) {
        result = '${(absAmount / 100000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}L';
      } else {
        result = '${(absAmount / 10000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}Cr';
      }
    } else {
      if (absAmount < 1000) {
        result = absAmount.toStringAsFixed(0);
      } else if (absAmount < 1000000) {
        result = '${(absAmount / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
      } else if (absAmount < 1000000000) {
        result = '${(absAmount / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
      } else {
        result = '${(absAmount / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
      }
    }

    return '${isNegative ? '-' : ''}$symbol$result';
  }

  String formatPercentage(num value) {
    final formatted = value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    return '$formatted%';
  }

  String formatNumber(num value, {int? decimalDigits}) {
    final locale = system == NumberSystem.indian ? 'en_IN' : 'en_US';
    final formatter = NumberFormat.decimalPattern(locale);
    if (decimalDigits != null) {
      formatter.minimumFractionDigits = decimalDigits;
      formatter.maximumFractionDigits = decimalDigits;
    } else {
      formatter.minimumFractionDigits = 0;
      formatter.maximumFractionDigits = 2;
    }
    return formatter.format(value);
  }
}
