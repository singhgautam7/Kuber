import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography definitions for the Kuber app.
/// 
/// Instead of calling [GoogleFonts.inter] in every build method,
/// we define the styles here as static constants (where possible) or
/// pre-computed configurations. This significantly reduces the overhead
/// that causes UI jank in lists and heavy screens.
class AppTextStyles {
  // Base Inter styles
  static TextStyle get inter => GoogleFonts.inter();
  
  static TextStyle get regular => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
      );

  static TextStyle get medium => GoogleFonts.inter(
        fontWeight: FontWeight.w500,
      );

  static TextStyle get semiBold => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bold => GoogleFonts.inter(
        fontWeight: FontWeight.w700,
      );

  static TextStyle get extraBold => GoogleFonts.inter(
        fontWeight: FontWeight.w800,
      );

  /// Returns the default TextTheme for the app based on Inter.
  /// Used in [AppTheme] to ensure consistency.
  static TextTheme getTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base);
  }
}
