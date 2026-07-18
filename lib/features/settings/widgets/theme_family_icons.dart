import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Squircle icon for a theme family, per the personalization icons spec:
/// 44x44 container, 12dp radius, fill = family accent at 12%, line-style glyph
/// at full accent strength. Glyph geometry is transcribed from the reference
/// SVGs in specs/design/kuber-theme/.../icons.md (24-unit viewBox, 1.75
/// stroke, round caps/joins).
class ThemeFamilyIcon extends StatelessWidget {
  final ThemeVariant variant;
  final double size;

  const ThemeFamilyIcon({super.key, required this.variant, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final tokens = KuberTokens.of(variant, Theme.of(context).brightness);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tokens.primarySubtle,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size.square(size * 24 / 44),
        painter: _GlyphPainter(variant: variant, color: tokens.primary),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  final ThemeVariant variant;
  final Color color;

  const _GlyphPainter({required this.variant, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (variant) {
      case ThemeVariant.signature:
        _rupee(canvas, stroke);
      case ThemeVariant.flewtube:
        _parrot(canvas, stroke, fill);
      case ThemeVariant.woofsapp:
        _dog(canvas, stroke, fill);
      case ThemeVariant.purrhub:
        _cat(canvas, stroke);
      case ThemeVariant.honkpe:
        _goose(canvas, stroke, fill);
      case ThemeVariant.squeakdin:
        _mouse(canvas, stroke, fill);
      case ThemeVariant.oinkzon:
        _pig(canvas, stroke, fill);
    }
  }

  void _rupee(Canvas c, Paint stroke) {
    c.drawLine(const Offset(6, 3), const Offset(18, 3), stroke);
    c.drawLine(const Offset(6, 8), const Offset(18, 8), stroke);
    final bowl = Path()
      ..moveTo(9, 3)
      ..cubicTo(15.5, 3, 15.5, 13, 9, 13)
      ..lineTo(6, 13);
    c.drawPath(bowl, stroke);
    c.drawLine(const Offset(6, 13), const Offset(14.5, 21), stroke);
  }

  void _parrot(Canvas c, Paint stroke, Paint fill) {
    final body = Path()
      ..moveTo(8, 6)
      ..cubicTo(11, 5, 15, 6, 16, 9)
      ..cubicTo(17, 12, 15, 15, 12, 16)
      ..cubicTo(9, 17, 6, 15, 6, 12)
      ..cubicTo(6, 10, 7, 8, 8, 6)
      ..close();
    c.drawPath(body, stroke);
    final beak = Path()
      ..moveTo(8, 8)
      ..cubicTo(6.5, 8, 5, 9, 5, 10.5)
      ..cubicTo(5, 12, 6.5, 13, 8, 12);
    c.drawPath(beak, stroke);
    c.drawCircle(const Offset(10.5, 9), 0.6, fill);
    c.drawLine(const Offset(14, 16), const Offset(17, 20), stroke);
    c.drawLine(const Offset(13, 5), const Offset(14, 3), stroke);
  }

  void _dog(Canvas c, Paint stroke, Paint fill) {
    final head = Path()
      ..moveTo(7, 12)
      ..cubicTo(7, 9, 9, 7, 12, 7)
      ..cubicTo(15, 7, 17, 9, 17, 12)
      ..lineTo(17, 15)
      ..cubicTo(17, 17, 15, 18, 12, 18)
      ..cubicTo(9, 18, 7, 17, 7, 15)
      ..close();
    c.drawPath(head, stroke);
    final earL = Path()
      ..moveTo(6, 7)
      ..cubicTo(5, 9, 5, 11, 6, 13);
    c.drawPath(earL, stroke);
    final earR = Path()
      ..moveTo(18, 7)
      ..cubicTo(19, 9, 19, 11, 18, 13);
    c.drawPath(earR, stroke);
    final snout = Path()
      ..moveTo(10, 15)
      ..cubicTo(11, 16, 13, 16, 14, 15);
    c.drawPath(snout, stroke);
    c.drawCircle(const Offset(12, 13.5), 0.7, fill);
    c.drawCircle(const Offset(10, 11), 0.5, fill);
    c.drawCircle(const Offset(14, 11), 0.5, fill);
  }

  void _cat(Canvas c, Paint stroke) {
    final earL = Path()
      ..moveTo(6, 9)
      ..lineTo(8, 5)
      ..lineTo(11, 8);
    c.drawPath(earL, stroke);
    final earR = Path()
      ..moveTo(18, 9)
      ..lineTo(16, 5)
      ..lineTo(13, 8);
    c.drawPath(earR, stroke);
    final head = Path()
      ..moveTo(6, 12)
      ..cubicTo(6, 10, 9, 8, 12, 8)
      ..cubicTo(15, 8, 18, 10, 18, 12)
      ..lineTo(18, 15)
      ..cubicTo(18, 17, 15, 19, 12, 19)
      ..cubicTo(9, 19, 6, 17, 6, 15)
      ..close();
    c.drawPath(head, stroke);
    c.drawLine(const Offset(10, 13), const Offset(10, 14), stroke);
    c.drawLine(const Offset(14, 13), const Offset(14, 14), stroke);
    c.drawLine(const Offset(12, 15), const Offset(12, 16), stroke);
    final mouth = Path()
      ..moveTo(11, 17)
      ..cubicTo(11.5, 17.4, 12.5, 17.4, 13, 17);
    c.drawPath(mouth, stroke);
    c.drawLine(const Offset(8, 15), const Offset(6, 15), stroke);
    c.drawLine(const Offset(16, 15), const Offset(18, 15), stroke);
  }

  void _goose(Canvas c, Paint stroke, Paint fill) {
    final body = Path()
      ..moveTo(6, 16)
      ..cubicTo(6, 13, 9, 11, 12, 11)
      ..cubicTo(15, 11, 18, 13, 18, 16)
      ..cubicTo(18, 17, 17, 18, 16, 18)
      ..lineTo(8, 18)
      ..cubicTo(7, 18, 6, 17, 6, 16)
      ..close();
    c.drawPath(body, stroke);
    final neck = Path()
      ..moveTo(9, 12)
      ..cubicTo(9, 9, 9, 6, 11, 4);
    c.drawPath(neck, stroke);
    c.drawCircle(const Offset(11.5, 4), 1.6, stroke);
    c.drawLine(const Offset(13, 4), const Offset(15.5, 4), stroke);
    c.drawCircle(const Offset(11.5, 4), 0.4, fill);
    c.drawLine(const Offset(18, 15), const Offset(20, 14), stroke);
  }

  void _mouse(Canvas c, Paint stroke, Paint fill) {
    c.drawCircle(const Offset(7, 8), 2.5, stroke);
    c.drawCircle(const Offset(17, 8), 2.5, stroke);
    final head = Path()
      ..moveTo(6, 13)
      ..cubicTo(6, 11, 9, 10, 12, 10)
      ..cubicTo(15, 10, 18, 11, 18, 13)
      ..lineTo(18, 16)
      ..cubicTo(18, 18, 15, 19, 12, 19)
      ..cubicTo(9, 19, 6, 18, 6, 16)
      ..close();
    c.drawPath(head, stroke);
    c.drawCircle(const Offset(10, 14), 0.5, fill);
    c.drawCircle(const Offset(14, 14), 0.5, fill);
    c.drawCircle(const Offset(12, 16), 0.6, fill);
    final tail = Path()
      ..moveTo(18, 18)
      ..cubicTo(20, 18, 21, 19, 21, 21);
    c.drawPath(tail, stroke);
  }

  void _pig(Canvas c, Paint stroke, Paint fill) {
    final earL = Path()
      ..moveTo(7, 8)
      ..lineTo(8, 5)
      ..lineTo(10, 7);
    c.drawPath(earL, stroke);
    final earR = Path()
      ..moveTo(17, 8)
      ..lineTo(16, 5)
      ..lineTo(14, 7);
    c.drawPath(earR, stroke);
    final head = Path()
      ..moveTo(6, 12)
      ..cubicTo(6, 9, 9, 7, 12, 7)
      ..cubicTo(15, 7, 18, 9, 18, 12)
      ..lineTo(18, 15)
      ..cubicTo(18, 18, 15, 20, 12, 20)
      ..cubicTo(9, 20, 6, 18, 6, 15)
      ..close();
    c.drawPath(head, stroke);
    c.drawOval(
      Rect.fromCenter(center: const Offset(12, 15), width: 5, height: 3),
      stroke,
    );
    c.drawCircle(const Offset(11, 15), 0.45, fill);
    c.drawCircle(const Offset(13, 15), 0.45, fill);
    c.drawCircle(const Offset(10, 12), 0.5, fill);
    c.drawCircle(const Offset(14, 12), 0.5, fill);
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.variant != variant || old.color != color;
}
