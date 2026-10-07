import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/widgets/animated_amount.dart';
import '../providers/dashboard_provider.dart';

class MonthlySummaryCard extends ConsumerWidget {
  final MonthlySummary summary;

  const MonthlySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isPrivate = ref.watch(privacyModeProvider);
    final fmt = ref.watch(formatterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.lg),
      child: Column(
        children: [
          // Net total — counts up on first appearance, tweens on change.
          AnimatedAmount(
            value: summary.net,
            isPrivate: isPrivate,
            format: fmt.formatCurrency,
            style: textTheme.displaySmall?.copyWith(
              color: summary.net >= 0
                  ? context.kuberMoney.income
                  : context.kuberMoney.expense,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Net this month',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: KuberSpace.lg),
          // Income / Expense row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(KuberSpace.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(KuberShape.medium),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: context.kuberMoney.income,
                        size: 20,
                      ),
                      const SizedBox(height: KuberSpace.xs),
                      Text('Income', style: textTheme.labelMedium),
                      Text(
                        maskAmount(
                          fmt.formatCurrency(summary.totalIncome),
                          isPrivate,
                        ),
                        style: textTheme.titleMedium?.copyWith(
                          color: context.kuberMoney.income,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(KuberSpace.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(KuberShape.medium),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: context.kuberMoney.expense,
                        size: 20,
                      ),
                      const SizedBox(height: KuberSpace.xs),
                      Text('Expenses', style: textTheme.labelMedium),
                      Text(
                        maskAmount(
                          fmt.formatCurrency(summary.totalExpense),
                          isPrivate,
                        ),
                        style: textTheme.titleMedium?.copyWith(
                          color: context.kuberMoney.expense,
                          fontWeight: FontWeight.w600,
                        ),
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
}
