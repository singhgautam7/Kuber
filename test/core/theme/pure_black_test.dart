// advanced-history-v1 pure-black.md: ramp + container tints per family, and
// WCAG for every selectable theme with Pure black on.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/theme_families.dart';

/// "All 16 families (v2)": Low, Container, High, Highest, Bright,
/// outlineVariant, secondaryContainer, primaryContainer.
const _table = <String, String>{
  'signature': '090A0D 101215 17191E 1F2228 272A30 32353D 1C2C51 24418D',
  'mull': '080B0C 0E1314 141B1C 1B2325 242C2E 2D373A 0C333C 002C36',
  'vellum': '0B0A08 13110E 1C1914 25211B 2D2A24 39352D 3C2A13 362207',
  'foxglove': '0C090B 141013 1C181C 252024 2E282D 3A3339 39263A 331D34',
  'slate': '080B0C 0E1314 141B1C 1B2325 242C2E 2D373A 0C333C 002C36',
  'clay': '0C0A08 14110E 1C1914 25211B 2E2924 3A342E 41261A 3A1E11',
  'perch': '090A0D 101215 17191E 1F2228 272A30 32353D 232D45 1A263F',
  'ember': '0C0908 14110E 1D1815 26201C 2F2925 3B342F 41261A 3A1E11',
  'fern': '080B09 0F1310 161B18 1D2320 252C28 2F3833 163527 0A2E1F',
  'tide': '080B0B 0E1312 141B1A 1B2423 242C2B 2D3837 0B3532 002E2B',
  'meadow': '090B09 0F130F 171B17 1E231E 272C26 313731 1F3420 152D17',
  'blush': '0C090A 151011 1E1819 271F21 2F282A 3C3235 40242D 3A1B26',
  'iris': '0A0A0C 111115 19191E 212127 2A2930 35343C 2D2A43 26223D',
  'coral': '0D0909 15100F 1E1817 27201E 302827 3C3331 422520 3B1C17',
  'citron': '0A0A08 11120E 191A15 21221C 2A2B24 35362E 2E3014 272908',
  'neon': '090B09 0F1310 171B17 1E231E 262C27 313731 1E3420 142D18',
};

/// Signature / Ember / Fern role tables: onPrimaryContainer, tertiaryContainer,
/// errorContainer, income/expense/warning containers.
const _roles = <String, String>{
  'signature': 'D8E2FF 482304 491513 132D15 431614 3A2305',
  'ember': 'F7D6C8 3A1E11 491513 132D15 431614 3A2305',
  'fern': 'C9E6D7 0A2E1F 491513 132D15 431614 3A2305',
};

KuberPalette _p(String id) {
  // Meadow / Coral are retired variants (kuberPalette redirects them), so
  // build them straight from the family.
  final v = ThemeVariant.values.byName(id);
  if (kRetiredVariants.contains(v)) {
    final f = MullFamily.of(v);
    return applySurfaceRule(f.palette(dark: true),
        dark: true,
        expressive: true,
        pureBlack: true,
        neutralHue: f.neutralHue,
        primaryHue: f.primaryHue);
  }
  return kuberPalette(v, Brightness.dark, pureBlack: true);
}

int _ch(Color c, int i) => [(c.r * 255).round(), (c.g * 255).round(), (c.b * 255).round()][i];
Color _hex(String h) => Color(0xFF000000 | int.parse(h, radix: 16));

int _delta(Color a, Color b) {
  var m = 0;
  for (var i = 0; i < 3; i++) {
    final d = (_ch(a, i) - _ch(b, i)).abs();
    if (d > m) m = d;
  }
  return m;
}

