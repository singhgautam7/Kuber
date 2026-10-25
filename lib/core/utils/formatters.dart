import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../features/settings/providers/settings_provider.dart';
import 'currency_data.dart';

class AppFormatter {
  /// The selected currency (ISO entry). Every amount in the app is formatted
  /// with it unless a caller passes a different explicit `symbol:` (currency
  /// converter).
  final KuberCurrency currency;

  /// Settings > "Show currency code instead of symbol".
  final bool showCode;

  final NumberSystem _system;

  AppFormatter({
    NumberSystem system = NumberSystem.indian,
    String? symbol,
    KuberCurrency? currency,
    this.showCode = false,
  })  : currency = currency ?? _currencyForSymbol(symbol),
        _system = system;

  static KuberCurrency _currencyForSymbol(String? symbol) {
    if (symbol == null) return kCurrencies.first;
    return kCurrencies.where((c) => c.symbol == symbol).firstOrNull ??
        KuberCurrency(code: symbol, name: symbol, symbol: symbol);
  }

  /// Effective grouping: Automatic resolves to Indian for INR, else
  /// international.
  NumberSystem get system => _system == NumberSystem.automatic
      ? (currency.indianGrouping ? NumberSystem.indian : NumberSystem.international)
      : _system;

  /// The symbol (or code) amounts are shown with.
  String get symbol => showCode ? currency.code : currency.symbol;

  /// The formatter for the current settings, for code that has no `ref`
  /// (notification bodies, stories isolate input). Seeded from prefs in
  /// `_bootstrap` and refreshed whenever `formatterProvider` rebuilds.
  static AppFormatter current = AppFormatter();

  /// Token stored in persisted text (in-app notification bodies) in place of a
  /// formatted amount, so it renders in the currency selected at display time.
  static String amountToken(num amount) => '{amt:$amount}';

  static final RegExp _amountTokenRe = RegExp(r'\{amt:(-?[\d.]+)\}');

  /// Replaces [amountToken]s in [text] with formatted amounts, or `****` when
  /// [isPrivate]. Text without tokens (older rows) is returned unchanged.
  String renderAmountTokens(String text, {bool isPrivate = false}) =>
      text.replaceAllMapped(_amountTokenRe, (m) {
        if (isPrivate) return '****';
        return formatCurrency(double.tryParse(m[1]!) ?? 0);
      });

  static final Map<String, NumberFormat> _cache = {};

  NumberFormat _number(int decimalDigits) {
    final locale = system == NumberSystem.indian ? 'en_IN' : 'en_US';
    final key = '$locale-$decimalDigits';
    return _cache[key] ??= NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: decimalDigits,
    );
  }

  /// Places [sym] before or after [number] per the currency (codes always
  /// lead with a space: "USD 1,200").
  String _place(String sym, String number) {
    if (showCode) return '$sym $number';
    if (currency.after) return '$number $sym';
    return currency.spaced ? '$sym $number' : '$sym$number';
  }

  /// A whole amount shows no decimals; otherwise the currency's ISO minor
  /// units (INR 2, JPY 0, KWD 3). Stored values are never rounded here.
  String formatCurrency(num amount, {String? symbol}) {
    final legacy =
        symbol != null && symbol != currency.symbol && symbol != currency.code;
    final d = legacy ? 2 : currency.decimals;
    final formatted =
        _number(amount % 1 == 0 || d == 0 ? 0 : d).format(amount.abs());
    // Handle negative values: -₹1,200 instead of ₹-1,200
    final body = legacy ? '$symbol$formatted' : _place(this.symbol, formatted);
    return amount < 0 ? '-$body' : body;
  }

  String formatCompactCurrency(num amount, {String? symbol}) {
    final legacy =
        symbol != null && symbol != currency.symbol && symbol != currency.code;
    String place(String n) => legacy ? '$symbol$n' : _place(this.symbol, n);
    if (amount == 0) return place('0');
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

    return '${isNegative ? '-' : ''}${place(result)}';
  }

  /// Parses a formatted or typed amount back to a number (grouping, symbol
  /// and code stripped). Used by the round-trip tests and amount fields.
  double? parseAmount(String text) {
    var t = text.trim();
    final neg = t.startsWith('-');
    // Longest first, so "MOP$" or "ZAR" go before "$" or "R".
    final marks = {currency.symbol, currency.code, currency.narrow}.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final m in marks) {
      t = t.replaceAll(m, '');
    }
    t = t
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('-', '');
    final v = double.tryParse(t);
    return v == null ? null : (neg ? -v : v);
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

class CurrencyInputFormatter extends TextInputFormatter {
  final bool isIndian;

  /// Most fraction digits accepted: the selected currency's minor units
  /// (JPY 0 = no decimal point, KWD 3).
  final int decimals;

  CurrencyInputFormatter({this.isIndian = true, int? decimals})
      : decimals = decimals ?? AppFormatter.current.currency.decimals;

  /// Groups a value set in code ("2500000" -> "25,00,000"); returns [raw]
  /// unchanged when it isn't a plain number or doesn't fit the decimals.
  String format(String raw) {
    final v = double.tryParse(raw.replaceAll(',', ''));
    if (v == null) return raw;
    final plain = v == v.roundToDouble() ? v.round().toString() : '$v';
    final f = formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: plain)).text;
    return f.isEmpty ? raw : f;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Remove commas and detect/preserve negative sign
    String text = newValue.text.replaceAll(',', '');
    final isNegative = text.startsWith('-');
    if (isNegative) text = text.substring(1);

    // Allow just a minus sign
    if (newValue.text == '-') {
      return newValue.copyWith(
        text: '-',
        selection: const TextSelection.collapsed(offset: 1),
      );
    }
    
    if (text.contains('.') && decimals == 0) return oldValue;
    if (text.contains('.') && text.split('.').last.length > decimals) {
      return oldValue;
    }

    // Allow partial decimals like "." or "0."
    if (text == '.') {
      final result = '${isNegative ? '-' : ''}0.';
      return newValue.copyWith(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }

    // 2. Parse number
    double? value = double.tryParse(text);
    if (value == null) {
      // If parsing fails but it's not empty, it might be invalid text
      // We check if it's just multiple dots or other junk
      return oldValue;
    }

    // 3. Format Number
    final locale = isIndian ? 'en_IN' : 'en_US';
    // We use decimalPattern for commas without currency symbol
    final formatter = NumberFormat.decimalPattern(locale);
    
    // Handle decimals
    String formatted;
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length > 2) return oldValue; // Multiple dots
      
      final integralPart = double.tryParse(parts[0]) ?? 0;
      final formattedIntegral = formatter.format(integralPart);
      formatted = '$formattedIntegral.${parts[1]}';
    } else {
      formatted = formatter.format(value);
    }

    // Re-prepend minus sign if negative
    if (isNegative) formatted = '-$formatted';

    // 4. Cursor position preservation
    final selectionIndex = newValue.selection.baseOffset;
    
    // Compare how many characters were added/removed compared to raw input
    // newValue.text might contain the character just typed + old commas
    final diff = formatted.length - newValue.text.length;
    final newOffset = (selectionIndex + diff).clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

class TitleCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String transformed = newValue.text.toTitleCase();

    return newValue.copyWith(
      text: transformed,
      selection: newValue.selection,
    );
  }
}

extension StringExtensions on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
