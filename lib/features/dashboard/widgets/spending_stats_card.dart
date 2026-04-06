import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

class SpendingStatsCard extends ConsumerWidget {
  const SpendingStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(spendingStatsProvider);

    if (stats.avgDaily == 0 && stats.monthTotal == 0) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text(
                    'SPENDING PATTERN',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
            ),
            Container(
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
                          ref.watch(formatterProvider).formatCurrency(stats.avgDaily.roundToDouble()),
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
                          ref.watch(formatterProvider).formatCurrency(stats.monthTotal.roundToDouble()),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text('${stats.daysElapsed} days', style: _captionStyle(context)),
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
                          ref.watch(formatterProvider).formatCurrency(stats.projected.roundToDouble()),
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
            ),
          ],
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
