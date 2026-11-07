import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/l10n_ext.dart';
import 'kuber_bottom_sheet.dart';
import 'kuber_list.dart';

/// The path sheet: the pages the user actually came through, read from the
/// root navigator (every page is pushed there), so it shows the real stack and
/// not a fixed tree. Only entry points touch this; nothing runs per frame.
class KuberPath {
  KuberPath._();

  /// Keeps the root navigator's stack, in order. Sheets and dialogs are in it
  /// too and are left out when read.
  static final observer = _PathObserver();

  /// The tab showing under the pushed pages, and the shell's own route.
  static int tab = 0;
  static Route<dynamic>? shellRoute;

  static final _titles = Expando<String>('kuberPathTitle');

  /// A page's header gives its route a title (the readable name of the page).
  static void setTitle(Route<dynamic> route, String title) => _titles[route] = title;

  static List<KuberPathEntry> read(BuildContext context) {
    final l = context.l10n;
    final tabs = [
      (Icons.home_rounded, l.navHome, '/'),
      (Icons.receipt_long_rounded, l.navHistory, '/history'),
      (Icons.pie_chart_rounded, l.navAnalytics, '/analytics'),
      (Icons.grid_view_rounded, l.navMore, '/more'),
    ];
    final out = <KuberPathEntry>[];
    final pages = observer.routes.where((r) => r is PageRoute && r.isActive).toList();
    if (pages.contains(shellRoute)) {
      // Back on any other tab goes to Home, so Home is where it starts.
      for (final (i, t) in tabs.indexed) {
        if (i == 0 || i == tab) out.add(KuberPathEntry(t.$1, t.$2, tabLocation: t.$3));
      }
    }
    for (final r in pages) {
      if (identical(r, shellRoute)) continue;
      final name = r.settings.name;
      out.add(KuberPathEntry(_iconOf(name), _titles[r] ?? _readable(name), route: r));
    }
    return out;
  }

  /// The route's name with its slashes and dashes out, for a page with no title.
  static String _readable(String? name) {
    final last = (name ?? '').split('/').where((s) => s.isNotEmpty).lastOrNull ?? 'Kuber';
    final words = last.replaceAll('-', ' ');
    return '${words[0].toUpperCase()}${words.substring(1)}';
  }

  static IconData _iconOf(String? name) {
    final last = (name ?? '').split('/').where((s) => s.isNotEmpty).lastOrNull;
    return _icons[last] ?? Icons.article_outlined;
  }

  static const _icons = <String, IconData>{
    'settings': Icons.settings_rounded,
    'theme': Icons.palette_outlined,
    'look': Icons.palette_outlined,
    'preferences': Icons.tune_rounded,
    'privacy': Icons.shield_outlined,
    'app-drawer': Icons.apps_rounded,
    'notifications': Icons.notifications_outlined,
    'activity': Icons.event_note_outlined,
    'data': Icons.storage_rounded,
    'automatic-backups': Icons.backup_outlined,
    'accounts': Icons.account_balance_wallet,
    'categories': Icons.category,
    'tags': Icons.label_rounded,
    'budgets': Icons.pie_chart_rounded,
    'recurring': Icons.sync_rounded,
    'ledger': Icons.handshake,
    'loans': Icons.account_balance_outlined,
    'investments': Icons.show_chart_rounded,
    'tools': Icons.calculate_rounded,
    'notes': Icons.sticky_note_2_outlined,
    'reminders': Icons.notifications_active_outlined,
    'upcoming-events': Icons.calendar_month_rounded,
    'stories-archive': Icons.auto_stories_rounded,
    'widgets-gallery': Icons.widgets_outlined,
    'about': Icons.info_outline_rounded,
    'pro': Icons.workspace_premium_rounded,
    'cards': Icons.credit_card_rounded,
    'ask-kuber': Icons.auto_awesome_rounded,
    'sms-import': Icons.sms_outlined,
  };

  /// Opens the sheet; with nowhere to jump to, does nothing.
  static void open(BuildContext context) {
    final entries = read(context);
    if (entries.length < 2) return;
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KuberPathSheet(entries: entries, router: GoRouter.of(context)),
    );
  }
}

