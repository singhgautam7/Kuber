import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An abstracted, non-trademarked mark for a card network, tinted [color]
/// (the card's `onCard` colour). Each network gets a visually distinct mark
/// drawn from simple shapes — never the real brand logo. The exact shapes
/// mirror the `Kuber Cards.dc.html` anatomy panel (Section 08, NETWORK GLYPHS)
/// per `tokens-and-visual-spec.md`.
class CardNetworkGlyph extends StatelessWidget {
  final String? network; // 'visa' | 'mastercard' | 'rupay' | 'amex' | ...
  final Color color;
  final double size;

  const CardNetworkGlyph({
    super.key,
    required this.network,
    required this.color,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final painter = switch (network) {
      'mastercard' => _MastercardPainter(color),
      'visa' => _VisaPainter(color),
      'rupay' => _RupayPainter(color),
      'amex' => _AmexPainter(color),
      'discover' => _DiscoverPainter(color),
      _ => null,
    };
    if (painter == null) return const SizedBox.shrink();
    // A single glyph box; each painter fits its native art (contain) centred
    // inside, so networks with different aspect ratios read at a matched
    // visual weight bottom-right of the card.
    return SizedBox(
      width: size,
      height: size * 0.64,
      child: CustomPaint(painter: painter),
    );
  }
}

/// Scales a `[0..vbW] x [0..vbH]` viewBox to fit (contain) inside [box],
/// centred, then runs [draw] in viewBox coordinates. Stroke widths defined in
/// viewBox units scale with the fit, matching the SVG source.
void _fit(
  Canvas canvas,
  Size box,
  double vbW,
  double vbH,
  void Function(Canvas) draw,
) {
  final scale = math.min(box.width / vbW, box.height / vbH);
  final dx = (box.width - vbW * scale) / 2;
  final dy = (box.height - vbH * scale) / 2;
  canvas
    ..save()
    ..translate(dx, dy)
    ..scale(scale);
  draw(canvas);
  canvas.restore();
}

/// Two overlapping circles (85% / 50%), the classic dual-disc motif.
class _MastercardPainter extends CustomPainter {
  final Color color;
  const _MastercardPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Two discs of diameter 20; the second overlaps left by 0.45×, so the
    // combined viewBox is 31 × 20.
    _fit(canvas, size, 31, 20, (c) {
      c.drawCircle(
          const Offset(10, 10), 10, Paint()..color = color.withValues(alpha: 0.85));
      c.drawCircle(
          const Offset(21, 10), 10, Paint()..color = color.withValues(alpha: 0.50));
    });
  }

  @override
  bool shouldRepaint(_MastercardPainter old) => old.color != color;
}

/// Two `>` chevrons (95% / 55%), the block skewed 11° left for an italic lean.
class _VisaPainter extends CustomPainter {
  final Color color;
  const _VisaPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 32, 20, (c) {
      // skewX(-11deg) about the vertical centre.
      c
        ..translate(0, 10)
        ..skew(math.tan(-11 * math.pi / 180), 0)
        ..translate(0, -10);
      Paint stroke(double a) => Paint()
        ..color = color.withValues(alpha: a)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      c.drawPath(
        Path()
          ..moveTo(4, 3)
          ..lineTo(12, 10)
          ..lineTo(4, 17),
        stroke(0.95),
      );
      c.drawPath(
        Path()
          ..moveTo(15, 3)
          ..lineTo(23, 10)
          ..lineTo(15, 17),
        stroke(0.55),
      );
    });
  }

  @override
  bool shouldRepaint(_VisaPainter old) => old.color != color;
}

/// A filled triangle (95%) followed by an outlined chevron (55%).
class _RupayPainter extends CustomPainter {
  final Color color;
  const _RupayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 32, 20, (c) {
      c.drawPath(
        Path()
          ..moveTo(4, 3)
          ..lineTo(18, 10)
          ..lineTo(4, 17)
          ..close(),
        Paint()..color = color.withValues(alpha: 0.95),
      );
      c.drawPath(
        Path()
          ..moveTo(18, 3)
          ..lineTo(27, 10)
          ..lineTo(18, 17),
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    });
  }

  @override
  bool shouldRepaint(_RupayPainter old) => old.color != color;
}

/// A rounded outlined square (16% fill, 85% border) with a small centred fill
/// (centurion-box abstraction).
class _AmexPainter extends CustomPainter {
  final Color color;
  const _AmexPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // 25 × 20 rounded rect; 1.5px border inset so the stroke stays inside.
    _fit(canvas, size, 25, 20, (c) {
      final r = RRect.fromRectAndRadius(
        const Rect.fromLTWH(0.75, 0.75, 23.5, 18.5),
        const Radius.circular(3),
      );
      c.drawRRect(r, Paint()..color = color.withValues(alpha: 0.16));
      c.drawRRect(
        r,
        Paint()
          ..color = color.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      c.drawRect(
        const Rect.fromLTWH(8.5, 6, 8, 8),
        Paint()..color = color.withValues(alpha: 0.90),
      );
    });
  }

  @override
  bool shouldRepaint(_AmexPainter old) => old.color != color;
}

/// A single filled disc with a bright top-edge highlight.
class _DiscoverPainter extends CustomPainter {
  final Color color;
  const _DiscoverPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _fit(canvas, size, 20, 20, (c) {
      c.drawCircle(
          const Offset(10, 10), 9, Paint()..color = color.withValues(alpha: 0.85));
      // Bright top-edge arc.
      c.drawArc(
        Rect.fromCircle(center: const Offset(10, 10), radius: 9),
        math.pi * 1.15,
        math.pi * 0.7,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    });
  }

  @override
  bool shouldRepaint(_DiscoverPainter old) => old.color != color;
}
