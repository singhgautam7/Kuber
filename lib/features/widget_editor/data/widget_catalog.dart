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
    id: 'smart_insights',
    name: 'Smart Insights',
    description: 'Personalised tips based on your spending',
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

List<HomeWidgetConfig> defaultsForScope(WidgetEditorScope scope) {
  switch (scope) {
    case WidgetEditorScope.home:
      return List.of(kHomeWidgetCatalog);
    case WidgetEditorScope.analytics:
      return List.of(kAnalyticsWidgetCatalog);
  }
}
