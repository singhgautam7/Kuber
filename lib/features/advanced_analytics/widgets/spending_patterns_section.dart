import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../providers/advanced_analytics_provider.dart';
import 'aa_bar_chart.dart';
import 'analytics_common.dart';

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class SpendingPatternsSection extends ConsumerWidget {
  const SpendingPatternsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(spendingPatternsProvider);
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDateRangePicker(
          section: AdvancedAnalyticsSection.patterns,
        ),
        const SizedBox(height: KuberSpace.lg),
        async.when(
          loading: () => const AnalyticsSkeletonBlock(),
          error: (error, _) => KuberEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load patterns',
            description: '$error',
          ),
          data: (data) {
            if (data.transactionCount < 30) {
              return KuberEmptyState(
                icon: Icons.scatter_plot_outlined,
                title: 'Not enough data',
                description:
                    'Patterns need at least 30 expense transactions. You have ${data.transactionCount}.',
              );
            }

            final peakDay = _argMax(data.weekdayAverages);
            final total = data.weekdaySpend + data.weekendSpend;
            final weekendPct = total <= 0
                ? 0
                : (data.weekendSpend / total) * 100;

            final timeTotal = data.timeBuckets.values.fold<double>(
              0,
              (a, b) => a + b,
            );
            var maxBucket = 'Evening';
            var maxBucketVal = -1.0;
            data.timeBuckets.forEach((k, v) {
              if (v > maxBucketVal) {
                maxBucketVal = v;
                maxBucket = k;
              }
            });

            final recTotal = data.recurringSpend + data.oneTimeSpend;
            final recPct = recTotal <= 0
                ? 0.0
                : (data.recurringSpend / recTotal) * 100;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day of week
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardLabel('Day of week'),
                      const SizedBox(height: KuberSpace.sm),
                      AaBarChart(
                        height: 110,
                        currentLabel: 'Spent',
                        showYAxis: false,
                        scrollable: false,
                        showBorder: false,
                        highlightIndex: peakDay,
                        data: [
                          for (var i = 0; i < data.weekdayAverages.length; i++)
                            AaBarDatum(
                              label: const [
                                'M',
                                'T',
                                'W',
                                'T',
                                'F',
                                'S',
                                'S',
                              ][i],
                              current: data.weekdayAverages[i],
                            ),
                        ],
                      ),
                      const SizedBox(height: KuberSpace.sm),
                      _RichLine(
                        'You spend most on ',
                        '${_weekdayNames[peakDay]}s',
                        '.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpace.sm),
                // Time of day
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardLabel('Time of day'),
                      const SizedBox(height: KuberSpace.sm),
                      for (final chunk in [
                        ['Morning', 'Afternoon'],
                        ['Evening', 'Night'],
                      ]) ...[
                        Row(
                          children: [
                            for (final b in chunk) ...[
                              Expanded(
                                child: _TimeTile(
                                  label: b,
                                  pct: timeTotal <= 0
                                      ? 0
                                      : ((data.timeBuckets[b] ?? 0) /
                                                timeTotal *
                                                100)
                                            .round(),
                                  highlight: b == maxBucket,
                                ),
                              ),
                              if (b == chunk.first)
                                const SizedBox(width: KuberSpace.sm),
                            ],
                          ],
                        ),
                        const SizedBox(height: KuberSpace.sm),
                      ],
                      _RichLine(
                        'Most of your spending happens in the ',
                        maxBucket.toLowerCase(),
                        '.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpace.sm),
                // Weekend vs weekday
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardLabel('Weekend vs weekday'),
                      const SizedBox(height: KuberSpace.sm),
                      _SplitBar(
                        weekend: data.weekendSpend,
                        weekday: data.weekdaySpend,
                      ),
                      const SizedBox(height: KuberSpace.sm),
                      _RichLine(
                        'Weekends are ',
                        '${weekendPct.round()}%',
                        ' of your total.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpace.sm),
                // Recurring vs one-time
                _Card(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: (recPct / 100).clamp(0.0, 1.0),
                                strokeWidth: 8,
                                strokeCap: StrokeCap.round,
                                color: cs.primary,
                                backgroundColor: cs.surfaceContainerHighest,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: KuberSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CardLabel('Recurring vs one-time'),
                            const SizedBox(height: 6),
                            Text.rich(
                              TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: cs.onSurfaceVariant),
                                children: [
                                  TextSpan(
                                    text: '${recPct.round()}% recurring',
                                    style: localeFont(
                                      fontWeight: FontWeight.w700,
                                      color: cs.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' · ${(100 - recPct).round()}% discretionary',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpace.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(KuberSpace.md),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      KuberShape.largeIncreased,
                    ),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: localeFont(
                        fontSize: 12,
                        color: cs.onSurface,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Recurring expenses make up '),
                        TextSpan(
                          text: '${recPct.round()}%',
                          style: localeFont(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' of your spending.'),
                      ],
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

int _argMax(List<double> v) {
  var idx = 0;
  var max = double.negativeInfinity;
  for (var i = 0; i < v.length; i++) {
    if (v[i] > max) {
      max = v[i];
      idx = i;
    }
  }
  return idx;
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.largeR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: child,
    );
  }
}

class _CardLabel extends StatelessWidget {
  final String text;
  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _RichLine extends StatelessWidget {
  final String pre;
  final String bold;
  final String post;
  const _RichLine(this.pre, this.bold, this.post);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Text.rich(
      TextSpan(
        style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        children: [
          TextSpan(text: pre),
          TextSpan(
            text: bold,
            style: tt.titleSmall!.copyWith(color: cs.onSurface),
          ),
          TextSpan(text: post),
        ],
      ),
    );
  }
}

/// Weekend | weekday split bar (4 gap) with the legend under it.
class _SplitBar extends StatelessWidget {
  final double weekend;
  final double weekday;
  const _SplitBar({required this.weekend, required this.weekday});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final total = weekend + weekday;
    final share = total <= 0 ? 0.5 : weekend / total;
    Widget bar(Color c) => Container(
      height: 8,
      decoration: BoxDecoration(color: c, borderRadius: KuberShape.fullR),
    );
    Widget legend(Color c, String label, double v) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(width: 6),
        Text(aaMoney(v), style: tt.titleSmall!.copyWith(color: cs.onSurface)),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: (share * 1000).round().clamp(1, 1000),
              child: bar(cs.primary),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: ((1 - share) * 1000).round().clamp(1, 1000),
              child: bar(cs.primaryContainer),
            ),
          ],
        ),
        const SizedBox(height: KuberSpace.sm),
        Wrap(
          spacing: KuberSpace.lg,
          runSpacing: 4,
          children: [
            legend(cs.primary, 'Weekend', weekend),
            legend(cs.primaryContainer, 'Weekday', weekday),
          ],
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final int pct;
  final bool highlight;
  const _TimeTile({
    required this.label,
    required this.pct,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fg = highlight ? cs.onSecondaryContainer : cs.onSurface;
    final sub = highlight ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(KuberSpace.md),
      decoration: BoxDecoration(
        color: highlight ? cs.secondaryContainer : cs.surfaceContainerHigh,
        borderRadius: KuberShape.mediumR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            switch (label) {
              'Morning' => Icons.wb_twilight_rounded,
              'Afternoon' => Icons.light_mode_outlined,
              'Evening' => Icons.nights_stay_outlined,
              _ => Icons.bedtime_outlined,
            },
            size: 20,
            color: sub,
          ),
          const SizedBox(height: KuberSpace.sm),
          Text(label, style: tt.bodySmall!.copyWith(color: sub)),
          Text('$pct%', style: tt.titleMedium!.copyWith(color: fg)),
        ],
      ),
    );
  }
}
