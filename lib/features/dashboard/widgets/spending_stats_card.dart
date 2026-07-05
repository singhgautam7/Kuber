import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';

class SpendingStatsCard extends ConsumerWidget {
  const SpendingStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(spendingStatsProvider);

    if (stats.avgDaily == 0 && stats.monthTotal == 0) {
      return const SizedBox.shrink();
    }

    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final valueStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final projectedStyle = valueStyle?.copyWith(color: cs.onSurface);

    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.xl),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberHomeWidgetTitle(title: context.l10n.spendingPattern),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.5),
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
                    Text(context.l10n.avgDaily, style: _captionStyle(theme)),
                    const SizedBox(height: 4),
                    Text(
                      maskAmount(fmt.formatCurrency(stats.avgDaily.roundToDouble()), isPrivate),
                      style: valueStyle,
                    ),
                    Text(context.l10n.last90Days, style: _captionStyle(theme)),
                  ],
                ),
              ),
              const _VerticalDivider(),
              // This month
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.statThisMonth, style: _captionStyle(theme)),
                    const SizedBox(height: 4),
                    Text(
                      maskAmount(fmt.formatCurrency(stats.monthTotal.roundToDouble()), isPrivate),
                      style: valueStyle,
                    ),
                    Text(context.l10n.statDays('${stats.daysElapsed}'), style: _captionStyle(theme)),
                  ],
                ),
              ),
              const _VerticalDivider(),
              // Projected
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.projectedLabel, style: _captionStyle(theme)),
                    const SizedBox(height: 4),
                    Text(
                      maskAmount(fmt.formatCurrency(stats.projected.roundToDouble()), isPrivate),
                      style: projectedStyle,
                    ),
                    Text(context.l10n.endOfMonth, style: _captionStyle(theme)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }

  TextStyle? _captionStyle(ThemeData theme) =>
      theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
