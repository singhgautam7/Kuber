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

/// Resolves the palette for [variant]. [seed] (Android wallpaper colour)
/// overrides the family; [amoled] drops dark surfaces to true black for
/// families that support it.
KuberPalette kuberPalette(
  ThemeVariant variant,
  Brightness brightness, {
  bool amoled = false,
  Color? seed,
}) {
  final dark = brightness == Brightness.dark;
  if (seed != null) {
    return MullFamily.fromSeed(seed).palette(dark: dark, amoled: amoled);
  }
  variant = resolveVariant(variant);
  if (variant == ThemeVariant.signature) return _signature(dark);
  return MullFamily.of(variant).palette(dark: dark, amoled: amoled);
}

// ── Kuber Signature: M3 seed scheme matching the app icon ────────────────────
//
// Seed #3B82F6 with the fidelity variant (tonalSpot washes this blue out to a
// dull #445E91). Dark mode drops surface / surfaceContainerLowest to true
// black; every other role is generated. Reference values, money colours and
// the heat ramp come from
// specs/design/kuber-m3-round-1-design-system/project/tokens/palettes.json
// (signature_light / signature_dark).

const _signatureSeed = Color(0xFF3B82F6);

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
  var scheme = ColorScheme.fromSeed(
    seedColor: _signatureSeed,
    brightness: dark ? Brightness.dark : Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  if (dark) {
    scheme = scheme.copyWith(
      surface: const Color(0xFF000000),
      surfaceContainerLowest: const Color(0xFF000000),
    );
  }
  return KuberPalette(
    scheme,
    dark ? _signatureMoneyDark : _signatureMoneyLight,
    dark ? _signatureHeatDark : _signatureHeatLight,
  );
}

// ── Mull families ────────────────────────────────────────────────────────────

