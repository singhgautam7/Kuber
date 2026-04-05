import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class SweepRingWidget extends AnimatedWidget {
  final AnimationController controller;
  final double size;
  final double iconSize;

  const SweepRingWidget({
    super.key,
    required this.controller,
    this.size = 96,
    this.iconSize = 36,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: SweepRingPainter(
            progress: controller.value,
            primaryColor: cs.primary,
            surfaceMutedColor: cs.surfaceContainerHigh,
          ),
          child: Center(
            child: Icon(
              Icons.sync_rounded,
              color: cs.primary,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final String value;

  const StatusPill({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.md,
        vertical: KuberSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.full),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class SweepRingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color surfaceMutedColor;

  SweepRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.surfaceMutedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background ring
    final bgPaint = Paint()
      ..color = surfaceMutedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    // Sweep gradient arc
    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          primaryColor.withValues(alpha: 0.0),
          primaryColor,
        ],
        transform: GradientRotation(progress * math.pi * 2 - math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + progress * math.pi * 2 - math.pi,
      math.pi,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(SweepRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
