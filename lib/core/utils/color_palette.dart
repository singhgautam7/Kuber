import 'dart:math';

class AppColorPalette {
  static const List<int> colors = [
    0xFF3B82F6, // blue
    0xFF6366F1, // indigo
    0xFF8B5CF6, // violet
    0xFFEC4899, // pink
    0xFFEF4444, // red
    0xFFF97316, // orange
    0xFFF59E0B, // amber
    0xFF10B981, // emerald
    0xFF14B8A6, // teal
    0xFF06B6D4, // cyan
    0xFF64748B, // slate
    0xFF78716C, // stone
  ];

  static int getRandomColor() {
    return colors[Random().nextInt(colors.length)];
  }
}
