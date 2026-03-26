import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_bar_chart.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/home_smart_insights.dart';
import '../widgets/spending_stats_card.dart';
import '../widgets/budget_snapshot_card.dart';
import '../widgets/home_accounts_card.dart';
import '../widgets/home_recurring_card.dart';
import '../widgets/home_recent_transactions.dart';

const _subtitles = [
  'Let\'s manage your money wisely',
  'Track every rupee, every day',
  'Stay on top of your finances',
  'Your wallet will thank you later',
  'Small savings, big results',
  'Every transaction counts',
  'Building smart money habits',
];

String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Morning';
  if (hour < 17) return 'Afternoon';
  return 'Evening';
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final String _subtitle;

  @override
  void initState() {
    super.initState();
    _subtitle = _subtitles[Random().nextInt(_subtitles.length)];
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(settingsProvider).valueOrNull?.userName ?? '';
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final chartAsync = ref.watch(last7DaysSummaryProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          left: KuberSpacing.lg,
          right: KuberSpacing.lg,
          bottom: navBarBottomPadding(context),
        ),
        children: [
          const KuberAppBar(),
          const SizedBox(height: KuberSpacing.lg),

          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName.isNotEmpty
                    ? '${_timeGreeting()}, $userName'
                    : _timeGreeting(),
                style: textTheme.displaySmall?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: KuberSpacing.xs),
              Text(
                _subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.xl),

          // [A] Balance Hero Card
          summaryAsync.when(
            loading: () => const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (summary) => _BalanceHeroCard(summary: summary),
          ),
          const SizedBox(height: KuberSpacing.md),

          // [A.1] Spending Stats
          const SpendingStatsCard(),
          const SizedBox(height: KuberSpacing.md),

          // [B] Bank Accounts
          const HomeAccountsCard(),
          const SizedBox(height: KuberSpacing.xl),

          // [C] 7-Day Chart
          chartAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (days) => KuberBarChart(
              title: 'Spending Analysis',
              subtitle: 'Last 7 Days Activity',
              buckets: _buildLast7DaysBuckets(days),
              height: 200,
              currencySymbol: ref.watch(currencyProvider).symbol,
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),

          // [A.2] Smart Insights
          const HomeSmartInsights(),
          const SizedBox(height: KuberSpacing.xl),

          // Budget Snapshot
          const BudgetSnapshotCard(),
          const SizedBox(height: KuberSpacing.xl),

          // [C.5] Upcoming Recurring
          const HomeRecurringCard(),
          const SizedBox(height: KuberSpacing.xl),

          // [D] Recent Transactions
          const HomeRecentTransactionsCard(),
        ],
      ),
    );
  }

  List<KuberBarBucket> _buildLast7DaysBuckets(List<DaySummary> days) {
    return List.generate(days.length, (i) {
      final d = days[i];
      return KuberBarBucket(
        dayLabel: DateFormat('d').format(d.date),
        monthLabel: DateFormat('MMM').format(d.date).toUpperCase(),
        income: d.income,
        expense: d.expense,
        isHighlighted: i == days.length - 1,
      );
    });
  }
}

class _BalanceHeroCard extends ConsumerWidget {
  final MonthlySummary summary;

  const _BalanceHeroCard({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final symbol = ref.watch(currencyProvider).symbol;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Total Balance',
            style: textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          Builder(
            builder: (context) {
              final formattedRaw = CurrencyFormatter.format(summary.net.abs()).replaceAll(symbol, '');
              final prefix = summary.net < 0 ? '-' : '';

              return RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    letterSpacing: -0.05,
                    color: cs.onSurface,
                  ) ?? const TextStyle(),
                  children: [
                    TextSpan(text: prefix),
                    TextSpan(
                      text: symbol,
                      style: TextStyle(color: cs.primary),
                    ),
                    TextSpan(text: formattedRaw),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: KuberSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _BalanceTile(
                  label: 'Income',
                  amount: summary.totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: cs.tertiary,
                ),
              ),
              const SizedBox(width: KuberSpacing.lg),
              Expanded(
                child: _BalanceTile(
                  label: 'Expense',
                  amount: summary.totalExpense,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: cs.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;

  const _BalanceTile({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
               color: cs.outline.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(amount),
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
