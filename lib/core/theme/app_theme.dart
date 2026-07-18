import 'package:flutter/material.dart';
import 'app_text_styles.dart';
import 'kuber_tokens.dart';
import '../utils/locale_font.dart';

export 'kuber_tokens.dart' show ThemeVariant, KuberTokens;

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
  static const xl = 24.0; // brand icons, large cards
  static const full = 999.0;
}

/// The Kuber Signature (default family) dark palette. These constants are the
/// reference values for `KuberTokens.dark(ThemeVariant.signature)`; widgets
/// must not read them directly — go through `Theme.of(context).colorScheme`
/// or `context.kuberColors` so all seven theme families work.
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
  static const warning = Color(0xFFF59E0B);
  static const warningSubtle = Color(0x1AF59E0B);

  // Upcoming Events source-pill accents (per the Notes/Reminders/Events
  // handoff design — EMI purple, Ledger yellow; other sources reuse
  // primary / income / warning).
  static const eventEmi = Color(0xFFA855F7);
  static const eventLedger = Color(0xFFFACC15);

  // Utility
  static const white = Color(0xFFFFFFFF);
}

/// The Kuber Signature (default family) light palette. Same caveat as
/// [KuberColors]: reference values only, never read from widgets.
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
  static const warning = Color(0xFFD97706);
  static const warningSubtle = Color(0x1AD97706);

  // Upcoming Events source-pill accents (darker for light surfaces).
  static const eventEmi = Color(0xFF9333EA);
  static const eventLedger = Color(0xFFCA8A04);

  // Utility
  static const white = Color(0xFFFFFFFF);
}

/// Semantic colors that have no slot in Material's [ColorScheme]: the
/// warning/over-budget amber, the selected-card ring, the accent-as-text
/// variant, and the Upcoming Events source-pill accents. Registered as a
/// [ThemeExtension] so every value tracks the active theme family and mode.
/// Access via `context.kuberColors.*` instead of hardcoding hex.
@immutable
class KuberSemanticColors extends ThemeExtension<KuberSemanticColors> {
  final Color warning;
  final Color warningSubtle;
  final Color primaryRing;
  final Color primaryText;
  final Color eventEmi;
  final Color eventLedger;

  /// The Vault `borderMuted` token. Light themes expose it as
  /// `colorScheme.outlineVariant`, but dark themes map `outlineVariant` to
  /// `border` (a long-standing mapping kept for visual parity), so this is the
  /// only reliable way to read borderMuted in both modes.
  final Color borderMuted;

  const KuberSemanticColors({
    required this.warning,
    required this.warningSubtle,
    this.primaryRing = const Color(0x473B82F6),
    this.primaryText = KuberColors.primary,
    this.eventEmi = KuberColors.eventEmi,
    this.eventLedger = KuberColors.eventLedger,
    this.borderMuted = KuberColors.borderMuted,
  });

  KuberSemanticColors.fromTokens(KuberTokens tokens)
      : warning = tokens.warning,
        warningSubtle = tokens.warningSubtle,
        primaryRing = tokens.primaryRing,
        primaryText = tokens.primaryText,
        eventEmi = tokens.eventEmi,
        eventLedger = tokens.eventLedger,
        borderMuted = tokens.borderMuted;

  static const dark = KuberSemanticColors(
    warning: KuberColors.warning,
    warningSubtle: KuberColors.warningSubtle,
  );

  static const light = KuberSemanticColors(
    warning: KuberLightColors.warning,
    warningSubtle: KuberLightColors.warningSubtle,
    primaryRing: Color(0x3D3B82F6),
    primaryText: KuberLightColors.primary,
    eventEmi: KuberLightColors.eventEmi,
    eventLedger: KuberLightColors.eventLedger,
    borderMuted: KuberLightColors.borderMuted,
  );

  @override
  KuberSemanticColors copyWith({
    Color? warning,
    Color? warningSubtle,
    Color? primaryRing,
    Color? primaryText,
    Color? eventEmi,
    Color? eventLedger,
    Color? borderMuted,
  }) {
    return KuberSemanticColors(
      warning: warning ?? this.warning,
      warningSubtle: warningSubtle ?? this.warningSubtle,
      primaryRing: primaryRing ?? this.primaryRing,
      primaryText: primaryText ?? this.primaryText,
      eventEmi: eventEmi ?? this.eventEmi,
      eventLedger: eventLedger ?? this.eventLedger,
      borderMuted: borderMuted ?? this.borderMuted,
    );
  }