/// One accent family, copied from Mull `core/theme/palette.dart`
/// (`ThemeFamily`): the same OKLCh construction for light, dark and true
/// black. [palette] maps Mull's roles onto Kuber's M3 scheme.
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
    required this.hasAmoled,
    this.lightSurfaceSink = 0,
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
  final bool hasAmoled;
  final double lightSurfaceSink;
  final double darkNeutralChroma;

  static const mull = MullFamily(id: 'mull', name: 'Mull', blurb: 'default', neutralHue: 215, neutralChroma: 1, primaryHue: 215, primaryLightness: 0.52, primaryChroma: 0.11, primaryContainerChroma: 0.04, hasAmoled: true);
  static const vellum = MullFamily(id: 'vellum', name: 'Vellum', blurb: 'warm', neutralHue: 80, neutralChroma: 1.3, primaryHue: 70, primaryLightness: 0.58, primaryChroma: 0.10, primaryContainerChroma: 0.04, hasAmoled: false);
  static const foxglove = MullFamily(id: 'foxglove', name: 'Foxglove', blurb: 'soft', neutralHue: 330, neutralChroma: 1.05, primaryHue: 325, primaryLightness: 0.55, primaryChroma: 0.12, primaryContainerChroma: 0.04, hasAmoled: false);
  static const slate = MullFamily(id: 'slate', name: 'Slate', blurb: 'mono', neutralHue: 215, neutralChroma: 0.4, primaryHue: 215, primaryLightness: 0.42, primaryChroma: 0.012, primaryContainerChroma: 0.006, hasAmoled: true);
  static const clay = MullFamily(id: 'clay', name: 'Clay', blurb: 'greige', neutralHue: 75, neutralChroma: 2.2, primaryHue: 45, primaryLightness: 0.50, primaryChroma: 0.055, primaryContainerChroma: 0.02, hasAmoled: false, lightSurfaceSink: 0.025, darkNeutralChroma: 1.2);
  static const perch = MullFamily(id: 'perch', name: 'Perch', blurb: 'violet', neutralHue: 265, neutralChroma: 1, primaryHue: 265, primaryLightness: 0.52, primaryChroma: 0.11, primaryContainerChroma: 0.04, hasAmoled: true);
  static const ember = MullFamily(id: 'ember', name: 'Ember', blurb: 'amber', neutralHue: 55, neutralChroma: 1.35, primaryHue: 45, primaryLightness: 0.58, primaryChroma: 0.11, primaryContainerChroma: 0.04, hasAmoled: false);
  static const fern = MullFamily(id: 'fern', name: 'Fern', blurb: 'cool green', neutralHue: 160, neutralChroma: 1.15, primaryHue: 162, primaryLightness: 0.54, primaryChroma: 0.10, primaryContainerChroma: 0.04, hasAmoled: false);
  static const azure = MullFamily(id: 'azure', name: 'Azure', blurb: 'blue', neutralHue: 259, neutralChroma: 1, primaryHue: 259, primaryLightness: 0.52, primaryChroma: 0.12, primaryContainerChroma: 0.04, hasAmoled: true);
  static const tide = MullFamily(id: 'tide', name: 'Tide', blurb: 'teal', neutralHue: 189, neutralChroma: 1, primaryHue: 189, primaryLightness: 0.50, primaryChroma: 0.09, primaryContainerChroma: 0.04, hasAmoled: true);
  static const meadow = MullFamily(id: 'meadow', name: 'Meadow', blurb: 'green', neutralHue: 145, neutralChroma: 1.1, primaryHue: 145, primaryLightness: 0.52, primaryChroma: 0.10, primaryContainerChroma: 0.04, hasAmoled: false);
  static const blush = MullFamily(id: 'blush', name: 'Blush', blurb: 'rose', neutralHue: 359, neutralChroma: 1.05, primaryHue: 359, primaryLightness: 0.55, primaryChroma: 0.12, primaryContainerChroma: 0.04, hasAmoled: false);
  static const iris = MullFamily(id: 'iris', name: 'Iris', blurb: 'purple', neutralHue: 290, neutralChroma: 1, primaryHue: 290, primaryLightness: 0.55, primaryChroma: 0.12, primaryContainerChroma: 0.04, hasAmoled: true);
  static const coral = MullFamily(id: 'coral', name: 'Coral', blurb: 'red orange', neutralHue: 30, neutralChroma: 1.2, primaryHue: 30, primaryLightness: 0.56, primaryChroma: 0.12, primaryContainerChroma: 0.04, hasAmoled: false);
  static const citron = MullFamily(id: 'citron', name: 'Citron', blurb: 'yellow green', neutralHue: 113, neutralChroma: 1.2, primaryHue: 113, primaryLightness: 0.55, primaryChroma: 0.10, primaryContainerChroma: 0.04, hasAmoled: false);
  static const neon = MullFamily(id: 'neon', name: 'Neon', blurb: 'vivid green', neutralHue: 147, neutralChroma: 0.8, primaryHue: 147, primaryLightness: 0.60, primaryChroma: 0.14, primaryContainerChroma: 0.05, hasAmoled: true);

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
      hasAmoled: true,
    );
  }

  Oklch _n(double l, double c, {bool dark = false}) =>
      Oklch(l, c * (dark ? darkNeutralChroma : neutralChroma), neutralHue);
  Oklch _nd(double l, double c) => _n(l, c, dark: true);
  Oklch _p(double l, double c) => Oklch(l, c, primaryHue);

  KuberPalette palette({required bool dark, bool amoled = false}) {
    final pc = primaryChroma;
    if (!dark) {
      final sink = lightSurfaceSink;
      final surface = _n(0.99 - sink, 0.004).toColor();
      final container = _n(0.965 - 1.6 * sink, 0.008).toColor();
      final high = _n(0.935 - 2.2 * sink, 0.011).toColor();
      final border = _n(0.885 - 2.2 * sink, 0.012).toColor();
      final primaryContainer = _p(0.92, primaryContainerChroma).toColor();
      final onPrimaryContainer = _p(0.38, pc).toColor();
      return KuberPalette(
        ColorScheme(
          brightness: Brightness.light,
          primary: _p(primaryLightness, pc).toColor(),
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
          surfaceContainerLowest: _n(1.0, 0).toColor(),
          surfaceContainerLow: Color.lerp(surface, container, 0.5)!,
          surfaceContainer: container,
          surfaceContainerHigh: high,
          surfaceContainerHighest: Color.lerp(high, border, 0.5)!,
          onSurface: _n(0.20, 0.02).toColor(),
          onSurfaceVariant: _n(0.52, 0.02).toColor(),
          outline: _n(0.62, 0.02).toColor(),
          outlineVariant: border,
          inverseSurface: _n(0.22, 0.02).toColor(),
          onInverseSurface: _n(0.97, 0.004).toColor(),
          shadow: Colors.black,
          scrim: Colors.black,
          surfaceTint: Colors.transparent,
        ),
        _money(dark: false),
        [for (final l in [0.95, 0.86, 0.73, 0.57, 0.44]) _p(l, pc).toColor()],
      );
    }
    final black = amoled && hasAmoled;
    final pcd = pc * 0.81;
    final surface =
        black ? const Color(0xFF000000) : _nd(0.205, 0.012).toColor();
    final container =
        _nd(black ? 0.13 : 0.255, black ? 0.012 : 0.014).toColor();
    final high = _nd(black ? 0.15 : 0.30, black ? 0.012 : 0.016).toColor();
    final border = _nd(black ? 0.30 : 0.36, black ? 0.014 : 0.016).toColor();
    final primaryContainer = _p(0.28, pcd * 0.46).toColor();
    final onPrimaryContainer = _p(0.90, pcd * 0.46).toColor();
    return KuberPalette(
      ColorScheme(
        brightness: Brightness.dark,
        primary: _p(0.74, pcd).toColor(),
        onPrimary: _nd(0.14, 0.01).toColor(),
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        inversePrimary: _p(primaryLightness, pc).toColor(),
        secondary: _p(0.85, pcd * 0.69).toColor(),
        onSecondary: _nd(0.14, 0.01).toColor(),
        secondaryContainer: primaryContainer,
        onSecondaryContainer: onPrimaryContainer,
        tertiary: _p(0.85, pcd * 0.69).toColor(),
        onTertiary: _nd(0.14, 0.01).toColor(),
        tertiaryContainer: primaryContainer,
        onTertiaryContainer: onPrimaryContainer,
        error: const Oklch(0.72, 0.14, 25).toColor(),
        onError: _nd(0.14, 0.01).toColor(),
        errorContainer: Oklch(black ? 0.20 : 0.26, 0.05, 25).toColor(),
        onErrorContainer: const Oklch(0.82, 0.11, 25).toColor(),
        surface: surface,
        surfaceDim: surface,
        surfaceBright: high,
        surfaceContainerLowest: black ? const Color(0xFF000000) : _nd(0.17, 0.01).toColor(),
        surfaceContainerLow: Color.lerp(surface, container, 0.5)!,
        surfaceContainer: container,
        surfaceContainerHigh: high,
        surfaceContainerHighest: Color.lerp(high, border, 0.5)!,
        onSurface: _nd(0.96, 0.005).toColor(),
        onSurfaceVariant: _nd(0.72, 0.012).toColor(),
        outline: _nd(0.60, 0.012).toColor(),
        outlineVariant: border,
        inverseSurface: _nd(0.93, 0.008).toColor(),
        onInverseSurface: _nd(0.20, 0.02).toColor(),
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

bool themeFamilyHasAmoled(ThemeVariant v) =>
    v == ThemeVariant.signature || MullFamily.of(v).hasAmoled;
