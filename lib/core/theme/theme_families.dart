import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'oklch.dart';

/// Kuber's theme families: Kuber Signature (an M3 fidelity scheme seeded from
/// the app icon blue) plus Mull's sixteen OKLCh families. Order is the display order on
/// the Theme screen and the persisted index (`PrefsKeys.themeVariant`), so
/// append only.
enum ThemeVariant {
  signature,
  mull,
  vellum,
  foxglove,
  slate,
  clay,
  perch,
  ember,
  fern,
  azure,
  tide,
  meadow,
  blush,
  iris,
  coral,
  citron,
  neon,
}

/// Azure was dropped from the picker (too close to Perch, review round 3).
/// The enum value stays because the index is persisted; a stored Azure
/// resolves to Perch.
const Set<ThemeVariant> kRetiredVariants = {ThemeVariant.azure};

/// The families offered on the Theme screen, in display order.
List<ThemeVariant> get kSelectableVariants => [
      for (final v in ThemeVariant.values)
        if (!kRetiredVariants.contains(v)) v,
    ];

/// Maps a stored variant to one that is still offered.
ThemeVariant resolveVariant(ThemeVariant v) =>
    v == ThemeVariant.azure ? ThemeVariant.perch : v;

/// One family x brightness: the M3 scheme, Kuber money colours and the viz
/// ramp.
class KuberPalette {
  final ColorScheme scheme;

  /// income c/on/cont/onCont, expense x4, warning x4.
  final List<Color> money;

  /// 5 tonal steps of the accent, weakest to strongest on this surface.
  final List<Color> ramp;
  const KuberPalette(this.scheme, this.money, this.ramp);
}

/// Theme settings that shape the surfaces (theme-surfaces-v1). Both are
/// global, not per family.
///
/// [expressive]: background roles take a light tint of the theme; off = one
/// neutral grey ramp for every theme. [pureBlack]: in dark only, the page
/// (surface, surfaceDim, surfaceContainerLowest) becomes #000000; containers
/// keep their value.
KuberPalette kuberPalette(
  ThemeVariant variant,
  Brightness brightness, {
  bool expressive = true,
  bool pureBlack = false,
  Color? seed,
}) {
  final dark = brightness == Brightness.dark;
  final KuberPalette base;
  if (seed != null) {
    base = MullFamily.fromSeed(seed).palette(dark: dark);
  } else {
    variant = resolveVariant(variant);
    base = variant == ThemeVariant.signature
        ? _signature(dark)
        : MullFamily.of(variant).palette(dark: dark);
  }
  return applySurfaceRule(base, dark: dark, expressive: expressive, pureBlack: pureBlack);
}

/// The one background rule (theme-surfaces.md §3): build the family scheme,
/// then replace the surface family with the neutral ramp when not
/// expressive, then black out the page when dark and pure black. Accent,
/// money, chart and error roles never change.
KuberPalette applySurfaceRule(
  KuberPalette p, {
  required bool dark,
  required bool expressive,
  required bool pureBlack,
}) {
  var cs = p.scheme;
  if (!expressive) {
    final n = dark ? kNeutralDark : kNeutralLight;
    cs = cs.copyWith(
      surface: n.surface,
      surfaceContainerLowest: n.lowest,
      surfaceContainerLow: n.low,
      surfaceContainer: n.container,
      surfaceContainerHigh: n.high,
      surfaceContainerHighest: n.highest,
      outlineVariant: n.outlineVariant,
      outline: n.outline,
      onSurfaceVariant: n.onSurfaceVariant,
      onSurface: n.onSurface,
      inverseSurface: n.inverseSurface,
      onInverseSurface: n.inverseOnSurface,
      surfaceDim: dark ? n.surface : n.high,
      surfaceBright: dark ? n.high : n.surface,
    );
  }
  if (dark && pureBlack) {
    const black = Color(0xFF000000);
    cs = cs.copyWith(surface: black, surfaceDim: black, surfaceContainerLowest: black);
  }
  return KuberPalette(cs, p.money, p.ramp);
}

