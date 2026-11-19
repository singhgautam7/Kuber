import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/tools_l10n.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../features/more/more_content.dart';
import '../../../features/pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../../features/pro/feature_gates/gate_sheet_advanced_history.dart';
import '../../../features/tools/tool_catalog.dart';

/// One page in the Quick navigation tree. The static tree is built once per
/// open from the same lists that draw the tabs, More, Settings and Tools, so a
/// page cannot be added there without showing up here (see the drift test).
class QuickNavNode {
  final String id;
  final String title;
  final IconData icon;

  /// The route this node matches (no query). Null: not a page.
  final String? route;

  /// Where a jump pushes, when it differs from [route] (a query is needed).
  final String? open;

  /// Bottom tab index for the four tab nodes.
  final int? tab;
  final List<QuickNavNode> children;

  /// End index of each section of [children]; empty means one section. Used
  /// when the child list is long.
  final List<int> sectionEnds;

  /// Pro gate shown instead of jumping, for a free user.
  final void Function(BuildContext)? gate;

  const QuickNavNode({
    required this.id,
    required this.title,
    required this.icon,
    this.route,
    this.open,
    this.tab,
    this.children = const [],
    this.sectionEnds = const [],
    this.gate,
  });

  String? get location => open ?? route;
}

/// A child list is long when it has more than this many pages.
const int quickNavLongList = 8;

// More entries carry no route, only an onTap, so their pages are listed here
// in the same order as buildMoreSections. test/shared/widgets/quick_nav checks
// the counts and icons, so adding an entry there fails until it is added here.
const _manageRoutes = [
  '/more/accounts',
  '/more/categories',
  '/more/tags',
  '/more/budgets',
  '/more/recurring',
  '/more/ledger',
  '/more/loans',
  '/more/investments',
];
const _signatureRoutes = [
  '/more/ask-kuber',
  '/more/sms-import',
  '/advanced-analytics',
  '/advanced-history',
  '/more/tools',
  '/more/notes',
  '/cards',
  '/quick-add',
  '/more/reminders',
];
const _aboutRoutes = ['/more/settings', '/more/about', '/onboarding'];

/// Routes per More section id, for the drift test.
const quickNavMoreRoutes = {
  MoreSectionId.manage: _manageRoutes,
  MoreSectionId.signature: _signatureRoutes,
  MoreSectionId.about: _aboutRoutes,
};

/// The four bottom tabs: Home, History, Analytics, More. History and
/// Analytics are only shown when the current page sits under them.
List<QuickNavNode> buildQuickNavTree(BuildContext context, WidgetRef ref) {
  final l = context.l10n;
  final lang = Localizations.localeOf(context).languageCode;

  final sections = buildMoreSections(context, ref);
  final moreKids = <QuickNavNode>[];
  final ends = <int>[];
  for (final s in sections) {
    final routes = quickNavMoreRoutes[s.id];
    if (routes == null) continue; // Help us: Rate / Share / Feedback, no page
    for (final (i, e) in s.entries.indexed) {
      if (i >= routes.length) break;
      final r = routes[i];
      moreKids.add(QuickNavNode(
        id: r,
        title: e.label,
        icon: e.icon,
        route: r,
        open: r == '/onboarding' ? '/onboarding?replay=true' : null,
        children: r == '/more/settings'
            ? _settings(l)
            : r == '/more/tools'
                ? _calculators(lang)
                : const [],
        sectionEnds: r == '/more/settings'
            ? const []
            : r == '/more/tools'
                ? _calculatorEnds
                : const [],
        gate: r == '/advanced-analytics'
            ? showAdvancedAnalyticsGateSheet
            : r == '/advanced-history'
                ? showAdvancedHistoryGateSheet
                : null,
      ));
    }
    ends.add(moreKids.length);
  }

  return [
    QuickNavNode(id: 'tab:0', title: l.navHome, icon: Icons.home_rounded, route: '/', tab: 0),
    QuickNavNode(
        id: 'tab:1', title: l.navHistory, icon: Icons.receipt_long_rounded, route: '/history', tab: 1),
    QuickNavNode(
        id: 'tab:2', title: l.navAnalytics, icon: Icons.pie_chart_rounded, route: '/analytics', tab: 2),
    QuickNavNode(
      id: 'tab:3',
      title: l.navMore,
      icon: Icons.grid_view_rounded,
      route: '/more',
      tab: 3,
      children: moreKids,
      sectionEnds: ends,
    ),
  ];
}

// Saved calculations join the first section (finance), like the hub's list.
final _calculatorEnds = () {
  final out = <int>[];
  var n = 1;
  for (final g in ToolCatalog.groups) {
    n += g.tools.length;
    out.add(n);
  }
  return out;
}();

List<QuickNavNode> _calculators(String lang) {
  QuickNavNode tool(ToolMeta t) => QuickNavNode(
        id: '/more/tools/${t.key}',
        title: tL10n(t.name, lang),
        icon: t.icon,
        route: '/more/tools/${t.key}',
      );
  return [
    QuickNavNode(
      id: '/more/tools/saved-calculations',
      title: tL10n('Saved Calculations', lang),
      icon: Icons.bookmarks_rounded,
      route: '/more/tools/saved-calculations',
    ),
    for (final g in ToolCatalog.groups) ...g.tools.map(tool),
  ];
}

List<QuickNavNode> _settings(AppLocalizations l) {
  QuickNavNode n(String route, String title, IconData icon, [List<QuickNavNode> kids = const []]) =>
      QuickNavNode(id: route, title: title, icon: icon, route: route, children: kids);
  return [
    n('/more/settings/look', l.setGroupLook, Icons.palette_outlined, [
      n('/more/settings/theme', l.themeLabel, Icons.contrast_rounded),
      n('/widget-editor/home', l.setHomeWidgets, Icons.home_outlined),
      n('/widget-editor/analytics', l.setAnalyticsWidgets, Icons.insert_chart_outlined_rounded),
      n('/more/widgets-gallery', l.setHomeScreenWidgets, Icons.widgets_outlined),
    ]),
    n('/more/settings/preferences', l.setGroupPrefs, Icons.tune_rounded, [
      n('/settings/quick-actions', l.setQuickActions, Icons.bolt_outlined),
      n('/settings/add-menu', l.setAddMenu, Icons.add_circle_outline_rounded),
    ]),
    n('/more/settings/app-drawer', l.appDrawerSection, Icons.apps_rounded),
    n('/more/settings/privacy', l.setGroupPrivacy, Icons.shield_outlined),
    n('/more/data', l.setGroupData, Icons.cloud_sync_outlined, [
      n('/more/data/automatic-backups', l.setAutoBackups, Icons.event_repeat_rounded),
    ]),
    n('/more/settings/notifications', l.menuNotifications, Icons.notifications_outlined),
    n('/more/settings/help', l.setHelpTitle, Icons.help_outline_rounded),
    n('/more/settings/activity', l.setGroupActivity, Icons.event_note_outlined, [
      n('/more/upcoming-events', l.setUpcoming, Icons.calendar_month_rounded),
      n('/more/stories-archive', l.setStories, Icons.auto_stories_rounded),
    ]),
  ];
}

/// Every node, depth first.
Iterable<QuickNavNode> quickNavWalk(Iterable<QuickNavNode> roots) sync* {
  for (final n in roots) {
    yield n;
    yield* quickNavWalk(n.children);
  }
}
