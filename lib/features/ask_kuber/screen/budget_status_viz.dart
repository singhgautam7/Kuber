import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../models/viz_payload.dart';

/// Budget progress rendered under a Kuber reply. Colour tracks the budget
/// state (within / approaching / over); over budget adds a red "over" suffix
/// on the caption.
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
      BudgetStatus.approaching => context.kuberMoney.warning,
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
    final progressState = switch (data.status) {
      BudgetStatus.withinBudget => KuberProgressState.normal,
      BudgetStatus.approaching => KuberProgressState.nearLimit,
      BudgetStatus.over => KuberProgressState.overLimit,
    };

    return Container(
      // Board 3.8b: viz sits in a surfaceContainerLow card.
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(KuberSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stateLabel,
                style: localeFont(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
              Text(
                '${pct.round()}%',
                style: localeFont(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: stateColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Wavy M3 progress in the budget state colour.
          KuberLinearProgress(value: fillFraction, state: progressState),
          const SizedBox(height: 6),
          // Caption (+ red over-suffix).
          RichText(
            text: TextSpan(
              style: localeFont(
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              children: [
                TextSpan(text: data.caption),
                if (isOver)
                  TextSpan(
                    text:
                        ' · ${formatter.formatCurrency((data.spent - data.budgeted).round(), symbol: symbol)} over',
                    style: TextStyle(
                      color: context.kuberMoney.expense,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
