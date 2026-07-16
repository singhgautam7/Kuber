import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/kuber_skeleton.dart';
import '../../pro/more/more_premium_card.dart';
import '../../pro/paywall/pro_state.dart';
import '../providers/advanced_analytics_provider.dart';
import '../widgets/about_analytics_info_sheet.dart';
import '../widgets/analytics_common.dart';

class AdvancedAnalyticsLanding extends ConsumerStatefulWidget {
  const AdvancedAnalyticsLanding({super.key});

  @override
  ConsumerState<AdvancedAnalyticsLanding> createState() =>
      _AdvancedAnalyticsLandingState();
}

class _AdvancedAnalyticsLandingState
    extends ConsumerState<AdvancedAnalyticsLanding> {
  @override
  Widget build(BuildContext context) {
    final hasAccess = ref.watch(
      kuberProStateProvider.select((s) => s.hasProAccess),
    );

    return Scaffold(
      appBar: KuberAppBar(
        showBack: true,
        showHome: true,
        showBrand: false,
        infoConfig: hasAccess ? kAboutAdvancedAnalyticsInfoConfig : null,
      ),
      body: hasAccess
          // ListView.builder (not a static children list) so off-screen
          // preview cards are built lazily. Each card watches its own heavy
          // `compute()` provider; building them all on the first frame spawned
          // ~8 isolates at once and janked the open. Now the visible cards
          // render skeletons immediately and the rest hydrate as they scroll
          // into view.
          ? ListView.builder(
              // No horizontal padding here — KuberPageHeader supplies its own
              // 20px, and the cards get matching horizontal padding below.
              padding: const EdgeInsets.only(bottom: KuberSpacing.xxl),
              itemCount: _landingCards.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const KuberPageHeader(
                    title: 'Advanced Analytics',
                    description: 'Deep analysis of your financial patterns',
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    KuberSpacing.md,
                  ),
                  child: _landingCards[index - 1],
                );
              },
            )
          : const _LockedUpgradeView(),
    );
  }
}

/// The landing preview cards, in order. Kept as a const list so the lazy
/// [ListView.builder] can index into them.
const List<Widget> _landingCards = [
  _HealthScoreCard(),
  _TrendsCard(),
  _CategoryDeepDiveCard(),
  _SpendingPatternsCard(),
  _ForecastCard(),
  _CashFlowCard(),
  _AnomalyCard(),
  _MerchantCard(),
  _SavingsRateCard(),
];

class _RowCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? preview;
  final Widget? subtitle;
  final VoidCallback onTap;

  const _RowCard({
    required this.title,
    required this.icon,
    this.preview,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: cs.primary, size: 20),
                const SizedBox(width: KuberSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: KuberSpacing.xs),
              subtitle!,
            ],
            if (preview != null) ...[
              const SizedBox(height: KuberSpacing.sm),
              preview!,
            ],
          ],
        ),
      ),
    );
  }
}

