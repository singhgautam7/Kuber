import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
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
        ref.watch(upcomingEventsProvider).valueOrNull ??
        const <UpcomingEvent>[];
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberMoney.warning;

    const note = FixedWindowNote(
      message:
          "Forecasts are always based on your current month and recent history. They don't follow section date filters.",
    );
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            final limit = totalBudget > 0
                ? totalBudget
                : data.projectedTotal * 0.85;

            double monthTotal(int offset) {
              final start = DateTime(now.year, now.month - offset, 1);
              final end = DateTime(now.year, now.month - offset + 1, 0);
              return txns
                  .where(
                    (t) =>
                        t.type == 'expense' &&
                        !t.isTransfer &&
                        !t.isBalanceAdjustment &&
                        !t.createdAt.isBefore(start) &&
                        t.createdAt.isBefore(end.add(const Duration(days: 1))),
                  )
                  .fold<double>(0, (s, t) => s + t.amount);
            }

            final lastMonth = monthTotal(1);
            final twoAgo = monthTotal(2);
            final avg = (lastMonth + twoAgo) / 2;

            // Outgoing obligations in the next 30 days (negative amount).
            final upcoming = eventsWithinDays(
              upcomingEvents,
              30,
            ).where((e) => (e.amount ?? 0) < 0).toList();
            final upcomingTotal = upcoming.fold<double>(
              0,
              (s, e) => s + (e.amount ?? 0).abs(),
            );

            final spentPct = data.projectedTotal <= 0
                ? 0.0
                : (lastActual / data.projectedTotal).clamp(0.0, 1.0);
            final body = tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant);
            final small = tt.bodySmall!.copyWith(color: cs.onSurfaceVariant);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Board "Forecast": the hero card, then the reasoning.
                KuberCard(
                  hero: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROJECTED MONTH-END SPEND',
                        style: sectionHeaderStyle(context),
                      ),
                      const SizedBox(height: KuberSpace.xs),
                      Text(
                        aaMoney(data.projectedTotal),
                        style: tt.headlineMedium!.copyWith(color: cs.onSurface),
                      ),
                      const SizedBox(height: KuberSpace.md),
                      KuberLinearProgress(
                        value: spentPct,
                        state: data.projectedTotal > limit
                            ? KuberProgressState.nearLimit
                            : KuberProgressState.normal,
                      ),
                      const SizedBox(height: KuberSpace.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Spent ${aaMoney(lastActual)}',
                              style: small,
                            ),
                          ),
                          Text(
                            'Last month ${aaMoney(lastMonth)}',
                            style: small,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpace.lg),
                Text.rich(
                  TextSpan(
                    style: body,
                    children: [
                      const TextSpan(
                        text: 'Based on your recurring transactions (',
                      ),
                      _bold(cs, aaMoney(data.lockedInRecurring)),
                      const TextSpan(
                        text: ' locked in) and current discretionary pace (',
                      ),
                      _bold(
                        cs,
                        aaMoney(
                          data.discretionarySoFar + data.projectedDiscretionary,
                        ),
                      ),
                      const TextSpan(
                        text: " projected), you're likely to spend ",
                      ),
                      _bold(cs, aaMoney(data.projectedTotal)),
                      const TextSpan(text: ' by month end.'),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpace.md),
                note,
                const SizedBox(height: KuberSpace.sectionGap - 4),
                AnalyticsSectionCard(
                  title: 'This month',
                  icon: Icons.auto_graph_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ForecastZoneChart(
                        actuals: actuals,
                        projections: projections,
                        limit: limit,
                      ),
                      const SizedBox(height: KuberSpace.sm),
                      Wrap(
                        spacing: KuberSpace.lg,
                        children: [
                          _LegendDot(
                            color: context.kuberMoney.income,
                            label: 'Safe',
                          ),
                          _LegendDot(color: warning, label: 'Warning'),
                          _LegendDot(
                            color: context.kuberMoney.expense,
                            label: 'Over',
                          ),
                        ],
                      ),
                      const SizedBox(height: KuberSpace.md),
                      Text.rich(
                        TextSpan(
                          style: body,
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
                    ],
                  ),
                ),
                const KuberSectionHeader(title: 'Budget forecast'),
                if (data.budgetForecasts.isEmpty)
                  _InfoCard(
                    child: Text(
                      budgets.where((b) => b.isActive).isEmpty
                          ? 'No budgets created yet. Create a budget to see how this month is tracking against it.'
                          : 'All your budgets are on track for this month.',
                      style: body,
                    ),
                  )
                else
                  KuberGroup(
                    children: [
                      for (final b in data.budgetForecasts)
                        AnalyticsCategoryRow(
                          categoryId: b.categoryId,
                          subtitle:
                              'At current pace, will hit ${aaPercent(b.utilization * 100)}',
                          trailing: KuberPill(
                            label: b.utilization >= 1 ? 'Over' : 'Warning',
                            tone: b.utilization >= 1
                                ? KuberTone.expense
                                : KuberTone.warning,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: KuberSpace.sectionGap - 4),
                const KuberSectionHeader(title: 'Upcoming in next 30 days'),
                if (upcoming.isEmpty)
                  _InfoCard(
                    child: Text(
                      'Nothing scheduled in the next 30 days.',
                      style: body,
                    ),
                  )
                else
                  KuberGroup(
                    children: [
                      for (final e in upcoming)
                        KuberListRow(
                          title: e.title,
                          subtitle: DateFormat('MMM d').format(e.date),
                          trailing: Text(
                            aaMoney((e.amount ?? 0).abs()),
                            style: tt.titleSmall!.copyWith(color: cs.onSurface),
                          ),
                        ),
                      KuberListRow(
                        title: 'Total',
                        trailing: Text(
                          aaMoney(upcomingTotal),
                          style: tt.titleMedium!.copyWith(color: cs.onSurface),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: KuberSpace.lg),
                const FixedWindowNote(
                  message: 'This is an estimate based on your recent activity.',
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
  style: localeFont(fontWeight: FontWeight.w700, color: cs.onSurface),
);

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});
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
            borderRadius: BorderRadius.circular(KuberShape.full),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
