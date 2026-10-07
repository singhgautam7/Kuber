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

import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// Allocation by asset type, drawn as the gapped bar + legend inside the
  /// card (board 3.22).
  final List<AssetSlice> allocation;

  const PortfolioHero({
    super.key,
    required this.currentValue,
    required this.invested,
    required this.gainLoss,
    required this.gainLossPercent,
    this.allocation = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final isGain = gainLoss >= 0;
    final gainColor = isGain
        ? context.kuberMoney.income
        : context.kuberMoney.expense;
    final total = allocation.fold<double>(0, (a, s) => a + s.value);

    Widget fact(String label, String value, [Color? color]) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        Text(
          value,
          style: tt.titleSmall!.copyWith(color: color ?? cs.onSurface),
        ),
      ],
    );

    return KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.portfolioValue,
            style: tt.labelMedium!.copyWith(
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            maskAmount(fmt.formatCurrency(currentValue), masked),
            style: tt.headlineMedium!.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: KuberSpace.md),
          Row(
            children: [
              Expanded(
                child: fact(
                  context.l10n.investedLabel,
                  maskAmount(fmt.formatCurrency(invested), masked),
                ),
              ),
              Expanded(
                child: fact(
                  context.l10n.gainLabel,
                  maskAmount(
                    '${isGain ? '+' : '−'}${fmt.formatCurrency(gainLoss.abs())}',
                    masked,
                  ),
                  gainColor,
                ),
              ),
              Expanded(
                child: fact(
                  context.l10n.returnLabel,
                  '${isGain ? '+' : '−'}${gainLossPercent.abs().toStringAsFixed(1)}%',
                  gainColor,
                ),
              ),
            ],
          ),
          if (allocation.isNotEmpty && total > 0) ...[
            const SizedBox(height: KuberSpace.lg),
            SizedBox(
              height: 8,
              child: Row(
                children: [
                  for (final (i, sl) in allocation.indexed) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      flex: (sl.value / total * 1000).round().clamp(1, 1000),
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryVizColor(context, sl.color),
                          borderRadius: KuberShape.fullR,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: KuberSpace.md),
            Wrap(
              spacing: KuberSpace.lg,
              runSpacing: KuberSpace.sm,
              children: [
                for (final sl in allocation)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: categoryVizColor(context, sl.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sl.label,
                        style: tt.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

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

/// One investment row (board 3.22): tile in the re-toned type colour, name,
/// "SIP ₹5,000 · Type", value with the return % under it.
class InvestmentCard extends ConsumerWidget {
  final String name;
  final String assetTypeLabel;
  final IconData icon;
  final Color iconColor;
  final String? quantityLabel; // "SIP ₹10,000"
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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final isGain = gainLossPercent >= 0;
    final tones = categoryTones(context, iconColor);
    return KuberListRow(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tones.container,
          borderRadius: KuberShape.mediumR,
        ),
        child: Icon(icon, size: 20, color: tones.fg),
      ),
      title: name,
      subtitle: [?quantityLabel, assetTypeLabel].join(' · '),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            maskAmount(fmt.formatCurrency(currentValue), masked),
            style: tt.titleMedium!.copyWith(color: cs.onSurface),
          ),
          Text(
            '${isGain ? '+' : '−'}${gainLossPercent.abs().toStringAsFixed(1)}%',
            style: tt.labelSmall!.copyWith(
              color: isGain
                  ? context.kuberMoney.income
                  : context.kuberMoney.expense,
            ),
          ),
        ],
      ),
    );
  }
}