/// A neutral grey ramp (Expressive colours off): OKLCh chroma 0, shared by
/// every theme and the wallpaper colour (theme-surfaces.md §4).
class NeutralRamp {
  final Color surface, lowest, low, container, high, highest, outlineVariant, outline,
      onSurfaceVariant, onSurface, inverseSurface, inverseOnSurface;
  NeutralRamp._(List<double> l)
      : surface = _grey(l[0]),
        lowest = _grey(l[1]),
        low = _grey(l[2]),
        container = _grey(l[3]),
        high = _grey(l[4]),
        highest = _grey(l[5]),
        outlineVariant = _grey(l[6]),
        outline = _grey(l[7]),
        onSurfaceVariant = _grey(l[8]),
        onSurface = _grey(l[9]),
        inverseSurface = _grey(l[10]),
        inverseOnSurface = _grey(l[11]);
  static Color _grey(double l) => _q(Oklch(l, 0, 0));
}

final kNeutralLight = NeutralRamp._([1, 1, .982, .965, .935, .91, .885, .60, .48, .20, .22, .97]);
final kNeutralDark = NeutralRamp._([.205, .17, .23, .255, .30, .33, .36, .60, .74, .96, .93, .20]);

/// 8-bit colour (the values the design tables list).
Color _q(Oklch o) => Color(o.toColor().toARGB32());

/// Per-channel 8-bit mix, rounded like the design's reference (surfaces.js).
Color _mix(Color a, Color b, double t) {
  int c8(double v) => (v * 255).round();
  final ar = c8(a.r), ag = c8(a.g), ab = c8(a.b);
  final br = c8(b.r), bg = c8(b.g), bb = c8(b.b);
  return Color.fromARGB(255, (ar + (br - ar) * t).round(), (ag + (bg - ag) * t).round(),
      (ab + (bb - ab) * t).round());
}

