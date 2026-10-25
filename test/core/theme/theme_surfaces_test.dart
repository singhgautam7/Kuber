// theme-surfaces-v1: one background rule for every family. Values are the
// tables in specs/design/.../theme-surfaces-v1/theme-surfaces.md (§4 to §6),
// computed by the design's reference (_kit/surfaces.js).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/theme_families.dart';
import 'package:kuber/features/settings/providers/theme_options_provider.dart';

String hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// Rows of theme-surfaces.md §2: (dark, expressive, pureBlack).
const rows = [
  (false, true, false),
  (false, false, false),
  (true, true, false),
  (true, true, true),
  (true, false, false),
  (true, false, true),
];

ColorScheme scheme(ThemeVariant v, int row) {
  final (dark, expr, black) = rows[row];
  return kuberPalette(v, dark ? Brightness.dark : Brightness.light, expressive: expr, pureBlack: black).scheme;
}

/// §6 page / card for all 16 themes.
const pageCard = <ThemeVariant, List<String>>{
  ThemeVariant.signature: ['#F1F7FF/#E3EDFF', '#FFFFFF/#F3F3F3', '#0A1326/#152037', '#000000/#152037', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.mull: ['#F4FCFD/#E6F3F6', '#FFFFFF/#F3F3F3', '#11191B/#1B2527', '#000000/#1B2527', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.vellum: ['#FEF9F2/#F7EFE3', '#FFFFFF/#F3F3F3', '#1B160F/#272219', '#000000/#272219', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.foxglove: ['#FEF8FD/#F6EDF5', '#FFFFFF/#F3F3F3', '#1B151A/#272026', '#000000/#272026', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.slate: ['#F8FBFB/#ECF1F2', '#FFFFFF/#F3F3F3', '#151818/#202424', '#000000/#202424', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.clay: ['#FFF9ED/#FDEEDA', '#FFFFFF/#F3F3F3', '#1B1610/#28221A', '#000000/#28221A', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.perch: ['#F7FAFF/#EBF0FA', '#FFFFFF/#F3F3F3', '#14171D/#1F232A', '#000000/#1F232A', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.ember: ['#FFF8F3/#FBEDE4', '#FFFFFF/#F3F3F3', '#1D1510/#2A211A', '#000000/#2A211A', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.fern: ['#F5FCF8/#E7F4EC', '#FFFFFF/#F3F3F3', '#121915/#1C2520', '#000000/#1C2520', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.tide: ['#F4FCFB/#E6F3F2', '#FFFFFF/#F3F3F3', '#111918/#1B2524', '#000000/#1B2524', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.meadow: ['#F7FCF6/#EAF3EA', '#FFFFFF/#F3F3F3', '#131913/#1E251E', '#000000/#1E251E', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.blush: ['#FFF8FA/#F9ECF0', '#FFFFFF/#F3F3F3', '#1C1517/#292023', '#000000/#292023', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.iris: ['#FAF9FF/#F0EFF9', '#FFFFFF/#F3F3F3', '#17161C/#232229', '#000000/#232229', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.coral: ['#FFF8F6/#FBECEA', '#FFFFFF/#F3F3F3', '#1D1513/#2A201E', '#000000/#2A201E', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.citron: ['#FAFBF4/#F0F2E5', '#FFFFFF/#F3F3F3', '#171810/#23241B', '#000000/#23241B', '#171717/#232323', '#000000/#232323'],
  ThemeVariant.neon: ['#F7FBF8/#EBF2EC', '#FFFFFF/#F3F3F3', '#141815/#1F2420', '#000000/#1F2420', '#171717/#232323', '#000000/#232323'],
};

/// §5 full role tables for the three showcase themes.
const showcase = <ThemeVariant, Map<String, List<String>>>{
  ThemeVariant.signature: {
    'surface': ['#F1F7FF', '#FFFFFF', '#0A1326', '#000000', '#171717', '#000000'],
    'surfaceContainerLowest': ['#FFFFFF', '#FFFFFF', '#060B1B', '#000000', '#0F0F0F', '#000000'],
    'surfaceContainerLow': ['#EAF2FF', '#F9F9F9', '#101A2F', '#101A2F', '#1D1D1D', '#1D1D1D'],
    'surfaceContainer': ['#E3EDFF', '#F3F3F3', '#152037', '#152037', '#232323', '#232323'],
    'surfaceContainerHigh': ['#DBE6FF', '#E9E9E9', '#1F2B44', '#1F2B44', '#2E2E2E', '#2E2E2E'],
    'surfaceContainerHighest': ['#D0DDF8', '#E1E1E1', '#29354F', '#29354F', '#353535', '#353535'],
    'outlineVariant': ['#C4D3F1', '#D9D9D9', '#333F5A', '#333F5A', '#3D3D3D', '#3D3D3D'],
    'outline': ['#6C7A99', '#808080', '#808CA5', '#808CA5', '#808080', '#808080'],
    'onSurface': ['#111A2D', '#161616', '#EAEFF7', '#EAEFF7', '#F2F2F2', '#F2F2F2'],
    'onSurfaceVariant': ['#485572', '#5D5D5D', '#B4BED2', '#B4BED2', '#ABABAB', '#ABABAB'],
    'primary': ['#0058BE', '#0058BE', '#ADC6FF', '#ADC6FF', '#ADC6FF', '#ADC6FF'],
    'onPrimary': ['#FFFFFF', '#FFFFFF', '#002E6A', '#002E6A', '#002E6A', '#002E6A'],
    'secondaryContainer': ['#BBD1FF', '#BBD1FF', '#283B67', '#283B67', '#283B67', '#283B67'],
    'onSecondaryContainer': ['#003D88', '#003D88', '#D8E2FF', '#D8E2FF', '#D8E2FF', '#D8E2FF'],
  },
  ThemeVariant.ember: {
    'surface': ['#FFF8F3', '#FFFFFF', '#1D1510', '#000000', '#171717', '#000000'],
    'surfaceContainerLowest': ['#FFFFFF', '#FFFFFF', '#140E0A', '#000000', '#0F0F0F', '#000000'],
    'surfaceContainerLow': ['#FDF3EC', '#F9F9F9', '#241B15', '#241B15', '#1D1D1D', '#1D1D1D'],
    'surfaceContainer': ['#FBEDE4', '#F3F3F3', '#2A211A', '#2A211A', '#232323', '#232323'],
    'surfaceContainerHigh': ['#F5E4DA', '#E9E9E9', '#372B24', '#372B24', '#2E2E2E', '#2E2E2E'],
    'surfaceContainerHighest': ['#EDDBD0', '#E1E1E1', '#3F332B', '#3F332B', '#353535', '#353535'],
    'outlineVariant': ['#E5D2C5', '#D9D9D9', '#463A32', '#463A32', '#3D3D3D', '#3D3D3D'],
    'outline': ['#948277', '#808080', '#887E77', '#887E77', '#808080', '#808080'],
    'onSurface': ['#20130A', '#161616', '#F6F1EE', '#F6F1EE', '#F2F2F2', '#F2F2F2'],
    'onSurfaceVariant': ['#705F55', '#5D5D5D', '#ADA29B', '#ADA29B', '#ABABAB', '#ABABAB'],
    'primary': ['#A45936', '#A45936', '#DB997C', '#DB997C', '#DB997C', '#DB997C'],
    'onPrimary': ['#FFFFFF', '#FFFFFF', '#0E0805', '#0E0805', '#0E0805', '#0E0805'],
    'secondaryContainer': ['#FDDDCF', '#FDDDCF', '#3A2217', '#3A2217', '#3A2217', '#3A2217'],
    'onSecondaryContainer': ['#6F2A00', '#6F2A00', '#F7D6C8', '#F7D6C8', '#F7D6C8', '#F7D6C8'],
  },
  ThemeVariant.slate: {
    'surface': ['#F8FBFB', '#FFFFFF', '#151818', '#000000', '#171717', '#000000'],
    'surfaceContainerLowest': ['#FFFFFF', '#FFFFFF', '#0E1010', '#000000', '#0F0F0F', '#000000'],
    'surfaceContainerLow': ['#F2F6F7', '#F9F9F9', '#1B1E1E', '#1B1E1E', '#1D1D1D', '#1D1D1D'],
    'surfaceContainer': ['#ECF1F2', '#F3F3F3', '#202424', '#202424', '#232323', '#232323'],
    'surfaceContainerHigh': ['#E3E9EB', '#E9E9E9', '#2A2F30', '#2A2F30', '#2E2E2E', '#2E2E2E'],
    'surfaceContainerHighest': ['#DAE0E2', '#E1E1E1', '#323738', '#323738', '#353535', '#353535'],
    'outlineVariant': ['#D0D7D9', '#D9D9D9', '#393E3F', '#393E3F', '#3D3D3D', '#3D3D3D'],
    'outline': ['#818789', '#808080', '#7D8182', '#7D8182', '#808080', '#808080'],
    'onSurface': ['#121718', '#161616', '#F0F2F2', '#F0F2F2', '#F2F2F2', '#F2F2F2'],
    'onSurfaceVariant': ['#5E6466', '#5D5D5D', '#A1A5A6', '#A1A5A6', '#ABABAB', '#ABABAB'],
    'primary': ['#464F51', '#464F51', '#A4ACAF', '#A4ACAF', '#A4ACAF', '#A4ACAF'],
    'onPrimary': ['#FFFFFF', '#FFFFFF', '#070A0A', '#070A0A', '#070A0A', '#070A0A'],
    'secondaryContainer': ['#E0E6E7', '#E0E6E7', '#26292A', '#26292A', '#26292A', '#26292A'],
    'onSecondaryContainer': ['#3B4446', '#3B4446', '#DBDFE0', '#DBDFE0', '#DBDFE0', '#DBDFE0'],
  },
};

Color role(ColorScheme s, String name) => switch (name) {
      'surface' => s.surface,
      'surfaceContainerLowest' => s.surfaceContainerLowest,
      'surfaceContainerLow' => s.surfaceContainerLow,
      'surfaceContainer' => s.surfaceContainer,
      'surfaceContainerHigh' => s.surfaceContainerHigh,
      'surfaceContainerHighest' => s.surfaceContainerHighest,
      'outlineVariant' => s.outlineVariant,
      'outline' => s.outline,
      'onSurface' => s.onSurface,
      'onSurfaceVariant' => s.onSurfaceVariant,
      'primary' => s.primary,
      'onPrimary' => s.onPrimary,
      'secondaryContainer' => s.secondaryContainer,
      'onSecondaryContainer' => s.onSecondaryContainer,
      _ => throw ArgumentError(name),
    };

void main() {
  test('all 16 themes x 6 rows: page and card match the design (§6)', () {
    expect(pageCard.keys.toSet(), kSelectableVariants.toSet());
    final bad = <String>[];
    for (final e in pageCard.entries) {
      for (var r = 0; r < 6; r++) {
        final s = scheme(e.key, r);
        final got = '${hex(s.surface)}/${hex(s.surfaceContainer)}';
        if (got != e.value[r]) bad.add('${e.key.name} row ${r + 1}: $got, want ${e.value[r]}');
      }
    }
    expect(bad, isEmpty);
  });

  test('Signature, Ember, Slate: every listed role in every row (§5)', () {
    final bad = <String>[];
    for (final t in showcase.entries) {
      for (final rolePair in t.value.entries) {
        for (var r = 0; r < 6; r++) {
          final got = hex(role(scheme(t.key, r), rolePair.key));
          if (got != rolePair.value[r]) bad.add('${t.key.name} ${rolePair.key} row ${r + 1}: $got, want ${rolePair.value[r]}');
        }
      }
    }
    expect(bad, isEmpty);
  });

  test('neutral ramps (§4)', () {
    String all(NeutralRamp n) => [
          n.surface, n.lowest, n.low, n.container, n.high, n.highest, n.outlineVariant, n.outline,
          n.onSurfaceVariant, n.onSurface, n.inverseSurface, n.inverseOnSurface,
        ].map(hex).join(' ');
    expect(all(kNeutralLight),
        '#FFFFFF #FFFFFF #F9F9F9 #F3F3F3 #E9E9E9 #E1E1E1 #D9D9D9 #808080 #5D5D5D #161616 #1B1B1B #F5F5F5');
    expect(all(kNeutralDark),
        '#171717 #0F0F0F #1D1D1D #232323 #2E2E2E #353535 #3D3D3D #808080 #ABABAB #F2F2F2 #E8E8E8 #161616');
  });

  test('pure black: only the page goes black; light ignores it', () {
    for (final v in kSelectableVariants) {
      final on = kuberPalette(v, Brightness.dark, pureBlack: true).scheme;
      final off = kuberPalette(v, Brightness.dark).scheme;
      expect((on.surface, on.surfaceDim, on.surfaceContainerLowest),
          (const Color(0xFF000000), const Color(0xFF000000), const Color(0xFF000000)));
      expect(on.surfaceContainer, off.surfaceContainer, reason: '${v.name} cards keep their colour');
      expect(on.surfaceContainerLow, off.surfaceContainerLow);
      expect(on.primary, off.primary);
      expect(kuberPalette(v, Brightness.light, pureBlack: true).scheme,
          kuberPalette(v, Brightness.light).scheme);
    }
  });

  test('accent, money and ramp never change with either switch', () {
    for (final v in kSelectableVariants) {
      for (final b in Brightness.values) {
        final base = kuberPalette(v, b);
        for (final (e, p) in [(false, false), (true, true), (false, true)]) {
          final x = kuberPalette(v, b, expressive: e, pureBlack: p);
          expect(x.money, base.money);
          expect(x.ramp, base.ramp);
          final s = x.scheme, t = base.scheme;
          expect([s.primary, s.onPrimary, s.primaryContainer, s.secondary, s.secondaryContainer, s.tertiary, s.error, s.errorContainer],
              [t.primary, t.onPrimary, t.primaryContainer, t.secondary, t.secondaryContainer, t.tertiary, t.error, t.errorContainer],
              reason: '${v.name} $b');
        }
      }
    }
  });

  test('the wallpaper colour goes through the same rule', () {
    const seed = Color(0xFF8E24AA);
    final light = kuberPalette(ThemeVariant.signature, Brightness.light, seed: seed, expressive: false).scheme;
    expect(hex(light.surface), '#FFFFFF');
    final dark = kuberPalette(ThemeVariant.signature, Brightness.dark, seed: seed, pureBlack: true).scheme;
    expect(hex(dark.surface), '#000000');
    expect(dark.surfaceContainer, kuberPalette(ThemeVariant.signature, Brightness.dark, seed: seed).scheme.surfaceContainer);
  });

  test('contrast guard: seven light primaries step down (§3c)', () {
    const want = {
      'vellum': .54, 'ember': .545, 'fern': .525, 'iris': .545, 'coral': .545, 'citron': .53, 'neon': .52,
    };
    for (final v in kSelectableVariants.where((v) => v != ThemeVariant.signature)) {
      final f = MullFamily.of(v);
      expect(f.guardedLightness, want[f.id] ?? f.primaryLightness, reason: f.id);
    }
    expect(hex(kuberPalette(ThemeVariant.neon, Brightness.light).scheme.primary), '#1D7D34');
    expect(hex(kuberPalette(ThemeVariant.ember, Brightness.dark).scheme.primary), '#DB997C', reason: 'dark unchanged');
  });

  test('WCAG AA in every theme and row (1632 checks, §8)', () {
    final bad = <String>[];
    var n = 0;
    for (final v in kSelectableVariants) {
      for (var r = 0; r < 6; r++) {
        final (dark, expr, black) = rows[r];
        final p = kuberPalette(v, dark ? Brightness.dark : Brightness.light, expressive: expr, pureBlack: black);
        final s = p.scheme;
        final checks = <(String, Color, Color, double)>[
          for (final (name, bg) in [
            ('surface', s.surface),
            ('low', s.surfaceContainerLow),
            ('container', s.surfaceContainer),
            ('high', s.surfaceContainerHigh),
          ]) ...[
            ('onSurface/$name', s.onSurface, bg, 4.5),
            ('onSurfaceVariant/$name', s.onSurfaceVariant, bg, 4.5),
          ],
          ('primary/surface', s.primary, s.surface, 4.5),
          ('primary/container', s.primary, s.surfaceContainer, 4.5),
          ('onPrimary/primary', s.onPrimary, s.primary, 4.5),
          ('onSecondaryContainer', s.onSecondaryContainer, s.secondaryContainer, 4.5),
          ('onPrimaryContainer', s.onPrimaryContainer, s.primaryContainer, 4.5),
          ('income/container', p.money[0], s.surfaceContainer, 4.5),
          ('expense/container', p.money[4], s.surfaceContainer, 4.5),
          ('outline/surface', s.outline, s.surface, 3),
        ];
        for (final (name, fg, bg, min) in checks) {
          n++;
          final c = contrastRatio(fg, bg);
          if (c < min) bad.add('${v.name} row ${r + 1} $name ${c.toStringAsFixed(2)}');
        }
      }
    }
    expect(n, 16 * 6 * 16);
    expect(bad, isEmpty);
  });

  group('migration (open-decisions.md 1)', () {
    test('new installs: Expressive on, Pure black off', () {
      expect(migratedThemeSurfaces(existingUser: false, variant: ThemeVariant.signature, dynamicColor: false, trueBlack: true),
          (expressive: true, pureBlack: false));
    });
    test('existing Kuber Signature users keep a white and black app', () {
      expect(migratedThemeSurfaces(existingUser: true, variant: ThemeVariant.signature, dynamicColor: false, trueBlack: false),
          (expressive: false, pureBlack: true));
    });
    test('Mull family with true black on keeps it; off stays off', () {
      expect(migratedThemeSurfaces(existingUser: true, variant: ThemeVariant.slate, dynamicColor: false, trueBlack: true),
          (expressive: true, pureBlack: true));
      expect(migratedThemeSurfaces(existingUser: true, variant: ThemeVariant.perch, dynamicColor: false, trueBlack: false),
          (expressive: true, pureBlack: false));
    });
    test('a stored true black that had no effect on its family stays off', () {
      expect(migratedThemeSurfaces(existingUser: true, variant: ThemeVariant.ember, dynamicColor: false, trueBlack: true),
          (expressive: true, pureBlack: false));
    });
    test('wallpaper colour honours its true black switch', () {
      expect(migratedThemeSurfaces(existingUser: true, variant: ThemeVariant.signature, dynamicColor: true, trueBlack: true),
          (expressive: true, pureBlack: true));
      expect(migratedThemeSurfaces(existingUser: true, variant: ThemeVariant.ember, dynamicColor: true, trueBlack: false),
          (expressive: true, pureBlack: false));
    });
    test('a retired Azure user (shown as Perch) keeps true black', () {
      expect(migratedThemeSurfaces(existingUser: true, variant: ThemeVariant.azure, dynamicColor: false, trueBlack: true),
          (expressive: true, pureBlack: true));
    });
  });
}
