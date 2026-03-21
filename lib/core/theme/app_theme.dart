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

class KuberRadius {
  static const sm = 4.0; // tags, badges
  static const md = 8.0; // cards, buttons, inputs, chips — universal
  static const lg = 12.0; // bottom sheets only
  static const full = 999.0;
}

class KuberColors {
  // Backgrounds
  static const background = Color(0xFF000000);
  static const surfaceCard = Color(0xFF09090B);
  static const surfaceMuted = Color(0xFF18181B);

  // Borders
  static const border = Color(0xFF27272A);
  static const borderMuted = Color(0xFF3F3F46);

  // Text
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFFA1A1AA);

  // Primary
  static const primary = Color(0xFF3B82F6);
  static const primarySubtle = Color(0x1A3B82F6);

  // Semantic
  static const income = Color(0xFF22C55E);
  static const incomeSubtle = Color(0x1A22C55E);
  static const expense = Color(0xFFEF4444);
  static const expenseSubtle = Color(0x1AEF4444);

  // Utility
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData dark() {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    final colorScheme = ColorScheme.dark(
      surface: KuberColors.background,
      onSurface: KuberColors.textPrimary,
      onSurfaceVariant: KuberColors.textSecondary,
      primary: KuberColors.primary,
      onPrimary: Colors.white,
      primaryContainer: KuberColors.primarySubtle,
      onPrimaryContainer: KuberColors.primary,
      secondary: KuberColors.primary,
      onSecondary: Colors.white,
      tertiary: KuberColors.income,
      onTertiary: Colors.white,
      error: KuberColors.expense,
      onError: Colors.white,
      errorContainer: KuberColors.expenseSubtle,
      onErrorContainer: KuberColors.expense,
      surfaceContainer: KuberColors.surfaceCard,
      surfaceContainerHigh: KuberColors.surfaceMuted,
      outline: KuberColors.border,
      outlineVariant: KuberColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      scaffoldBackgroundColor: KuberColors.background,
      cardTheme: CardThemeData(
        color: KuberColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: KuberColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KuberColors.surfaceCard,
        indicatorColor: KuberColors.primarySubtle,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(
            color: KuberColors.textSecondary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KuberColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: KuberColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: KuberColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: KuberColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: KuberColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: KuberColors.border,
        thickness: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KuberColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: KuberColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KuberColors.surfaceCard,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: KuberColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: KuberColors.border),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KuberColors.surfaceMuted,
        side: const BorderSide(color: KuberColors.border),
        selectedColor: KuberColors.primarySubtle,
        checkmarkColor: KuberColors.primary,
        showCheckmark: true,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: KuberColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KuberColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KuberRadius.lg),
          ),
          side: BorderSide(color: KuberColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: KuberColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: KuberColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KuberColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KuberColors.textPrimary,
          side: const BorderSide(color: KuberColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KuberColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return KuberColors.primarySubtle;
            }
            return KuberColors.surfaceCard;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return KuberColors.primary;
            }
            return KuberColors.textSecondary;
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: KuberColors.border),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return KuberColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return KuberColors.primary;
          return KuberColors.surfaceMuted;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KuberColors.primary,
        linearTrackColor: KuberColors.surfaceMuted,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: KuberColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: KuberColors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
    );
  }
}