  @override
  KuberSemanticColors lerp(
    ThemeExtension<KuberSemanticColors>? other,
    double t,
  ) {
    if (other is! KuberSemanticColors) return this;
    return KuberSemanticColors(
      warning: Color.lerp(warning, other.warning, t)!,
      warningSubtle: Color.lerp(warningSubtle, other.warningSubtle, t)!,
      primaryRing: Color.lerp(primaryRing, other.primaryRing, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      eventEmi: Color.lerp(eventEmi, other.eventEmi, t)!,
      eventLedger: Color.lerp(eventLedger, other.eventLedger, t)!,
      borderMuted: Color.lerp(borderMuted, other.borderMuted, t)!,
    );
  }
}

/// Convenience accessor for [KuberSemanticColors]. Falls back to the dark
/// palette if the extension is somehow missing (e.g. a bare test theme).
extension KuberThemeX on BuildContext {
  KuberSemanticColors get kuberColors =>
      Theme.of(this).extension<KuberSemanticColors>() ??
      KuberSemanticColors.dark;
}

class AppTheme {
  static ThemeData dark(
    Locale locale, [
    ThemeVariant variant = ThemeVariant.signature,
  ]) {
    return _build(
      tokens: KuberTokens.dark(variant),
      brightness: Brightness.dark,
      locale: locale,
    );
  }

  static ThemeData light(
    Locale locale, [
    ThemeVariant variant = ThemeVariant.signature,
  ]) {
    return _build(
      tokens: KuberTokens.light(variant),
      brightness: Brightness.light,
      locale: locale,
    );
  }

  static ThemeData _build({
    required KuberTokens tokens,
    required Brightness brightness,
    required Locale locale,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = buildKuberTextTheme(
      locale,
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    // Keep the legacy named constructors so every slot not set here resolves
    // to the exact same fallback it always has; Signature must stay
    // byte-identical to the pre-personalization theme.
    final colorScheme = isDark
        ? ColorScheme.dark(
            surface: tokens.background,
            onSurface: tokens.textPrimary,
            onSurfaceVariant: tokens.textSecondary,
            primary: tokens.primary,
            onPrimary: tokens.onPrimary,
            primaryContainer: tokens.primarySubtle,
            onPrimaryContainer: tokens.primary,
            secondary: tokens.primary,
            onSecondary: tokens.onPrimary,
            tertiary: tokens.income,
            onTertiary: Colors.white,
            tertiaryContainer: tokens.incomeSubtle,
            onTertiaryContainer: tokens.income,
            error: tokens.expense,
            onError: Colors.white,
            errorContainer: tokens.expenseSubtle,
            onErrorContainer: tokens.expense,
            surfaceContainer: tokens.surfaceCard,
            surfaceContainerHigh: tokens.surfaceMuted,
            outline: tokens.border,
            // Dark has always mapped outlineVariant to border (not
            // borderMuted); preserved for parity.
            outlineVariant: tokens.border,
          )
        : ColorScheme.light(
            surface: tokens.background,
            onSurface: tokens.textPrimary,
            onSurfaceVariant: tokens.textSecondary,
            primary: tokens.primary,
            onPrimary: tokens.onPrimary,
            primaryContainer: tokens.primarySubtle,
            onPrimaryContainer: tokens.primary,
            secondary: tokens.primary,
            onSecondary: tokens.onPrimary,
            tertiary: tokens.income,
            onTertiary: Colors.white,
            tertiaryContainer: tokens.incomeSubtle,
            onTertiaryContainer: tokens.income,
            error: tokens.expense,
            onError: Colors.white,
            errorContainer: tokens.expenseSubtle,
            onErrorContainer: tokens.expense,
            surfaceContainer: tokens.surfaceCard,
            surfaceContainerHigh: tokens.surfaceMuted,
            outline: tokens.border,
            outlineVariant: tokens.borderMuted,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [KuberSemanticColors.fromTokens(tokens)],
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      scaffoldBackgroundColor: tokens.background,
      cardTheme: CardThemeData(
        color: tokens.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: BorderSide(color: tokens.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surfaceCard,
        indicatorColor: tokens.primarySubtle,
        surfaceTintColor: Colors.transparent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: tokens.primary);
          }
          return IconThemeData(color: tokens.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: tokens.primaryText,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: tokens.textSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: BorderSide(color: tokens.primary, width: 2),
        ),
        labelStyle: TextStyle(color: tokens.textSecondary),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.border,
        thickness: 0.5,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: tokens.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.surfaceCard,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: tokens.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: BorderSide(color: tokens.border),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.surfaceMuted,
        side: BorderSide(color: tokens.border),
        selectedColor: tokens.primarySubtle,
        checkmarkColor: tokens.primary,
        showCheckmark: true,
        labelStyle: AppTextStyles.inter.copyWith(
          fontSize: 13,
          color: tokens.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(KuberRadius.lg),
          ),
          side: BorderSide(color: tokens.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: BorderSide(color: tokens.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.textPrimary,
          side: BorderSide(color: tokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.primaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return tokens.primarySubtle;
            }
            return tokens.surfaceCard;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return tokens.primaryText;
            }
            return tokens.textSecondary;
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: tokens.border),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return tokens.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return tokens.primary;
          return tokens.surfaceMuted;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.primary,
        linearTrackColor: tokens.surfaceMuted,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: tokens.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: tokens.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
      ),
    );
  }
}
