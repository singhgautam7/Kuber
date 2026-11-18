import 'package:flutter/material.dart';
import 'package:kuber/features/pro/trial/widgets/pro_suggestion_slot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/edit_widgets_button.dart';
import '../../widget_editor/models/home_widget_config.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../providers/analytics_provider.dart';
import '../../charts/widgets/category_donut_chart.dart';
import '../../charts/widgets/analytics_income_expense_chart.dart';
import '../../charts/widgets/income_expense_chart_controls.dart'
    show KuberSegmentedTabs;
import '../widgets/avg_weekly_heatmap.dart';
import '../widgets/transaction_size_distribution.dart';
import '../widgets/tag_wise_analytics.dart';
import '../widgets/top_filter_row.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../tutorial/models/tutorial_step_keys.dart';
import '../../advanced_analytics/widgets/deeper_insights_teaser.dart';

// ---------------------------------------------------------------------------
// Private data classes
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Analytics Screen
// ---------------------------------------------------------------------------

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

/// Local state provider for the Biggest-Transactions expense/income tab.
/// Promoted out of the screen's local state so switching tabs invalidates only
/// that section instead of re-running the whole screen build (which recomputes
/// the O(n) chart buckets).
final _biggestTabProvider = StateProvider<int>((_) => 0);

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(analyticsFilterProvider);
    final periodTxns = ref.watch(analyticsTransactionsProvider);
    final computed = ref.watch(analyticsComputedProvider);

    final cs = Theme.of(context).colorScheme;
    final colorScheme = cs;
    final textTheme = Theme.of(context).textTheme;

    final isEmpty = computed == null;

    // Totals — from cached provider (single O(n) pass)
    final totalIncome = computed?.totalIncome ?? 0.0;
    final totalExpense = computed?.totalExpense ?? 0.0;
    final netAmount = computed?.netAmount ?? 0.0;

    // Category map — only watched when needed for biggest transactions
    final categoryMap = ref.watch(categoryMapProvider).valueOrNull ?? {};

    // Top-5 biggest transactions are now computed inside `_BiggestTransactionsSection`,
    // which watches `_biggestTabProvider` directly — so a tab switch doesn't
    // invalidate this build (and doesn't re-run bucket computation).

    return Scaffold(
      body: CustomScrollView(
        key: TutorialStepKeys.analyticsPage,
        slivers: [
          // ── Header (always eager) ─────────────────────────────────
          // Header (feedback round 1): "Analytics", no description.
          SliverToBoxAdapter(
            child: KuberAppBar(title: context.l10n.navAnalytics),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
            sliver: SliverToBoxAdapter(child: TopFilterRow()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: KuberSpace.md)),
          // v7.0.0-b trial: dashboards / Advanced analytics suggestion.
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
            sliver: SliverToBoxAdapter(
              child: ProSuggestionSlot(place: ProSuggestionPlace.analytics),
            ),
          ),

          // ── Analytics widgets (dynamic order + visibility from editor) ─
          if (isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpace.screenMargin,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: KuberSpace.xl),
                    KuberEmptyState(
                      icon: Icons.bar_chart,
                      title: context.l10n.noData,
                      description: context.l10n.noTransactionsForPeriod,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpace.screenMargin,
              ),
              sliver: _AnalyticsWidgetList(
                filter: filter,
                periodTxns: periodTxns,
                computed: computed,
                categoryMap: categoryMap,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                netAmount: netAmount,
                colorScheme: colorScheme,
                textTheme: textTheme,
                buildSummary: (cs, tt, inc, exp, net) =>
                    _buildSummaryCard(ref, cs, tt, inc, exp, net),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ---- summary card -------------------------------------------------------

  Widget _buildSummaryCard(
    WidgetRef ref,
    ColorScheme cs,
    TextTheme tt,
    double income,
    double expense,
    double net,
  ) {
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    // Summary (board 3.6b): two tiles + a net row, all surfaceContainerHigh r12.
    return KuberCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: context.l10n.incomeLabel,
                  amount: maskAmount(
                    fmt.formatCurrency(income.round()),
                    isPrivate,
                  ),
                  color: context.kuberMoney.income,
                  icon: Icons.south_rounded,
                ),
              ),
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: _SummaryTile(
                  label: context.l10n.expenseLabel,
                  amount: maskAmount(
                    fmt.formatCurrency(expense.round()),
                    isPrivate,
                  ),
                  color: context.kuberMoney.expense,
                  icon: Icons.north_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KuberSpace.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: KuberShape.mediumR,
            ),
            child: Row(
              children: [
                Text(
                  'Net',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      maskAmount(
                        '${net >= 0 ? '+' : ''}${fmt.formatCurrency(net.round())}',
                        isPrivate,
                      ),
                      style: tt.titleLarge?.copyWith(
                        color: net >= 0
                            ? context.kuberMoney.income
                            : context.kuberMoney.expense,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    // Chart-card header pattern (screens/analytics.md): titleMedium, tabs
    // under it, 16 above the content.
    return KuberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (trailing != null) ...[
            const SizedBox(height: KuberSpace.lg),
            Align(alignment: Alignment.centerLeft, child: trailing!),
          ],
          const SizedBox(height: KuberSpace.lg),
          child,
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpace.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.mediumR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: KuberSpace.xs),
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: textTheme.titleLarge),
          ),
        ],
      ),
    );
  }
}

