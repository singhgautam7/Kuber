import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class TutorialSpotlightPainter extends CustomPainter {
  final Rect? spotlightRect;
  final double dimOpacity;
  final double borderOpacity;
  final Color primaryColor;

  const TutorialSpotlightPainter({
    required this.spotlightRect,
    required this.dimOpacity,
    required this.borderOpacity,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (spotlightRect != null) {
      final inflated = spotlightRect!.inflate(8);
      final holeRRect = RRect.fromRectAndRadius(
        inflated,
        const Radius.circular(KuberRadius.md),
      );

      final fullPath = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      final holePath = Path()..addRRect(holeRRect);
      final cutout = Path.combine(
        PathOperation.difference,
        fullPath,
        holePath,
      );

      canvas.drawPath(
        cutout,
        Paint()
          ..color = Color.fromRGBO(0, 0, 0, dimOpacity)
          ..style = PaintingStyle.fill,
      );

      // Primary-color border around spotlight
      canvas.drawRRect(
        holeRRect,
        Paint()
          ..color = primaryColor.withValues(alpha: borderOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Soft glow ring
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          inflated.inflate(3),
          const Radius.circular(KuberRadius.md + 3),
        ),
        Paint()
          ..color = primaryColor.withValues(alpha: borderOpacity * 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    } else {
      // Dim-only step — no cutout
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..color = Color.fromRGBO(0, 0, 0, dimOpacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(TutorialSpotlightPainter old) =>
      old.spotlightRect != spotlightRect ||
      old.dimOpacity != dimOpacity ||
      old.borderOpacity != borderOpacity;
}