/// WCAG contrast ratio.
double contrastRatio(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

// ── Kuber Signature v2: surfaces from the app icon ────────────────────────────
//
// The app icon: background #D8E2FF, strokes #003D88 / #2573E6, dark splash
// #001A42; OKLCh hue 265 (theme-surfaces.md §3b). Secondary, tertiary and error
// still come from the M3 fidelity scheme seeded with #3B82F6, money colours
// and the heat ramp from tokens/palettes.json, as before.

const _signatureSeed = Color(0xFF3B82F6);
const _sigHue = 265.0;
Color _sq(double l, double c) => _q(Oklch(l, c, _sigHue));

/// palettes.json `money`: income c/on/cont/onCont, expense x4, warning x4.
const _signatureMoneyLight = [
  Color(0xFF296B2A), Color(0xFFFFFFFF), Color(0xFFACF4A2), Color(0xFF0B5314), //
  Color(0xFFBA1A1A), Color(0xFFFFFFFF), Color(0xFFFFDAD6), Color(0xFF93000A),
  Color(0xFF825500), Color(0xFFFFFFFF), Color(0xFFFFDDB2), Color(0xFF624000),
];
const _signatureMoneyDark = [
  Color(0xFF91D888), Color(0xFF003908), Color(0xFF0B5314), Color(0xFFACF4A2), //
  Color(0xFFFFB4AB), Color(0xFF690005), Color(0xFF93000A), Color(0xFFFFDAD6),
  Color(0xFFFFB94E), Color(0xFF452B00), Color(0xFF624000), Color(0xFFFFDDB2),
];

/// palettes.json `heat`, weakest to strongest on each surface.
const _signatureHeatLight = [
  Color(0xFFEDF0FF), Color(0xFFC3D4FF), Color(0xFF81AAFF), //
  Color(0xFF2573E6), Color(0xFF004FAB),
];
const _signatureHeatDark = [
  Color(0xFF002E6A), Color(0xFF004395), Color(0xFF0566D9), //
  Color(0xFF699CFF), Color(0xFFADC6FF),
];

KuberPalette _signature(bool dark) {
  final seeded = ColorScheme.fromSeed(
    seedColor: _signatureSeed,
    brightness: dark ? Brightness.dark : Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  final ColorScheme scheme;
  if (!dark) {
    final surface = _sq(.975, .016), container = _sq(.945, .03), high = _sq(.925, .036),
        border = _sq(.865, .045);
    scheme = seeded.copyWith(
      primary: const Color(0xFF0058BE),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFF1F6CDF),
      onPrimaryContainer: const Color(0xFFFFFFFF),
      secondaryContainer: _sq(.86, .07),
      onSecondaryContainer: const Color(0xFF003D88),
      surface: surface,
      surfaceDim: high,
      surfaceBright: surface,
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: _mix(surface, container, .5),
      surfaceContainer: container,
      surfaceContainerHigh: high,
      surfaceContainerHighest: _mix(high, border, .5),
      outlineVariant: border,
      outline: _sq(.58, .05),
      onSurface: _sq(.22, .04),
      onSurfaceVariant: _sq(.45, .05),
      inverseSurface: _sq(.25, .04),
      onInverseSurface: _sq(.96, .012),
    );
  } else {
    final surface = _sq(.19, .042), container = _sq(.245, .048), high = _sq(.29, .05),
        border = _sq(.37, .05);
    scheme = seeded.copyWith(
      primary: const Color(0xFFADC6FF),
      onPrimary: const Color(0xFF002E6A),
      primaryContainer: const Color(0xFF4D8EFF),
      onPrimaryContainer: const Color(0xFF001A42),
      secondaryContainer: _sq(.36, .08),
      onSecondaryContainer: const Color(0xFFD8E2FF),
      surface: surface,
      surfaceDim: surface,
      surfaceBright: high,
      surfaceContainerLowest: _sq(.155, .035),
      surfaceContainerLow: _mix(surface, container, .5),
      surfaceContainer: container,
      surfaceContainerHigh: high,
      surfaceContainerHighest: _mix(high, border, .5),
      outlineVariant: border,
      outline: _sq(.64, .04),
      onSurface: _sq(.95, .012),
      onSurfaceVariant: _sq(.80, .03),
      inverseSurface: _sq(.92, .015),
      onInverseSurface: _sq(.22, .04),
    );
  }
  return KuberPalette(
    scheme,
    dark ? _signatureMoneyDark : _signatureMoneyLight,
    dark ? _signatureHeatDark : _signatureHeatLight,
  );
}

// ── Mull families ────────────────────────────────────────────────────────────

/// One accent family, from Mull `core/theme/palette.dart` (`ThemeFamily`),
/// with the theme-surfaces-v1 light ladder. [palette] maps the roles onto
/// Kuber's M3 scheme; the surface rule is applied on top by [kuberPalette].
@immutable
class MullFamily {
  const MullFamily({
    required this.id,
    required this.name,
    required this.blurb,
    required this.neutralHue,
    required this.neutralChroma,
    required this.primaryHue,
    required this.primaryLightness,
    required this.primaryChroma,
    required this.primaryContainerChroma,
    double? darkNeutralChroma,
  }) : darkNeutralChroma = darkNeutralChroma ?? neutralChroma;

  final String id;
  final String name;
  final String blurb;
  final double neutralHue;
  final double neutralChroma;
  final double primaryHue;
  final double primaryLightness;
  final double primaryChroma;
  final double primaryContainerChroma;
  final double darkNeutralChroma;

  static const mull = MullFamily(id: 'mull', name: 'Mull', blurb: 'default', neutralHue: 215, neutralChroma: 1, primaryHue: 215, primaryLightness: 0.52, primaryChroma: 0.11, primaryContainerChroma: 0.04);
  static const vellum = MullFamily(id: 'vellum', name: 'Vellum', blurb: 'warm', neutralHue: 80, neutralChroma: 1.3, primaryHue: 70, primaryLightness: 0.58, primaryChroma: 0.10, primaryContainerChroma: 0.04);
  static const foxglove = MullFamily(id: 'foxglove', name: 'Foxglove', blurb: 'soft', neutralHue: 330, neutralChroma: 1.05, primaryHue: 325, primaryLightness: 0.55, primaryChroma: 0.12, primaryContainerChroma: 0.04);
  static const slate = MullFamily(id: 'slate', name: 'Slate', blurb: 'mono', neutralHue: 215, neutralChroma: 0.4, primaryHue: 215, primaryLightness: 0.42, primaryChroma: 0.012, primaryContainerChroma: 0.006);
  static const clay = MullFamily(id: 'clay', name: 'Clay', blurb: 'greige', neutralHue: 75, neutralChroma: 2.2, primaryHue: 45, primaryLightness: 0.50, primaryChroma: 0.055, primaryContainerChroma: 0.02, darkNeutralChroma: 1.2);
  static const perch = MullFamily(id: 'perch', name: 'Perch', blurb: 'violet', neutralHue: 265, neutralChroma: 1, primaryHue: 265, primaryLightness: 0.52, primaryChroma: 0.11, primaryContainerChroma: 0.04);
  static const ember = MullFamily(id: 'ember', name: 'Ember', blurb: 'amber', neutralHue: 55, neutralChroma: 1.35, primaryHue: 45, primaryLightness: 0.58, primaryChroma: 0.11, primaryContainerChroma: 0.04);
  static const fern = MullFamily(id: 'fern', name: 'Fern', blurb: 'cool green', neutralHue: 160, neutralChroma: 1.15, primaryHue: 162, primaryLightness: 0.54, primaryChroma: 0.10, primaryContainerChroma: 0.04);
  static const azure = MullFamily(id: 'azure', name: 'Azure', blurb: 'blue', neutralHue: 259, neutralChroma: 1, primaryHue: 259, primaryLightness: 0.52, primaryChroma: 0.12, primaryContainerChroma: 0.04);
  static const tide = MullFamily(id: 'tide', name: 'Tide', blurb: 'teal', neutralHue: 189, neutralChroma: 1, primaryHue: 189, primaryLightness: 0.50, primaryChroma: 0.09, primaryContainerChroma: 0.04);
  static const meadow = MullFamily(id: 'meadow', name: 'Meadow', blurb: 'green', neutralHue: 145, neutralChroma: 1.1, primaryHue: 145, primaryLightness: 0.52, primaryChroma: 0.10, primaryContainerChroma: 0.04);
  static const blush = MullFamily(id: 'blush', name: 'Blush', blurb: 'rose', neutralHue: 359, neutralChroma: 1.05, primaryHue: 359, primaryLightness: 0.55, primaryChroma: 0.12, primaryContainerChroma: 0.04);
  static const iris = MullFamily(id: 'iris', name: 'Iris', blurb: 'purple', neutralHue: 290, neutralChroma: 1, primaryHue: 290, primaryLightness: 0.55, primaryChroma: 0.12, primaryContainerChroma: 0.04);
  static const coral = MullFamily(id: 'coral', name: 'Coral', blurb: 'red orange', neutralHue: 30, neutralChroma: 1.2, primaryHue: 30, primaryLightness: 0.56, primaryChroma: 0.12, primaryContainerChroma: 0.04);
  static const citron = MullFamily(id: 'citron', name: 'Citron', blurb: 'yellow green', neutralHue: 113, neutralChroma: 1.2, primaryHue: 113, primaryLightness: 0.55, primaryChroma: 0.10, primaryContainerChroma: 0.04);
  static const neon = MullFamily(id: 'neon', name: 'Neon', blurb: 'vivid green', neutralHue: 147, neutralChroma: 0.8, primaryHue: 147, primaryLightness: 0.60, primaryChroma: 0.14, primaryContainerChroma: 0.05);


  static MullFamily of(ThemeVariant v) => switch (v) {
        ThemeVariant.signature || ThemeVariant.mull => mull,
        ThemeVariant.vellum => vellum,
        ThemeVariant.foxglove => foxglove,
        ThemeVariant.slate => slate,
        ThemeVariant.clay => clay,
        ThemeVariant.perch => perch,
        ThemeVariant.ember => ember,
        ThemeVariant.fern => fern,
        ThemeVariant.azure => azure,
        ThemeVariant.tide => tide,
        ThemeVariant.meadow => meadow,
        ThemeVariant.blush => blush,
        ThemeVariant.iris => iris,
        ThemeVariant.coral => coral,
        ThemeVariant.citron => citron,
        ThemeVariant.neon => neon,
      };

  /// Android hands over one wallpaper seed; the rest is derived exactly as a
  /// bundled family's is (Mull `ThemeFamily.fromSeed`).
  factory MullFamily.fromSeed(Color seed) {
    final hue = Oklch.hueOf(seed);
    return MullFamily(
      id: 'dynamic',
      name: 'Dynamic',
      blurb: 'wallpaper',
      neutralHue: hue,
      neutralChroma: 1,
      primaryHue: hue,
      primaryLightness: 0.52,
      primaryChroma: 0.11,
      primaryContainerChroma: 0.04,
    );
  }

  Color _n(double l, double c) => _q(Oklch(l, c * neutralChroma, neutralHue));
  Color _nd(double l, double c) => _q(Oklch(l, c * darkNeutralChroma, neutralHue));
  Oklch _p(double l, double c) => Oklch(l, c, primaryHue);

  /// Contrast guard (theme-surfaces.md §3c): the light primary steps down in
  /// 0.005 lightness until it reads at 4.5:1 as text on the deepest card fill
  /// (expressive and neutral) and under white labels.
  double get guardedLightness {
    final worst = [_n(.955, .014), _q(const Oklch(.965, 0, 0))];
    var l = primaryLightness;
    bool fails(double l) {
      final p = _q(_p(l, primaryChroma));
      return contrastRatio(const Color(0xFFFFFFFF), p) < 4.5 ||
          worst.any((w) => contrastRatio(p, w) < 4.5);
    }

    while (l > .3 && fails(l)) {
      l = ((l - .005) * 1000).round() / 1000;
    }
    return l;
  }

  KuberPalette palette({required bool dark}) {
    final pc = primaryChroma;
    if (!dark) {
      final surface = _n(.985, .008), container = _n(.955, .014), high = _n(.93, .017),
          border = _n(.875, .02);
      final primaryContainer = _p(0.92, primaryContainerChroma).toColor();
      final onPrimaryContainer = _p(0.38, pc).toColor();
      return KuberPalette(
        ColorScheme(
          brightness: Brightness.light,
          primary: _q(_p(guardedLightness, pc)),
          onPrimary: Colors.white,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          inversePrimary: _p(0.74, pc * 0.81).toColor(),
          secondary: _p(0.45, pc).toColor(),
          onSecondary: Colors.white,
          secondaryContainer: primaryContainer,
          onSecondaryContainer: onPrimaryContainer,
          tertiary: _p(0.45, pc).toColor(),
          onTertiary: Colors.white,
          tertiaryContainer: primaryContainer,
          onTertiaryContainer: onPrimaryContainer,
          error: const Oklch(0.55, 0.16, 25).toColor(),
          onError: Colors.white,
          errorContainer: const Oklch(0.95, 0.03, 25).toColor(),
          onErrorContainer: const Oklch(0.48, 0.17, 25).toColor(),
          surface: surface,
          surfaceDim: high,
          surfaceBright: surface,
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: _mix(surface, container, 0.5),
          surfaceContainer: container,
          surfaceContainerHigh: high,
          surfaceContainerHighest: _mix(high, border, 0.5),
          onSurface: _n(0.20, 0.02),
          onSurfaceVariant: _n(0.50, 0.02),
          outline: _n(0.62, 0.02),
          outlineVariant: border,
          inverseSurface: _n(0.22, 0.02),
          onInverseSurface: _n(0.97, 0.004),
          shadow: Colors.black,
          scrim: Colors.black,
          surfaceTint: Colors.transparent,
        ),
        _money(dark: false),
        [for (final l in [0.95, 0.86, 0.73, 0.57, 0.44]) _p(l, pc).toColor()],
      );
    }
    final pcd = pc * 0.81;
    final surface = _nd(0.205, 0.012), container = _nd(0.255, 0.014), high = _nd(0.30, 0.016),
        border = _nd(0.36, 0.016);
    final primaryContainer = _p(0.28, pcd * 0.46).toColor();
    final onPrimaryContainer = _p(0.90, pcd * 0.46).toColor();
    return KuberPalette(
      ColorScheme(
        brightness: Brightness.dark,
        primary: _p(0.74, pcd).toColor(),
        onPrimary: _nd(0.14, 0.01),
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        inversePrimary: _p(primaryLightness, pc).toColor(),
        secondary: _p(0.85, pcd * 0.69).toColor(),
        onSecondary: _nd(0.14, 0.01),
        secondaryContainer: primaryContainer,
        onSecondaryContainer: onPrimaryContainer,
        tertiary: _p(0.85, pcd * 0.69).toColor(),
        onTertiary: _nd(0.14, 0.01),
        tertiaryContainer: primaryContainer,
        onTertiaryContainer: onPrimaryContainer,
        error: const Oklch(0.72, 0.14, 25).toColor(),
        onError: _nd(0.14, 0.01),
        errorContainer: const Oklch(0.26, 0.05, 25).toColor(),
        onErrorContainer: const Oklch(0.82, 0.11, 25).toColor(),
        surface: surface,
        surfaceDim: surface,
        surfaceBright: high,
        surfaceContainerLowest: _nd(0.17, 0.01),
        surfaceContainerLow: _mix(surface, container, 0.5),
        surfaceContainer: container,
        surfaceContainerHigh: high,
        surfaceContainerHighest: _mix(high, border, 0.5),
        onSurface: _nd(0.96, 0.005),
        onSurfaceVariant: _nd(0.72, 0.012),
        outline: _nd(0.60, 0.012),
        outlineVariant: border,
        inverseSurface: _nd(0.93, 0.008),
        onInverseSurface: _nd(0.20, 0.02),
        shadow: Colors.black,
        scrim: Colors.black,
        surfaceTint: Colors.transparent,
      ),
      _money(dark: true),
      [for (final l in [0.28, 0.38, 0.52, 0.68, 0.82]) _p(l, pcd).toColor()],
    );
  }

  /// Income / expense / warning in the same OKLCh register as the family.
  static List<Color> _money({required bool dark}) {
    List<Color> role(double hue, double chroma) => dark
        ? [
            Oklch(0.78, chroma, hue).toColor(),
            Oklch(0.25, chroma * 0.4, hue).toColor(),
            Oklch(0.32, chroma * 0.45, hue).toColor(),
            Oklch(0.90, chroma * 0.5, hue).toColor(),
          ]
        : [
            Oklch(0.52, chroma, hue).toColor(),
            Colors.white,
            Oklch(0.93, chroma * 0.4, hue).toColor(),
            Oklch(0.38, chroma, hue).toColor(),
          ];
    return [...role(145, 0.13), ...role(25, 0.15), ...role(70, 0.12)];
  }
}

/// Display name and blurb for a family (Theme screen, Settings row).
String themeFamilyName(ThemeVariant v) =>
    v == ThemeVariant.signature ? 'Kuber Signature' : MullFamily.of(v).name;

String themeFamilyBlurb(ThemeVariant v) =>
    v == ThemeVariant.signature ? 'classic blue' : MullFamily.of(v).blurb;
