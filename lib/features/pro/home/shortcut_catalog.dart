import 'package:flutter/material.dart';

import '../../../core/utils/color_palette.dart';
import '../../tools/tool_catalog.dart';

/// Grouping shown as section headers in the shortcuts configure sheet.
enum ShortcutSection { manage, tools, kuberSpecific }

extension ShortcutSectionX on ShortcutSection {
  /// Section header shown in the configure sheet. `kuberSpecific`'s label is
  /// "Kuber Signature" per review (an earlier "Vault Exclusives" name was
  /// wrong — Vault is only the internal design system codename, not the
  /// product name) — a stylish name for the group of shortcuts unique to
  /// Kuber rather than generic finance utilities.
  String get label => switch (this) {
    ShortcutSection.manage => 'MANAGE',
    ShortcutSection.tools => 'TOOLS',
    ShortcutSection.kuberSpecific => 'KUBER SIGNATURE',
  };
}

/// One configurable shortcut: id (persisted), label, icon, the route it
/// opens, and which catalog section it's grouped under in the picker.
class ShortcutMeta {
  final String id;

  /// Full descriptive name, shown in the configure sheet.
  final String label;

  /// Compact name shown on the home-widget tile (56px wide). Defaults to
  /// [label]; overridden for anything that would wrap awkwardly, so every tile
  /// stays a tidy one/two words.
  final String shortLabel;

  final IconData icon;
  final String route;
  final ShortcutSection section;

  const ShortcutMeta({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    required this.section,
    String? shortLabel,
  }) : shortLabel = shortLabel ?? label;
}

/// Manage-section shortcuts — mirrors the More tab's "Manage" list (same
/// icons, labels and routes) so the two stay in sync.
const List<ShortcutMeta> _kManageShortcuts = [
  ShortcutMeta(
    id: 'accounts',
    label: 'Accounts',
    icon: Icons.account_balance_wallet,
    route: '/more/accounts',
    section: ShortcutSection.manage,
  ),
  ShortcutMeta(
    id: 'categories',
    label: 'Categories',
    icon: Icons.category,
    route: '/more/categories',
    section: ShortcutSection.manage,
  ),
  ShortcutMeta(
    id: 'tags',
    label: 'Tags',
    icon: Icons.label_rounded,
    route: '/more/tags',
    section: ShortcutSection.manage,
  ),
  ShortcutMeta(
    id: 'budgets',
    label: 'Budgets',
    icon: Icons.pie_chart_rounded,
    route: '/more/budgets',
    section: ShortcutSection.manage,
  ),
  ShortcutMeta(
    id: 'recurring',
    label: 'Recurring',
    icon: Icons.sync_rounded,
    route: '/more/recurring',
    section: ShortcutSection.manage,
  ),
  ShortcutMeta(
    id: 'ledger',
    label: 'Lend / Borrow',
    shortLabel: 'Lend/Borrow',
    icon: Icons.handshake,
    route: '/more/ledger',
    section: ShortcutSection.manage,
  ),
  ShortcutMeta(
    id: 'loans',
    label: 'Loans',
    icon: Icons.account_balance_outlined,
    route: '/more/loans',
    section: ShortcutSection.manage,
  ),
  ShortcutMeta(
    id: 'investments',
    label: 'Investments',
    icon: Icons.show_chart,
    route: '/more/investments',
    section: ShortcutSection.manage,
  ),
  // Reminders lives under "Manage" on the More tab, so it is grouped here too.
  ShortcutMeta(
    id: 'reminders',
    label: 'Reminders',
    icon: Icons.notifications_active_outlined,
    route: '/more/reminders',
    section: ShortcutSection.manage,
  ),
];

