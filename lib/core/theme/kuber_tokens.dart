import 'package:flutter/material.dart';

import 'app_theme.dart';

/// The seven Kuber theme families. Order is the display order in the Theme
/// sheet and the persisted index in SharedPreferences, so append only.
enum ThemeVariant {
  signature,
  flewtube,
  woofsapp,
  purrhub,
  honkpe,
  squeakdin,
  oinkzon,
}

/// One variant's full Vault token set (one brightness of one family), as
/// specified in specs/design/kuber-theme/.../tokens.md. `AppTheme` builds the
/// entire ThemeData from an instance of this class; widgets never read these
/// directly (they go through ColorScheme / KuberSemanticColors).
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
  static KuberTokens dark(ThemeVariant variant) => _dark[variant]!;

  /// Light (Alabaster) token set for [variant].
  static KuberTokens light(ThemeVariant variant) => _light[variant]!;

  static KuberTokens of(ThemeVariant variant, Brightness brightness) =>
      brightness == Brightness.dark ? dark(variant) : light(variant);

  // Shared warning safety token (unchanged from Vault across families).
  static const _warnDark = Color(0xFFF59E0B);
  static const _warnDarkSubtle = Color(0x1FF59E0B);
  static const _warnLight = Color(0xFFD97706);
  static const _warnLightSubtle = Color(0x1AD97706);

  // Event pill accents, brightness-dependent only.
  static const _eventEmiDark = Color(0xFFA855F7);
  static const _eventLedgerDark = Color(0xFFFACC15);
  static const _eventEmiLight = Color(0xFF9333EA);
  static const _eventLedgerLight = Color(0xFFCA8A04);

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
    ThemeVariant.flewtube: KuberTokens(
      background: Color(0xFF080304),
      surfaceCard: Color(0xFF140B0C),
      surfaceMuted: Color(0xFF201315),
      border: Color(0xFF332022),
      borderMuted: Color(0xFF4C3438),
      textPrimary: Color(0xFFFBF7F7),
      textSecondary: Color(0xFFAF9DA0),
      primary: Color(0xFFE5484D),
      primarySubtle: Color(0x24E5484D),
      primaryRing: Color(0x4DE5484D),
      onPrimary: Colors.white,
      primaryText: Color(0xFFE5484D),
      income: Color(0xFF34D399),
      incomeSubtle: Color(0x2434D399),
      expense: Color(0xFFF59E0B),
      expenseSubtle: Color(0x24F59E0B),
      warning: _warnDark,
      warningSubtle: _warnDarkSubtle,
      eventEmi: _eventEmiDark,
      eventLedger: _eventLedgerDark,
    ),
    ThemeVariant.woofsapp: KuberTokens(
      background: Color(0xFF020805),
      surfaceCard: Color(0xFF0A140E),
      surfaceMuted: Color(0xFF122017),
      border: Color(0xFF1F3326),
      borderMuted: Color(0xFF334C3C),
      textPrimary: Color(0xFFF6FBF8),
      textSecondary: Color(0xFF9BAFA2),
      primary: Color(0xFF1FB855),
      primarySubtle: Color(0x241FB855),
      primaryRing: Color(0x4D1FB855),
      onPrimary: Color(0xFF020805),
      primaryText: Color(0xFF1FB855),
      income: Color(0xFF38BDF8),
      incomeSubtle: Color(0x2438BDF8),
      expense: Color(0xFFEF4444),
      expenseSubtle: Color(0x24EF4444),
      warning: _warnDark,
      warningSubtle: _warnDarkSubtle,
      eventEmi: _eventEmiDark,
      eventLedger: _eventLedgerDark,
    ),
    ThemeVariant.purrhub: KuberTokens(
      background: Color(0xFF0A0A08),
      surfaceCard: Color(0xFF14140F),
      surfaceMuted: Color(0xFF1F1F18),
      border: Color(0xFF2A2A22),
      borderMuted: Color(0xFF3F3F33),
      textPrimary: Color(0xFFFAFAF5),
      textSecondary: Color(0xFFA8A89A),
      primary: Color(0xFFFACC15),
      primarySubtle: Color(0x24FACC15),
      primaryRing: Color(0x4DFACC15),
      onPrimary: Color(0xFF14120A),
      // Accent yellow carrying a text label uses the lighter #FDE68A to keep
      // contrast above 7:1 (tokens.md note).
      primaryText: Color(0xFFFDE68A),
      income: Color(0xFF22C55E),
      incomeSubtle: Color(0x2422C55E),
      expense: Color(0xFFEF4444),
      expenseSubtle: Color(0x24EF4444),
      warning: _warnDark,
      warningSubtle: _warnDarkSubtle,
      eventEmi: _eventEmiDark,
      eventLedger: _eventLedgerDark,
    ),
    ThemeVariant.honkpe: KuberTokens(
      background: Color(0xFF060310),
      surfaceCard: Color(0xFF0F0A1C),
      surfaceMuted: Color(0xFF181229),
      border: Color(0xFF271E3F),
      borderMuted: Color(0xFF3D315C),
      textPrimary: Color(0xFFF9F8FC),
      textSecondary: Color(0xFFA49CB8),
      primary: Color(0xFF8B5CF6),
      primarySubtle: Color(0x248B5CF6),
      primaryRing: Color(0x4D8B5CF6),
      onPrimary: Colors.white,
      primaryText: Color(0xFF8B5CF6),
      income: Color(0xFF22C55E),
      incomeSubtle: Color(0x2422C55E),
      expense: Color(0xFFEF4444),
      expenseSubtle: Color(0x24EF4444),
      warning: _warnDark,
      warningSubtle: _warnDarkSubtle,
      eventEmi: _eventEmiDark,
      eventLedger: _eventLedgerDark,
    ),
    ThemeVariant.squeakdin: KuberTokens(
      background: Color(0xFF020509),
      surfaceCard: Color(0xFF080E17),
      surfaceMuted: Color(0xFF101A28),
      border: Color(0xFF1C2C42),
      borderMuted: Color(0xFF2F4460),
      textPrimary: Color(0xFFF6FAFD),
      textSecondary: Color(0xFF96A7BB),
      primary: Color(0xFF4A7FD1),
      primarySubtle: Color(0x244A7FD1),
      primaryRing: Color(0x4D4A7FD1),
      onPrimary: Colors.white,
      primaryText: Color(0xFF4A7FD1),
      income: Color(0xFF22C55E),
      incomeSubtle: Color(0x2422C55E),
      expense: Color(0xFFEF4444),
      expenseSubtle: Color(0x24EF4444),
      warning: _warnDark,
      warningSubtle: _warnDarkSubtle,
      eventEmi: _eventEmiDark,
      eventLedger: _eventLedgerDark,
    ),
    ThemeVariant.oinkzon: KuberTokens(
      background: Color(0xFF080502),
      surfaceCard: Color(0xFF150E07),
      surfaceMuted: Color(0xFF22170D),
      border: Color(0xFF362617),
      borderMuted: Color(0xFF503A26),
      textPrimary: Color(0xFFFCF8F4),
      textSecondary: Color(0xFFB3A190),
      primary: Color(0xFFFB923C),
      primarySubtle: Color(0x24FB923C),
      primaryRing: Color(0x4DFB923C),
      onPrimary: Color(0xFF1A1006),
      primaryText: Color(0xFFFB923C),
      income: Color(0xFF22C55E),
      incomeSubtle: Color(0x2422C55E),
      expense: Color(0xFFEF4444),
      expenseSubtle: Color(0x24EF4444),
      warning: _warnDark,
      warningSubtle: _warnDarkSubtle,
      eventEmi: _eventEmiDark,
      eventLedger: _eventLedgerDark,
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
    ThemeVariant.flewtube: KuberTokens(
      background: Color(0xFFFFF9F9),
      surfaceCard: Color(0xFFFBF2F2),
      surfaceMuted: Color(0xFFF6E9E9),
      border: Color(0xFFECD8D8),
      borderMuted: Color(0xFFDDC2C2),
      textPrimary: Color(0xFF1A0B0D),
      textSecondary: Color(0xFF7E686B),
      primary: Color(0xFFC41E3A),
      primarySubtle: Color(0x1AC41E3A),
      primaryRing: Color(0x3DC41E3A),
      onPrimary: Colors.white,
      primaryText: Color(0xFFC41E3A),
      income: Color(0xFF059669),
      incomeSubtle: Color(0x1A059669),
      expense: Color(0xFFB45309),
      expenseSubtle: Color(0x1AB45309),
      warning: _warnLight,
      warningSubtle: _warnLightSubtle,
      eventEmi: _eventEmiLight,
      eventLedger: _eventLedgerLight,
    ),
    ThemeVariant.woofsapp: KuberTokens(
      background: Color(0xFFF8FDF9),
      surfaceCard: Color(0xFFF0F9F2),
      surfaceMuted: Color(0xFFE7F3EA),
      border: Color(0xFFD5E8DA),
      borderMuted: Color(0xFFBFD8C6),
      textPrimary: Color(0xFF08140D),
      textSecondary: Color(0xFF5F7A68),
      primary: Color(0xFF15803D),
      primarySubtle: Color(0x1A15803D),
      primaryRing: Color(0x3D15803D),
      onPrimary: Colors.white,
      primaryText: Color(0xFF15803D),
      income: Color(0xFF0369A1),
      incomeSubtle: Color(0x1A0369A1),
      expense: Color(0xFFDC2626),
      expenseSubtle: Color(0x1ADC2626),
      warning: _warnLight,
      warningSubtle: _warnLightSubtle,
      eventEmi: _eventEmiLight,
      eventLedger: _eventLedgerLight,
    ),
    ThemeVariant.purrhub: KuberTokens(
      background: Color(0xFFFFFDF5),
      surfaceCard: Color(0xFFFBF8EC),
      surfaceMuted: Color(0xFFF5F1E1),
      border: Color(0xFFEAE4CE),
      borderMuted: Color(0xFFDBD2B5),
      textPrimary: Color(0xFF14120A),
      textSecondary: Color(0xFF78715B),
      primary: Color(0xFFA16207),
      primarySubtle: Color(0x1AA16207),
      primaryRing: Color(0x3DA16207),
      onPrimary: Colors.white,
      primaryText: Color(0xFFA16207),
      income: Color(0xFF16A34A),
      incomeSubtle: Color(0x1A16A34A),
      expense: Color(0xFFDC2626),
      expenseSubtle: Color(0x1ADC2626),
      warning: _warnLight,
      warningSubtle: _warnLightSubtle,
      eventEmi: _eventEmiLight,
      eventLedger: _eventLedgerLight,
    ),
    ThemeVariant.honkpe: KuberTokens(
      background: Color(0xFFFCFAFF),
      surfaceCard: Color(0xFFF7F3FD),
      surfaceMuted: Color(0xFFF0EAF9),
      border: Color(0xFFE2D8F0),
      borderMuted: Color(0xFFCFC0E3),
      textPrimary: Color(0xFF120A20),
      textSecondary: Color(0xFF6F6488),
      primary: Color(0xFF6D28D9),
      primarySubtle: Color(0x1A6D28D9),
      primaryRing: Color(0x3D6D28D9),
      onPrimary: Colors.white,
      primaryText: Color(0xFF6D28D9),
      income: Color(0xFF16A34A),
      incomeSubtle: Color(0x1A16A34A),
      expense: Color(0xFFDC2626),
      expenseSubtle: Color(0x1ADC2626),
      warning: _warnLight,
      warningSubtle: _warnLightSubtle,
      eventEmi: _eventEmiLight,
      eventLedger: _eventLedgerLight,
    ),
    ThemeVariant.squeakdin: KuberTokens(
      background: Color(0xFFF7FAFE),
      surfaceCard: Color(0xFFEFF4FB),
      surfaceMuted: Color(0xFFE6EDF7),
      border: Color(0xFFD3DEEC),
      borderMuted: Color(0xFFBCCCE0),
      textPrimary: Color(0xFF081220),
      textSecondary: Color(0xFF5B6E86),
      primary: Color(0xFF1E3A8A),
      primarySubtle: Color(0x1A1E3A8A),
      primaryRing: Color(0x3D1E3A8A),
      onPrimary: Colors.white,
      primaryText: Color(0xFF1E3A8A),
      income: Color(0xFF16A34A),
      incomeSubtle: Color(0x1A16A34A),
      expense: Color(0xFFDC2626),
      expenseSubtle: Color(0x1ADC2626),
      warning: _warnLight,
      warningSubtle: _warnLightSubtle,
      eventEmi: _eventEmiLight,
      eventLedger: _eventLedgerLight,
    ),
    ThemeVariant.oinkzon: KuberTokens(
      background: Color(0xFFFFFAF4),
      surfaceCard: Color(0xFFFBF3E9),
      surfaceMuted: Color(0xFFF6EADB),
      border: Color(0xFFECDBC4),
      borderMuted: Color(0xFFDDC6A7),
      textPrimary: Color(0xFF1A1006),
      textSecondary: Color(0xFF7E6C58),
      primary: Color(0xFFC2410C),
      primarySubtle: Color(0x1AC2410C),
      primaryRing: Color(0x3DC2410C),
      onPrimary: Colors.white,
      primaryText: Color(0xFFC2410C),
      income: Color(0xFF16A34A),
      incomeSubtle: Color(0x1A16A34A),
      expense: Color(0xFFDC2626),
      expenseSubtle: Color(0x1ADC2626),
      warning: _warnLight,
      warningSubtle: _warnLightSubtle,
      eventEmi: _eventEmiLight,
      eventLedger: _eventLedgerLight,
    ),
  };
}
