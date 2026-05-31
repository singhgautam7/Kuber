import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography definitions for the Kuber app.
///
/// Instead of calling [GoogleFonts.inter] in every build method,
/// we define the styles here as pre-resolved configurations. The Inter font
/// is resolved by GoogleFonts exactly once (per weight) and the resulting
/// [TextStyle] is cached, so build methods can `.copyWith(...)` off these
/// without paying the GoogleFonts lookup cost on every frame. This is what
/// keeps lists and heavy screens (the story ring, the story viewer, the
/// archive grid) from re-resolving Inter on every rebuild.
class AppTextStyles {
  // Base Inter styles — resolved once and cached (note: `final`, not `get`,
  // so the GoogleFonts lookup does not run on every access).
  static final TextStyle inter = GoogleFonts.inter();

  static final TextStyle regular = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
  );

  static final TextStyle medium = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
  );

  static final TextStyle semiBold = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bold = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
  );

  static final TextStyle extraBold = GoogleFonts.inter(
    fontWeight: FontWeight.w800,
  );

  /// Returns the default TextTheme for the app based on Inter.
  /// Used in [AppTheme] to ensure consistency.
  static TextTheme getTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base);
  }
}