/// Kuber-signature shortcuts — the features unique to Kuber's product.
const List<ShortcutMeta> _kSignatureShortcuts = [
  ShortcutMeta(
    id: 'advanced_analytics',
    label: 'Advanced Analytics',
    shortLabel: 'Insights',
    icon: Icons.insert_chart_outlined_rounded,
    route: '/advanced-analytics',
    section: ShortcutSection.kuberSpecific,
  ),
  ShortcutMeta(
    id: 'ask_kuber',
    label: 'Ask Kuber',
    icon: Icons.auto_awesome_rounded,
    route: '/more/ask-kuber',
    section: ShortcutSection.kuberSpecific,
  ),
  ShortcutMeta(
    id: 'kuber_notes',
    label: 'Notes',
    icon: Icons.sticky_note_2_outlined,
    route: '/more/notes',
    section: ShortcutSection.kuberSpecific,
  ),
  ShortcutMeta(
    id: 'sms_import',
    label: 'SMS Import',
    shortLabel: 'SMS',
    icon: Icons.sms_outlined,
    route: '/more/sms-import',
    section: ShortcutSection.kuberSpecific,
  ),
  ShortcutMeta(
    id: 'upcoming_events',
    label: 'Upcoming Events',
    shortLabel: 'Events',
    icon: Icons.event_rounded,
    route: '/more/upcoming-events',
    section: ShortcutSection.kuberSpecific,
  ),
  ShortcutMeta(
    id: 'money_stories',
    label: 'Money Stories',
    shortLabel: 'Stories',
    icon: Icons.auto_stories_rounded,
    route: '/more/stories-archive',
    section: ShortcutSection.kuberSpecific,
  ),
];

/// Short tile labels for the calculators, keyed by `ToolCatalog` route key.
/// The catalog's full names ("Investment Returns", "Currency Converter") are
/// too long for a 56px tile, so the widget uses these instead.
const Map<String, String> _kToolShortLabels = {
  'emi-calculator': 'EMI',
  'sip-calculator': 'Returns',
  'sip-amount-finder': 'SIP Amt',
  'fd-rd-calculator': 'FD / RD',
  'ppf-calculator': 'PPF',
  'inflation-calculator': 'Inflation',
  'loan-prepayment': 'Prepay',
  'lumpsum-vs-sip': 'Lumpsum',
  'salary-calculator': 'Salary',
  'gst-calculator': 'GST',
  'hra-calculator': 'HRA',
  'goal-planner': 'Goal',
  'retirement-corpus': 'Retire',
  'split-calculator': 'Split',
  'currency-converter': 'Currency',
  'breakeven-calculator': 'Break-even',
  'tip-calculator': 'Tip',
  'discount-calculator': 'Discount',
};

/// The "All Tools" hub entry, appended after the individual calculators.
const ShortcutMeta _kToolsHubShortcut = ShortcutMeta(
  id: 'tools_hub',
  label: 'All Tools',
  icon: Icons.calculate_outlined,
  route: '/more/tools',
  section: ShortcutSection.tools,
);

/// Everything a user can pin, grouped the way the configure sheet presents it:
/// **Manage** (the More tab's Manage list), **Tools** (every calculator in
/// [ToolCatalog], so the two never drift, plus an All-Tools hub link), and
/// **Kuber Signature** (features unique to Kuber). Built from the app's real
/// catalogs rather than a hand-maintained subset.
final List<ShortcutMeta> kShortcutCatalog = [
  ..._kManageShortcuts,
  for (final t in ToolCatalog.all)
    ShortcutMeta(
      id: t.key,
      label: t.name,
      shortLabel: _kToolShortLabels[t.key],
      icon: t.icon,
      route: '/more/tools/${t.key}',
      section: ShortcutSection.tools,
    ),
  _kToolsHubShortcut,
  ..._kSignatureShortcuts,
];

ShortcutMeta? shortcutById(String id) =>
    kShortcutCatalog.where((s) => s.id == id).firstOrNull;

/// Swatch set offered when tinting a pinned shortcut. Drawn straight from
/// [AppColorPalette] — the same vibrant hues the category-color picker offers
/// — so shortcut accents and category accents come from one source of truth.
const List<Color> kShortcutColorSwatches = [
  Color(AppColorPalette.kVibrantBlue),
  Color(AppColorPalette.kVibrantGreen),
  Color(AppColorPalette.kVibrantAmber),
  Color(AppColorPalette.kVibrantRed),
  Color(AppColorPalette.kVibrantPurple),
  Color(AppColorPalette.kVibrantPink),
  Color(AppColorPalette.kVibrantTeal),
  Color(AppColorPalette.kVibrantIndigo),
];
