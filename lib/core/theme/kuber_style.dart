import 'package:flutter/material.dart';

/// The two design language options in Kuber.
enum KuberStyle {
  /// Today's Vault look: crisp 8dp universal radius, standard pill nav, compact type.
  signature,

  /// Google's Material 3 Expressive: pill shapes, rounded cards/dialogs, active-pill nav.
  m3Expressive,
}

/// Token values determined by the active [KuberStyle].
/// Registered as a [ThemeExtension] on [ThemeData]. Shared components read
/// these tokens (e.g. `context.styleTokens.buttonRadius`) instead of hardcoding radii.
@immutable
class KuberStyleTokens extends ThemeExtension<KuberStyleTokens> {
  final KuberStyle style;
  final double buttonRadius;
  final double cardRadius;
  final double featuredCardRadius;
  final double sheetRadius;
  final double dialogRadius;
  final double chipRadius;
  final double textFieldRadius;
  final double snackbarRadius;
  final double fabRadius;
  final double bottomNavHeight;
  final bool isM3Expressive;

  const KuberStyleTokens({
    required this.style,
    required this.buttonRadius,
    required this.cardRadius,
    required this.featuredCardRadius,
    required this.sheetRadius,
    required this.dialogRadius,
    required this.chipRadius,
    required this.textFieldRadius,
    required this.snackbarRadius,
    required this.fabRadius,
    required this.bottomNavHeight,
    required this.isM3Expressive,
  });

  factory KuberStyleTokens.of(KuberStyle style) {
    switch (style) {
      case KuberStyle.signature:
        return const KuberStyleTokens(
          style: KuberStyle.signature,
          buttonRadius: 8.0,
          cardRadius: 8.0,
          featuredCardRadius: 8.0,
          sheetRadius: 12.0,
          dialogRadius: 8.0,
          chipRadius: 8.0,
          textFieldRadius: 8.0,
          snackbarRadius: 8.0,
          fabRadius: 8.0,
          bottomNavHeight: 64.0,
          isM3Expressive: false,
        );
      case KuberStyle.m3Expressive:
        return const KuberStyleTokens(
          style: KuberStyle.m3Expressive,
          buttonRadius: 999.0,
          cardRadius: 16.0,
          featuredCardRadius: 20.0,
          sheetRadius: 28.0,
          dialogRadius: 28.0,
          chipRadius: 999.0,
          textFieldRadius: 8.0,
          snackbarRadius: 4.0,
          fabRadius: 999.0,
          bottomNavHeight: 64.0,
          isM3Expressive: true,
        );
    }
  }

  @override
  KuberStyleTokens copyWith({
    KuberStyle? style,
    double? buttonRadius,
    double? cardRadius,
    double? featuredCardRadius,
    double? sheetRadius,
    double? dialogRadius,
    double? chipRadius,
    double? textFieldRadius,
    double? snackbarRadius,
    double? fabRadius,
    double? bottomNavHeight,
    bool? isM3Expressive,
  }) {
    return KuberStyleTokens(
      style: style ?? this.style,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      featuredCardRadius: featuredCardRadius ?? this.featuredCardRadius,
      sheetRadius: sheetRadius ?? this.sheetRadius,
      dialogRadius: dialogRadius ?? this.dialogRadius,
      chipRadius: chipRadius ?? this.chipRadius,
      textFieldRadius: textFieldRadius ?? this.textFieldRadius,
      snackbarRadius: snackbarRadius ?? this.snackbarRadius,
      fabRadius: fabRadius ?? this.fabRadius,
      bottomNavHeight: bottomNavHeight ?? this.bottomNavHeight,
      isM3Expressive: isM3Expressive ?? this.isM3Expressive,
    );
  }

  @override
  KuberStyleTokens lerp(ThemeExtension<KuberStyleTokens>? other, double t) {
    if (other is! KuberStyleTokens) return this;
    return KuberStyleTokens(
      style: t < 0.5 ? style : other.style,
      buttonRadius: lerpDouble(buttonRadius, other.buttonRadius, t),
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t),
      featuredCardRadius: lerpDouble(featuredCardRadius, other.featuredCardRadius, t),
      sheetRadius: lerpDouble(sheetRadius, other.sheetRadius, t),
      dialogRadius: lerpDouble(dialogRadius, other.dialogRadius, t),
      chipRadius: lerpDouble(chipRadius, other.chipRadius, t),
      textFieldRadius: lerpDouble(textFieldRadius, other.textFieldRadius, t),
      snackbarRadius: lerpDouble(snackbarRadius, other.snackbarRadius, t),
      fabRadius: lerpDouble(fabRadius, other.fabRadius, t),
      bottomNavHeight: lerpDouble(bottomNavHeight, other.bottomNavHeight, t),
      isM3Expressive: t < 0.5 ? isM3Expressive : other.isM3Expressive,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Convenience accessor for [KuberStyleTokens].
extension KuberStyleThemeX on BuildContext {
  KuberStyleTokens get styleTokens =>
      Theme.of(this).extension<KuberStyleTokens>() ??
      KuberStyleTokens.of(KuberStyle.signature);
}
