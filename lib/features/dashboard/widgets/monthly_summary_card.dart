import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/dashboard_provider.dart';

class MonthlySummaryCard extends StatelessWidget {
  final MonthlySummary summary;

  const MonthlySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
      child: Column(
        children: [
          // Net total
          Text(
            CurrencyFormatter.format(summary.net),
            style: textTheme.displaySmall?.copyWith(
              color: summary.net >= 0
                  ? colorScheme.tertiary
                  : colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Net this month',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          // Income / Expense row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(KuberSpacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.arrow_downward,
                          color: colorScheme.tertiary, size: 20),
                      const SizedBox(height: KuberSpacing.xs),
                      Text('Income', style: textTheme.labelMedium),
                      Text(
                        CurrencyFormatter.format(summary.totalIncome),
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(KuberSpacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.arrow_upward,
                          color: colorScheme.error, size: 20),
                      const SizedBox(height: KuberSpacing.xs),
                      Text('Expenses', style: textTheme.labelMedium),
                      Text(
                        CurrencyFormatter.format(summary.totalExpense),
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
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
