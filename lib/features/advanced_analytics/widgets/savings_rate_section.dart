import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../providers/advanced_analytics_provider.dart';
import 'advanced_analytics_charts.dart';
import 'analytics_common.dart';

class SavingsRateSection extends ConsumerWidget {
  const SavingsRateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savingsRateProvider);
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberColors.warning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: SectionDateRangePicker(
            section: AdvancedAnalyticsSection.savings,
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
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
                ? cs.tertiary
                : data.overallRate >= 10
                    ? warning
                    : cs.error;
            final avg = data.months
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        'CURRENT SAVINGS RATE',
                        style: localeFont(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        aaPercent(data.overallRate),
                        style: localeFont(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: rateColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                SavingsRateLineChart(
                  values: data.months.map((m) => m.savingsRate).toList(),
                  labels: data.months.map((m) => m.label).toList(),
                ),
                const SizedBox(height: KuberSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('20% target',
                        style: localeFont(
                            fontSize: 9.5, color: cs.onSurfaceVariant)),
                    Text('10% baseline',
                        style: localeFont(
                            fontSize: 9.5, color: cs.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: KuberSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _Kpi(
                        label: 'AVERAGE',
                        value: aaPercent(avg),
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: _Kpi(
                        label: 'BEST MONTH',
                        value: aaPercent(best),
                        color: cs.tertiary,
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: _Kpi(
                        label: 'WORST MONTH',
                        value: aaPercent(worst),
                        color: cs.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.md),
                Container(
                  padding: const EdgeInsets.all(KuberSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.tertiary.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    insight,
                    style: localeFont(
                      fontSize: 12.5,
                      color: cs.onSurface,
                      height: 1.4,
                    ),
                  ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.sm,
        vertical: KuberSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: localeFont(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: localeFont(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
