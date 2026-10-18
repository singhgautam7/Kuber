import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formatters.dart';
import '../../settings/providers/settings_provider.dart';

/// Progress of one storyboard row: 0 before [start] ms, 1 after [end] ms,
/// [curve] in between. Same maths as `Interval(start/total, end/total)` on
/// the page controller (storyboards.md › Rules), in milliseconds so the
/// code reads like the storyboard tables.
double seg(
  double ms,
  double start,
  double end, [
  Curve curve = Curves.easeOutCubic,
]) {
  if (ms <= start) return 0;
  if (ms >= end) return 1;
  return curve.transform((ms - start) / (end - start));
}

/// One page's animation stage. One controller, `forward()` once the first
/// time the page is visible in this tour session, never repeated. A page
/// already played (or left mid-way) shows the rest frame. Reduced motion:
/// the controller never runs and [builder] gets `reduced: true`.
class WhyKuberStage extends StatefulWidget {
  final int durationMs;

  /// The page is the one on screen.
  final bool active;

  /// Played earlier in this tour session: start on the rest frame.
  final bool played;
  final VoidCallback? onPlayed;

  /// Read instead of the animation (it is excluded from semantics). Null
  /// when the builder also holds readable text (page 5 labels its own card).
  final String? semanticsLabel;

  /// Fixed text size inside the illustration: it is a picture with fixed
  /// boxes, read through [semanticsLabel]. Page 5 clamps only its card.
  final bool clampText;
  final Widget Function(BuildContext context, double ms, bool reduced) builder;

  const WhyKuberStage({
    super.key,
    required this.durationMs,
    required this.active,
    required this.played,
    required this.builder,
    this.semanticsLabel,
    this.clampText = true,
    this.onPlayed,
  });

  @override
  State<WhyKuberStage> createState() => _WhyKuberStageState();

  /// Page 5's feature lines: stops whatever is playing (the automatic run
  /// included) and plays [fromMs] to [toMs], then holds there. From the
  /// first such tap the stage is manual: a tap on the stage no longer
  /// restarts the whole run. Ignored under reduced motion.
  static void playRange(BuildContext context, double fromMs, double toMs) =>
      context.findAncestorStateOfType<_WhyKuberStageState>()?._play(
        fromMs,
        toMs,
        manual: true,
      );
}

class _WhyKuberStageState extends State<WhyKuberStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.durationMs),
    value: widget.played ? 1 : 0,
  );
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) _c.value = 1;
    _sync();
  }

  @override
  void didUpdateWidget(WhyKuberStage old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (_reduced) return;
    if (widget.active && _c.value == 0 && !_c.isAnimating) {
      _c.forward();
      widget.onPlayed?.call();
    } else if (!widget.active && _c.isAnimating) {
      _c.value = 1; // left mid-animation: jump to the end
    }
  }

  /// Set by the first [WhyKuberStage.playRange] tap.
  bool _manual = false;

  /// Tap on a stopped stage replays it; a manual (feature line) tap
  /// interrupts at once.
  void _play(double fromMs, double toMs, {bool manual = false}) {
    if (_reduced) return;
    if (manual) {
      _manual = true;
      _c.stop();
    } else if (_c.isAnimating || _manual) {
      return;
    }
    final total = widget.durationMs.toDouble();
    _c.value = fromMs / total;
    _c.animateTo(
      toMs / total,
      duration: Duration(milliseconds: (toMs - fromMs).round()),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget animated = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _play(0, widget.durationMs.toDouble()),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              widget.builder(context, _c.value * widget.durationMs, _reduced),
        ),
      ),
    );
    if (widget.clampText) animated = clampedText(animated);
    final label = widget.semanticsLabel;
    if (label == null) return animated;
    return Semantics(
      label: label,
      child: ExcludeSemantics(child: animated),
    );
  }
}

/// Sample data formatting shared by the five pages: the user's currency
/// (non-INR amounts are the INR sample divided by 20, so ₹250 → $12.50) and
/// locale dates. Built once per page build, never per frame.
class WhyKuberDemo {
  final AppFormatter fmt;
  final String symbol;
  final bool inr;
  final DateFormat _dayMonth;
  final DateFormat _month;

  WhyKuberDemo._(this.fmt, this.symbol, this.inr, this._dayMonth, this._month);

  factory WhyKuberDemo.of(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    DateFormat df(String p) {
      try {
        return DateFormat(p, locale);
      } catch (_) {
        return DateFormat(p);
      }
    }

    return WhyKuberDemo._(
      ref.watch(formatterProvider),
      currency.symbol,
      currency.code == 'INR',
      df('d MMM'),
      df('MMM'),
    );
  }

  num value(num inrValue) => inr ? inrValue : inrValue / 20;

  /// Sample amount in the user's currency.
  String money(num inrValue) =>
      fmt.formatCurrency(value(inrValue), symbol: symbol);

  /// Plain grouped number (note lines).
  String number(num inrValue) => fmt.formatNumber(value(inrValue));

  String day(int month, int day) =>
      _dayMonth.format(DateTime(2026, month, day));
  String month(int month) => _month.format(DateTime(2026, month));
}

/// Illustration text keeps its design size at any system font scale.
Widget clampedText(Widget child) => MediaQuery.withNoTextScaling(child: child);

/// Opacity plus a vertical offset (the "rises N px and fades in" rows).
Widget fadeUp(double p, double dy, Widget child) => Opacity(
  opacity: p.clamp(0.0, 1.0),
  child: Transform.translate(offset: Offset(0, dy * (1 - p)), child: child),
);

/// Draws the first [progress] of [path] (lines that draw left to right).
void drawPathPortion(Canvas canvas, Path path, double progress, Paint paint) {
  if (progress <= 0) return;
  for (final PathMetric m in path.computeMetrics()) {
    canvas.drawPath(
      m.extractPath(0, m.length * progress.clamp(0.0, 1.0)),
      paint,
    );
  }
}

/// Dashed rounded-rect outline (the "New" category chip).
class DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double opacity;
  const DashedRRectPainter(this.color, this.radius, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedRRectPainter old) =>
      old.color != color || old.opacity != opacity;
}

/// Small category tile used across the pages.
class DemoTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const DemoTile(this.icon, this.color, {super.key, this.size = 32});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(size * 0.3),
    ),
    child: Icon(icon, size: size * 0.56, color: color),
  );
}
