import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global reference to track the active app locale so that non-contextual
/// typography lookups can dynamically resolve to the correct regional font family.
class AppLocale {
  static Locale current = const Locale('en');
}

/// Monospace style for raw SMS text, sender ids, hashes and similar. Backed by
/// the JetBrains Mono weights bundled in pubspec `fonts:`, so the engine has
/// it from the first frame. Do not use GoogleFonts.jetBrainsMono: a runtime
/// font load parses on the UI thread and relayouts every route on arrival.
TextStyle monoFont({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  List<FontFeature>? fontFeatures,
}) {
  return TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    fontFeatures: fontFeatures,
  );
}

/// Instrument Serif italic, the About page's editorial accent (board 3.13).
/// Bundled in pubspec `fonts:` (never a runtime GoogleFonts load). The family
/// ships one weight, so [fontWeight] is accepted for call-site parity but not
/// applied (no faux bold); the style is always italic.
TextStyle serifFont({
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  Color? color,
  double? letterSpacing,
  double? height,
  TextDecoration? decoration,
  Color? decorationColor,
  TextDecorationStyle? decorationStyle,
}) {
  return TextStyle(
    fontFamily: 'InstrumentSerif',
    fontStyle: FontStyle.italic,
    fontSize: fontSize,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    decorationColor: decorationColor,
    decorationStyle: decorationStyle,
  );
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
    if (w == FontWeight.w700 || w == FontWeight.w900) {
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

/// Kuber M3 type scale (tokens.md §3): 13 roles, 9 sizes, Inter (or the
/// locale's Noto family) via [localeFont]. Figures are tabular everywhere so
/// amounts line up.
///
/// Regional scripts keep their taller family-aware line height; Inter takes the
/// spec's line height.
TextTheme buildKuberTextTheme(Locale locale, ColorScheme cs) {
  final en = locale.languageCode == 'en';
  const tab = [FontFeature.tabularFigures()];
  TextStyle r(double size, double line, FontWeight w, double tracking,
          [Color? color]) =>
      localeFont(
        locale: locale,
        fontSize: size,
        fontWeight: w,
        letterSpacing: tracking,
        height: en ? line / size : null,
        color: color ?? cs.onSurface,
        fontFeatures: tab,
      );
  return TextTheme(
    displayLarge: r(57, 64, FontWeight.w700, -0.25),
    displayMedium: r(45, 52, FontWeight.w700, 0),
    displaySmall: r(36, 44, FontWeight.w700, -0.5),
    headlineLarge: r(32, 40, FontWeight.w700, -0.5),
    headlineMedium: r(28, 36, FontWeight.w700, -0.25),
    headlineSmall: r(24, 32, FontWeight.w600, 0),
    titleLarge: r(22, 28, FontWeight.w600, -0.2),
    titleMedium: r(16, 24, FontWeight.w600, 0.1),
    titleSmall: r(14, 20, FontWeight.w600, 0.1),
    bodyLarge: r(16, 24, FontWeight.w400, 0),
    bodyMedium: r(14, 20, FontWeight.w400, 0),
    bodySmall: r(12, 16, FontWeight.w400, 0, cs.onSurfaceVariant),
    labelLarge: r(14, 20, FontWeight.w600, 0.1),
    labelMedium: r(12, 16, FontWeight.w600, 0.5),
    labelSmall: r(11, 16, FontWeight.w500, 0.5),
  );
}

/// Section header style: labelMedium, uppercase is applied by the caller,
/// 0.8 tracking, onSurfaceVariant (tokens.md §3).
TextStyle sectionHeaderStyle(BuildContext context) {
  final t = Theme.of(context);
  return t.textTheme.labelMedium!.copyWith(
    letterSpacing: 0.8,
    color: t.colorScheme.onSurfaceVariant,
  );
}

/// Display-only sentence case for labels whose ARB copy is all caps ("AVG
/// DAILY" -> "Avg daily"), the M3 boards' "sentence case via style". Copy is
/// unchanged; scripts without case pass through untouched.
String sentenceCase(String s) {
  if (s.isEmpty || s != s.toUpperCase()) return s;
  final lower = s.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}
