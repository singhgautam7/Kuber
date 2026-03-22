import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';

class RecurringLoaderScreen extends ConsumerStatefulWidget {
  const RecurringLoaderScreen({super.key});

  @override
  ConsumerState<RecurringLoaderScreen> createState() =>
      _RecurringLoaderScreenState();
}

class _RecurringLoaderScreenState extends ConsumerState<RecurringLoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && !_navigating) {
        _navigating = true;
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(recurringProcessResultProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: KuberColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated sync ring
              SizedBox(
                width: 96,
                height: 96,
                child: _SweepRingWidget(
                  controller: _controller,
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),

              Text(
                'Processing Recurring',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KuberColors.textPrimary,
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              Text(
                'Creating missed transactions...',
                style: textTheme.bodyMedium?.copyWith(
                  color: KuberColors.textSecondary,
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),

              // Status pills
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusPill(label: 'NETWORK', value: 'Local Only'),
                  const SizedBox(width: KuberSpacing.md),
                  _StatusPill(
                    label: 'PROCESSED',
                    value: '$count transaction${count == 1 ? '' : 's'}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SweepRingWidget extends AnimatedWidget {
  final AnimationController controller;

  const _SweepRingWidget({required this.controller})
      : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SweepRingPainter(progress: controller.value),
      child: const Center(
        child: Icon(
          Icons.sync_rounded,
          color: KuberColors.primary,
          size: 36,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatusPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.md,
        vertical: KuberSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: KuberColors.surfaceMuted,
        borderRadius: BorderRadius.circular(KuberRadius.full),
        border: Border.all(color: KuberColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: KuberColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: KuberColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SweepRingPainter extends CustomPainter {
  final double progress;

  _SweepRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background ring
    final bgPaint = Paint()
      ..color = KuberColors.surfaceMuted
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
          KuberColors.primary.withValues(alpha: 0.0),
          KuberColors.primary,
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
  bool shouldRepaint(_SweepRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
