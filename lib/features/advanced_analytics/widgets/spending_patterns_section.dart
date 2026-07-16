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
        const SizedBox(height: KuberSpacing.lg),
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
            final weekendPct = total <= 0 ? 0 : (data.weekendSpend / total) * 100;

            final timeTotal =
                data.timeBuckets.values.fold<double>(0, (a, b) => a + b);
            var maxBucket = 'Evening';
            var maxBucketVal = -1.0;
            data.timeBuckets.forEach((k, v) {
              if (v > maxBucketVal) {
                maxBucketVal = v;
                maxBucket = k;
              }
            });

            final recTotal = data.recurringSpend + data.oneTimeSpend;
            final recPct =
                recTotal <= 0 ? 0.0 : (data.recurringSpend / recTotal) * 100;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day of week
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardLabel('Day of week'),
                      const SizedBox(height: KuberSpacing.sm),
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
                              label: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                              current: data.weekdayAverages[i],
                            ),
                        ],
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      _RichLine('You spend most on ', '${_weekdayNames[peakDay]}s', '.'),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                // Time of day
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardLabel('Time of day'),
                      const SizedBox(height: KuberSpacing.sm),
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
                                const SizedBox(width: KuberSpacing.sm),
                            ],
                          ],
                        ),
                        const SizedBox(height: KuberSpacing.sm),
                      ],
                      _RichLine('Most of your spending happens in the ',
                          maxBucket.toLowerCase(), '.'),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                // Weekend vs weekday
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardLabel('Weekend vs weekday'),
                      const SizedBox(height: KuberSpacing.sm),
                      _KvLine('Weekend spending', aaMoney(data.weekendSpend)),
                      _KvLine('Weekday spending', aaMoney(data.weekdaySpend)),
                      const SizedBox(height: 4),
                      _RichLine('Weekends are ', '${weekendPct.round()}%',
                          ' of your total.'),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
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
                                strokeWidth: 9,
                                color: cs.primary,
                                backgroundColor: cs.surfaceContainerHigh,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: KuberSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CardLabel('Recurring vs one-time'),
                            const SizedBox(height: 6),
                            Text.rich(
                              TextSpan(
                                style: localeFont(
                                  fontSize: 12.5,
                                  color: cs.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${recPct.round()}% recurring',
                                    style: localeFont(
                                      fontWeight: FontWeight.w800,
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
                const SizedBox(height: KuberSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(KuberSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: localeFont(
                        fontSize: 12.5,
                        color: cs.onSurface,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Recurring expenses make up '),
                        TextSpan(
                          text: '${recPct.round()}%',
                          style: localeFont(fontWeight: FontWeight.w800),
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
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
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
      style: localeFont(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    return Text.rich(
      TextSpan(
        style: localeFont(fontSize: 12.5, color: cs.onSurfaceVariant, height: 1.4),
        children: [
          TextSpan(text: pre),
          TextSpan(
            text: bold,
            style: localeFont(fontWeight: FontWeight.w800, color: cs.onSurface),
          ),
          TextSpan(text: post),
        ],
      ),
    );
  }
}

class _KvLine extends StatelessWidget {
  final String label;
  final String value;
  const _KvLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: localeFont(fontSize: 12.5, color: cs.onSurfaceVariant)),
          Text(
            value,
            style: localeFont(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.md),
      decoration: BoxDecoration(
        color: highlight
            ? cs.primary.withValues(alpha: 0.12)
            : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.sm),
        border: highlight
            ? Border.all(color: cs.primary.withValues(alpha: 0.35))
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: localeFont(
              fontSize: 11,
              color: highlight ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$pct%',
            style: localeFont(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: highlight ? cs.primary : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
