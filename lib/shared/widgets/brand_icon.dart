import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../../core/theme/app_theme.dart';

/// The Kuber brand mark: the folded-leg ₹ from the icon board
/// (specs/design/kuber-m3-round-1-design-system/project/icon/icon.md), drawn
/// as a vector so it follows the active theme family. The tones are the
/// board's HCT recipe (ground T90, bars + bowl T27, leg T50) applied to the
/// family's primary, so with Signature it is the launcher icon exactly.
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
    final hct = Hct.fromInt(Theme.of(context).colorScheme.primary.toARGB32());
    Color tone(double t) =>
        Color(Hct.from(hct.hue, hct.chroma, t).toInt());
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? KuberShape.largeIncreased),
      child: CustomPaint(
        size: Size.square(size),
        painter: KuberBrandMarkPainter(
          background: tone(90),
          dark: tone(27),
          mid: tone(50),
        ),
      ),
    );
  }
}

/// Paints the mark on the board's 108 x 108 adaptive-icon canvas, scaled to
/// the paint size. Also used by `tool/generate_icons_test.dart` for the legacy
/// launcher PNGs and the splash art, so the app and the launcher can't drift.
class KuberBrandMarkPainter extends CustomPainter {
  final Color background;
  final Color dark;
  final Color mid;

  const KuberBrandMarkPainter({
    required this.background,
    required this.dark,
    required this.mid,
  });

  /// Launcher icon / light splash colours from icon.md.
  static const light = KuberBrandMarkPainter(
    background: Color(0xFFD8E2FF),
    dark: Color(0xFF003D88),
    mid: Color(0xFF2573E6),
  );

  /// Dark splash colours from icon.md.
  static const night = KuberBrandMarkPainter(
    background: Color(0xFF001A42),
    dark: Color(0xFFADC6FF),
    mid: Color(0xFF4D8EFF),
  );

  /// Same strokes on a transparent ground (Android 12 splash icon).
  KuberBrandMarkPainter get glyphOnly =>
      KuberBrandMarkPainter(background: Colors.transparent, dark: dark, mid: mid);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 108, size.height / 108);
    if (background.a > 0) {
      canvas.drawRect(
          const Rect.fromLTWH(0, 0, 108, 108), Paint()..color = background);
    }
    Paint stroke(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dark: top bar, bowl, second bar. Mid: the leg, drawn last so its round
    // cap sits on the end of the bowl (the fold).
    final bars = Path()
      ..moveTo(40.4, 32.75)
      ..lineTo(67.6, 32.75)
      ..moveTo(50.6, 32.75)
      ..arcToPoint(const Offset(50.6, 58.25),
          radius: const Radius.circular(12.75))
      ..lineTo(42.1, 58.25)
      ..moveTo(40.4, 45.5)
      ..lineTo(67.6, 45.5);
    canvas.drawPath(bars, stroke(dark));
    canvas.drawLine(const Offset(42.1, 58.25), const Offset(61.65, 74.4),
        stroke(mid));
    canvas.restore();
  }

  @override
  bool shouldRepaint(KuberBrandMarkPainter old) =>
      old.background != background || old.dark != dark || old.mid != mid;
}