/// Dynamic analytics widget list — order + enabled flags come from
/// `analyticsWidgetsProvider`. Hidden widgets are not constructed; their
/// underlying providers stay idle until re-enabled.
class _AnalyticsWidgetList extends ConsumerStatefulWidget {
  final AnalyticsFilter filter;
  final List<Transaction> periodTxns;
  final AnalyticsComputed computed;
  final Map<int, dynamic> categoryMap;
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  final Widget Function(
    ColorScheme cs,
    TextTheme tt,
    double inc,
    double exp,
    double net,
  )
  buildSummary;

  const _AnalyticsWidgetList({
    required this.filter,
    required this.periodTxns,
    required this.computed,
    required this.categoryMap,
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.colorScheme,
    required this.textTheme,
    required this.buildSummary,
  });

  @override
  ConsumerState<_AnalyticsWidgetList> createState() =>
      _AnalyticsWidgetListState();
}

class _AnalyticsWidgetListState extends ConsumerState<_AnalyticsWidgetList> {
  // Progressive reveal, mirroring the home dashboard (see dashboard_screen).
  // Reveal one card per frame so the heavy above-the-fold widgets (summary
  // card, spending-trend fl_chart, heatmap …) inflate across frames instead of
  // in the single frame that renders when the Analytics tab first opens —
  // which would drop a frame on this 90Hz display and read as tab-switch jitter.
  // Start at 1 so the heavy spending-trend fl_chart does not inflate in the
  // same frame as the summary card when the tab first opens.
  static const _kInitialReveal = 1;
  int _revealCount = _kInitialReveal;
  int _lastItemCount = 1 << 30;
  bool _revealScheduled = false;