void main() {
  test('all 16 families match the design table within 2 per channel', () {
    final bad = <String>[];
    var worst = 0;
    for (final e in _table.entries) {
      final s = _p(e.key).scheme;
      final got = [
        s.surfaceContainerLow, s.surfaceContainer, s.surfaceContainerHigh,
        s.surfaceContainerHighest, s.surfaceBright, s.outlineVariant,
        s.secondaryContainer, s.primaryContainer, //
      ];
      final want = e.value.split(' ').map(_hex).toList();
      for (var i = 0; i < got.length; i++) {
        final d = _delta(got[i], want[i]);
        if (d > worst) worst = d;
        if (d > 2) bad.add('${e.key}[$i] got ${got[i]} want ${want[i]}');
      }
      expect(s.surface, const Color(0xFF000000));
      expect(s.surfaceContainerLowest, const Color(0xFF000000));
    }
    // ignore: avoid_print
    print('max channel delta: $worst');
    expect(bad, isEmpty);
  });

  test('Signature / Ember / Fern role tables', () {
    final bad = <String>[];
    for (final e in _roles.entries) {
      final p = _p(e.key);
      final s = p.scheme;
      final got = [s.onPrimaryContainer, s.tertiaryContainer, s.errorContainer, p.money[2], p.money[6], p.money[10]];
      final want = e.value.split(' ').map(_hex).toList();
      for (var i = 0; i < got.length; i++) {
        if (_delta(got[i], want[i]) > 2) bad.add('${e.key}[$i] got ${got[i]} want ${want[i]}');
      }
    }
    expect(bad, isEmpty);
  });

  test('Expressive off: ramp is grey, containers keep their tint', () {
    final s = kuberPalette(ThemeVariant.ember, Brightness.dark, expressive: false, pureBlack: true).scheme;
    for (final c in [s.surfaceContainerLow, s.surfaceContainer, s.surfaceBright, s.outlineVariant]) {
      expect(_ch(c, 0) == _ch(c, 1) && _ch(c, 1) == _ch(c, 2), isTrue);
    }
    expect(s.secondaryContainer, _hex('41261A'));
  });

  test('Light ignores Pure black', () {
    expect(kuberPalette(ThemeVariant.ember, Brightness.light, pureBlack: true).scheme,
        kuberPalette(ThemeVariant.ember, Brightness.light).scheme);
  });

  test('WCAG AA for every selectable theme with Pure black on', () {
    final minRatio = <String, double>{};
    final bad = <String>[];
    for (final v in kSelectableVariants) {
      for (final expressive in [true, false]) {
        final p = kuberPalette(v, Brightness.dark, expressive: expressive, pureBlack: true);
        final s = p.scheme, m = p.money;
        final checks = <(String, Color, Color, double)>[
          for (final (n, bg) in [
            ('surface', s.surface),
            ('low', s.surfaceContainerLow),
            ('container', s.surfaceContainer),
            ('high', s.surfaceContainerHigh),
            ('highest', s.surfaceContainerHighest),
          ]) ...[
            ('onSurface/$n', s.onSurface, bg, 4.5),
            ('onSurfaceVariant/$n', s.onSurfaceVariant, bg, 4.5),
          ],
          ('primary/container', s.primary, s.surfaceContainer, 4.5),
          ('onPrimary/primary', s.onPrimary, s.primary, 4.5),
          ('onPrimaryContainer', s.onPrimaryContainer, s.primaryContainer, 4.5),
          ('onSecondaryContainer', s.onSecondaryContainer, s.secondaryContainer, 4.5),
          ('onTertiaryContainer', s.onTertiaryContainer, s.tertiaryContainer, 4.5),
          ('onErrorContainer', s.onErrorContainer, s.errorContainer, 4.5),
          ('onIncomeContainer', m[3], m[2], 4.5),
          ('onExpenseContainer', m[7], m[6], 4.5),
          ('onWarningContainer', m[11], m[10], 4.5),
          ('income/container', m[0], s.surfaceContainer, 4.5),
          ('expense/container', m[4], s.surfaceContainer, 4.5),
          ('outline/surface', s.outline, s.surface, 3),
        ];
        for (final (n, fg, bg, min) in checks) {
          final c = contrastRatio(fg, bg);
          if (c < (minRatio[n] ?? 99)) minRatio[n] = c;
          if (c < min) bad.add('${v.name} expr=$expressive $n ${c.toStringAsFixed(2)}');
        }
      }
    }
    // ignore: avoid_print
    print(minRatio.entries.map((e) => '${e.key} ${e.value.toStringAsFixed(2)}').join('\n'));
    expect(bad, isEmpty);
  });
}
