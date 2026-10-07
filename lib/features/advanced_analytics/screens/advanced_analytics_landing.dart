import 'package:flutter/material.dart';
import 'package:kuber/shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
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
      body: KuberScrollAwayHeader(
        header: KuberAppBar(
          title: 'Advanced Analytics',
          showBack: true,
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
                padding: const EdgeInsets.only(bottom: KuberSpace.xxl),
                itemCount: _landingCards.length + 1,
                // Board 3.6c: the health score is its own card; every other
                // section is a row of one grouped list. The rows stay separate
                // lazy items (drawn as segments of the group) so off-screen
                // sections still build late.
                itemBuilder: (context, index) {
                  if (index == 0) return const SizedBox.shrink();
                  final i = index - 1;
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KuberSpace.screenMargin,
                        0,
                        KuberSpace.screenMargin,
                        KuberSpace.md,
                      ),
                      child: _landingCards[0],
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KuberSpace.screenMargin,
                    ),
                    child: _GroupSegment(
                      isFirst: i == 1,
                      isLast: i == _landingCards.length - 1,
                      child: _landingCards[i],
                    ),
                  );
                },
              )
            : const _LockedUpgradeView(),
      ),
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

/// One segment of the sections group: surfaceContainer with the outline on
/// the outer edges, rounded at the ends, a divider between rows.
class _GroupSegment extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Widget child;
  const _GroupSegment({
    required this.isFirst,
    required this.isLast,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final side = BorderSide(color: cs.outlineVariant);
    final radius = BorderRadius.vertical(
      top: isFirst ? KuberShape.cardR.topLeft : Radius.zero,
      bottom: isLast ? KuberShape.cardR.bottomLeft : Radius.zero,
    );
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: radius,
        border: Border(
          left: side,
          right: side,
          top: side,
          bottom: isLast ? side : BorderSide.none,
        ),
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );
  }
}

