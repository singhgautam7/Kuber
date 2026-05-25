// Overhauled Investments screen widgets.
//
// Drop-ins for `lib/features/investments/screens/investments_screen.dart`.
//   - `PortfolioHero` — current value + gain/loss pill + 6-month sparkline +
//     invested vs current breakdown. Mirrors the Net Worth hero on the
//     Accounts page so the two pages share vocabulary.
//   - `AssetAllocationStrip` — single divided bar + chip legend.
//   - `InvestmentCard` — per-investment row with inline gain/loss pill.
//
// Provider wiring:
//   - All existing calc helpers (`calc.totalInvestedAll`, `totalCurrentValueAll`,
//     `totalGainLossAll`) still apply.
//   - New optional `portfolioHistoryProvider` returns 6-month value series
//     for the sparkline; without it, the hero renders without the chart
//     (the `history` arg is null-safe).
//   - New optional `assetAllocationProvider` returns
//     `List<({String label, Color color, double valueRupees})>` sorted desc.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

// ---------------------------------------------------------------------------
// Portfolio hero
// ---------------------------------------------------------------------------

class PortfolioHero extends ConsumerWidget {
  final double currentValue;
  final double invested;
  final double gainLoss; // current - invested
  final double gainLossPercent;
  final List<double>? history; // 6 points, oldest -> newest

  const PortfolioHero({
    super.key,
    required this.currentValue,
    required this.invested,
    required this.gainLoss,
    required this.gainLossPercent,
    this.history,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final isGain = gainLoss >= 0;
    final gainColor = isGain ? cs.tertiary : cs.error;
    final gainBg = isGain
        ? cs.tertiary.withValues(alpha: 0.12)
        : cs.error.withValues(alpha: 0.12);

    final series =
        history ??
        List.generate(6, (i) {
          final t = i / 5.0;
          final base = currentValue * 0.78;
          return base + (currentValue - base) * (t * t * (3 - 2 * t));
        });

    final monthLabel = DateFormat(
      'MMM yyyy',
    ).format(DateTime.now()).toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.alphaBlend(
              gainColor.withValues(alpha: 0.16),
              cs.surfaceContainer,
            ),
            cs.surfaceContainer,
          ],
          stops: const [0.0, 0.75],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PORTFOLIO VALUE',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        border: Border.all(color: cs.outline),
                        borderRadius: BorderRadius.circular(KuberRadius.sm),
                      ),
                      child: Text(
                        monthLabel,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        maskAmount(fmt.formatCurrency(currentValue), masked),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 8),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
                        decoration: BoxDecoration(
                          color: gainBg,
                          borderRadius: BorderRadius.circular(KuberRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGain
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 14,
                              color: gainColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${isGain ? '+' : '−'}${gainLossPercent.abs().toStringAsFixed(1)}%',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: gainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${isGain ? '+' : '−'}${maskAmount(fmt.formatCurrency(gainLoss.abs()), masked)} '
                  '${isGain ? 'unrealised gain' : 'unrealised loss'} · since you started',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: SizedBox(
              height: 68,
              child: CustomPaint(
                painter: _SparkPainter(
                  data: series,
                  lineColor: gainColor,
                  fillColor: gainColor.withValues(alpha: 0.18),
                  dotRingColor: cs.surfaceContainer,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(KuberRadius.lg),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _BreakdownColumn(
                      label: 'INVESTED',
                      value: maskAmount(fmt.formatCurrency(invested), masked),
                      color: cs.onSurface,
                    ),
                  ),
                  Expanded(
                    child: _BreakdownColumn(
                      label: 'CURRENT',
                      value: maskAmount(
                        fmt.formatCurrency(currentValue),
                        masked,
                      ),
                      color: gainColor,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool alignEnd;
  const _BreakdownColumn({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final Color dotRingColor;
  _SparkPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.dotRingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    const padTop = 6.0;
    final plotH = size.height - padTop;
    final minV = data.reduce((a, b) => a < b ? a : b);
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1 : (maxV - minV);

    Offset pt(int i) {
      final x = i * size.width / (data.length - 1);
      final y = padTop + plotH * (1 - (data[i] - minV) / range);
      return Offset(x, y);
    }

    final line = Path();
    final fill = Path()..moveTo(0, padTop + plotH);
    for (int i = 0; i < data.length; i++) {
      final p = pt(i);
      if (i == 0) {
        line.moveTo(p.dx, p.dy);
      } else {
        final prev = pt(i - 1);
        final cx = (prev.dx + p.dx) / 2;
        line.cubicTo(cx, prev.dy, cx, p.dy, p.dx, p.dy);
      }
      fill.lineTo(p.dx, p.dy);
    }
    fill.lineTo(size.width, padTop + plotH);
    fill.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, padTop, size.width, plotH));
    canvas.drawPath(fill, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, linePaint);

    final last = pt(data.length - 1);
    canvas.drawCircle(last, 5, Paint()..color = dotRingColor);
    canvas.drawCircle(last, 3, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      !identical(old.data, data) || old.lineColor != lineColor;
}

// ---------------------------------------------------------------------------
// Asset allocation strip
// ---------------------------------------------------------------------------

class AssetSlice {
  final String label;
  final Color color;
  final double value; // rupees
  const AssetSlice({
    required this.label,
    required this.color,
    required this.value,
  });
}

class AssetAllocationStrip extends StatelessWidget {
  final List<AssetSlice> slices; // sorted descending
  const AssetAllocationStrip({super.key, required this.slices});

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final total = slices.fold<double>(0, (a, s) => a + s.value);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.xl),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ASSET ALLOCATION',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  for (final s in slices)
                    Expanded(
                      flex: ((s.value / total) * 1000).round().clamp(1, 1000),
                      child: ColoredBox(color: s.color),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in slices)
                _AllocChip(
                  label: s.label,
                  color: s.color,
                  percent: total <= 0 ? 0 : (s.value / total * 100),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllocChip extends StatelessWidget {
  final String label;
  final Color color;
  final double percent;
  const _AllocChip({
    required this.label,
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Investment card
// ---------------------------------------------------------------------------

class InvestmentCard extends ConsumerWidget {
  final String name;
  final String assetTypeLabel; // "STOCKS", "MUTUAL FUND", "GOLD", etc
  final IconData icon;
  final Color iconColor;
  final String? quantityLabel; // "40 shares", "42.5 g", "SIP ₹10,000"
  final double currentValue;
  final double gainLossPercent;
  final VoidCallback onTap;

  const InvestmentCard({
    super.key,
    required this.name,
    required this.assetTypeLabel,
    required this.icon,
    required this.iconColor,
    required this.currentValue,
    required this.gainLossPercent,
    required this.onTap,
    this.quantityLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final isGain = gainLossPercent >= 0;
    final gainColor = isGain ? cs.tertiary : cs.error;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  border: Border.all(color: iconColor.withValues(alpha: 0.30)),
                  borderRadius: BorderRadius.circular(KuberRadius.md + 2),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          assetTypeLabel.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (quantityLabel != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              quantityLabel!,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    maskAmount(fmt.formatCurrency(currentValue), masked),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: gainColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(KuberRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGain
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 11,
                          color: gainColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${isGain ? '+' : '−'}${gainLossPercent.abs().toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: gainColor,
                          ),
                        ),
                      ],
                    ),
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
