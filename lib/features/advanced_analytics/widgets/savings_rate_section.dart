import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../providers/advanced_analytics_provider.dart';
import 'advanced_analytics_charts.dart';
import 'analytics_common.dart';

class SavingsRateSection extends ConsumerWidget {
  const SavingsRateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savingsRateProvider);
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberMoney.warning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: SectionDateRangePicker(
            section: AdvancedAnalyticsSection.savings,
          ),
        ),
        const SizedBox(height: KuberSpace.md),
        async.when(
          loading: () => const AnalyticsSkeletonBlock(),
          error: (error, _) => KuberEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load savings rate',
            description: '$error',
          ),
          data: (data) {
            if (data.months.length < 3) {
              return KuberEmptyState(
                icon: Icons.savings_outlined,
                title: 'Not enough data',
                description:
                    'Savings rate needs 3 months. You have ${data.months.length}.',
              );
            }

            final rateColor = data.overallRate >= 20
                ? context.kuberMoney.income
                : data.overallRate >= 10
                ? warning
                : context.kuberMoney.expense;
            final avg =
                data.months
                    .map((m) => m.savingsRate)
                    .fold<double>(0, (s, r) => s + r) /
                data.months.length;
            final best = data.bestMonth?.savingsRate ?? 0;
            final worst = data.worstMonth?.savingsRate ?? 0;
            final last = data.months.last;
            final isNewBest = last.savingsRate >= best && best > 0;
            final insight = isNewBest
                ? 'You saved more this month than any previous month.'
                : data.assessment == 'Negative'
                ? 'Your savings rate has dipped into the negative recently.'
                : data.assessment == 'Consistent'
                ? "You've kept a consistent savings streak."
                : 'Your savings rate varies month to month.';

            final tt = Theme.of(context).textTheme;
            final small = tt.bodySmall!.copyWith(color: cs.onSurfaceVariant);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Board "Savings rate tracker": hero, chart card, figures.
                KuberCard(
                  hero: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT SAVINGS RATE',
                        style: sectionHeaderStyle(context),
                      ),
                      const SizedBox(height: KuberSpace.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            aaPercent(data.overallRate),
                            style: tt.headlineMedium!.copyWith(
                              color: rateColor,
                            ),
                          ),
                          const SizedBox(width: KuberSpace.sm),
                          Text(
                            'target 20%',
                            style: tt.bodyMedium!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: KuberSpace.sm),
                      Text(
                        insight,
                        style: tt.bodyMedium!.copyWith(color: cs.onSurface),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpace.sectionGap - 4),
                AnalyticsSectionCard(
                  title: 'By month',
                  icon: Icons.show_chart_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SavingsRateLineChart(
                        values: data.months.map((m) => m.savingsRate).toList(),
                        labels: data.months.map((m) => m.label).toList(),
                      ),
                      const SizedBox(height: KuberSpace.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('20% target', style: small),
                          Text('10% baseline', style: small),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Kpi(
                        label: 'Average',
                        value: aaPercent(avg),
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: KuberSpace.sm),
                    Expanded(
                      child: _Kpi(
                        label: 'Best month',
                        value: aaPercent(best),
                        color: context.kuberMoney.income,
                      ),
                    ),
                    const SizedBox(width: KuberSpace.sm),
                    Expanded(
                      child: _Kpi(
                        label: 'Worst month',
                        value: aaPercent(worst),
                        color: context.kuberMoney.expense,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Kpi({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpace.sm,
        vertical: KuberSpace.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.largeR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              style: tt.labelSmall!.copyWith(
                letterSpacing: 0.6,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: tt.titleMedium!.copyWith(color: color)),
        ],
      ),
    );
  }
}