/// A section row (board 3.6c): primary glyph, title, one-line summary,
/// chevron.
class _RowCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? subtitle;
  final VoidCallback onTap;

  const _RowCard({
    required this.title,
    required this.icon,
    this.subtitle,
    required this.onTap,
  });

  /// Placeholder row while the section's provider computes.
  static Widget loading(String title, IconData icon, VoidCallback onTap) =>
      _RowCard(
        title: title,
        icon: icon,
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: KuberSkeleton(width: 160, height: 12),
        ),
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Icon(icon, color: cs.primary, size: 24),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium!.copyWith(color: cs.onSurface),
                    ),
                    if (subtitle != null)
                      DefaultTextStyle.merge(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: subtitle!,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpace.sm),
              const KuberChevron(),
            ],
          ),
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
      loading: () => const KuberSkeleton(height: 88),
      error: (_, __) => KuberGroup(
        children: [
          _RowCard(
            title: 'Financial health score',
            icon: Icons.health_and_safety_outlined,
            subtitle: Text(
              'Score calculation error',
              style: localeFont(fontSize: 12, color: cs.error),
            ),
            onTap: () => context.push('/advanced-analytics/health-score'),
          ),
        ],
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

        final ratingColor = scoreVal >= 75
            ? context.kuberMoney.income
            : scoreVal >= 50
            ? context.kuberMoney.warning
            : cs.error;
        final tt = Theme.of(context).textTheme;
        // Board 3.6c: its own card above the sections group.
        return KuberCard(
          onTap: () => context.push('/advanced-analytics/health-score'),
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: scoreVal / 100,
                        strokeWidth: 5,
                        strokeCap: StrokeCap.round,
                        color: cs.primary,
                        backgroundColor: cs.secondaryContainer,
                      ),
                    ),
                    Text(
                      '$scoreVal',
                      style: tt.titleMedium!.copyWith(color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial health score',
                      style: tt.titleMedium!.copyWith(color: cs.onSurface),
                    ),
                    Text.rich(
                      TextSpan(
                        style: tt.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: rating,
                            style: TextStyle(
                              color: ratingColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' · $focus'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpace.sm),
              const KuberChevron(),
            ],
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
      loading: () => _RowCard.loading(
        'Year over year',
        Icons.bar_chart_rounded,
        () => context.push('/advanced-analytics/trends'),
      ),
      error: (_, __) => _RowCard(
        title: 'Year over year',
        icon: Icons.bar_chart_rounded,
        onTap: () => context.push('/advanced-analytics/trends'),
      ),
      data: (data) {
        final change = data.percentChange;
        final changeText =
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% vs last year';

        return _RowCard(
          title: 'Year over year',
          icon: Icons.bar_chart_rounded,
          onTap: () => context.push('/advanced-analytics/trends'),
          subtitle: Text(
            changeText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
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
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
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
      loading: () => _RowCard.loading(
        'Spending patterns',
        Icons.donut_large_rounded,
        () => context.push('/advanced-analytics/spending-patterns'),
      ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
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
          'Sundays',
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
          subtitle: Text.rich(
            TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
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
      loading: () => _RowCard.loading(
        'Forecast',
        Icons.trending_up_rounded,
        () => context.push('/advanced-analytics/forecast'),
      ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            ),
            onTap: () => context.push('/advanced-analytics/forecast'),
          );
        }

        return _RowCard(
          title: 'Forecast',
          icon: Icons.trending_up_rounded,
          subtitle: Text.rich(
            TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              children: [
                const TextSpan(text: 'Likely to spend '),
                TextSpan(
                  text: aaMoney(data.projectedTotal),
                  style: localeFont(
                    fontWeight: FontWeight.bold,
                    color: context.kuberMoney.warning,
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
      loading: () => _RowCard.loading(
        'Cash flow',
        Icons.account_balance_wallet_outlined,
        () => context.push('/advanced-analytics/cash-flow'),
      ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
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
                  color: negative == 0
                      ? context.kuberMoney.income
                      : context.kuberMoney.warning,
                ),
              ),
              const SizedBox(width: KuberSpace.xs),
              Expanded(
                child: Text(
                  '$label · ${rate.toStringAsFixed(0)}% savings rate · includes monthly ledger',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
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
      loading: () => _RowCard.loading(
        'Anomaly detection',
        Icons.radar_rounded,
        () => context.push('/advanced-analytics/anomalies'),
      ),
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
      loading: () => _RowCard.loading(
        'Merchant analysis',
        Icons.storefront_outlined,
        () => context.push('/advanced-analytics/merchants'),
      ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            ),
            onTap: () => context.push('/advanced-analytics/merchants'),
          );
        }

        final topMerchant = data.topMerchants.first.name;

        return _RowCard(
          title: 'Merchant analysis',
          icon: Icons.storefront_outlined,
          subtitle: Text.rich(
            TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
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
      loading: () => _RowCard.loading(
        'Savings rate tracker',
        Icons.savings_outlined,
        () => context.push('/advanced-analytics/savings-rate'),
      ),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
            ),
            onTap: () => context.push('/advanced-analytics/savings-rate'),
          );
        }

        final overallRate = data.overallRate;
        final targetMet = overallRate >= 20;

        return _RowCard(
          title: 'Savings rate tracker',
          icon: Icons.savings_outlined,
          subtitle: Text.rich(
            TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              children: [
                TextSpan(
                  text: '${overallRate.toStringAsFixed(0)}%',
                  style: localeFont(
                    fontWeight: FontWeight.bold,
                    color: targetMet
                        ? context.kuberMoney.income
                        : context.kuberMoney.warning,
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
        KuberSpace.lg,
        0,
        KuberSpace.lg,
        KuberSpace.xxl,
      ),
      children: [
        const MorePremiumHeroCard(),
        const SizedBox(height: KuberSpace.lg),
        Text(
          "What's inside",
          style: localeFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: KuberSpace.sm),
        for (final feature in _features)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: KuberSpace.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: cs.primary,
                ),
                const SizedBox(width: KuberSpace.sm),
                Expanded(
                  child: Text(
                    feature,
                    style: localeFont(
                      fontSize: 14,
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
