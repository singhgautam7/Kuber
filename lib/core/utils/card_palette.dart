import 'package:flutter/material.dart';

/// Curated card-background palette for Kuber Cards. The card fill is **content
/// data** (a stored `int` / gradient index), exactly like `Account.colorValue`,
/// and is the one sanctioned exception to "colorScheme only". Everything else on
/// and around the card stays pure `colorScheme`.
///
/// Solids reuse `AppColorPalette.kVibrant` hues (so cards feel native) plus two
/// neutrals. Gradients pair sit-adjacent hues so the mid-point keeps a single
/// brightness, which keeps the derived `onCard` text colour honest.
/// See `specs/design/.../kuber-cards/tokens-and-visual-spec.md`.
class CardPalette {
  const CardPalette._();

  /// Solid backgrounds (ARGB ints). A broad set: a bright bank + a deep bank +
  /// neutrals, all saturated/dark enough to keep `onCard` legible (near-white
  /// hues are deliberately excluded).
  static const List<int> solids = <int>[
    // Bright
    0xFF3B82F6, // Blue
    0xFF6366F1, // Indigo
    0xFF8B5CF6, // Violet
    0xFFA855F7, // Purple
    0xFFD946EF, // Fuchsia
    0xFFEC4899, // Pink
    0xFFF43F5E, // Rose
    0xFFEF4444, // Red
    0xFFF97316, // Orange
    0xFFF59E0B, // Amber
    0xFF84CC16, // Lime
    0xFF22C55E, // Green
    0xFF10B981, // Emerald
    0xFF14B8A6, // Teal
    0xFF06B6D4, // Cyan
    0xFF0EA5E9, // Sky
    // Deep
    0xFF1D4ED8, // Deep Blue
    0xFF4338CA, // Deep Indigo
    0xFF7C3AED, // Deep Violet
    0xFF9333EA, // Deep Purple
    0xFFC026D3, // Deep Fuchsia
    0xFFDB2777, // Deep Pink
    0xFFE11D48, // Deep Rose
    0xFFDC2626, // Deep Red
    0xFFEA580C, // Deep Orange
    0xFFD97706, // Deep Amber
    0xFF65A30D, // Deep Lime
    0xFF16A34A, // Deep Green
    0xFF059669, // Deep Emerald
    0xFF0D9488, // Deep Teal
    0xFF0891B2, // Deep Cyan
    0xFF0284C7, // Deep Sky
    // Neutrals
    0xFF64748B, // Slate
    0xFF475569, // Steel
    0xFF52525B, // Graphite
    0xFF57534E, // Stone
    0xFF78716C, // Bark
    0xFF1E293B, // Midnight
    0xFF27272A, // Charcoal
  ];

  /// Two-stop gradients (top-left -> bottom-right), as (start, end) pairs.
  static const List<(int, int)> gradients = <(int, int)>[
    (0xFF1E3A8A, 0xFF3B82F6), // Midnight
    (0xFF6366F1, 0xFFA855F7), // Twilight
    (0xFF8B5CF6, 0xFFEC4899), // Orchid
    (0xFFF43F5E, 0xFFF97316), // Sunset
    (0xFFEF4444, 0xFFF59E0B), // Ember
    (0xFF10B981, 0xFF84CC16), // Meadow
    (0xFF14B8A6, 0xFF0EA5E9), // Lagoon
    (0xFF0EA5E9, 0xFF6366F1), // Deep sea
    (0xFFDB2777, 0xFF7C3AED), // Berry
    (0xFF0D9488, 0xFF15803D), // Forest
    (0xFFF59E0B, 0xFFDC2626), // Marigold
    (0xFF334155, 0xFF64748B), // Slate steel
    (0xFF27272A, 0xFF52525B), // Graphite
  ];

  /// Human-readable names, index-aligned with [gradients].
  static const List<String> gradientNames = <String>[
    'Midnight',
    'Twilight',
    'Orchid',
    'Sunset',
    'Ember',
    'Meadow',
    'Lagoon',
    'Deep sea',
    'Berry',
    'Forest',
    'Marigold',
    'Slate steel',
    'Graphite',
  ];

  /// The two colour stops for a gradient index.
  static (Color, Color) gradientColors(int index) {
    final (a, b) = gradients[index];
    return (Color(a), Color(b));
  }

  /// The representative "base" colour used to derive [onCardColor]: the solid
  /// itself, or a gradient's mid-point.
  static Color baseColor({required int colorValue, required bool isGradient}) {
    if (!isGradient) return Color(colorValue);
    final (a, b) = gradientColors(colorValue);
    return Color.lerp(a, b, 0.5)!;
  }

  /// Auto-contrast text/glyph colour for a given card fill. Same brightness test
  /// `_SwatchCell` uses in `color_picker_bottom_sheet.dart`. Independent of the
  /// active theme, because the card fill is fixed by the user.
  static Color onCardColor({required int colorValue, required bool isGradient}) {
    final base = baseColor(colorValue: colorValue, isGradient: isGradient);
    return ThemeData.estimateBrightnessForColor(base) == Brightness.light
        ? const Color(0xFF14140F)
        : Colors.white;
  }

  /// Default fill for a brand-new card: cycles the solid palette by existing
  /// card count so a wallet stays scannable.
  static int defaultColorForIndex(int existingCount) =>
      solids[existingCount % solids.length];
}
