import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_bar_chart.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../../shared/widgets/transaction_list_item.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final summaryAsync = ref.watch(monthlySummaryProvider);
    final accountsAsync = ref.watch(accountListProvider);
    final recentAsync = ref.watch(recentTransactionsProvider);
    final chartAsync = ref.watch(last7DaysSummaryProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);

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

            // [A] Balance Hero Card
            summaryAsync.when(
              loading: () => const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (summary) => _BalanceHeroCard(summary: summary),
            ),
            const SizedBox(height: KuberSpacing.xl),

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
                          onPressed: () => context.go('/accounts'),
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
                                color: KuberColors.surfaceCard,
                                borderRadius: BorderRadius.circular(KuberRadius.md),
                                border: Border.all(
                                  color: KuberColors.border,
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
                                            ? KuberColors.expense
                                            : balance < 0
                                                ? KuberColors.income
                                                : null;
                                      } else {
                                        balanceColor = balance < 0
                                            ? KuberColors.expense
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
              ),
            ),
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
                      color: KuberColors.surfaceCard,
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
                    color: KuberColors.surfaceCard,
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

class _BalanceHeroCard extends StatelessWidget {
  final MonthlySummary summary;

  const _BalanceHeroCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.xl),
      decoration: BoxDecoration(
        color: KuberColors.surfaceCard,
        border: Border.all(color: KuberColors.border),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Total Balance',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          Builder(
            builder: (context) {
              final formattedRaw = CurrencyFormatter.format(summary.net.abs()).replaceAll('₹', '');
              final prefix = summary.net < 0 ? '-' : '';

              return RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.05,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: prefix),
                    const TextSpan(
                      text: '₹',
                      style: TextStyle(color: KuberColors.primary),
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
                  iconColor: KuberColors.income,
                ),
              ),
              const SizedBox(width: KuberSpacing.lg),
              Expanded(
                child: _BalanceTile(
                  label: 'Expense',
                  amount: summary.totalExpense,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: KuberColors.expense,
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
               color: Colors.black.withValues(alpha: 0.25),
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
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(amount),
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
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
