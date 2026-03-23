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
  // static const surfaceCard = Color(0xFF09090B);
  static const surfaceCard = Color(0xFF0D0D10);
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

class KuberLightColors {
  // Backgrounds
  static const background = Color(0xFFFFFFFF);
  static const surfaceCard = Color(0xFFFAFAFA);
  static const surfaceMuted = Color(0xFFF4F4F5);

  // Borders
  static const border = Color(0xFFE4E4E7);
  static const borderMuted = Color(0xFFD4D4D8);

  // Text
  static const textPrimary = Color(0xFF09090B);
  static const textSecondary = Color(0xFF71717A);

  // Primary
  static const primary = Color(0xFF3B82F6);
  static const primarySubtle = Color(0x1A3B82F6);

  // Semantic
  static const income = Color(0xFF16A34A);
  static const incomeSubtle = Color(0x1A16A34A);
  static const expense = Color(0xFFDC2626);
  static const expenseSubtle = Color(0x1ADC2626);

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
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: KuberColors.primary);
          }
          return const IconThemeData(color: KuberColors.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: KuberColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: KuberColors.textSecondary,
          );
        }),
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

  static ThemeData light() {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    );

    final colorScheme = ColorScheme.light(
      surface: KuberLightColors.background,
      onSurface: KuberLightColors.textPrimary,
      onSurfaceVariant: KuberLightColors.textSecondary,
      primary: KuberLightColors.primary,
      onPrimary: Colors.white,
      primaryContainer: KuberLightColors.primarySubtle,
      onPrimaryContainer: KuberLightColors.primary,
      secondary: KuberLightColors.primary,
      onSecondary: Colors.white,
      tertiary: KuberLightColors.income,
      onTertiary: Colors.white,
      error: KuberLightColors.expense,
      onError: Colors.white,
      errorContainer: KuberLightColors.expenseSubtle,
      onErrorContainer: KuberLightColors.expense,
      surfaceContainer: KuberLightColors.surfaceCard,
      surfaceContainerHigh: KuberLightColors.surfaceMuted,
      outline: KuberLightColors.border,
      outlineVariant: KuberLightColors.borderMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      scaffoldBackgroundColor: KuberLightColors.background,
      cardTheme: CardThemeData(
        color: KuberLightColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: KuberLightColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KuberLightColors.surfaceCard,
        indicatorColor: KuberLightColors.primarySubtle,
        surfaceTintColor: Colors.transparent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: KuberLightColors.primary);
          }
          return const IconThemeData(color: KuberLightColors.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: KuberLightColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: KuberLightColors.textSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KuberLightColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: KuberLightColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: KuberLightColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: const BorderSide(color: KuberLightColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: KuberLightColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: KuberLightColors.border,
        thickness: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KuberLightColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: KuberLightColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KuberLightColors.surfaceCard,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: KuberLightColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: KuberLightColors.border),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KuberLightColors.surfaceMuted,
        side: const BorderSide(color: KuberLightColors.border),
        selectedColor: KuberLightColors.primarySubtle,
        checkmarkColor: KuberLightColors.primary,
        showCheckmark: true,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: KuberLightColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KuberLightColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(KuberRadius.lg),
          ),
          side: BorderSide(color: KuberLightColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: KuberLightColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: const BorderSide(color: KuberLightColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KuberLightColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KuberLightColors.textPrimary,
          side: const BorderSide(color: KuberLightColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KuberLightColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return KuberLightColors.primarySubtle;
            }
            return KuberLightColors.surfaceCard;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return KuberLightColors.primary;
            }
            return KuberLightColors.textSecondary;
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: KuberLightColors.border),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return KuberLightColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KuberLightColors.primary;
          }
          return KuberLightColors.surfaceMuted;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KuberLightColors.primary,
        linearTrackColor: KuberLightColors.surfaceMuted,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: KuberLightColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: KuberLightColors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
    );
  }
}
