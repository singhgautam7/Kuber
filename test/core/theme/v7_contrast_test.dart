// v7.0.0 contrast guard: the colour pairs used by the new and changed
// components (button groups, chips, nav indicator, icon buttons, Quick
// navigation rows, skeletons, Motion sheet) stay readable in every theme
// family, light / dark / Pure black, Expressive colours on and off.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/core/theme/theme_families.dart';

double _lum(Color c) {
  double ch(double v) => v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final x = _lum(a), y = _lum(b);
  return (max(x, y) + 0.05) / (min(x, y) + 0.05);
}

void main() {
  final schemes = <String, ColorScheme>{};
  for (final v in ThemeVariant.values) {
    for (final ex in [true, false]) {
      final tag = '${v.name}${ex ? '' : '/neutral'}';
      schemes['$tag light'] = AppTheme.light(const Locale('en'), v, null, ex).colorScheme;
      schemes['$tag dark'] = AppTheme.dark(const Locale('en'), v, false, null, ex).colorScheme;
      schemes['$tag black'] = AppTheme.dark(const Locale('en'), v, true, null, ex).colorScheme;
    }
  }

  // (name, fg, bg, minimum). Text 4.5; disabled-but-readable labels and the
  // selected pill against its neighbours 3.0; filled shapes that must stand
  // out from the page 1.25 (skeleton 1.15). Chips and the nav indicator keep
  // secondaryContainer (unchanged since v4; they also have a check / filled
  // icon / outline), so that pair is not checked here.
  List<(String, Color, Color, double)> pairs(ColorScheme cs) => [
        ('selected label', cs.onSecondaryContainer, cs.secondaryContainer, 4.5),
        ('emphasis label', cs.onPrimary, cs.primary, 4.5),
        ('group label', cs.onSurface, cs.surfaceContainerHighest, 4.5),
        ('locked group label', cs.onSurfaceVariant, cs.surfaceContainerHighest, 3.0),
        ('chip label', cs.onSurfaceVariant, cs.surface, 4.5),
        ('icon button', cs.onSurface, cs.surfaceContainerHigh, 4.5),
        ('icon button pressed', cs.onSurface, cs.surfaceContainerHighest, 4.5),
        ('nav label', cs.onSurfaceVariant, cs.surface, 4.5),
        ('quick nav row', cs.onSurface, cs.surfaceContainerLow, 4.5),
        ('quick nav current', cs.onSecondaryContainer, cs.secondaryContainer, 4.5),
        ('show remaining', cs.primary, cs.surfaceContainerLow, 4.5),
        ('fab', cs.onPrimaryContainer, cs.primaryContainer, 4.5),
        ('sheet text', cs.onSurfaceVariant, cs.surfaceContainerLow, 4.5),
        ('group pill vs page', cs.surfaceContainerHighest, cs.surface, 1.25),
        ('emphasis vs page', cs.primary, cs.surface, 3.0),
        ('group selected vs unselected', cs.primary, cs.surfaceContainerHighest, 3.0),
        ('skeleton vs page', cs.surfaceContainerHigh, cs.surface, 1.15),
        ('loader vs page', cs.primary, cs.surface, 3.0),
      ];

  test('v7 component colours are readable in every theme', () {
    final fails = <String>[];
    schemes.forEach((name, cs) {
      for (final (what, fg, bg, minimum) in pairs(cs)) {
        final r = contrast(fg, bg);
        if (r < minimum) fails.add('$name · $what: ${r.toStringAsFixed(2)} < $minimum');
      }
    });
    // ignore: avoid_print
    for (final f in fails) print(f);
    expect(fails, isEmpty);
  });
}
