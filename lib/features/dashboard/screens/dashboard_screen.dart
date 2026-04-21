import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
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
import '../widgets/quick_add_widget.dart';

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

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final String _subtitle;
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _subtitle = _subtitles[Random().nextInt(_subtitles.length)];
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: 0.0, end: 1.0).animate(_shimmerCtrl);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(settingsProvider.select(
      (async) => async.valueOrNull?.userName ?? '',
    ));
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
          KuberAppBar(
            horizontalPadding: 0,
            actions: [
              AnimatedBuilder(
                animation: _shimmerAnim,
                builder: (_, __) {
                  final t = _shimmerAnim.value;
                  const gold = Color(0xFFFFB300);
                  // Gradient always spans full width; stops move the highlight band
                  final bandStart = (t - 0.18).clamp(0.0, 1.0);
                  final bandMid   = t.clamp(0.0, 1.0);
                  final bandEnd   = (t + 0.18).clamp(0.0, 1.0);
                  return GestureDetector(
                    onTap: () => context.push('/more/ask-kuber'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            gold.withValues(alpha: 0.08),
                            gold.withValues(alpha: 0.08),
                            gold.withValues(alpha: 0.30),
                            gold.withValues(alpha: 0.08),
                            gold.withValues(alpha: 0.08),
                          ],
                          stops: [0.0, bandStart, bandMid, bandEnd, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: gold.withValues(alpha: 0.55), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 13, color: gold),
                          const SizedBox(width: 5),
                          Text(
                            'Ask Kuber',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName.isNotEmpty
                    ? '${_timeGreeting()}, ${userName.toTitleCase()}'
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
          const SizedBox(height: KuberSpacing.lg),

          // [A] Balance Hero Card
          RepaintBoundary(
            child: summaryAsync.when(
              loading: () => const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (summary) => _BalanceHeroCard(summary: summary),
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),

          // Quick Add
          const QuickAddWidget(),
          const SizedBox(height: KuberSpacing.md),
          const SizedBox(height: KuberSpacing.md),

          // [A.1] Spending Stats
          const RepaintBoundary(child: SpendingStatsCard()),
          const SizedBox(height: KuberSpacing.md),

          // [B] Bank Accounts
          const RepaintBoundary(child: HomeAccountsCard()),
          const SizedBox(height: KuberSpacing.xl),

          // [C] 7-Day Chart
          RepaintBoundary(
            child: chartAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (days) {
                final hasData = days.any((d) => d.income > 0 || d.expense > 0);
                if (!hasData) {
                  return const _SpendingAnalysisEmpty();
                }
                return KuberBarChart(
                  title: 'SPENDING ANALYSIS',
                  subtitle: 'Last 7 Days Activity',
                  buckets: _buildLast7DaysBuckets(days),
                  height: 200,
                );
              },
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),

          // [A.2] Smart Insights
          const RepaintBoundary(child: HomeSmartInsights()),

          // Budget Snapshot
          const RepaintBoundary(child: BudgetSnapshotCard()),

          // [C.5] Upcoming Recurring
          const RepaintBoundary(child: HomeRecurringCard()),

          // [D] Recent Transactions
          const RepaintBoundary(child: HomeRecentTransactionsCard()),
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
            'This Month\'s Balance',
            style: textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          Builder(
            builder: (context) {
              final formatter = ref.watch(formatterProvider);
              final formattedRaw = formatter.formatCurrency(summary.net.abs(), symbol: '').trim();
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

class _BalanceTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                  ref.watch(formatterProvider).formatCurrency(amount),
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

class _SpendingAnalysisEmpty extends StatelessWidget {
  const _SpendingAnalysisEmpty();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPENDING ANALYSIS',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Last 7 Days Activity',
            style: textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
              child: Text(
                'No income or expense transactions in the last 7 days. '
                'Add a transaction to see your spending analysis here.'
                '\n\nNote: Transfers are not included.',
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
