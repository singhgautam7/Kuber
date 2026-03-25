import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_bar_chart.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../../shared/widgets/transaction_list_item.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../recurring/providers/recurring_provider.dart';
import '../../recurring/widgets/recurring_detail_sheet.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/home_smart_insights.dart';
import '../widgets/spending_stats_card.dart';
import '../widgets/budget_snapshot_card.dart';

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
    final cs = Theme.of(context).colorScheme;
    final colorScheme = cs;
    final textTheme = Theme.of(context).textTheme;
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final accountsAsync = ref.watch(accountListProvider);
    final recentAsync = ref.watch(recentTransactionsProvider);
    final chartAsync = ref.watch(last7DaysSummaryProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final userName = ref.watch(settingsProvider).valueOrNull?.userName ?? '';

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

            // [A.2] Smart Insights
            const HomeSmartInsights(),

            // Budget Snapshot
            const BudgetSnapshotCard(),

            // [B] Bank Accounts
            accountsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (accounts) {
                if (accounts.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bank Accounts',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                        TextButton(
                          onPressed: () => context.push('/more/accounts'),
                          child: Text('View All',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.sm),
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: accounts.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: KuberSpacing.md),
                        itemBuilder: (context, i) {
                          final account = accounts[i];
                          final balanceAsync =
                              ref.watch(accountBalanceProvider(account.id));
                          final acctColor = resolveAccountColor(account);
                          final cardWidth =
                              (MediaQuery.of(context).size.width -
                                      2 * KuberSpacing.lg -
                                      KuberSpacing.md) /
                                  2;
                          return SizedBox(
                            width: cardWidth,
                            child: Container(
                              padding: const EdgeInsets.all(KuberSpacing.lg),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainer,
                                borderRadius: BorderRadius.circular(KuberRadius.md),
                                border: Border.all(
                                  color: cs.outline,
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: acctColor
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          resolveAccountIcon(account),
                                          size: 18,
                                          color: acctColor,
                                        ),
                                      ),
                                      const SizedBox(width: KuberSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          account.name,
                                          style:
                                              textTheme.labelMedium?.copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: KuberSpacing.sm),
                                  balanceAsync.when(
                                    loading: () => Text('...',
                                        style: textTheme.titleMedium),
                                    error: (e, _) => Text('-',
                                        style: textTheme.titleMedium),
                                    data: (balance) {
                                      final Color? balanceColor;
                                      if (account.isCreditCard) {
                                        balanceColor = balance > 0
                                            ? cs.error
                                            : balance < 0
                                                ? cs.tertiary
                                                : null;
                                      } else {
                                        balanceColor = balance < 0
                                            ? cs.error
                                            : null;
                                      }
                                      final prefix = balance < 0 ? '-' : '';
                                      return Text(
                                        '$prefix${CurrencyFormatter.format(balance)}',
                                        style:
                                            textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: balanceColor,
                                        ),
                                      );
                                    },
                                  ),
                                  if (account.last4Digits != null)
                                    Text(
                                      '**** ${account.last4Digits}',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.xl),
                  ],
                );
              },
            ),

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
            // [C.5] Upcoming Recurring
            _UpcomingRecurringSection(ref: ref),

            const SizedBox(height: KuberSpacing.xl),

            // [D] Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                TextButton(
                  onPressed: () => context.go('/history'),
                  child: Text('View All',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.md),
            recentAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(KuberSpacing.xl),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                    vertical: KuberSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: categoryMapAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (categories) => Column(
                      children: transactions.map((t) {
                        final catId = int.tryParse(t.categoryId);
                        final cat =
                            catId != null ? categories[catId] : null;
                        return DashboardTransactionItem(
                          transaction: t,
                          category: cat,
                          onTap: () => showTransactionDetailSheet(
                            context,
                            ref,
                            t,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
      ),
    );
  }

}

class _UpcomingRecurringSection extends StatelessWidget {
  final WidgetRef ref;

  const _UpcomingRecurringSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final upcomingAsync = ref.watch(upcomingRecurringProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final colorScheme = cs;

    return upcomingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (rules) {
        if (rules.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            const SizedBox(height: KuberSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recurring Transactions',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                TextButton(
                  onPressed: () => GoRouter.of(context).push('/more/recurring'),
                  child: Text('View All',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.sm),
            categoryMapAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (catMap) => Column(
                children: rules.map((rule) {
                  final catId = int.tryParse(rule.categoryId);
                  final cat = catId != null ? catMap[catId] : null;
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final dueDay = DateTime(
                      rule.nextDueAt.year, rule.nextDueAt.month, rule.nextDueAt.day);

                  String statusLabel;
                  Color statusColor;
                  if (dueDay.isBefore(today)) {
                    statusLabel = 'PROCESSED';
                    statusColor = cs.tertiary;
                  } else if (dueDay.isAtSameMomentAs(today)) {
                    statusLabel = 'PENDING';
                    statusColor = cs.primary;
                  } else {
                    statusLabel = 'SCHEDULED';
                    statusColor = cs.onSurfaceVariant;
                  }

                  final catColor = cat != null
                      ? harmonizeCategory(context, Color(cat.colorValue))
                      : cs.onSurfaceVariant;

                  return GestureDetector(
                    onTap: () => showRecurringDetailSheet(context, ref, rule),
                    child: Container(
                    margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
                    padding: const EdgeInsets.all(KuberSpacing.md),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            cat != null
                                ? IconMapper.fromString(cat.icon)
                                : Icons.category_outlined,
                            color: catColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      rule.name,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: KuberSpacing.sm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(KuberRadius.sm),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                DateFormat('MMM d').format(rule.nextDueAt),
                                style: textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(rule.amount),
                          style: textTheme.bodyMedium?.copyWith(
                            color: rule.type == 'income'
                                ? cs.tertiary
                                : cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
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
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.05,
                    color: cs.onSurface,
                  ),
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
