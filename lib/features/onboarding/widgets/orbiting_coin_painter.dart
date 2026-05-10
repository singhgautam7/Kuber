import 'dart:math' as math;

import 'package:flutter/material.dart';

class OrbitingCoinAnimation extends StatefulWidget {
  const OrbitingCoinAnimation({super.key});

  @override
  State<OrbitingCoinAnimation> createState() => _OrbitingCoinAnimationState();
}

class _OrbitingCoinAnimationState extends State<OrbitingCoinAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _OrbitingCoinPainter(
            progress: _controller.value,
            orbitColor: cs.outline.withValues(alpha: 0.6),
            primaryColor: cs.primary,
          ),
        );
      },
    );
  }
}

class _OrbitingCoinPainter extends CustomPainter {
  final double progress;
  final Color orbitColor;
  final Color primaryColor;

  static const _goldColor = Color(0xFFF5A623);
  static const _orbitRadius = 110.0;
  static const _centralRadius = 70.0;
  static const _smallCoinRadius = 18.0;
  static const _dotRadius = 6.0;

  const _OrbitingCoinPainter({
    required this.progress,
    required this.orbitColor,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    _drawDashedCircle(canvas, center, _orbitRadius, orbitColor);

    final goldPaint = Paint()..color = _goldColor;
    canvas.drawCircle(center, _centralRadius, goldPaint);

    final innerRingPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, _centralRadius - 10, innerRingPaint);

    _drawRupee(canvas, center, 48, FontWeight.w800, Colors.white);

    final angle1 = progress * 2 * math.pi;
    final angle2 = angle1 + math.pi * 0.7;
    _drawSmallCoin(canvas, center, angle1);
    _drawSmallCoin(canvas, center, angle2);

    final dotAngle = angle1 + math.pi * 1.4;
    final dotPos = Offset(
      center.dx + _orbitRadius * math.cos(dotAngle),
      center.dy + _orbitRadius * math.sin(dotAngle),
    );
    canvas.drawCircle(dotPos, _dotRadius, Paint()..color = primaryColor);
  }

  void _drawDashedCircle(
      Canvas canvas, Offset center, double radius, Color color) {
    const dashWidth = 6.0;
    const dashGap = 4.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final circumference = 2 * math.pi * radius;
    final totalSegments = circumference / (dashWidth + dashGap);
    final anglePerSegment = 2 * math.pi / totalSegments;
    final dashAngle = anglePerSegment * (dashWidth / (dashWidth + dashGap));

    for (int i = 0; i < totalSegments.floor(); i++) {
      final startAngle = i * anglePerSegment;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  void _drawSmallCoin(Canvas canvas, Offset center, double angle) {
    final pos = Offset(
      center.dx + _orbitRadius * math.cos(angle),
      center.dy + _orbitRadius * math.sin(angle),
    );
    canvas.drawCircle(pos, _smallCoinRadius, Paint()..color = _goldColor);
    canvas.drawCircle(
      pos,
      _smallCoinRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _drawRupee(canvas, pos, 14, FontWeight.w700, Colors.white);
  }

  void _drawRupee(Canvas canvas, Offset center, double fontSize,
      FontWeight weight, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: '₹',
        style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_OrbitingCoinPainter old) => old.progress != progress;
}
