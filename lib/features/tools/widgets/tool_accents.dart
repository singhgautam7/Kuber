import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Per-tool accent colours from the design mockup. The blue/green/amber/red
/// map onto Vault tokens; purple/emerald/pink have no ColorScheme slot so they
/// live here as named constants (never raw hex in screens).
class ToolAccents {
  static const blue = KuberColors.primary;
  static const green = KuberColors.income;
  static const amber = KuberColors.warning;
  static const red = KuberColors.expense;
  static const purple = Color(0xFFA855F7);
  static const emerald = Color(0xFF10B981);
  static const pink = Color(0xFFEC4899);
}
