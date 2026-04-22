import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          data: (p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 14, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Budget',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${ref.watch(formatterProvider).formatCurrency(p.spent)} / ${ref.watch(formatterProvider).formatCurrency(p.limit)} (${p.percentage.toStringAsFixed(0)}% used)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: p.percentage >= 100 ? cs.error : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (p.percentage >= 100)
                  Icon(Icons.warning_amber_rounded, size: 14, color: cs.error),
              ],
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
