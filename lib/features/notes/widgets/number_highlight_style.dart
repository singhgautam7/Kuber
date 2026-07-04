import 'package:flutter/material.dart';

import '../../../core/utils/locale_font.dart';

/// Shared styling for highlighted numbers and resolved arithmetic results in
/// the Notes editor (screens 1d-1g).
///
/// Regular tokens: primary-tinted background + primary text, w600. Negative
/// tokens use the expense-red equivalent. Resolved results: solid primary
/// background, onPrimary text, w800, noticeably larger.
class NumberHighlightStyle {
  const NumberHighlightStyle._();

  /// Brightens [base] slightly on dark surfaces so tinted text keeps the
  /// "60A5FA on rgba(59,130,246,0.14)" contrast relationship of the design.
  static Color _brighten(BuildContext context, Color base) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Color.lerp(base, Colors.white, 0.25)!;
    }
    return base;
  }

  static TextStyle regular(BuildContext context, {required bool negative}) {
    final cs = Theme.of(context).colorScheme;
    final accent = negative ? cs.error : cs.primary;
    return localeFont(
      fontWeight: FontWeight.w600,
      color: _brighten(context, accent),
    ).copyWith(backgroundColor: accent.withValues(alpha: 0.14));
  }

  static TextStyle result(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return localeFont(
      fontWeight: FontWeight.w800,
      fontSize: 17,
      color: Colors.white,
    ).copyWith(backgroundColor: cs.primary);
  }
}