  void _growReveal() {
    if (_revealScheduled || _revealCount >= _lastItemCount) return;
    _revealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealScheduled = false;
      if (!mounted) return;
      setState(() => _revealCount += 1);
      _growReveal();
    });
  }

  Widget _buildWidget(BuildContext ctx, WidgetRef ref, String id) {
    final bottom = const EdgeInsets.only(bottom: KuberSpace.cardGap);
    switch (id) {
      case 'summary_card':
        return Padding(
          padding: bottom,
          child: widget.buildSummary(
            widget.colorScheme,
            widget.textTheme,
            widget.totalIncome,
            widget.totalExpense,
            widget.netAmount,
          ),
        );
      case 'spending_trend':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: AnalyticsIncomeExpenseChart(
              key: TutorialStepKeys.spendingTrendsChart,
            ),
          ),
        );
      case 'weekly_heatmap':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: AvgWeeklyHeatmap(
              transactions: widget.periodTxns,
              precomputedDailyAverages: widget.computed.dailyAverages,
            ),
          ),
        );
      case 'size_distribution':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: TransactionSizeDistribution(
              transactions: widget.periodTxns,
              precomputedDistribution: widget.computed.sizeDistribution,
            ),
          ),
        );
      case 'category_breakdown':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: CategoryDonutChart(
              key: TutorialStepKeys.categoryBreakdownChart,
            ),
          ),
        );
      case 'tag_analytics':
        return Padding(
          padding: bottom,
          child: RepaintBoundary(
            child: TagWiseAnalytics(transactions: widget.periodTxns),
          ),
        );
      case 'biggest_transactions':
        // Scoped widget: watches _biggestTabProvider internally so a tab switch
        // rebuilds only this section, not the whole analytics screen (which
        // would otherwise re-run bucket computation for every tab tap).
        return Padding(
          padding: bottom,
          child: _BiggestTransactionsSection(
            periodTxns: widget.periodTxns,
            categoryMap: widget.categoryMap,
            colorScheme: widget.colorScheme,
            textTheme: widget.textTheme,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetsAsync = ref.watch(analyticsWidgetsProvider);
    return widgetsAsync.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (configs) {
        final visible = configs.where((c) => c.enabled).toList();
        // +3 for Advanced Analytics teaser, EditWidgetsButton, and bottom spacer.
        final total = visible.length + 3;
        _lastItemCount = total;
        if (_revealCount < total) _growReveal();
        return SliverList.builder(
          itemCount: _revealCount.clamp(0, total),
          itemBuilder: (ctx, i) {
            if (i == visible.length) {
              return const Padding(
                padding: EdgeInsets.only(bottom: KuberSpace.cardGap),
                child: DeeperInsightsTeaser(),
              );
            }
            if (i == visible.length + 1) {
              return const EditWidgetsButton(
                scope: WidgetEditorScope.analytics,
              );
            }
            if (i == visible.length + 2) {
              return SizedBox(height: navBarBottomPadding(ctx));
            }
            return _buildWidget(ctx, ref, visible[i].id);
          },
        );
      },
    );
  }
}

/// Biggest-transactions section with its own local tab state, so switching
/// between Expense/Income doesn't invalidate the analytics screen build (and
/// doesn't re-run the O(n) chart-bucket construction).
class _BiggestTransactionsSection extends ConsumerWidget {
  final List<Transaction> periodTxns;
  final Map<int, dynamic> categoryMap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _BiggestTransactionsSection({
    required this.periodTxns,
    required this.categoryMap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = colorScheme;
    final tt = textTheme;
    final biggestTab = ref.watch(_biggestTabProvider);
    final biggestType = biggestTab == 0 ? 'expense' : 'income';
    final top5 =
        (periodTxns.where((t) => t.type == biggestType).toList()
              ..sort((a, b) => b.amount.compareTo(a.amount)))
            .take(5)
            .toList();

    return _AnalyticsCard(
      title: context.l10n.biggestTransactions,
      trailing: KuberSegmentedTabs(
        labels: [context.l10n.expenseLabel, context.l10n.incomeLabel],
        selectedIndex: biggestTab,
        onChanged: (i) => ref.read(_biggestTabProvider.notifier).state = i,
      ),
      child: top5.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: KuberSpace.xl),
              child: Center(
                child: Text(
                  'No $biggestType transactions',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            )
          : KuberGroup(
              children: List.generate(top5.length, (i) {
                final t = top5[i];
                final cat = categoryMap[int.tryParse(t.categoryId)];
                final isExpense = t.type == 'expense';
                return KuberListRow(
                  onTap: () => showTransactionDetailSheet(context, ref, t),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '#${i + 1}',
                          style: tt.labelLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: KuberSpace.sm),
                      if (cat != null)
                        CategoryIcon.square(
                          icon: IconMapper.fromString(cat.icon),
                          rawColor: Color(cat.colorValue),
                        ),
                    ],
                  ),
                  title: t.name,
                  subtitle: cat?.name,
                  trailing: Text(
                    maskAmount(
                      '${isExpense ? '-' : '+'}${ref.watch(formatterProvider).formatCurrency(t.amount)}',
                      ref.watch(privacyModeProvider),
                    ),
                    style: tt.titleMedium?.copyWith(
                      color: isExpense
                          ? context.kuberMoney.expense
                          : context.kuberMoney.income,
                    ),
                  ),
                );
              }),
            ),
    );
  }
}
