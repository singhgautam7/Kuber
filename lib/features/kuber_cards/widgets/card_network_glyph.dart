import 'package:flutter/material.dart';

/// An abstracted, non-trademarked mark for a card network, tinted [color]
/// (the card's `onCard` colour). Each network gets a visually distinct mark
/// drawn from simple shapes — never the real brand logo (see
/// `tokens-and-visual-spec.md`).
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
    final w = size;
    final h = size * 0.66;
    final painter = switch (network) {
      'mastercard' => _MastercardPainter(color),
      'visa' => _VisaPainter(color),
      'rupay' => _RupayPainter(color),
      'amex' => _AmexPainter(color),
      'discover' => _DiscoverPainter(color),
      _ => null,
    };
    if (painter == null) return const SizedBox.shrink();
    return SizedBox(width: w, height: h, child: CustomPaint(painter: painter));
  }
}

/// Two overlapping circles (Venn), the classic dual-disc motif.
class _MastercardPainter extends CustomPainter {
  final Color color;
  const _MastercardPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(r * 1.1, cy), r, Paint()..color = color);
    canvas.drawCircle(
      Offset(size.width - r * 1.1, cy),
      r,
      Paint()..color = color.withValues(alpha: 0.72),
    );
  }

  @override
  bool shouldRepaint(_MastercardPainter old) => old.color != color;
}

/// A bold italic wing: a single slanted parallelogram.
class _VisaPainter extends CustomPainter {
  final Color color;
  const _VisaPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bar = Path()
      ..moveTo(w * 0.20, h)
      ..lineTo(w * 0.62, 0)
      ..lineTo(w * 0.90, 0)
      ..lineTo(w * 0.48, h)
      ..close();
    canvas.drawPath(bar, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_VisaPainter old) => old.color != color;
}

/// Two rightward chevrons (»).
class _RupayPainter extends CustomPainter {
  final Color color;
  const _RupayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    void chevron(double x) {
      final p = Path()
        ..moveTo(x, h * 0.15)
        ..lineTo(x + w * 0.22, h * 0.5)
        ..lineTo(x, h * 0.85);
      canvas.drawPath(p, stroke);
    }

    chevron(w * 0.30);
    chevron(w * 0.52);
  }

  @override
  bool shouldRepaint(_RupayPainter old) => old.color != color;
}

/// A filled rounded square with an inset outline (abstract card block).
class _AmexPainter extends CustomPainter {
  final Color color;
  const _AmexPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height;
    final rect = Rect.fromLTWH((size.width - s) / 2, 0, s, s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(s * 0.2)),
      Paint()..color = color,
    );
    // Inset outline reads as a bordered block against the fill.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(s * 0.24), Radius.circular(s * 0.1)),
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.09,
    );
  }

  @override
  bool shouldRepaint(_AmexPainter old) => old.color != color;
}

/// A ring with a filled dot offset to the right (a stylized globe).
class _DiscoverPainter extends CustomPainter {
  final Color color;
  const _DiscoverPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.28,
    );
    canvas.drawCircle(
      Offset(cx + r * 0.5, cy),
      r * 0.45,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_DiscoverPainter old) => old.color != color;
}
