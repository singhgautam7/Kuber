import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kuber mark variants. Default is [spark] (rupee + one twinkle).
enum KuberMarkVariant { spark, plain, flanked }

/// The Kuber identity mark: a rupee glyph in a softly glowing primary-tinted
/// circle, with a small four-point twinkle in the top-right that signals
/// "assistant". Single source of truth, consumed by the AppBar avatar and the
/// Welcome centerpiece. Glow is rendered as a [RadialGradient] (never a
/// BoxShadow) to keep the Vault "no shadows" rule.
class KuberMarkWidget extends StatelessWidget {
  final double size;
  final KuberMarkVariant variant;

  /// Flat icon mode: just the rupee + twinkle glyph in [color] (no glowing
  /// circle, border or halo). For entry-point icon slots elsewhere in the app.
  final bool bare;

  /// Glyph colour in [bare] mode. Defaults to the theme primary.
  final Color? color;

  const KuberMarkWidget({
    super.key,
    required this.size,
    this.variant = KuberMarkVariant.spark,
    this.bare = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (bare) {
      final c = color ?? cs.primary;
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              '₹',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: size * 0.92,
                height: 1.0,
                color: c,
              ),
            ),
            if (variant != KuberMarkVariant.plain)
              Positioned(
                top: -size * 0.06,
                right: -size * 0.02,
                child: CustomPaint(
                  size: Size.square(size * 0.34),
                  painter: _TwinklePainter(c),
                ),
              ),
          ],
        ),
      );
    }

    // The halo extends beyond the circle; reserve room for it.
    final box = size * 1.34;
    final twinkle = size * 0.26;
    final inset = size * 0.04;

    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Outer soft glow (radial gradient, not a shadow).
          Container(
            width: box,
            height: box,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.18),
                  cs.primary.withValues(alpha: 0.06),
                  cs.primary.withValues(alpha: 0.0),
                ],
                stops: const [0.45, 0.7, 1.0],
              ),
            ),
          ),
          // The mark circle.
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.45),
                  cs.primary.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
            ),
          ),
          // Rupee, optically nudged up.
          Transform.translate(
            offset: Offset(0, -size * 0.024),
            child: Text(
              '₹',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: size * 0.62,
                height: 1.0,
                color: cs.onPrimary,
              ),
            ),
          ),
          // Twinkle, top-right.
          if (variant != KuberMarkVariant.plain)
            Positioned(
              top: (box - size) / 2 + inset,
              right: (box - size) / 2 + inset,
              child: CustomPaint(
                size: Size.square(twinkle),
                painter: _TwinklePainter(cs.onPrimary),
              ),
            ),
          if (variant == KuberMarkVariant.flanked)
            Positioned(
              bottom: (box - size) / 2 + inset,
              left: (box - size) / 2 + inset,
              child: CustomPaint(
                size: Size.square(twinkle * 0.7),
                painter: _TwinklePainter(cs.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wraps [KuberMarkWidget] in the shared pulse animation. The whole mark scales
/// together; [thinking] swaps to the faster, deeper pulse. Wrapped in a
/// [RepaintBoundary] so the pulse never repaints siblings.
class PulsingKuberMark extends StatelessWidget {
  final double size;
  final Animation<double> pulse;
  final bool thinking;
  final KuberMarkVariant variant;

  const PulsingKuberMark({
    super.key,
    required this.size,
    required this.pulse,
    this.thinking = false,
    this.variant = KuberMarkVariant.spark,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(pulse.value);
          final amplitude = thinking ? 0.10 : 0.05;
          return Transform.scale(scale: 1.0 + t * amplitude, child: child);
        },
        child: KuberMarkWidget(size: size, variant: variant),
      ),
    );
  }
}

/// A sharp four-point sparkle filling the paint area.
class _TwinklePainter extends CustomPainter {
  final Color color;
  const _TwinklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.18; // small inner radius => sharp points

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final r = i.isEven ? outer : inner;
      final angle = (math.pi / 4) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TwinklePainter oldDelegate) => oldDelegate.color != color;
}
