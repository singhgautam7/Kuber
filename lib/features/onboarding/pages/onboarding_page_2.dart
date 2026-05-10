import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/widgets/settings_widgets.dart';
import '../widgets/onboarding_entrance.dart';
import '../widgets/onboarding_fit.dart';
import '../widgets/onboarding_skip_button.dart';

class OnboardingPageTwo extends StatelessWidget {
  final VoidCallback onSkip;

  const OnboardingPageTwo({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cards = [
      (
        icon: Icons.wifi_off_rounded,
        title: 'Fully offline',
        body: 'No cloud servers. Nothing to breach. Works in airplane mode.',
      ),
      (
        icon: Icons.no_accounts_rounded,
        title: 'No account needed',
        body: 'Open the app and start. Zero signup, zero friction.',
      ),
      (
        icon: Icons.visibility_off_outlined,
        title: 'Privacy mode',
        body: 'One tap hides every balance when you hand over your phone.',
      ),
    ];

    return Column(
      children: [
        OnboardingSkipButton(onSkip: onSkip),
        Expanded(
          child: OnboardingFit(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: _PrivacyIllustration()),
                const SizedBox(height: KuberSpacing.lg),
                OnboardingEntrance(
                  child: Text(
                    'Private by design.',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                OnboardingEntrance(
                  delay: const Duration(milliseconds: 90),
                  child: Text(
                    'Your money stays on your device. No telemetry, no syncing, no third parties.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.42,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                for (var i = 0; i < cards.length; i++) ...[
                  OnboardingEntrance(
                    delay: Duration(milliseconds: 140 + i * 120),
                    child: _PrivacyFeatureCard(
                      icon: cards[i].icon,
                      title: cards[i].title,
                      body: cards[i].body,
                      highlighted: i == 0,
                    ),
                  ),
                  if (i < cards.length - 1)
                    const SizedBox(height: KuberSpacing.sm),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivacyFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool highlighted;

  const _PrivacyFeatureCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
          color: highlighted ? cs.primary.withValues(alpha: 0.75) : cs.outline,
        ),
      ),
      child: Row(
        children: [
          SquircleIcon(
            icon: icon,
            color: highlighted ? cs.primary : cs.onSurfaceVariant,
            size: 20,
            padding: 10,
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: KuberSpacing.xs),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.32,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyIllustration extends StatefulWidget {
  const _PrivacyIllustration();

  @override
  State<_PrivacyIllustration> createState() => _PrivacyIllustrationState();
}

class _PrivacyIllustrationState extends State<_PrivacyIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 250,
        height: 132,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _PrivacyPainter(
              progress: Curves.easeInOut.transform(_controller.value),
              colorScheme: Theme.of(context).colorScheme,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyPainter extends CustomPainter {
  final double progress;
  final ColorScheme colorScheme;

  const _PrivacyPainter({required this.progress, required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);
    final arcRect = Rect.fromCenter(
      center: center.translate(0, 8),
      width: size.width * 0.64,
      height: size.height * 0.58,
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = colorScheme.primary.withValues(alpha: 0.75);
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = colorScheme.primary.withValues(alpha: 0.28);

    canvas.drawArc(arcRect, math.pi * 1.12, math.pi * 0.76, false, arcPaint);
    canvas.drawArc(
      arcRect.inflate(16),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      dashPaint,
    );

    _drawClose(canvas, Offset(size.width * 0.28, size.height * 0.28));
    _drawClose(canvas, Offset(size.width * 0.72, size.height * 0.28));
    _drawCoinStack(canvas, Offset(size.width / 2, size.height * 0.78));
    _drawLock(canvas, center.translate(0, -8 - progress * 5));
  }

  void _drawClose(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = colorScheme.onSurfaceVariant.withValues(alpha: 0.58)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    const size = 12.0;
    canvas.drawLine(
      center.translate(-size, -size),
      center.translate(size, size),
      paint,
    );
    canvas.drawLine(
      center.translate(size, -size),
      center.translate(-size, size),
      paint,
    );
  }

  void _drawCoinStack(Canvas canvas, Offset center) {
    final fill = Paint()..color = colorScheme.primary.withValues(alpha: 0.78);
    final rim = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 2; i >= 0; i--) {
      final rect = Rect.fromCenter(
        center: center.translate(0, -i * 13),
        width: 92,
        height: 26,
      );
      canvas.drawOval(rect, fill);
      canvas.drawOval(rect, rim);
    }
  }

  void _drawLock(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, 8), width: 42, height: 34),
      const Radius.circular(KuberRadius.md),
    );
    canvas.drawRRect(body, paint);
    canvas.drawArc(
      Rect.fromCenter(center: center.translate(0, -6), width: 28, height: 32),
      math.pi,
      math.pi,
      false,
      paint,
    );
    canvas.drawCircle(
      center.translate(0, 8),
      3,
      Paint()..color = colorScheme.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _PrivacyPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colorScheme != colorScheme;
  }
}
