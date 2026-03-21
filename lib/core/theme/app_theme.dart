import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KuberSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class KuberColors {
  static const background = Color(0xFF0F0F11);
  static const card = Color(0xFF1C1B1F);
  static const cardLight = Color(0xFF252429);
  static const surface = Color(0xFF161618);
  static const divider = Color(0xFF2C2C2E);
  static const textPrimary = Color(0xFFE6E1E5);
  static const textSecondary = Color(0xFF938F99);
  static const accent = Color(0xFF4B6BFB);
  static const income = Color(0xFF4CAF50);
  static const expense = Color(0xFFEF5350);
  static const gradientStart = Color(0xFF1565C0);
  static const gradientEnd = Color(0xFF0D47A1);

  // Aliases for semantic usage
  static const surfaceElement = cardLight;
  static const surfaceCard = card;
  static const surfaceDivider = divider;
  static const textMuted = Color(0xFF5E5A66);
  static const primary = accent;
}

class AppTheme {
  static ThemeData dark() {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );

    final colorScheme = ColorScheme.dark(
      surface: KuberColors.background,
      onSurface: KuberColors.textPrimary,
      onSurfaceVariant: KuberColors.textSecondary,
      primary: KuberColors.accent,
      onPrimary: Colors.white,
      primaryContainer: KuberColors.accent.withValues(alpha: 0.2),
      onPrimaryContainer: KuberColors.accent,
      secondary: KuberColors.accent,
      onSecondary: Colors.white,
      tertiary: KuberColors.income,
      onTertiary: Colors.white,
      error: KuberColors.expense,
      onError: Colors.white,
      errorContainer: KuberColors.expense.withValues(alpha: 0.2),
      onErrorContainer: KuberColors.expense,
      surfaceContainer: KuberColors.card,
      surfaceContainerHigh: KuberColors.cardLight,
      outline: KuberColors.divider,
      outlineVariant: KuberColors.divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      scaffoldBackgroundColor: KuberColors.background,
      cardTheme: CardThemeData(
        color: KuberColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KuberColors.surface,
        indicatorColor: KuberColors.accent.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(
            color: KuberColors.textSecondary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KuberColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KuberColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KuberColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KuberColors.accent, width: 2),
        ),
        labelStyle: TextStyle(color: KuberColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: KuberColors.divider,
        thickness: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: KuberColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KuberColors.cardLight,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: KuberColors.textPrimary,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KuberColors.surfaceElement,
        side: BorderSide.none,
        selectedColor: KuberColors.primary.withValues(alpha: 0.18),
        checkmarkColor: KuberColors.primary,
        showCheckmark: false,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: KuberColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
    );
  }
}
