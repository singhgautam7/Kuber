import 'package:flutter/widgets.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import '../models/home_widget_config.dart';

/// Canonical list of toggleable widgets for the home dashboard. The order
/// here is the default order shown to a user with no saved preferences.
/// Adding a new id here also requires handling that id in the dashboard
/// builder switch — otherwise it'll fall through to `SizedBox.shrink()`.
const List<HomeWidgetConfig> kHomeWidgetCatalog = [
  HomeWidgetConfig(
    id: 'balance_hero',
    name: 'Balance Card',
    description: 'Current-month net with income / expense split',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'insight_stories',
    name: 'Money Stories',
    description: 'Recaps and highlights about your money',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'quick_add',
    name: 'Quick Add',
    description: 'One-tap expense / income / transfer entry',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'spending_stats',
    name: 'Spending Stats',
    description: 'Spent vs received this month',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'home_accounts',
    name: 'Bank Accounts',
    description: 'All accounts and balances',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'seven_day_chart',
    name: 'Last 7 Days Chart',
    description: 'Daily income vs expense for the past week',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'budget_snapshot',
    name: 'Budget Snapshot',
    description: 'Progress against active budgets',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'upcoming_recurring',
    name: 'Upcoming Recurring',
    description: 'Next recurring transactions due',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'recent_transactions',
    name: 'Recent Transactions',
    description: 'Latest activity at a glance',
    enabled: true,
  ),
];

/// Canonical list of toggleable widgets for the analytics screen.
const List<HomeWidgetConfig> kAnalyticsWidgetCatalog = [
  HomeWidgetConfig(
    id: 'summary_card',
    name: 'Summary Card',
    description: 'Income, expense and net for the period',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'spending_trend',
    name: 'Spending Trend',
    description: 'Bar / line chart with bucket dropdown',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'weekly_heatmap',
    name: 'Weekly Heatmap',
    description: 'Average expense by day of week',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'size_distribution',
    name: 'Transaction Sizes',
    description: 'Small / medium / large breakdown',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'category_breakdown',
    name: 'Category Breakdown',
    description: 'Spending grouped by category',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'tag_analytics',
    name: 'Tag Analytics',
    description: 'Totals grouped by tag',
    enabled: true,
  ),
  HomeWidgetConfig(
    id: 'biggest_transactions',
    name: 'Biggest Transactions',
    description: 'Top 5 by amount, expense or income',
    enabled: true,
  ),
];

/// Localized display name for a widget catalog [id]. Falls back to the id.
String localizedWidgetName(BuildContext context, String id) {
  final l = context.l10n;
  return switch (id) {
    'balance_hero' => l.wgtBalanceHeroName,
    'insight_stories' => l.wgtInsightStoriesName,
    'quick_add' => l.wgtQuickAddName,
    'spending_stats' => l.wgtSpendingStatsName,
    'home_accounts' => l.wgtHomeAccountsName,
    'seven_day_chart' => l.wgtSevenDayChartName,
    'budget_snapshot' => l.wgtBudgetSnapshotName,
    'upcoming_recurring' => l.wgtUpcomingRecurringName,
    'recent_transactions' => l.wgtRecentTransactionsName,
    'summary_card' => l.wgtSummaryCardName,
    'spending_trend' => l.wgtSpendingTrendName,
    'weekly_heatmap' => l.wgtWeeklyHeatmapName,
    'size_distribution' => l.wgtSizeDistributionName,
    'category_breakdown' => l.wgtCategoryBreakdownName,
    'tag_analytics' => l.wgtTagAnalyticsName,
    'biggest_transactions' => l.wgtBiggestTransactionsName,
    _ => id,
  };
}

/// Localized description for a widget catalog [id]. Returns null if unknown.
String? localizedWidgetDesc(BuildContext context, String id) {
  final l = context.l10n;
  return switch (id) {
    'balance_hero' => l.wgtBalanceHeroDesc,
    'insight_stories' => l.wgtInsightStoriesDesc,
    'quick_add' => l.wgtQuickAddDesc,
    'spending_stats' => l.wgtSpendingStatsDesc,
    'home_accounts' => l.wgtHomeAccountsDesc,
    'seven_day_chart' => l.wgtSevenDayChartDesc,
    'budget_snapshot' => l.wgtBudgetSnapshotDesc,
    'upcoming_recurring' => l.wgtUpcomingRecurringDesc,
    'recent_transactions' => l.wgtRecentTransactionsDesc,
    'summary_card' => l.wgtSummaryCardDesc,
    'spending_trend' => l.wgtSpendingTrendDesc,
    'weekly_heatmap' => l.wgtWeeklyHeatmapDesc,
    'size_distribution' => l.wgtSizeDistributionDesc,
    'category_breakdown' => l.wgtCategoryBreakdownDesc,
    'tag_analytics' => l.wgtTagAnalyticsDesc,
    'biggest_transactions' => l.wgtBiggestTransactionsDesc,
    _ => null,
  };
}

List<HomeWidgetConfig> defaultsForScope(WidgetEditorScope scope) {
  switch (scope) {
    case WidgetEditorScope.home:
      return List.of(kHomeWidgetCatalog);
    case WidgetEditorScope.analytics:
      return List.of(kAnalyticsWidgetCatalog);
  }
}
