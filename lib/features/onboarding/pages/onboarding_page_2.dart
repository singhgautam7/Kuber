import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/onboarding_nav_bar.dart';

class OnboardingPage2 extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingPage2({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _cards = [
    _CardData(
      icon: Icons.wifi_off_rounded,
      title: 'Fully offline',
      description:
          'No cloud servers. Nothing to breach. Works in airplane mode.',
    ),
    _CardData(
      icon: Icons.no_accounts_rounded,
      title: 'No account needed',
      description: 'Open the app and start. Zero signup, zero friction.',
    ),
    _CardData(
      icon: Icons.visibility_off_outlined,
      title: 'Privacy mode',
      description:
          'One tap hides every balance when you hand over your phone.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _cardAnim(int index) {
    final start = index * 0.18;
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, (start + 0.55).clamp(0.0, 1.0),
          curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: KuberSpacing.xxl),

                      // Illustration
                      Center(
                        child: SizedBox(
                          height: 120,
                          child: CustomPaint(
                            size: const Size(180, 120),
                            painter: _PrivacyMotifPainter(
                              primary: cs.primary,
                              onSurface: cs.onSurface,
                              outline: cs.outline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.xl),

                      Text(
                        'Private by design.',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.9,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      Text(
                        'Your money stays on your device. No telemetry, no syncing, no third parties.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.xl),

                      ..._cards.asMap().entries.map((e) {
                        final anim = _cardAnim(e.key);
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: KuberSpacing.md,
                          ),
                          child: AnimatedBuilder(
                            animation: anim,
                            builder: (context, child) {
                              return Opacity(
                                opacity: anim.value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - anim.value)),
                                  child: child,
                                ),
                              );
                            },
                            child: _PrivacyCard(data: e.value),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.xl,
                  vertical: KuberSpacing.lg,
                ),
                child: OnboardingNavBar(
                  currentPage: 1,
                  onBack: widget.onBack,
                  onNext: widget.onNext,
                ),
              ),
            ],
          ),
        ),

        // Skip button — top right
        Positioned(
          top: MediaQuery.of(context).padding.top + KuberSpacing.md,
          right: KuberSpacing.xl,
          child: TextButton(
            onPressed: widget.onSkip,
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardData {
  final IconData icon;
  final String title;
  final String description;
  const _CardData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _PrivacyCard extends StatelessWidget {
  final _CardData data;
  const _PrivacyCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(data.icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.45,
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

// Lock + X marks + arc illustration
class _PrivacyMotifPainter extends CustomPainter {
  final Color primary;
  final Color onSurface;
  final Color outline;

  const _PrivacyMotifPainter({
    required this.primary,
    required this.onSurface,
    required this.outline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.28;

    final arcPaint = Paint()
      ..color = primary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Arc connecting two sides
    final arcPath = Path()
      ..moveTo(size.width * 0.17, size.height * 0.45)
      ..quadraticBezierTo(cx, size.height * 0.06, size.width * 0.83,
          size.height * 0.45);
    canvas.drawPath(arcPath, arcPaint);

    // Dashed arc below
    final dashedPaint = Paint()
      ..color = primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    _drawDashedArc(canvas, size, dashedPaint);

    // X marks
    final xPaint = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    _drawX(canvas, Offset(size.width * 0.14, size.height * 0.22), 6, xPaint);
    _drawX(canvas, Offset(size.width * 0.86, size.height * 0.22), 6, xPaint);

    // Lock body
    final lockPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final lockBodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 6), width: 18, height: 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(lockBodyRect, lockPaint);

    // Lock shackle
    final shacklePath = Path()
      ..moveTo(cx - 5, cy + 6)
      ..lineTo(cx - 5, cy - 2)
      ..arcToPoint(
        Offset(cx + 5, cy - 2),
        radius: const Radius.circular(5),
        clockwise: false,
      )
      ..lineTo(cx + 5, cy + 6);
    canvas.drawPath(shacklePath, lockPaint);

    // Lock keyhole dot
    canvas.drawCircle(
      Offset(cx, cy + 10),
      1.5,
      Paint()..color = primary,
    );

    // Coin stack (simplified)
    _drawCoinStack(canvas, size);
  }

  void _drawDashedArc(Canvas canvas, Size size, Paint paint) {
    const dashCount = 8;
    final cx = size.width / 2;
    for (int i = 0; i < dashCount; i++) {
      final t = i / dashCount;
      final t2 = (i + 0.6) / dashCount;
      final path = Path()
        ..moveTo(
          _arcX(t, size.width, cx),
          _arcY(t, size.height),
        )
        ..lineTo(
          _arcX(t2, size.width, cx),
          _arcY(t2, size.height),
        );
      canvas.drawPath(path, paint);
    }
  }

  double _arcX(double t, double w, double cx) {
    return cx + (t - 0.5) * w * 1.3;
  }

  double _arcY(double t, double h) {
    return h * 0.35 - (1 - (2 * t - 1) * (2 * t - 1)) * h * 0.28;
  }

  void _drawX(Canvas canvas, Offset center, double r, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - r, center.dy - r),
      Offset(center.dx + r, center.dy + r),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + r, center.dy - r),
      Offset(center.dx - r, center.dy + r),
      paint,
    );
  }

  void _drawCoinStack(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final coinPaint = Paint()
      ..color = const Color(0xFFE5A623)
      ..style = PaintingStyle.fill;
    final edgePaint = Paint()
      ..color = const Color(0xFF6B4A0E)
      ..style = PaintingStyle.fill;

    // Draw 3 stacked coins from bottom to top
    for (int i = 2; i >= 0; i--) {
      final y = size.height * 0.74 - i * 9.0;
      final rx = 32.0 - i * 1.0;
      final ry = 8.0;

      // Edge shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, y + 5),
          width: rx * 2,
          height: ry * 1.1,
        ),
        edgePaint,
      );
      // Face
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, y),
          width: rx * 2,
          height: ry * 2,
        ),
        coinPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_PrivacyMotifPainter old) => false;
}

