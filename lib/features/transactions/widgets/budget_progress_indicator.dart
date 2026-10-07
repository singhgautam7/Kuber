import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_progress.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;

class BudgetProgressIndicator extends ConsumerWidget {
  final String categoryId;
  const BudgetProgressIndicator({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetByCategoryProvider(categoryId));
    final cs = Theme.of(context).colorScheme;

    return budgetAsync.when(
      data: (budget) {
        if (budget == null || !budget.isActive) return const SizedBox.shrink();

        final progressAsync = ref.watch(budgetProgressProvider(budget));
        return progressAsync.when(
          data: (p) {
            final state = p.percentage >= 100
                ? KuberProgressState.overLimit
                : p.percentage >= 50
                ? KuberProgressState.nearLimit
                : KuberProgressState.normal;
            final fmt = ref.watch(formatterProvider);
            final small = Theme.of(context).textTheme.bodySmall!;
            // Board 3.4: surfaceContainerHigh r16 block, label row + progress.
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: KuberShape.largeR,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.budgetLabel,
                        style: small.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${fmt.formatCurrency(p.spent)} / ${fmt.formatCurrency(p.limit)} · ${p.percentage.toStringAsFixed(0)}% ${context.l10n.usedLabel}',
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: small.copyWith(
                            color: p.percentage >= 100
                                ? context.kuberMoney.expense
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KuberSpace.sm),
                  KuberLinearProgress(
                    value: (p.percentage / 100).clamp(0.0, 1.0),
                    state: state,
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
