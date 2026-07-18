import 'package:flutter/material.dart';

/// Per-tool accent colours from the design mockup. These are fixed decorative
/// identity colors (like category colors), deliberately independent of the
/// active theme family so each tool keeps a stable identity; screens render
/// them via `harmonizeCategory`-style usage or as-is, never as theme roles.
/// Named constants only — never raw hex in screens.
class ToolAccents {
  static const blue = Color(0xFF3B82F6);
  static const green = Color(0xFF22C55E);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const purple = Color(0xFFA855F7);
  static const emerald = Color(0xFF10B981);
  static const pink = Color(0xFFEC4899);
}
