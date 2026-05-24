// Net Worth hero card for the Accounts page.
//
// Replaces the old `_NetWorthCard` — a flat "TOTAL NET WORTH + Assets/Debt
// legend" arrangement — with a richer hero element:
//
//   - Eyebrow + month pill (date stamp gives the hero temporal context)
//   - Big amount paired with a tinted trend pill (+/- vs last month)
//   - 6-month sparkline (lightweight CustomPainter, no fl_chart needed)
//   - Calm Assets/Debt breakdown via a single divided bar + paired figures
//
// All values via `Theme.of(context).colorScheme`. No drop shadows — depth is
// borders + a soft inset accent disc behind the sparkline.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

class NetWorthHeroCard extends ConsumerWidget {
  final double netWorth;
  final double totalAssets;
  final double totalDebt;

  /// Optional 6-month history. Order: oldest → newest, last entry == current.
  /// If omitted, a placeholder gentle-uptrend curve is drawn. Production
  /// wiring should pass a real series from a `netWorthHistoryProvider`
  /// (TODO — compute from transactions grouped by month).
  final List<double>? history;

  /// % change vs last month. Pass `null` to hide the trend pill.
  final double? trendPercent;

  /// Absolute change vs last month, in the user's currency.
  final double? trendAbsolute;

  const NetWorthHeroCard({
    super.key,
    required this.netWorth,
    required this.totalAssets,
    required this.totalDebt,
    this.history,
    this.trendPercent,
    this.trendAbsolute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    // Placeholder history — produces a gently rising curve so the hero
    // doesn't look empty before the real provider lands. Replace as
    // documented above.
    final series =
        history ??
        List.generate(6, (i) {
          final t = i / 5.0; // 0..1
          final base = netWorth * 0.78;
          return base + (netWorth - base) * (t * t * (3 - 2 * t));
        });

    final hasTrend = trendPercent != null && trendAbsolute != null;
    final trendUp = (trendPercent ?? 0) >= 0;
    final trendColor = trendUp ? cs.tertiary : cs.error;
    final trendBg = trendUp
        ? cs.tertiary.withValues(alpha: 0.12)
        : cs.error.withValues(alpha: 0.12);

    final monthLabel = DateFormat(
      'MMM yyyy',
    ).format(DateTime.now()).toUpperCase();

    final total = totalAssets + totalDebt;
    final assetPct = total <= 0 ? 0.0 : (totalAssets / total).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.xl),
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Soft accent disc, mirrors the dashboard's hero treatment.
          Positioned(
            top: -60,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Top: eyebrow + month + amount + trend -----------------
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'TOTAL NET WORTH',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        _MonthPill(label: monthLabel),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            maskAmount(
                              '${netWorth < 0 ? '−' : ''}${fmt.formatCurrency(netWorth.abs())}',
                              masked,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: netWorth < 0 ? cs.error : cs.onSurface,
                              letterSpacing: -1,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (hasTrend)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 8),
                            child: _TrendPill(
                              up: trendUp,
                              percent: trendPercent!,
                              color: trendColor,
                              bg: trendBg,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasTrend
                          ? '${trendAbsolute! >= 0 ? '+' : '−'}'
                                '${maskAmount(fmt.formatCurrency(trendAbsolute!.abs()), masked)}'
                                ' vs last month  ·  6-month trend'
                          : '6-month trend',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Sparkline -----------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                child: SizedBox(
                  height: 76,
                  child: CustomPaint(
                    painter: _SparklinePainter(
                      data: series,
                      lineColor: cs.primary,
                      fillColor: cs.primary.withValues(alpha: 0.18),
                      dotRingColor: cs.surfaceContainer,
                      tickColor: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      labels: _last6MonthLabels(),
                    ),
                  ),
                ),
              ),

              // --- Assets / Debt breakdown ---------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(KuberRadius.lg),
                    border: Border.all(color: cs.outline),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Divided bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 8,
                          child: Row(
                            children: [
                              Expanded(
                                flex: (assetPct * 1000).round().clamp(1, 1000),
                                child: ColoredBox(color: cs.tertiary),
                              ),
                              if (totalDebt > 0)
                                Expanded(
                                  flex: ((1 - assetPct) * 1000).round().clamp(
                                    1,
                                    1000,
                                  ),
                                  child: ColoredBox(color: cs.error),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _LegendBlock(
                              dotColor: cs.tertiary,
                              label: 'Assets',
                              value: maskAmount(
                                fmt.formatCurrency(totalAssets),
                                masked,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _LegendBlock(
                              dotColor: cs.error,
                              label: 'Debt',
                              value: maskAmount(
                                fmt.formatCurrency(totalDebt),
                                masked,
                              ),
                              alignEnd: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static List<String> _last6MonthLabels() {
    final now = DateTime.now();
    final fmt = DateFormat('MMM');
    return List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i), 1);
      return fmt.format(m).toUpperCase();
    });
  }
}

class _MonthPill extends StatelessWidget {
  final String label;
  const _MonthPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TrendPill extends StatelessWidget {
  final bool up;
  final double percent;
  final Color color;
  final Color bg;
  const _TrendPill({
    required this.up,
    required this.percent,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KuberRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${up ? '+' : '−'}${percent.abs().toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendBlock extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String value;
  final bool alignEnd;
  const _LegendBlock({
    required this.dotColor,
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final alignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final rowAlignment = alignEnd
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: rowAlignment,
          children: [
            if (!alignEnd) ...[_Dot(color: dotColor), const SizedBox(width: 6)],
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            if (alignEnd) ...[const SizedBox(width: 6), _Dot(color: dotColor)],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Lightweight sparkline painter — line + area fill + tick labels +
/// current-value ring dot. No external chart package.
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final Color dotRingColor;
  final Color tickColor;
  final List<String> labels;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.dotRingColor,
    required this.tickColor,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    const tickAreaH = 14.0;
    const padTop = 6.0;
    final plotH = size.height - tickAreaH - padTop;

    final minV = data.reduce((a, b) => a < b ? a : b);
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1 : (maxV - minV);

    Offset pt(int i) {
      final x = i * size.width / (data.length - 1);
      final yNorm = (data[i] - minV) / range;
      final y = padTop + plotH * (1 - yNorm);
      return Offset(x, y);
    }

    final path = Path();
    final fillPath = Path()..moveTo(0, padTop + plotH);
    for (int i = 0; i < data.length; i++) {
      final p = pt(i);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        // Catmull-Rom-ish smoothing via cubic
        final prev = pt(i - 1);
        final cx1 = (prev.dx + p.dx) / 2;
        final cx2 = (prev.dx + p.dx) / 2;
        path.cubicTo(cx1, prev.dy, cx2, p.dy, p.dx, p.dy);
      }
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, padTop + plotH);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, padTop, size.width, plotH));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Current-value dot (ring + fill, blended into the card surface)
    final last = pt(data.length - 1);
    canvas.drawCircle(last, 5, Paint()..color = dotRingColor);
    canvas.drawCircle(last, 3, Paint()..color = lineColor);

    // Tick labels (oldest → newest)
    if (labels.length == data.length) {
      final tp = TextPainter(textDirection: TextDirection.ltr);
      final style = TextStyle(
        fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
        fontSize: 9,
        color: tickColor,
        letterSpacing: 0.3,
      );
      for (int i = 0; i < labels.length; i++) {
        final x = i * size.width / (data.length - 1);
        tp.text = TextSpan(text: labels[i], style: style);
        tp.layout();
        var dx = x - tp.width / 2;
        if (i == 0) dx = 0;
        if (i == labels.length - 1) dx = size.width - tp.width;
        tp.paint(canvas, Offset(dx, size.height - tickAreaH + 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      !identical(old.data, data) || old.lineColor != lineColor;
}
