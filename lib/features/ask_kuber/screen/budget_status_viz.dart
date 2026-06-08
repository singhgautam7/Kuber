import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/viz_payload.dart';

/// Thin budget progress bar rendered inside the Kuber bubble. Colour tracks the
/// budget state (within / approaching / over); an over-budget bar gets a
/// diagonal-hatch overshoot and a red "over" suffix on the caption.
class BudgetStatusVizView extends ConsumerWidget {
  final BudgetStatusViz data;
  const BudgetStatusVizView({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final symbol = ref.watch(currencyProvider).symbol;

    final Color stateColor = switch (data.status) {
      BudgetStatus.withinBudget => cs.primary,
      BudgetStatus.approaching => context.kuberColors.warning,
      BudgetStatus.over => cs.error,
    };
    final String stateLabel = switch (data.status) {
      BudgetStatus.withinBudget => 'Within budget',
      BudgetStatus.approaching => 'Approaching limit',
      BudgetStatus.over => 'Over budget',
    };

    final pct = data.budgeted > 0 ? (data.spent / data.budgeted) * 100 : 0;
    final fillFraction = data.budgeted > 0
        ? (data.spent / data.budgeted).clamp(0.0, 1.0)
        : 0.0;
    final isOver = data.status == BudgetStatus.over;
    final hatchFraction =
        isOver && data.spent > 0 ? ((data.spent - data.budgeted) / data.spent).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stateLabel,
                style: localeFont(
                    fontSize: 12.5, fontWeight: FontWeight.w500, color: cs.onSurface),
              ),
              Text(
                '${pct.round()}%',
                style: localeFont(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: stateColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Track + fill.
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: cs.onSurface.withValues(alpha: 0.04)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: fillFraction,
                      child: Container(color: stateColor),
                    ),
                  ),
                  if (hatchFraction > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: hatchFraction,
                        child: CustomPaint(
                          painter: _HatchPainter(cs.onError.withValues(alpha: 0.45)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Caption (+ red over-suffix).
          RichText(
            text: TextSpan(
              style: localeFont(fontSize: 11.5, color: cs.onSurfaceVariant)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              children: [
                TextSpan(text: data.caption),
                if (isOver)
                  TextSpan(
                    text:
                        ' · ${formatter.formatCurrency((data.spent - data.budgeted).round(), symbol: symbol)} over',
                    style: TextStyle(color: cs.error, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Diagonal hatch fill for the over-budget overshoot region.
class _HatchPainter extends CustomPainter {
  final Color color;
  const _HatchPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const step = 4.0;
    for (double x = -size.height; x < size.width; x += step) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => oldDelegate.color != color;
}
