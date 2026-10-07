import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// The three tones a user-picked category colour is drawn in (tokens.md §6,
/// open decision 6, feedback round 1): the user's hue and chroma are kept, only
/// the HCT tone moves so every colour reads on every surface.
@immutable
class CategoryTones {
  /// Glyph / text: T40 light, T80 dark.
  final Color fg;

  /// Tile fill: T92 light (chroma <= 20), T28 dark (chroma <= 16).
  final Color container;

  /// Chart mark: T52 light, T76 dark.
  final Color viz;

  const CategoryTones(this.fg, this.container, this.viz);
}

final Map<int, CategoryTones> _cache = {};

/// Re-tones [raw] for [brightness]. Cached per (colour, brightness): HCT is a
/// few hundred flops, and category tiles sit in scrolling lists.
CategoryTones categoryTonesFor(Color raw, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final key = raw.toARGB32() ^ (dark ? 0x40000000 : 0);
  return _cache.putIfAbsent(key, () {
    final h = Hct.fromInt(raw.toARGB32());
    Color tone(double t, [double? maxChroma]) => Color(Hct.from(
          h.hue,
          maxChroma == null ? h.chroma : (h.chroma < maxChroma ? h.chroma : maxChroma),
          t,
        ).toInt());
    return dark
        ? CategoryTones(tone(80), tone(28, 16), tone(76))
        : CategoryTones(tone(40), tone(92, 20), tone(52));
  });
}

CategoryTones categoryTones(BuildContext context, Color raw) =>
    categoryTonesFor(raw, Theme.of(context).brightness);

/// A user category colour as a glyph / text colour for the active theme
/// (T40 light, T80 dark). Must be called before rendering any category colour.
Color harmonizeCategory(BuildContext context, Color rawColor) =>
    categoryTones(context, rawColor).fg;

/// A user category colour as a chart mark (T52 light, T76 dark).
Color categoryVizColor(BuildContext context, Color rawColor) =>
    categoryTones(context, rawColor).viz;
