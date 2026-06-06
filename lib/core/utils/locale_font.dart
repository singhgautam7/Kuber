import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global reference to track the active app locale so that non-contextual
/// typography lookups can dynamically resolve to the correct regional font family.
class AppLocale {
  static Locale current = const Locale('en');
}

/// Returns a TextStyle in the script-appropriate family for `locale`,
/// matching Inter's weight scale across all four families. The
/// `height` value is family-aware.
///
/// Always call this from any text builder. Never call GoogleFonts.inter
/// (or any other family) directly from a widget.
TextStyle localeFont({
  Locale? locale,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  FontStyle? fontStyle,
  List<FontFeature>? fontFeatures,
}) {
  // Use the explicit locale arg if given; otherwise read from the global static
  // active locale.
  final code = (locale ?? AppLocale.current).languageCode;

  final h = height ?? _defaultHeight(code);

  // Non-Latin scripts combines glyphs into ligatures; negative tracking is
  // unset to avoid collisions in these joins.
  var ls = letterSpacing;
  if (code != 'en' && ls != null && ls < 0) {
    ls = 0.0;
  }

  // Cap font weight at Bold (w700) for regional scripts because heavier
  // weights do not exist in Noto Sans regional variants.
  var w = fontWeight;
  if (code != 'en') {
    if (w == FontWeight.w800 || w == FontWeight.w900) {
      w = FontWeight.w700;
    }
  }

  switch (code) {
    case 'hi':
    case 'mr':
      return GoogleFonts.notoSansDevanagari(
        fontSize: fontSize,
        fontWeight: w,
        color: color,
        letterSpacing: ls,
        height: h,
        decoration: decoration,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
      );
    case 'pa':
      return GoogleFonts.notoSansGurmukhi(
        fontSize: fontSize,
        fontWeight: w,
        color: color,
        letterSpacing: ls,
        height: h,
        decoration: decoration,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
      );
    case 'bn':
      return GoogleFonts.notoSansBengali(
        fontSize: fontSize,
        fontWeight: w,
        color: color,
        letterSpacing: ls,
        height: h,
        decoration: decoration,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
      );
    case 'te':
      return GoogleFonts.notoSansTelugu(
        fontSize: fontSize,
        fontWeight: w,
        color: color,
        letterSpacing: ls,
        height: h,
        decoration: decoration,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
      );
    case 'ta':
      return GoogleFonts.notoSansTamil(
        fontSize: fontSize,
        fontWeight: w,
        color: color,
        letterSpacing: ls,
        height: h,
        decoration: decoration,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
      );
    case 'ml':
      return GoogleFonts.notoSansMalayalam(
        fontSize: fontSize,
        fontWeight: w,
        color: color,
        letterSpacing: ls,
        height: h,
        decoration: decoration,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
      );
    case 'kn':
      return GoogleFonts.notoSansKannada(
        fontSize: fontSize,
        fontWeight: w,
        color: color,
        letterSpacing: ls,
        height: h,
        decoration: decoration,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
      );
    case 'en':
    default:
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: w,
        color: color,
        letterSpacing: ls,
        height: h,
        decoration: decoration,
        fontStyle: fontStyle,
        fontFeatures: fontFeatures,
      );
  }
}

double _defaultHeight(String code) {
  switch (code) {
    case 'hi':
    case 'mr':
    case 'bn':
    case 'te':
    case 'ta':
    case 'ml':
    case 'kn':
      return 1.45; // upper matras + descenders need air
    case 'pa':
      return 1.40; // Gurmukhi sits a touch tighter than Devanagari
    case 'en':
    default:
      return 1.30; // Inter's existing app-wide line-height
  }
}

/// Builds a locale-aware [TextTheme] based on a fallback base theme.
TextTheme buildKuberTextTheme(Locale locale, TextTheme base) {
  return TextTheme(
    displayLarge: localeFont(locale: locale, fontSize: base.displayLarge?.fontSize, fontWeight: base.displayLarge?.fontWeight, color: base.displayLarge?.color, letterSpacing: base.displayLarge?.letterSpacing),
    displayMedium: localeFont(locale: locale, fontSize: base.displayMedium?.fontSize, fontWeight: base.displayMedium?.fontWeight, color: base.displayMedium?.color, letterSpacing: base.displayMedium?.letterSpacing),
    displaySmall: localeFont(locale: locale, fontSize: base.displaySmall?.fontSize, fontWeight: base.displaySmall?.fontWeight, color: base.displaySmall?.color, letterSpacing: base.displaySmall?.letterSpacing),
    headlineLarge: localeFont(locale: locale, fontSize: base.headlineLarge?.fontSize, fontWeight: base.headlineLarge?.fontWeight, color: base.headlineLarge?.color, letterSpacing: base.headlineLarge?.letterSpacing),
    headlineMedium: localeFont(locale: locale, fontSize: base.headlineMedium?.fontSize, fontWeight: base.headlineMedium?.fontWeight, color: base.headlineMedium?.color, letterSpacing: base.headlineMedium?.letterSpacing),
    headlineSmall: localeFont(locale: locale, fontSize: base.headlineSmall?.fontSize, fontWeight: base.headlineSmall?.fontWeight, color: base.headlineSmall?.color, letterSpacing: base.headlineSmall?.letterSpacing),
    titleLarge: localeFont(locale: locale, fontSize: base.titleLarge?.fontSize, fontWeight: base.titleLarge?.fontWeight, color: base.titleLarge?.color, letterSpacing: base.titleLarge?.letterSpacing),
    titleMedium: localeFont(locale: locale, fontSize: base.titleMedium?.fontSize, fontWeight: base.titleMedium?.fontWeight, color: base.titleMedium?.color, letterSpacing: base.titleMedium?.letterSpacing),
    titleSmall: localeFont(locale: locale, fontSize: base.titleSmall?.fontSize, fontWeight: base.titleSmall?.fontWeight, color: base.titleSmall?.color, letterSpacing: base.titleSmall?.letterSpacing),
    bodyLarge: localeFont(locale: locale, fontSize: base.bodyLarge?.fontSize, fontWeight: base.bodyLarge?.fontWeight, color: base.bodyLarge?.color, letterSpacing: base.bodyLarge?.letterSpacing),
    bodyMedium: localeFont(locale: locale, fontSize: base.bodyMedium?.fontSize, fontWeight: base.bodyMedium?.fontWeight, color: base.bodyMedium?.color, letterSpacing: base.bodyMedium?.letterSpacing),
    bodySmall: localeFont(locale: locale, fontSize: base.bodySmall?.fontSize, fontWeight: base.bodySmall?.fontWeight, color: base.bodySmall?.color, letterSpacing: base.bodySmall?.letterSpacing),
    labelLarge: localeFont(locale: locale, fontSize: base.labelLarge?.fontSize, fontWeight: base.labelLarge?.fontWeight, color: base.labelLarge?.color, letterSpacing: base.labelLarge?.letterSpacing),
    labelMedium: localeFont(locale: locale, fontSize: base.labelMedium?.fontSize, fontWeight: base.labelMedium?.fontWeight, color: base.labelMedium?.color, letterSpacing: base.labelMedium?.letterSpacing),
    labelSmall: localeFont(locale: locale, fontSize: base.labelSmall?.fontSize, fontWeight: base.labelSmall?.fontWeight, color: base.labelSmall?.color, letterSpacing: base.labelSmall?.letterSpacing),
  );
}
