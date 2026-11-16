import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../common/ah_motion.dart';

/// Share bar: the M3 Expressive wavy progress (amplitude 3, wavelength 24,
/// 4 dp stroke) in the group colour, a 4 dp track after a 4 dp gap and a stop
/// dot. Grows from 0 with the expressive spring, [delay] after mount
/// (30 ms apart, first 8 rows). Reduced motion: drawn at full length.
class AhShareBar extends StatefulWidget {
  const AhShareBar({
    super.key,
    required this.share,
    required this.color,
    required this.track,
    this.delay = Duration.zero,
  });
  final double share;
  final Color color;
  final Color track;
  final Duration delay;

  @override
  State<AhShareBar> createState() => _AhShareBarState();
}

class _AhShareBarState extends State<AhShareBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: AhMotion.defaultCurve.settle);
  Timer? _t;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AhMotion.reduced(context)) {
      _c.value = 1;
    } else if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _t = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = CurvedAnimation(parent: _c, curve: AhMotion.defaultCurve);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: v,
        builder: (context, _) => CustomPaint(
          size: const Size(double.infinity, 12),
          painter: _WavyPainter(
              widget.share.clamp(0.0, 1.0) * v.value.clamp(0.0, 1.0),
              widget.color,
              widget.track),
        ),
      ),
    );
  }
}

class _WavyPainter extends CustomPainter {
  _WavyPainter(this.p, this.color, this.track);
  final double p;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 4.0, amp = 3.0, wave = 24.0, gap = 4.0;
    final y = size.height / 2;
    final endX = size.width * p;
    final cap = StrokeCap.round;
    if (endX > 0.5) {
      final path = Path()..moveTo(0, y);
      for (var x = 1.0; x <= endX; x += 1) {
        path.lineTo(x, y + amp * math.sin(x / wave * 2 * math.pi) * math.min(1, x / 12));
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = cap);
    }
    final tx = endX + gap + (endX > 0.5 ? stroke / 2 : 0);
    if (tx < size.width - stroke) {
      canvas.drawLine(
          Offset(tx, y),
          Offset(size.width - stroke, y),
          Paint()
            ..color = track
            ..strokeWidth = stroke
            ..strokeCap = cap);
    }
    canvas.drawCircle(Offset(size.width - stroke / 2, y), stroke / 2,
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WavyPainter o) =>
      o.p != p || o.color != color || o.track != track;
}
