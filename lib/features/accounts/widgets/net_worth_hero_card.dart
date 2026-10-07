// Net Worth card for the Accounts page (board 3.15): the Home hero card
// pattern. Caps "Net worth" label, headlineMedium amount (same AnimatedAmount
// count-up as before), an 8 split bar (assets / debt, 4 gap) and the legend.

import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/animated_amount.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

class NetWorthHeroCard extends ConsumerWidget {
  final double netWorth;
  final double totalAssets;
  final double totalDebt;

  const NetWorthHeroCard({
    super.key,
    required this.netWorth,
    required this.totalAssets,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final m = context.kuberMoney;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final total = totalAssets + totalDebt;
    final assetShare = total > 0 ? totalAssets / total : 1.0;
    final legend = theme.textTheme.titleSmall!.copyWith(color: cs.onSurface);
    final legendLabel = theme.textTheme.bodySmall!.copyWith(
      color: cs.onSurfaceVariant,
    );

    Widget dot(Color c) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
    Widget bar(Color c) => Container(
      height: 8,
      decoration: BoxDecoration(color: c, borderRadius: KuberShape.fullR),
    );

    return KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.netWorthUpper,
            style: theme.textTheme.labelMedium!.copyWith(
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: KuberSpace.xs),
          AnimatedAmount(
            value: netWorth,
            isPrivate: masked,
            format: (v) => '${v < 0 ? '−' : ''}${fmt.formatCurrency(v.abs())}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium!.copyWith(
              color: netWorth < 0 ? m.expense : cs.onSurface,
            ),
          ),
          const SizedBox(height: KuberSpace.lg),
          if (total == 0)
            bar(cs.surfaceContainerHighest)
          else
            Row(
              children: [
                Expanded(
                  flex: (assetShare * 1000).round().clamp(1, 1000),
                  child: bar(m.income),
                ),
                if (totalDebt > 0) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    flex: ((1 - assetShare) * 1000).round().clamp(1, 1000),
                    child: bar(m.expense),
                  ),
                ],
              ],
            ),
          const SizedBox(height: KuberSpace.md),
          Row(
            children: [
              dot(m.income),
              const SizedBox(width: KuberSpace.sm),
              Text(context.l10n.assets, style: legendLabel),
              const SizedBox(width: 6),
              Text(
                maskAmount(fmt.formatCurrency(totalAssets), masked),
                style: legend,
              ),
              const Spacer(),
              dot(m.expense),
              const SizedBox(width: KuberSpace.sm),
              Text(context.l10n.debt, style: legendLabel),
              const SizedBox(width: 6),
              Text(
                maskAmount(fmt.formatCurrency(totalDebt), masked),
                style: legend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
