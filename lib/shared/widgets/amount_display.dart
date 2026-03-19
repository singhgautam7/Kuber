import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';

class AmountDisplay extends StatelessWidget {
  final double amount;
  final String type; // 'income' | 'expense'
  final TextStyle? style;
  final String currency;

  const AmountDisplay({
    super.key,
    required this.amount,
    required this.type,
    this.style,
    this.currency = 'INR',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIncome = type == 'income';
    final prefix = isIncome ? '+' : '-';
    final color = isIncome ? colorScheme.tertiary : colorScheme.error;

    final defaultStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        );

    return Text(
      '$prefix${CurrencyFormatter.format(amount, currency: currency)}',
      style: style?.copyWith(color: color) ?? defaultStyle,
    );
  }
}
