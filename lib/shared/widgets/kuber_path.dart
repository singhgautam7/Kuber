import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion/kuber_haptics.dart';
import '../../core/motion/motion_level.dart';
import '../../core/motion/route_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/l10n_ext.dart';
import '../../features/pro/paywall/pro_state.dart';
import 'kuber_bottom_sheet.dart';
import 'quick_nav/quick_nav_jump.dart';
import 'quick_nav/quick_nav_model.dart';
import 'quick_nav/quick_nav_tree.dart';
import 'quick_nav/quick_nav_view.dart';

/// Quick navigation (the old path sheet): one tree of the app's pages with the
/// current page marked, built from the real back stack. Only entry points touch
/// this; nothing runs per frame.
class KuberPath {
  KuberPath._();

  /// Keeps the root navigator's stack, in order. Sheets and dialogs are in it
  /// too; only pages and registered virtual pages are read from it.
  static final observer = _PathObserver();

  /// The tab showing under the pushed pages, and the shell's own route.
  static int tab = 0;
  static Route<dynamic>? shellRoute;

  static final _titles = Expando<String>('kuberPathTitle');
  static final _virtual = Expando<(String, IconData)>('kuberPathVirtual');

  /// A page's header gives its route a title (the readable name of the page).
  static void setTitle(Route<dynamic> route, String title) => _titles[route] = title;

  /// Registers the page or sheet that [context] belongs to as a page of its own
  /// in Quick navigation, for screens that are not routes (a loan detail
  /// sheet, a fund, SIP history). It shows as a leaf under the page below it
  /// and is gone when its route pops, so there is nothing to undo. Call it
  /// from `didChangeDependencies` or `build`; calling again just updates it.
  static void pushVirtual(BuildContext context, {required String title, required IconData icon}) {
    final route = ModalRoute.of(context);
    if (route != null) _virtual[route] = (title, icon);
  }

  /// The pages on the stack, bottom first, the tab shell left out.
  static List<QuickNavStackEntry> stack(GoRouter router) {
    final where = <String, String>{};
    void walk(Iterable<RouteMatchBase> ms) {
      for (final m in ms) {
        if (m is ShellRouteMatch) {
          walk(m.matches);
        } else {
          where[m.pageKey.value] = m.matchedLocation;
        }
      }
    }

    walk(router.routerDelegate.currentConfiguration.matches);
    final out = <QuickNavStackEntry>[];
    for (final r in observer.routes) {
      if (!r.isActive || identical(r, shellRoute)) continue;
      final v = _virtual[r];
      if (r is! PageRoute && v == null) continue;
      final page = r.settings;
      final key = page is Page ? page.key : null;
      out.add(QuickNavStackEntry(
        route: r,
        location: v != null || key is! ValueKey<String> ? null : where[key.value],
        title: v?.$1 ?? _titles[r] ?? _readable(r.settings.name),
        icon: v?.$2 ?? _iconOf(r.settings.name),
      ));
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
    'theme': Icons.contrast_rounded,
    'look': Icons.palette_outlined,
    'help': Icons.help_outline_rounded,
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

  /// Opens the sheet; on a tab's own page there is no path, so nothing opens.
  static void open(BuildContext context) {
    final router = GoRouter.of(context);
    final stack = KuberPath.stack(router);
    if (stack.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
      sheetAnimationStyle: kuberSheetStyle(context),
      builder: (_) => KuberPathSheet(
        stack: stack,
        tab: tab,
        router: router,
        fromNotification: observer.routes.any((r) => r.isActive && _fromNotification[r] == true),
      ),
    );
  }

  static final _fromNotification = Expando<bool>('kuberPathNotification');

  /// A notification tap just opened the page on top: the sheet says so.
  static void markFromNotification() {
    final top = observer.routes.lastWhere((r) => r is PageRoute, orElse: () => observer.routes.last);
    _fromNotification[top] = true;
  }

  /// Long press on a header's back button: the long-press haptic, then the sheet.
  static void openFromLongPress(BuildContext context) {
    KuberHaptics.longPress();
    open(context);
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

/// The sheet: Quick navigation. A tap on a row takes the user there with one
/// fade-through; see [quickNavJump] for how the back stack is kept.
class KuberPathSheet extends ConsumerStatefulWidget {
  final List<QuickNavStackEntry> stack;
  final int tab;
  final GoRouter router;
  final bool fromNotification;
  const KuberPathSheet({
    super.key,
    required this.stack,
    required this.tab,
    required this.router,
    this.fromNotification = false,
  });

  @override
  ConsumerState<KuberPathSheet> createState() => _KuberPathSheetState();
}

class _KuberPathSheetState extends ConsumerState<KuberPathSheet> {
  QuickNavModel? _model;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Once per open: the tree resets every time the sheet opens.
    _model ??= QuickNavModel.build(buildQuickNavTree(context, ref), widget.stack, widget.tab);
  }

  void _jump(QvNode n) {
    final nav = Navigator.of(context, rootNavigator: true);
    final cs = Theme.of(context).colorScheme;
    final reduced = KuberMotion.levelOf(context) == MotionLevel.off;
    nav.pop();
    if (n.current) return;
    final gate = n.node.gate;
    if (gate != null && n.route == null && !ref.read(kuberProStateProvider).hasProAccess) {
      gate(nav.context);
      return;
    }
    unawaited(quickNavJump(
      nav: nav,
      router: widget.router,
      target: n,
      readStack: () => KuberPath.stack(widget.router),
      topRoute: () => KuberPath.observer.routes.lastOrNull,
      currentTab: () => KuberPath.tab,
      curtainColor: cs.surface,
      reduced: reduced,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return KuberBottomSheet(
      title: l.pathSheetTitle,
      description: l.pathSheetSub,
      bodyPadding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.fromNotification)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: KuberSpace.sm),
                  Expanded(
                    child: Text(l.pathSheetFromNotification,
                        style: theme.textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
          QuickNavTree(model: _model!, onJump: _jump),
        ],
      ),
    );
  }
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
