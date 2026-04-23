import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/dashboard_provider.dart';

class MonthlySummaryCard extends ConsumerWidget {
  final MonthlySummary summary;

  const MonthlySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPrivate = ref.watch(privacyModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
      child: Column(
        children: [
          // Net total
          Text(
            maskAmount(CurrencyFormatter.format(summary.net), isPrivate),
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
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.arrow_downward,
                          color: colorScheme.tertiary, size: 20),
                      const SizedBox(height: KuberSpacing.xs),
                      Text('Income', style: textTheme.labelMedium),
                      Text(
                        maskAmount(CurrencyFormatter.format(summary.totalIncome), isPrivate),
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
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.arrow_upward,
                          color: colorScheme.error, size: 20),
                      const SizedBox(height: KuberSpacing.xs),
                      Text('Expenses', style: textTheme.labelMedium),
                      Text(
                        maskAmount(CurrencyFormatter.format(summary.totalExpense), isPrivate),
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
