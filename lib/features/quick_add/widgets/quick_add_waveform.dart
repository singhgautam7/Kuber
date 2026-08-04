import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Amplitude-driven waveform for the voice overlay. A single repeating
/// controller drives the idle shimmer; live mic amplitude scales the bars.
/// Wrapped in a RepaintBoundary and painted with a CustomPainter so only this
/// box repaints per frame — never the whole overlay. No visualization package.
class QuickAddWaveform extends StatefulWidget {
  final ValueListenable<double> amplitude; // 0..1
  final bool frozen; // processing: freeze + desaturate
  final bool reducedMotion; // static bars + single pulsing dot
  final Color color;

  const QuickAddWaveform({
    super.key,
    required this.amplitude,
    required this.color,
    this.frozen = false,
    this.reducedMotion = false,
  });

  static const _barCount = 30;

  @override
  State<QuickAddWaveform> createState() => _QuickAddWaveformState();
}

class _QuickAddWaveformState extends State<QuickAddWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (!widget.reducedMotion) _controller.repeat();
  }

  @override
  void didUpdateWidget(QuickAddWaveform old) {
    super.didUpdateWidget(old);
    if (widget.frozen || widget.reducedMotion) {
      if (_controller.isAnimating) _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reducedMotion) {
      return RepaintBoundary(
        child: CustomPaint(
          size: const Size(double.infinity, 88),
          painter: _WavePainter(
            phase: 0,
            amplitude: 0.5,
            frozen: widget.frozen,
            reducedMotion: true,
            color: widget.color,
            barCount: QuickAddWaveform._barCount,
          ),
        ),
      );
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, widget.amplitude]),
        builder: (context, _) {
          return CustomPaint(
            size: const Size(double.infinity, 88),
            painter: _WavePainter(
              phase: _controller.value,
              amplitude: widget.frozen ? 0.35 : widget.amplitude.value,
              frozen: widget.frozen,
              reducedMotion: false,
              color: widget.color,
              barCount: QuickAddWaveform._barCount,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase; // 0..1
  final double amplitude; // 0..1
  final bool frozen;
  final bool reducedMotion;
  final Color color;
  final int barCount;

  _WavePainter({
    required this.phase,
    required this.amplitude,
    required this.frozen,
    required this.reducedMotion,
    required this.color,
    required this.barCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 4.0;
    final slot = size.width / barCount;
    final centerY = size.height / 2;
    final paint = Paint()
      ..color = frozen ? color.withValues(alpha: 0.6) : color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < barCount; i++) {
      // Per-bar phase so the shimmer travels along the row.
      final barPhase = phase * 2 * math.pi + i * 0.55;
      // Envelope: taller toward the center, gentler at the edges.
      final edge = 1 - (2 * i / (barCount - 1) - 1).abs();
      final envelope = 0.35 + 0.65 * edge;

      double factor;
      if (reducedMotion) {
        // Static varied heights, no per-bar motion.
        factor = 0.25 + 0.55 * (0.5 + 0.5 * math.sin(i * 1.3));
      } else {
        final shimmer = 0.5 + 0.5 * math.sin(barPhase);
        // Amplitude dominates when there's signal; shimmer is the idle floor.
        factor = (0.18 + shimmer * 0.32) + amplitude * 0.9 * envelope;
      }
      factor = factor.clamp(0.05, 1.0);

      final barHeight = (size.height * 0.9) * factor;
      final x = i * slot + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, centerY - barHeight / 2, barWidth, barHeight),
        const Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }

    if (reducedMotion) {
      // Single pulsing dot cue (drawn static here; the overlay can pulse it).
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(size.width / 2, size.height + 14), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.phase != phase ||
      old.amplitude != amplitude ||
      old.frozen != frozen ||
      old.color != color;
}
