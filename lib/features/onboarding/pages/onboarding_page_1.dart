import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/onboarding_entrance.dart';
import '../widgets/onboarding_fit.dart';
import '../widgets/onboarding_skip_button.dart';

class OnboardingPageOne extends StatelessWidget {
  final String version;
  final VoidCallback onSkip;

  const OnboardingPageOne({
    super.key,
    required this.version,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        OnboardingSkipButton(onSkip: onSkip),
        Expanded(
          child: OnboardingFit(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const OrbitingCoinAnimation(size: 264),
                const SizedBox(height: KuberSpacing.lg),
                OnboardingEntrance(
                  delay: const Duration(milliseconds: 80),
                  child: _VersionBadge(version: version),
                ),
                const SizedBox(height: KuberSpacing.lg),
                OnboardingEntrance(
                  delay: const Duration(milliseconds: 160),
                  child: Text(
                    context.l10n.yourMoneyYourRules,
                    textAlign: TextAlign.center,
                    style: localeFont(
                      fontSize: 32,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                OnboardingEntrance(
                  delay: const Duration(milliseconds: 260),
                  child: Text(
                    context.l10n.onboardingPage1Description,
                    textAlign: TextAlign.center,
                    style: localeFont(
                      fontSize: 14,
                      height: 1.45,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VersionBadge extends StatelessWidget {
  final String version;

  const _VersionBadge({required this.version});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
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
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: cs.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Text(
            context.l10n.offlineFirstBadge(
              version.isEmpty ? 'V' : version.toUpperCase(),
            ),
            style: localeFont(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class OrbitingCoinAnimation extends StatefulWidget {
  final double size;

  const OrbitingCoinAnimation({super.key, this.size = 260});

  @override
  State<OrbitingCoinAnimation> createState() => _OrbitingCoinAnimationState();
}

class _OrbitingCoinAnimationState extends State<OrbitingCoinAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _CoinOrbitPainter(
              progress: _controller.value,
              colorScheme: Theme.of(context).colorScheme,
            ),
          ),
        ),
      ),
    );
  }
}

class _CoinOrbitPainter extends CustomPainter {
  final double progress;
  final ColorScheme colorScheme;

  const _CoinOrbitPainter({required this.progress, required this.colorScheme});

  static const _goldLight = Color(0xFFFFD35A);
  static const _goldMid = Color(0xFFE3A51A);
  static const _goldDark = Color(0xFF8D6208);
  static const _goldRim = Color(0xFFB57F10);
  static const _orbitBlue = Color(0xFF3B82F6);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final orbitRadius = size.shortestSide * 0.4;
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colorScheme.onSurface.withValues(alpha: 0.16);
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = colorScheme.onSurface.withValues(alpha: 0.18);

    canvas.drawCircle(center, orbitRadius, orbitPaint);
    _drawDashedCircle(canvas, center, orbitRadius * 0.77, dashPaint);

    final pulse = 1 + math.sin(progress * math.pi * 2) * 0.018;
    _drawCoin(
      canvas,
      center,
      size.shortestSide * 0.235 * pulse,
      progress * math.pi * 2,
      large: true,
    );

    _drawOrbitDot(
      canvas,
      center,
      orbitRadius * 0.96,
      progress * math.pi * 2 + math.pi * 0.96,
      _orbitBlue,
    );
    _drawOrbitDot(
      canvas,
      center,
      orbitRadius * 0.77,
      progress * math.pi * 2 + math.pi * 1.92,
      colorScheme.onSurfaceVariant,
    );

    final orbiting = [
      (
        angle: progress * math.pi * 2 + math.pi * 0.05,
        size: 0.074,
        edge: false,
      ),
      (
        angle: progress * math.pi * 2 + math.pi * 0.86,
        size: 0.064,
        edge: false,
      ),
      (angle: progress * math.pi * 2 + math.pi * 1.52, size: 0.056, edge: true),
    ];

    for (final coin in orbiting) {
      final x = center.dx + math.cos(coin.angle) * orbitRadius;
      final y = center.dy + math.sin(coin.angle) * orbitRadius;
      if (coin.edge) {
        _drawEdgeCoin(canvas, Offset(x, y), size.shortestSide * coin.size);
      } else {
        _drawCoin(
          canvas,
          Offset(x, y),
          size.shortestSide * coin.size,
          coin.angle,
        );
      }
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const dash = math.pi / 36;
    const gap = math.pi / 28;
    var angle = 0.0;
    while (angle < math.pi * 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        dash,
        false,
        paint,
      );
      angle += dash + gap;
    }
  }

  void _drawOrbitDot(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    Color color,
  ) {
    final dot = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    canvas.drawCircle(dot, 4.5, Paint()..color = color.withValues(alpha: 0.72));
  }

  void _drawCoin(
    Canvas canvas,
    Offset center,
    double radius,
    double angle, {
    bool large = false,
  }) {
    final shadow = Paint()
      ..color = _goldMid.withValues(alpha: large ? 0.28 : 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, large ? 22 : 12);
    canvas.drawCircle(center, radius * 1.22, shadow);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = const RadialGradient(
      center: Alignment(-0.28, -0.38),
      colors: [_goldLight, Color(0xFFF5BC2C), _goldMid],
      stops: [0.0, 0.62, 1.0],
    ).createShader(rect);
    final fill = Paint()..shader = gradient;
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, radius * 0.05)
      ..color = _goldRim.withValues(alpha: 0.48);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle * 0.12);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, rim);
    canvas.drawCircle(center, radius * 0.75, rim);
    _drawCoinTicks(canvas, center, radius);
    _drawHighlight(canvas, center, radius, angle);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '₹',
        style: localeFont(
          fontSize: radius * 1.12,
          fontWeight: FontWeight.w900,
          color: _goldDark.withValues(alpha: large ? 0.95 : 0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
    canvas.restore();
  }

  void _drawCoinTicks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = _goldDark.withValues(alpha: 0.34)
      ..strokeWidth = math.max(1, radius * 0.025)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 72; i++) {
      final angle = math.pi * 2 * i / 72;
      final outer = Offset(
        center.dx + math.cos(angle) * radius * 1.02,
        center.dy + math.sin(angle) * radius * 1.02,
      );
      final inner = Offset(
        center.dx + math.cos(angle) * radius * 0.95,
        center.dy + math.sin(angle) * radius * 0.95,
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  void _drawHighlight(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
  ) {
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFF2A3).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.065
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.86),
      -math.pi * 0.58 + math.sin(angle) * 0.16,
      math.pi * 0.43,
      false,
      highlightPaint,
    );
    canvas.drawCircle(
      center.translate(-radius * 0.44, -radius * 0.44),
      radius * 0.07,
      Paint()..color = const Color(0xFFFFF2A3).withValues(alpha: 0.75),
    );
  }

  void _drawEdgeCoin(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 0.55,
      height: radius * 2.4,
    );
    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [_goldDark, _goldLight, _goldMid, _goldDark],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), Radius.circular(radius)),
      Paint()
        ..color = _goldDark.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _CoinOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colorScheme != colorScheme;
  }
}