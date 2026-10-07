import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/locale_font.dart';

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
    final valueStyle = theme.textTheme.titleMedium;

    Widget stat(String label, String value, String caption) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sentenceCase(label), style: _captionStyle(theme)),
          Text(maskAmount(value, isPrivate), style: valueStyle),
          Text(caption, style: _captionStyle(theme)),
        ],
      ),
    );

    // Stat card (2l / board 3.2a): three columns 12 apart, no vertical rules.
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KuberHomeWidgetTitle(title: context.l10n.spendingPattern),
          KuberCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: KuberSpace.md,
              children: [
                stat(
                  context.l10n.avgDaily,
                  fmt.formatCurrency(stats.avgDaily.roundToDouble()),
                  context.l10n.last90Days,
                ),
                stat(
                  context.l10n.statThisMonth,
                  fmt.formatCurrency(stats.monthTotal.roundToDouble()),
                  context.l10n.statDays('${stats.daysElapsed}'),
                ),
                stat(
                  context.l10n.projectedLabel,
                  fmt.formatCurrency(stats.projected.roundToDouble()),
                  context.l10n.endOfMonth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _captionStyle(ThemeData theme) => theme.textTheme.bodySmall
      ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
}
