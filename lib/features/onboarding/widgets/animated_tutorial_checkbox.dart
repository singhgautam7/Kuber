import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class AnimatedTutorialCheckbox extends StatefulWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;

  const AnimatedTutorialCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
  });

  @override
  State<AnimatedTutorialCheckbox> createState() =>
      _AnimatedTutorialCheckboxState();
}

class _AnimatedTutorialCheckboxState extends State<AnimatedTutorialCheckbox>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkProgress;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _checkProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeOut),
    );
    if (widget.checked) _checkController.value = 1.0;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _pulseController.forward();
      });
    });
  }

  @override
  void didUpdateWidget(AnimatedTutorialCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.checked != old.checked) {
      if (widget.checked) {
        _checkController.forward();
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.checked),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_pulseScale, _pulseOpacity]),
                    builder: (context, _) {
                      if (!_pulseController.isAnimating &&
                          _pulseController.value == 0) {
                        return const SizedBox.shrink();
                      }
                      return Transform.scale(
                        scale: _pulseScale.value,
                        child: Opacity(
                          opacity: _pulseOpacity.value,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(KuberRadius.sm),
                              border:
                                  Border.all(color: cs.primary, width: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _checkProgress,
                    builder: (context, _) {
                      return CustomPaint(
                        size: const Size(22, 22),
                        painter: _CheckboxPainter(
                          progress: _checkProgress.value,
                          checked: widget.checked,
                          primaryColor: cs.primary,
                          borderRadius: KuberRadius.sm,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Show me how to use Kuber',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'A quick walkthrough after setup',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _CheckboxPainter extends CustomPainter {
  final double progress;
  final bool checked;
  final Color primaryColor;
  final double borderRadius;

  const _CheckboxPainter({
    required this.progress,
    required this.checked,
    required this.primaryColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Fill
    final fillPaint = Paint()
      ..color = checked
          ? Color.lerp(Colors.transparent, primaryColor, progress)!
          : Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    // Border
    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);

    // Checkmark
    if (progress > 0) {
      final checkPaint = Paint()
        ..color = Colors.white.withValues(alpha: progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final w = size.width;
      final h = size.height;

      // Checkmark: start at ~(0.2, 0.5), go to (0.4, 0.7), go to (0.8, 0.3)
      final p1 = Offset(w * 0.2, h * 0.5);
      final p2 = Offset(w * 0.42, h * 0.72);
      final p3 = Offset(w * 0.8, h * 0.28);

      path.moveTo(p1.dx, p1.dy);

      final midT = 0.5;
      if (progress <= midT) {
        final t = progress / midT;
        final mid = Offset.lerp(p1, p2, t)!;
        path.lineTo(mid.dx, mid.dy);
      } else {
        path.lineTo(p2.dx, p2.dy);
        final t = (progress - midT) / midT;
        final end = Offset.lerp(p2, p3, t)!;
        path.lineTo(end.dx, end.dy);
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_CheckboxPainter old) =>
      old.progress != progress || old.checked != checked;
}
