import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/gallery_previews.dart';

/// Size category headings used in the Widgets gallery landing.
enum WidgetSizeGroup { small, medium, large }

/// One entry in the in-app Widgets gallery. Mirrors an Android home-screen
/// widget provider (see android/.../widgets/*.kt).
class WidgetCatalogEntry {
  /// Android provider class simple name (used for requestPinAppWidget).
  final String providerClass;
  final String name;

  /// One-line picker description (matches strings.xml / the design handoff).
  final String description;

  /// Cell-size chip label, e.g. "2×2", "4×2", "4×3".
  final String sizeLabel;
  final WidgetSizeGroup group;

  /// 2-3 sentence detail-sheet explanation.
  final String info;

  /// Whether placing this widget opens a configuration activity.
  final bool needsConfig;

  /// Faithful in-app preview of the widget.
  final WidgetBuilder preview;

  const WidgetCatalogEntry({
    required this.providerClass,
    required this.name,
    required this.description,
    required this.sizeLabel,
    required this.group,
    required this.info,
    required this.preview,
    this.needsConfig = false,
  });
}

/// The full 12-widget catalog, grouped small / medium / large.
const List<WidgetCatalogEntry> kWidgetCatalog = [
  // ---- SMALL ----
  WidgetCatalogEntry(
    providerClass: 'MonthlyNetWidgetProvider',
    name: 'Monthly Net',
    description: "See this month's net at a glance",
    sizeLabel: '2×2',
    group: WidgetSizeGroup.small,
    info:
        "Shows this month's net (income minus expense) with the income and expense "
        "totals underneath. Updates whenever you add or edit a transaction. Tap it "
        "to open the Home tab.",
    preview: monthlyNetPreview,
  ),
  WidgetCatalogEntry(
    providerClass: 'AccountBalanceWidgetProvider',
    name: 'Account Balance',
    description: "Show any account's current balance",
    sizeLabel: '2×2',
    group: WidgetSizeGroup.small,
    needsConfig: true,
    info:
        "Displays the current balance of one account you pick when placing it. "
        "Negative balances (like credit cards) show in red. Add it more than once "
        "for different accounts. Tap it to open that account.",
    preview: accountBalancePreview,
  ),
  WidgetCatalogEntry(
    providerClass: 'SmsImportBadgeWidgetProvider',
    name: 'SMS Import Badge',
    description: 'Unreviewed bank messages count',
    sizeLabel: '2×1',
    group: WidgetSizeGroup.small,
    info:
        "Counts bank SMS messages waiting to be reviewed in Import from SMS. Shows "
        "\"All caught up\" at zero. Tap it to open the Import from SMS screen.",
    preview: smsBadgePreview,
  ),
  // ---- MEDIUM ----
  WidgetCatalogEntry(
    providerClass: 'UpcomingEventsWidgetProvider',
    name: 'Upcoming Events',
    description: 'Next 30 days of reminders, EMIs, and SIPs',
    sizeLabel: '4×2',
    group: WidgetSizeGroup.medium,
    info:
        "Lists your next reminders, loan EMIs, SIPs, recurring entries and ledger "
        "due dates for the coming 30 days. Tap a row to open that item, or \"View "
        "all\" for the full Upcoming Events screen.",
    preview: upcomingEventsPreview,
  ),
  WidgetCatalogEntry(
    providerClass: 'RecentTransactionsWidgetProvider',
    name: 'Recent Transactions',
    description: 'Latest 5 transactions',
    sizeLabel: '4×2',
    group: WidgetSizeGroup.medium,
    info:
        "Shows your most recent transactions with category, account and amount. "
        "Tap a row to open that transaction, or \"View all\" for History.",
    preview: recentTransactionsPreview,
  ),
  WidgetCatalogEntry(
    providerClass: 'QuickActionsWidgetProvider',
    name: 'Quick Actions',
    description: 'Add transaction and open Ask Kuber',
    sizeLabel: '4×1',
    group: WidgetSizeGroup.medium,
    info:
        "Four one-tap shortcuts: Add Transaction, Add Recurring, Ask Kuber and "
        "Import from SMS. No data to sync, always ready.",
    preview: quickActionsPreview,
  ),
  WidgetCatalogEntry(
    providerClass: 'ChartCompactWidgetProvider',
    name: 'Chart (7 days)',
    description: 'Last 7 days spending trend',
    sizeLabel: '4×2',
    group: WidgetSizeGroup.medium,
    info:
        "A compact stacked bar chart of the last 7 days of income and expense, with "
        "the 7-day net. Refreshes on data change. Tap it to open Analytics.",
    preview: chartCompactPreview,
  ),
  // ---- LARGE ----
  WidgetCatalogEntry(
    providerClass: 'ChartWithRangeWidgetProvider',
    name: 'Trends (range switcher)',
    description: 'Trends with 7D / 4W / 6M toggle',
    sizeLabel: '4×3',
    group: WidgetSizeGroup.large,
    needsConfig: true,
    info:
        "A larger trends chart with 7D / 4W / 6M chips you can switch right on the "
        "home screen. Pick a default range when placing it. Tap the chart to open "
        "Analytics.",
    preview: trendsPreview,
  ),
  WidgetCatalogEntry(
    providerClass: 'CategoryDonutWidgetProvider',
    name: 'Category Donut',
    description: 'Top spending categories',
    sizeLabel: '4×3',
    group: WidgetSizeGroup.large,
    info:
        "A donut of this month's spending with your top three categories and their "
        "share. Tap it to open Analytics with the category view.",
    preview: categoryDonutPreview,
  ),
  WidgetCatalogEntry(
    providerClass: 'BudgetStatusWidgetProvider',
    name: 'Budget Status',
    description: 'Track top 3 budgets',
    sizeLabel: '4×3',
    group: WidgetSizeGroup.large,
    info:
        "Progress bars for your top three budgets this month, colored by how close "
        "you are to the limit. Tap a budget to open it, or \"+N more\" for the "
        "Budgets list.",
    preview: budgetStatusPreview,
  ),
  WidgetCatalogEntry(
    providerClass: 'QuickActionsExtendedWidgetProvider',
    name: 'Quick Actions Extended',
    description: '8 shortcuts to common actions',
    sizeLabel: '4×3',
    group: WidgetSizeGroup.large,
    info:
        "Eight one-tap shortcuts: Add Transaction, Recurring, Loan, Investment, "
        "Lent/Borrow, Ask Kuber, Calculators and Notes.",
    preview: quickActionsExtendedPreview,
  ),
  WidgetCatalogEntry(
    providerClass: 'NotesWidgetProvider',
    name: 'Notes',
    description: 'Recent notes and quick add',
    sizeLabel: '4×3',
    group: WidgetSizeGroup.large,
    info:
        "Your three most recent Kuber Notes with a quick \"Add note\" button. Tap a "
        "note to open it in the editor, or \"View all notes\" for the Notes landing.",
    preview: notesPreview,
  ),
];

/// Bridges to the native requestPinAppWidget API (see MainActivity).
class WidgetPinService {
  static const _channel = MethodChannel('com.grs.kuber/widgets');

  static Future<bool> isPinSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isPinSupported') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests the launcher pin [providerClass] to the home screen. Returns
  /// false if unsupported or the request could not be issued.
  static Future<bool> requestPin(String providerClass) async {
    try {
      return await _channel.invokeMethod<bool>(
            'requestPin',
            {'provider': providerClass},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }
}
