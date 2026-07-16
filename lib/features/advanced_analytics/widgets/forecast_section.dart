import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../upcoming_events/engine/event_aggregator.dart';
import '../../upcoming_events/providers/upcoming_events_provider.dart';
import '../providers/advanced_analytics_provider.dart';
import 'advanced_analytics_charts.dart';
import 'analytics_common.dart';
import 'fixed_window_note.dart';

class ForecastSection extends ConsumerWidget {
  const ForecastSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(forecastProvider);
    final txns = ref.watch(transactionListProvider).valueOrNull ?? const [];
    final budgets = ref.watch(budgetListProvider).valueOrNull ?? const [];
    // Reuse the shared upcoming-events aggregator (loan EMIs, SIPs, reminders,
    // recurring, ledger) — the same source the Home widget and the Upcoming
    // Events screen use — instead of a recurring-only list.
    final upcomingEvents =
        ref.watch(upcomingEventsProvider).valueOrNull ?? const <UpcomingEvent>[];
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberColors.warning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FixedWindowNote(
          message:
              "Forecasts are always based on your current month and recent history. They don't follow section date filters.",
        ),
        const SizedBox(height: KuberSpacing.md),
        async.when(
          loading: () => const AnalyticsSkeletonBlock(),
          error: (error, _) => KuberEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load forecast',
            description: '$error',
          ),
          data: (data) {
            if (data.monthsTracked < 2) {
              return KuberEmptyState(
                icon: Icons.auto_graph_rounded,
                title: 'Not enough data',
                description:
                    'Come back after a couple months of tracking for forecasts. You have ${data.monthsTracked}.',
              );
            }

            final now = DateTime.now();
            final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
            final currentDay = now.day.clamp(1, daysInMonth);

            final dailySpending = List<double>.filled(daysInMonth, 0.0);
            for (final t in txns) {
              if (t.type == 'expense' &&
                  !t.isTransfer &&
                  !t.isBalanceAdjustment &&
                  t.createdAt.year == now.year &&
                  t.createdAt.month == now.month) {
                final day = t.createdAt.day;
                if (day >= 1 && day <= daysInMonth) {
                  dailySpending[day - 1] += t.amount;
                }
              }
            }
            final actuals = <double>[];
            var cumulative = 0.0;
            for (var i = 0; i < currentDay; i++) {
              cumulative += dailySpending[i];
              actuals.add(cumulative);
            }
            final projections = <double>[];
            final lastActual = actuals.isEmpty ? 0.0 : actuals.last;
            final remainingDays = daysInMonth - currentDay;
            if (remainingDays > 0) {
              final step = (data.projectedTotal - lastActual) / remainingDays;
              for (var i = 1; i <= remainingDays; i++) {
                projections.add(lastActual + step * i);
              }
            }
            final totalBudget = budgets
                .where((b) => b.isActive)
                .fold<double>(0, (s, b) => s + b.amount);
            final limit =
                totalBudget > 0 ? totalBudget : data.projectedTotal * 0.85;

            double monthTotal(int offset) {
              final start = DateTime(now.year, now.month - offset, 1);
              final end = DateTime(now.year, now.month - offset + 1, 0);
              return txns
                  .where((t) =>
                      t.type == 'expense' &&
                      !t.isTransfer &&
                      !t.isBalanceAdjustment &&
                      !t.createdAt.isBefore(start) &&
                      t.createdAt.isBefore(
                          end.add(const Duration(days: 1))))
                  .fold<double>(0, (s, t) => s + t.amount);
            }

            final lastMonth = monthTotal(1);
            final twoAgo = monthTotal(2);
            final avg = (lastMonth + twoAgo) / 2;

            // Outgoing obligations in the next 30 days (negative amount).
            final upcoming = eventsWithinDays(upcomingEvents, 30)
                .where((e) => (e.amount ?? 0) < 0)
                .toList();
            final upcomingTotal = upcoming.fold<double>(
              0,
              (s, e) => s + (e.amount ?? 0).abs(),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Projected month-end spend
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(KuberSpacing.lg),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'PROJECTED MONTH-END SPEND',
                        style: localeFont(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        aaMoney(data.projectedTotal),
                        style: localeFont(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: warning,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      Text.rich(
                        TextSpan(
                          style: localeFont(
                            fontSize: 12,
                            height: 1.5,
                            color: cs.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(
                                text: 'Based on your recurring transactions ('),
                            _bold(cs, aaMoney(data.lockedInRecurring)),
                            const TextSpan(text: ' locked in) and current '
                                'discretionary pace ('),
                            _bold(
                                cs,
                                aaMoney(data.discretionarySoFar +
                                    data.projectedDiscretionary)),
                            const TextSpan(text: ' projected), you\'re likely '
                                'to spend '),
                            _bold(cs, aaMoney(data.projectedTotal)),
                            const TextSpan(text: ' by month end.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                // Zone chart
                ForecastZoneChart(
                  actuals: actuals,
                  projections: projections,
                  limit: limit,
                ),
                const SizedBox(height: KuberSpacing.xs),
                Row(
                  children: [
                    _LegendDot(color: cs.tertiary, label: 'Safe'),
                    const SizedBox(width: KuberSpacing.md),
                    _LegendDot(color: warning, label: 'Warning'),
                    const SizedBox(width: KuberSpacing.md),
                    _LegendDot(color: cs.error, label: 'Over'),
                  ],
                ),
                const SizedBox(height: KuberSpacing.md),
                // Recent months
                _InfoCard(
                  child: Text.rich(
                    TextSpan(
                      style: localeFont(
                        fontSize: 12.5,
                        height: 1.5,
                        color: cs.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: 'Last month you spent '),
                        _bold(cs, aaMoney(lastMonth)),
                        const TextSpan(text: '. Two months ago: '),
                        _bold(cs, aaMoney(twoAgo)),
                        const TextSpan(text: '. Average: '),
                        _bold(cs, aaMoney(avg)),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                _Label('BUDGET FORECAST'),
                const SizedBox(height: KuberSpacing.sm),
                if (data.budgetForecasts.isEmpty)
                  _InfoCard(
                    child: Text(
                      budgets.where((b) => b.isActive).isEmpty
                          ? 'No budgets created yet. Create a budget to see how this month is tracking against it.'
                          : 'All your budgets are on track for this month.',
                      style: localeFont(
                        fontSize: 12.5,
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  )
                else ...[
                  for (final b in data.budgetForecasts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
                      child: Container(
                        padding: const EdgeInsets.all(KuberSpacing.md),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                          border: Border.all(
                            color: warning.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: CategoryLabel(b.categoryId)),
                                Text(
                                  aaPercent(b.utilization * 100),
                                  style: localeFont(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: warning,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'At current pace, will hit ${aaPercent(b.utilization * 100)} by end of month.',
                              style: localeFont(
                                fontSize: 11.5,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: KuberSpacing.lg),
                _Label('UPCOMING IN NEXT 30 DAYS'),
                const SizedBox(height: KuberSpacing.sm),
                if (upcoming.isEmpty)
                  _InfoCard(
                    child: Text(
                      'Nothing scheduled in the next 30 days.',
                      style: localeFont(
                        fontSize: 12.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                else ...[
                  for (final e in upcoming)
                    _KvRow(
                      left: e.title,
                      right: aaMoney((e.amount ?? 0).abs()),
                    ),
                  _KvRow(left: 'Total', right: aaMoney(upcomingTotal), bold: true),
                ],
                const SizedBox(height: KuberSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'This is an estimate based on your recent activity.',
                        style: localeFont(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
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

TextSpan _bold(ColorScheme cs, String text) => TextSpan(
      text: text,
      style: localeFont(fontWeight: FontWeight.w800, color: cs.onSurface),
    );

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: localeFont(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});
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

class _KvRow extends StatelessWidget {
  final String left;
  final String right;
  final bool bold;
  const _KvRow({required this.left, required this.right, this.bold = false});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: localeFont(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ),
          Text(
            right,
            style: localeFont(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: localeFont(fontSize: 10.5, color: cs.onSurfaceVariant)),
      ],
    );
  }
}
