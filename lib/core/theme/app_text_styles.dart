import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

/// Centralized typography definitions for the Kuber app.
///
/// Pre-built Inter styles cached as `final`s so build methods can
/// `.copyWith(...)` off them without constructing a style on every frame.
class AppTextStyles {
    static final TextStyle inter = localeFont();

  static final TextStyle regular = localeFont(
    fontWeight: FontWeight.w400,
  );

  static final TextStyle medium = localeFont(
    fontWeight: FontWeight.w500,
  );

  static final TextStyle semiBold = localeFont(
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bold = localeFont(
    fontWeight: FontWeight.w700,
  );

  /// Returns the default TextTheme for the app based on Inter.
  /// Used in [AppTheme] to ensure consistency.
  static TextTheme getTextTheme(TextTheme base) {
    TextStyle? f(TextStyle? t) =>
        t?.merge(localeFont(fontWeight: t.fontWeight ?? FontWeight.w400));
    return base.copyWith(
      displayLarge: f(base.displayLarge),
      displayMedium: f(base.displayMedium),
      displaySmall: f(base.displaySmall),
      headlineLarge: f(base.headlineLarge),
      headlineMedium: f(base.headlineMedium),
      headlineSmall: f(base.headlineSmall),
      titleLarge: f(base.titleLarge),
      titleMedium: f(base.titleMedium),
      titleSmall: f(base.titleSmall),
      bodyLarge: f(base.bodyLarge),
      bodyMedium: f(base.bodyMedium),
      bodySmall: f(base.bodySmall),
      labelLarge: f(base.labelLarge),
      labelMedium: f(base.labelMedium),
      labelSmall: f(base.labelSmall),
    );
  }
}