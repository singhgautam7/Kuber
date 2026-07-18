import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// The Kuber brand mark (dark tile, accent circle, angular rupee), drawn as a
/// vector so it follows the active theme family instead of the static blue
/// launcher PNG. Geometry is traced 1:1 from android/play_store_512.png; with
/// the Signature theme the output matches the launcher icon (tile #0E397C,
/// circle #4388FD).
class BrandIcon extends StatelessWidget {
  final double size;
  final double? radius;

  const BrandIcon({
    super.key,
    this.size = 80,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? KuberRadius.xl),
      child: CustomPaint(
        size: Size.square(size),
        painter: KuberBrandMarkPainter(accent: cs.primary),
      ),
    );
  }
}

class KuberBrandMarkPainter extends CustomPainter {
  final Color accent;

  const KuberBrandMarkPainter({required this.accent});

  /// Deep shade of the accent used for the tile and the rupee glyph. Derived
  /// in HSL so every family keeps its hue: for the Signature blue this
  /// reproduces the launcher icon's #0E397C within a couple of RGB points.
  static Color deepShade(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return hsl
        .withSaturation((hsl.saturation * 0.85).clamp(0.0, 1.0))
        .withLightness(0.26)
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 512;
    canvas.scale(s);
    final deep = deepShade(accent);

    // Tile
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 512, 512),
      Paint()..color = deep,
    );

    // Accent circle
    canvas.drawCircle(
      const Offset(256, 256),
      190,
      Paint()..color = accent,
    );

    // Angular rupee glyph (same deep shade as the tile), traced from the
    // 512px source. Overlapping subpaths union under the non-zero fill rule.
    final glyph = Path()
      // Top bar (right end is slightly shorter, matching the source).
      ..addRect(const Rect.fromLTRB(176, 150, 335, 172))
      ..addRect(const Rect.fromLTRB(176, 150, 303, 178))
      // Bowl outer edge between the bars.
      ..addPolygon(const [
        Offset(259, 177),
        Offset(306, 177),
        Offset(316, 199),
        Offset(281, 199),
      ], true)
      // Second bar.
      ..addRect(const Rect.fromLTRB(176, 199, 335, 222))
      // Bowl outer edge below the second bar.
      ..addPolygon(const [
        Offset(283, 222),
        Offset(315, 222),
        Offset(307, 246),
        Offset(259, 246),
      ], true)
      // Bowl bottom, tapering into the leg junction.
      ..addPolygon(const [
        Offset(202, 245),
        Offset(306, 245),
        Offset(293, 260),
        Offset(276, 270),
        Offset(247, 275),
        Offset(202, 275),
      ], true)
      // Diagonal leg.
      ..addPolygon(const [
        Offset(202, 275),
        Offset(247, 275),
        Offset(326, 360),
        Offset(280, 361),
      ], true);
    canvas.drawPath(glyph, Paint()..color = deep);
  }

  @override
  bool shouldRepaint(KuberBrandMarkPainter old) => old.accent != accent;
}
