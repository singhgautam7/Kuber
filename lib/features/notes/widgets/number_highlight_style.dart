import 'package:flutter/material.dart';
import 'package:kuber/core/theme/app_theme.dart';

import '../../../core/utils/locale_font.dart';

/// Shared styling for highlighted numbers and resolved arithmetic results in
/// the Notes editor (board 3.23): tapped numbers get a secondaryContainer
/// mark, negatives the expense container, results a primary mark.
class NumberHighlightStyle {
  const NumberHighlightStyle._();

  static TextStyle regular(BuildContext context, {required bool negative}) {
    final cs = Theme.of(context).colorScheme;
    final m = context.kuberMoney;
    return localeFont(
      fontWeight: FontWeight.w600,
      color: negative ? m.onExpenseContainer : cs.onSecondaryContainer,
    ).copyWith(
      backgroundColor: negative ? m.expenseContainer : cs.secondaryContainer,
    );
  }

  static TextStyle result(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return localeFont(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: cs.onPrimary,
    ).copyWith(backgroundColor: cs.primary);
  }
}