class _HealthScoreCard extends ConsumerWidget {
  const _HealthScoreCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(financialHealthProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const KuberSkeleton(height: 72),
      error: (_, __) => _RowCard(
        title: 'Financial health score',
        icon: Icons.health_and_safety_outlined,
        subtitle: Text(
          'Score calculation error',
          style: localeFont(fontSize: 12, color: cs.error),
        ),
        onTap: () => context.push('/advanced-analytics/health-score'),
      ),
      data: (score) {
        final scoreVal = score.total;
        final rating = scoreVal >= 75
            ? 'Good'
            : scoreVal >= 50
                ? 'Fair'
                : 'Needs improvement';
        final focus = score.improvementAreas.isNotEmpty
            ? 'focus on ${score.improvementAreas.first.toLowerCase()} next'
            : 'finances are in great shape';

        return InkWell(
          onTap: () => context.push('/advanced-analytics/health-score'),
          borderRadius: BorderRadius.circular(KuberRadius.md),
          child: Container(
            padding: const EdgeInsets.all(KuberSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: scoreVal / 100,
                        strokeWidth: 4,
                        color: scoreVal >= 75
                            ? cs.tertiary
                            : scoreVal >= 50
                                ? context.kuberColors.warning
                                : cs.error,
                        backgroundColor: cs.outline,
                      ),
                      Text(
                        '$scoreVal',
                        style: localeFont(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
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
                      Text(
                        'Financial health score',
                        style: localeFont(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          style: localeFont(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: rating,
                              style: localeFont(
                                fontWeight: FontWeight.bold,
                                color: scoreVal >= 75
                                    ? cs.tertiary
                                    : scoreVal >= 50
                                        ? context.kuberColors.warning
                                        : cs.error,
                              ),
                            ),
                            TextSpan(text: ' · $focus'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrendsCard extends ConsumerWidget {
  const _TrendsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trendsProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const KuberSkeleton(height: 84),
      error: (_, __) => _RowCard(
        title: 'Year over year',
        icon: Icons.bar_chart_rounded,
        onTap: () => context.push('/advanced-analytics/trends'),
      ),
      data: (data) {
        final change = data.percentChange;
        final isNegative = change <= 0;
        final changeText =
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% vs last year';

        final bars = [
          ...data.previousSeries.map((m) => m.expense),
          ...data.currentSeries.map((m) => m.expense),
        ].take(6).toList();

        return _RowCard(
          title: 'Year over year',
          icon: Icons.bar_chart_rounded,
          onTap: () => context.push('/advanced-analytics/trends'),
          preview: Row(
            children: [
              if (bars.isNotEmpty)
                SizedBox(
                  width: 80,
                  height: 24,
                  child: TinyBars(
                    values: bars,
                    color: cs.primary,
                  ),
                ),
              const Spacer(),
              Text(
                changeText,
                style: localeFont(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isNegative ? cs.tertiary : cs.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryDeepDiveCard extends StatelessWidget {
  const _CategoryDeepDiveCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _RowCard(
      title: 'Category deep-dive',
      icon: Icons.category_outlined,
      subtitle: Text(
        'Pick any category for merchants, trends & weekday habits',
        style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      onTap: () => context.push('/advanced-analytics/category'),
    );
  }
}

class _SpendingPatternsCard extends ConsumerWidget {
  const _SpendingPatternsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(spendingPatternsProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const KuberSkeleton(height: 72),
      error: (_, __) => _RowCard(
        title: 'Spending patterns',
        icon: Icons.donut_large_rounded,
        onTap: () => context.push('/advanced-analytics/spending-patterns'),
      ),
      data: (data) {
        if (data.transactionCount < 30) {
          return _RowCard(
            title: 'Spending patterns',
            icon: Icons.donut_large_rounded,
            subtitle: Text(
              'Not enough transaction history yet',
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            onTap: () => context.push('/advanced-analytics/spending-patterns'),
          );
        }

        // Find weekday with highest average
        var maxAvgIdx = 0;
        var maxAvg = 0.0;
        for (var i = 0; i < data.weekdayAverages.length; i++) {
          if (data.weekdayAverages[i] > maxAvg) {
            maxAvg = data.weekdayAverages[i];
            maxAvgIdx = i;
          }
        }
        const days = [
          'Mondays',
          'Tuesdays',
          'Wednesdays',
          'Thursdays',
          'Fridays',
          'Saturdays',
          'Sundays'
        ];
        final maxDay = days[maxAvgIdx];

        // Find time bucket with highest spending
        var maxTime = 'evening';
        var maxTimeVal = 0.0;
        for (final entry in data.timeBuckets.entries) {
          if (entry.value > maxTimeVal) {
            maxTimeVal = entry.value;
            maxTime = entry.key.toLowerCase();
          }
        }

        return _RowCard(
          title: 'Spending patterns',
          icon: Icons.donut_large_rounded,
          subtitle: RichText(
            text: TextSpan(
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
              children: [
                const TextSpan(text: 'You spend most on '),
                TextSpan(
                  text: maxDay,
                  style: localeFont(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const TextSpan(text: ', mostly in the '),
                TextSpan(
                  text: maxTime,
                  style: localeFont(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          onTap: () => context.push('/advanced-analytics/spending-patterns'),
        );
      },
    );
  }
}

class _ForecastCard extends ConsumerWidget {
  const _ForecastCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(forecastProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const KuberSkeleton(height: 72),
      error: (_, __) => _RowCard(
        title: 'Forecast',
        icon: Icons.trending_up_rounded,
        onTap: () => context.push('/advanced-analytics/forecast'),
      ),
      data: (data) {
        if (data.monthsTracked < 2) {
          return _RowCard(
            title: 'Forecast',
            icon: Icons.trending_up_rounded,
            subtitle: Text(
              'Forecast needs 2 months of history',
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            onTap: () => context.push('/advanced-analytics/forecast'),
          );
        }

        return _RowCard(
          title: 'Forecast',
          icon: Icons.trending_up_rounded,
          subtitle: RichText(
            text: TextSpan(
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
              children: [
                const TextSpan(text: 'Likely to spend '),
                TextSpan(
                  text: aaMoney(data.projectedTotal),
                  style: localeFont(
                    fontWeight: FontWeight.bold,
                    color: context.kuberColors.warning,
                  ),
                ),
                const TextSpan(text: ' by month end (estimate)'),
              ],
            ),
          ),
          onTap: () => context.push('/advanced-analytics/forecast'),
        );
      },
    );
  }
}

class _CashFlowCard extends ConsumerWidget {
  const _CashFlowCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(monthlyLedgerProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const KuberSkeleton(height: 72),
      error: (_, __) => _RowCard(
        title: 'Cash flow',
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => context.push('/advanced-analytics/cash-flow'),
      ),
      data: (months) {
        if (months.isEmpty) {
          return _RowCard(
            title: 'Cash flow',
            icon: Icons.account_balance_wallet_outlined,
            subtitle: Text(
              'Track income and expenses to see ledger',
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            onTap: () => context.push('/advanced-analytics/cash-flow'),
          );
        }

        final negative = months.where((m) => m.net < 0).length;
        final label = negative == 0
            ? 'Consistent positive cash flow'
            : negative > months.length / 2
                ? 'Negative cash flow is frequent'
                : 'Cash flow is variable';

        final income = months.fold<double>(0, (sum, m) => sum + m.income);
        final expense = months.fold<double>(0, (sum, m) => sum + m.expense);
        final rate = income <= 0 ? 0.0 : ((income - expense) / income) * 100;

        return _RowCard(
          title: 'Cash flow',
          icon: Icons.account_balance_wallet_outlined,
          subtitle: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: negative == 0 ? cs.tertiary : context.kuberColors.warning,
                ),
              ),
              const SizedBox(width: KuberSpacing.xs),
              Expanded(
                child: Text(
                  '$label · ${rate.toStringAsFixed(0)}% savings rate · includes monthly ledger',
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          onTap: () => context.push('/advanced-analytics/cash-flow'),
        );
      },
    );
  }
}

class _AnomalyCard extends ConsumerWidget {
  const _AnomalyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(anomalyProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const KuberSkeleton(height: 72),
      error: (_, __) => _RowCard(
        title: 'Anomaly detection',
        icon: Icons.radar_rounded,
        onTap: () => context.push('/advanced-analytics/anomalies'),
      ),
      data: (data) {
        final count = data.items.length;
        final subtitle = count == 0
            ? 'No unusual patterns detected'
            : '$count unusual pattern${count > 1 ? 's' : ''} noticed this month';

        return _RowCard(
          title: 'Anomaly detection',
          icon: Icons.radar_rounded,
          subtitle: Text(
            subtitle,
            style: localeFont(
              fontSize: 12,
              color: count == 0 ? cs.onSurfaceVariant : cs.error,
              fontWeight: count == 0 ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          onTap: () => context.push('/advanced-analytics/anomalies'),
        );
      },
    );
  }
}

class _MerchantCard extends ConsumerWidget {
  const _MerchantCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(merchantAnalysisProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const KuberSkeleton(height: 72),
      error: (_, __) => _RowCard(
        title: 'Merchant analysis',
        icon: Icons.storefront_outlined,
        onTap: () => context.push('/advanced-analytics/merchants'),
      ),
      data: (data) {
        if (data.merchantCount < 3 || data.topMerchants.isEmpty) {
          return _RowCard(
            title: 'Merchant analysis',
            icon: Icons.storefront_outlined,
            subtitle: Text(
              'Not enough merchant history yet',
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            onTap: () => context.push('/advanced-analytics/merchants'),
          );
        }

        final topMerchant = data.topMerchants.first.name;

        return _RowCard(
          title: 'Merchant analysis',
          icon: Icons.storefront_outlined,
          subtitle: RichText(
            text: TextSpan(
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
              children: [
                TextSpan(
                  text: topMerchant,
                  style: localeFont(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const TextSpan(text: ' is your top merchant this period'),
              ],
            ),
          ),
          onTap: () => context.push('/advanced-analytics/merchants'),
        );
      },
    );
  }
}

class _SavingsRateCard extends ConsumerWidget {
  const _SavingsRateCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savingsRateProvider);
    final cs = Theme.of(context).colorScheme;

    return async.when(
      loading: () => const KuberSkeleton(height: 72),
      error: (_, __) => _RowCard(
        title: 'Savings rate tracker',
        icon: Icons.savings_outlined,
        onTap: () => context.push('/advanced-analytics/savings-rate'),
      ),
      data: (data) {
        if (data.months.length < 3) {
          return _RowCard(
            title: 'Savings rate tracker',
            icon: Icons.savings_outlined,
            subtitle: Text(
              'Savings rate tracker needs 3 months of history',
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            onTap: () => context.push('/advanced-analytics/savings-rate'),
          );
        }

        final overallRate = data.overallRate;
        final targetMet = overallRate >= 20;

        return _RowCard(
          title: 'Savings rate tracker',
          icon: Icons.savings_outlined,
          subtitle: RichText(
            text: TextSpan(
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
              children: [
                TextSpan(
                  text: '${overallRate.toStringAsFixed(0)}%',
                  style: localeFont(
                    fontWeight: FontWeight.bold,
                    color: targetMet ? cs.tertiary : context.kuberColors.warning,
                  ),
                ),
                const TextSpan(text: ' overall rate · '),
                TextSpan(
                  text: targetMet ? 'above' : 'below',
                  style: localeFont(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' your 20% target'),
              ],
            ),
          ),
          onTap: () => context.push('/advanced-analytics/savings-rate'),
        );
      },
    );
  }
}

class _LockedUpgradeView extends StatelessWidget {
  const _LockedUpgradeView();

  static const _features = <String>[
    'Financial health score with a breakdown of every factor',
    'Month over month and year over year trends',
    'Category deep-dives and spending patterns',
    'Conservative forecast for the current month',
    'Cash flow, anomalies, merchant analysis and savings rate',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KuberSpacing.lg,
        0,
        KuberSpacing.lg,
        KuberSpacing.xxl,
      ),
      children: [
        const KuberPageHeader(
          title: 'Advanced Analytics',
          description: 'Deep analysis of your financial patterns',
        ),
        const SizedBox(height: KuberSpacing.md),
        const MorePremiumHeroCard(),
        const SizedBox(height: KuberSpacing.lg),
        Text(
          "What's inside",
          style: localeFont(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        for (final feature in _features)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: KuberSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: cs.primary,
                ),
                const SizedBox(width: KuberSpacing.sm),
                Expanded(
                  child: Text(
                    feature,
                    style: localeFont(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