class _PathObserver extends NavigatorObserver {
  final routes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => routes.add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => routes.remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => routes.remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = routes.indexOf(oldRoute as Route<dynamic>);
    if (i >= 0 && newRoute != null) routes[i] = newRoute;
  }
}

class KuberPathEntry {
  final IconData icon;
  final String title;

  /// The page to go back to, or the tab's location for a tab entry.
  final Route<dynamic>? route;
  final String? tabLocation;

  const KuberPathEntry(this.icon, this.title, {this.route, this.tabLocation});
}

/// The path to the current page. An earlier entry pops straight back to that
/// page: the ones in between close and it is not rebuilt.
class KuberPathSheet extends StatelessWidget {
  final List<KuberPathEntry> entries;
  final GoRouter router;
  const KuberPathSheet({super.key, required this.entries, required this.router});

  void _jump(BuildContext context, KuberPathEntry e) {
    final nav = Navigator.of(context, rootNavigator: true);
    nav.pop();
    final target = e.route;
    if (target != null) {
      nav.popUntil((r) => r == target);
    } else {
      router.go(e.tabLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return KuberBottomSheet(
      title: l.pathSheetTitle,
      child: LayoutBuilder(
        builder: (context, box) {
          // Each page sits one step in from the page before it; a deep path
          // tightens the steps so titles keep their room.
          final last = entries.length - 1;
          final step = last == 0 ? 0.0 : math.min(_treeStep, (box.maxWidth - _titleRoom) / last);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, e) in entries.indexed)
                _PathTreeRow(
                  entry: e,
                  depth: i,
                  step: step,
                  current: i == last,
                  onTap: i == last ? null : () => _jump(context, e),
                ),
            ],
          );
        },
      ),
    );
  }
}

const double _treeStep = 28;
const double _titleRoom = 200;
const double _iconSize = 24;

/// One page of the tree: its branch from the page above, icon and title.
class _PathTreeRow extends StatelessWidget {
  final KuberPathEntry entry;
  final int depth;
  final double step;
  final bool current;
  final VoidCallback? onTap;

  const _PathTreeRow({
    required this.entry,
    required this.depth,
    required this.step,
    required this.current,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: KuberShape.mediumR,
      child: CustomPaint(
        painter: _PathBranchPainter(depth: depth, step: step, color: cs.outlineVariant),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: KuberSpace.listItem1),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: depth * step,
              top: KuberSpace.sm,
              bottom: KuberSpace.sm,
            ),
            child: Row(
              children: [
                Icon(entry.icon, size: _iconSize, color: current ? cs.primary : cs.onSurfaceVariant),
                const SizedBox(width: KuberSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: current ? cs.primary : cs.onSurface,
                        ),
                      ),
                      if (current) KuberPill(label: l.pathSheetCurrent),
                    ],
                  ),
                ),
                if (!current) const KuberChevron(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The tree line: down from the parent's icon, then across to this row's icon.
class _PathBranchPainter extends CustomPainter {
  final int depth;
  final double step;
  final Color color;
  const _PathBranchPainter({required this.depth, required this.step, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (depth == 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final x = (depth - 1) * step + _iconSize / 2;
    final mid = size.height / 2;
    final end = depth * step - 4;
    // Starts in the row above, under the parent's icon.
    canvas.drawPath(
      Path()
        ..moveTo(x, -size.height / 2 + _iconSize / 2 + 4)
        ..lineTo(x, mid)
        ..lineTo(end, mid),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PathBranchPainter old) =>
      old.depth != depth || old.step != step || old.color != color;
}

/// The tab shell tells [KuberPath] which route and tab it is.
class KuberPathShell extends StatelessWidget {
  final int tab;
  final Widget child;
  const KuberPathShell({super.key, required this.tab, required this.child});

  @override
  Widget build(BuildContext context) {
    KuberPath.tab = tab;
    KuberPath.shellRoute = ModalRoute.of(context);
    return child;
  }
}
