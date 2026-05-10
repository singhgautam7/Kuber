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
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final target = spotlightRect;

    if (target == null) {
      canvas.drawPath(
        fullPath,
        Paint()..color = Color.fromRGBO(0, 0, 0, dimOpacity),
      );
      return;
    }

    final hole = RRect.fromRectAndRadius(
      target.inflate(8),
      const Radius.circular(KuberRadius.md),
    );
    final holePath = Path()..addRRect(hole);
    final cutout = Path.combine(PathOperation.difference, fullPath, holePath);

    canvas.drawPath(
      cutout,
      Paint()..color = Color.fromRGBO(0, 0, 0, dimOpacity),
    );
    canvas.drawRRect(
      hole,
      Paint()
        ..color = primaryColor.withValues(alpha: borderOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant TutorialSpotlightPainter oldDelegate) {
    return oldDelegate.spotlightRect != spotlightRect ||
        oldDelegate.dimOpacity != dimOpacity ||
        oldDelegate.borderOpacity != borderOpacity ||
        oldDelegate.primaryColor != primaryColor;
  }
}
