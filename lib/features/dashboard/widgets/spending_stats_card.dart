import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

class SpendingStatsCard extends ConsumerWidget {
  const SpendingStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return transactionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (transactions) {
        if (transactions.isEmpty) return const SizedBox.shrink();

        // Compute base dates
        final now = DateTime.now();
        final cutoff90 = now.subtract(const Duration(days: 90));
        final monthStart = DateTime(now.year, now.month, 1);
        final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
        final daysElapsed = now.day;

        // Filter expenses: strictly excludes transfers & balance adjustments
        final expenses = transactions.where((t) => 
          t.type == 'expense' && 
          !t.isTransfer && 
          !t.isBalanceAdjustment
        ).toList();
        
        // This Month: filtered expenditures since monthStart
        final monthTotal = expenses
            .where((t) => t.createdAt.isAfter(monthStart))
            .fold(0.0, (s, t) => s + t.amount);

        // Smart Divider Logic (last 90 days)
        final last90Expenses = expenses.where((t) => t.createdAt.isAfter(cutoff90)).toList();
        final last90Total = last90Expenses.fold(0.0, (s, t) => s + t.amount);
        
        double avgDaily = 0.0;
        if (last90Expenses.isNotEmpty) {
          // Find the earliest transaction date in the 90 day window
          final firstDate = last90Expenses.map((e) => e.createdAt).reduce((min, e) => e.isBefore(min) ? e : min);
          
          // Days since first transaction in this window (min 1, max 90)
          final diff = now.difference(firstDate).inDays + 1;
          final daysActive = diff > 90 ? 90 : (diff < 1 ? 1 : diff);
          
          avgDaily = last90Total / daysActive;
        }

        final projected = avgDaily * daysInMonth;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Avg daily
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AVG DAILY', style: _captionStyle(context)),
                    const SizedBox(height: 4),
                    Text(
                      ref.watch(formatterProvider).formatCurrency(avgDaily),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text('last 90 days', style: _captionStyle(context)),
                  ],
                ),
              ),
              const _VerticalDivider(),
              // This month
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('THIS MONTH', style: _captionStyle(context)),
                    const SizedBox(height: 4),
                    Text(
                      ref.watch(formatterProvider).formatCurrency(monthTotal),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text('$daysElapsed days', style: _captionStyle(context)),
                  ],
                ),
              ),
              const _VerticalDivider(),
              // Projected
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROJECTED', style: _captionStyle(context)),
                    const SizedBox(height: 4),
                    Text(
                      ref.watch(formatterProvider).formatCurrency(projected),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Text('end of month', style: _captionStyle(context)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle? _captionStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          );
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 48,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );
}
