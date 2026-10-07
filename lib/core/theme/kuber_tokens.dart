import 'package:flutter/material.dart';

import 'theme_families.dart';

export 'theme_families.dart' show ThemeVariant;

/// The Vault token set (Signature only since the M3 redesign; other
/// families fall back to it). Feeds the native home-widget bridge.
/// One variant's full Vault token set (one brightness of one family), as
/// specified in specs/design/kuber-theme/.../tokens.md. `AppTheme` builds the
/// entire ThemeData from an instance of this class; widgets never read these
/// directly (the app theme is built from theme_families.dart).
@immutable
class KuberTokens {
  final Color background;
  final Color surfaceCard;
  final Color surfaceMuted;
  final Color border;
  final Color borderMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final Color primarySubtle;

  /// Accent at 24-30% alpha: selected-card borders and focus outlines.
  final Color primaryRing;

  /// Text/icon color rendered on top of a solid [primary] fill.
  final Color onPrimary;

  /// Accent variant that is safe to use as text on the variant's BG. Equals
  /// [primary] except where the accent is too low-contrast as text (Purrhub
  /// Obsidian per the tokens.md note).
  final Color primaryText;

  final Color income;
  final Color incomeSubtle;
  final Color expense;
  final Color expenseSubtle;
  final Color warning;
  final Color warningSubtle;

  // Upcoming Events source-pill accents. Family-independent by design; they
  // only vary with brightness.
  final Color eventEmi;
  final Color eventLedger;

  const KuberTokens({
    required this.background,
    required this.surfaceCard,
    required this.surfaceMuted,
    required this.border,
    required this.borderMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.primarySubtle,
    required this.primaryRing,
    required this.onPrimary,
    required this.primaryText,
    required this.income,
    required this.incomeSubtle,
    required this.expense,
    required this.expenseSubtle,
    required this.warning,
    required this.warningSubtle,
    required this.eventEmi,
    required this.eventLedger,
  });

  /// Dark (Obsidian) token set for [variant].
  static KuberTokens dark(ThemeVariant variant) =>
      _dark[variant] ?? _dark[ThemeVariant.signature]!;

  /// Light (Alabaster) token set for [variant].
  static KuberTokens light(ThemeVariant variant) =>
      _light[variant] ?? _light[ThemeVariant.signature]!;

  static KuberTokens of(ThemeVariant variant, Brightness brightness) =>
      brightness == Brightness.dark ? dark(variant) : light(variant);

  static const Map<ThemeVariant, KuberTokens> _dark = {
    // Kuber Signature keeps the exact pre-personalization Vault values from
    // KuberColors so the default theme is byte-identical to before.
    ThemeVariant.signature: KuberTokens(
      background: KuberColors.background,
      surfaceCard: KuberColors.surfaceCard,
      surfaceMuted: KuberColors.surfaceMuted,
      border: KuberColors.border,
      borderMuted: KuberColors.borderMuted,
      textPrimary: KuberColors.textPrimary,
      textSecondary: KuberColors.textSecondary,
      primary: KuberColors.primary,
      primarySubtle: KuberColors.primarySubtle,
      primaryRing: Color(0x473B82F6),
      onPrimary: Colors.white,
      primaryText: KuberColors.primary,
      income: KuberColors.income,
      incomeSubtle: KuberColors.incomeSubtle,
      expense: KuberColors.expense,
      expenseSubtle: KuberColors.expenseSubtle,
      warning: KuberColors.warning,
      warningSubtle: KuberColors.warningSubtle,
      eventEmi: KuberColors.eventEmi,
      eventLedger: KuberColors.eventLedger,
    ),
  };

  static const Map<ThemeVariant, KuberTokens> _light = {
    // Signature light likewise mirrors KuberLightColors exactly.
    ThemeVariant.signature: KuberTokens(
      background: KuberLightColors.background,
      surfaceCard: KuberLightColors.surfaceCard,
      surfaceMuted: KuberLightColors.surfaceMuted,
      border: KuberLightColors.border,
      borderMuted: KuberLightColors.borderMuted,
      textPrimary: KuberLightColors.textPrimary,
      textSecondary: KuberLightColors.textSecondary,
      primary: KuberLightColors.primary,
      primarySubtle: KuberLightColors.primarySubtle,
      primaryRing: Color(0x3D3B82F6),
      onPrimary: Colors.white,
      primaryText: KuberLightColors.primary,
      income: KuberLightColors.income,
      incomeSubtle: KuberLightColors.incomeSubtle,
      expense: KuberLightColors.expense,
      expenseSubtle: KuberLightColors.expenseSubtle,
      warning: KuberLightColors.warning,
      warningSubtle: KuberLightColors.warningSubtle,
      eventEmi: KuberLightColors.eventEmi,
      eventLedger: KuberLightColors.eventLedger,
    ),
  };
}

/// Vault reference values. Since the M3 redesign these feed only the native
/// home-screen widget bridge (WidgetSyncService) via [KuberTokens]; the app
/// theme is built from theme_families.dart.
/// The Kuber Signature (default family) dark palette. These constants are the
/// reference values for `KuberTokens.dark(ThemeVariant.signature)`; widgets
/// must not read them directly — go through `Theme.of(context).colorScheme`
/// so all seven theme families work.
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

