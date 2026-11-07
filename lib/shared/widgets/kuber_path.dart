import 'dart:math' as math;

import 'package:flutter/material.dart';
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

  /// Opens the sheet; with nowhere to jump to, does nothing.
  static void open(BuildContext context) {
    final entries = read(context);
    if (entries.length < 2) return;
    final reduced = KuberMotion.reduced(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
      sheetAnimationStyle: reduced
          ? const AnimationStyle(
              duration: Duration(milliseconds: 150),
              reverseDuration: Duration(milliseconds: 150),
            )
          : const AnimationStyle(
              duration: Duration(milliseconds: 300),
              reverseDuration: Duration(milliseconds: 200),
              curve: Easing.emphasizedDecelerate,
              reverseCurve: Easing.emphasizedAccelerate,
            ),
      builder: (_) => KuberPathSheet(
        entries: entries,
        router: GoRouter.of(context),
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

/// The path to the current page, as a tree (Components 2m). An earlier entry
/// pops straight back to that page: the ones in between close and it is not
/// rebuilt.
class KuberPathSheet extends StatelessWidget {
  final List<KuberPathEntry> entries;
  final GoRouter router;
  final bool fromNotification;
  const KuberPathSheet({
    super.key,
    required this.entries,
    required this.router,
    this.fromNotification = false,
  });

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return KuberBottomSheet(
      title: l.pathSheetTitle,
      description: l.pathSheetSub,
      bodyPadding: const EdgeInsets.fromLTRB(12, 4, 12, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (fromNotification)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
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
          KuberPathTree(entries: entries, onJump: (e) => _jump(context, e)),
        ],
      ),
    );
  }
}

/// Row sizes of the tree. From 6 levels the rows tighten so titles keep room.
class _TreeSize {
  final double row, step, tile, glyph, radius;
  const _TreeSize(this.row, this.step, this.tile, this.glyph, this.radius);
  static const normal = _TreeSize(56, 28, 32, 18, 10);
  static const dense = _TreeSize(48, 22, 28, 16, 8);
}

const double _treeBase = 12;
const double _titleRoom = 140;
const double _elbow = 10;
// A deep path scrolls inside this height, opened at the current page.
const double _deepHeight = 300;

// Stagger: rows come in once the sheet is about 60% up.
const int _treeDelay = 90;
const int _rowMs = 180;
const int _rowGap = 30;
const int _staggered = 8;

/// One row per page on the stack, the last being the current page.
class KuberPathTree extends StatefulWidget {
  final List<KuberPathEntry> entries;
  final ValueChanged<KuberPathEntry> onJump;
  const KuberPathTree({super.key, required this.entries, required this.onJump});

  @override
  State<KuberPathTree> createState() => _KuberPathTreeState();
}

class _KuberPathTreeState extends State<KuberPathTree> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final _scroll = ScrollController();
  var _started = false;

  int get _total => _treeDelay + _rowGap * (math.min(widget.entries.length, _staggered) - 1) + _rowMs;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Duration(milliseconds: _total));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (KuberMotion.reduced(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Animation<double> _rowAnim(int i, double ms) {
    final at = _treeDelay + _rowGap * math.min(i, _staggered - 1);
    return CurvedAnimation(
      parent: _c,
      curve: Interval(at / _total, math.min(1, (at + ms) / _total), curve: Easing.emphasizedDecelerate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.entries.length;
    final size = n > 5 ? _TreeSize.dense : _TreeSize.normal;
    return LayoutBuilder(
      builder: (context, box) {
        final last = n - 1;
        final titles = MediaQuery.textScalerOf(context).scale(_titleRoom);
        final room = box.maxWidth - _treeBase - size.tile - KuberSpace.md - titles;
        final step = last == 0 ? 0.0 : math.min(size.step, math.max(4.0, room / last));
        final tree = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, e) in widget.entries.indexed)
              _TreeRow(
                entry: e,
                depth: i,
                step: step,
                size: size,
                current: i == last,
                fade: _rowAnim(i, _rowMs.toDouble()),
                line: _rowAnim(i, 120),
                onTap: i == last ? null : () => widget.onJump(e),
              ),
          ],
        );
        if (n * size.row <= _deepHeight) return tree;
        return _DeepTree(controller: _scroll, child: tree);
      },
    );
  }
}

/// A path too long for the sheet: opens on the current page, with a fade and a
/// bar at the top edge to say there's more above.
class _DeepTree extends StatelessWidget {
  final ScrollController controller;
  final Widget child;
  const _DeepTree({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sheet = cs.surfaceContainerLow;
    return SizedBox(
      height: _deepHeight,
      child: Stack(
        children: [
          RawScrollbar(
            controller: controller,
            thumbVisibility: true,
            thickness: 4,
            radius: const Radius.circular(KuberShape.full),
            thumbColor: cs.onSurfaceVariant.withValues(alpha: 0.4),
            child: SingleChildScrollView(controller: controller, reverse: true, child: child),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 40,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [sheet, sheet.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One page of the tree: its branch from the page above, tile and title.
class _TreeRow extends StatelessWidget {
  final KuberPathEntry entry;
  final int depth;
  final double step;
  final _TreeSize size;
  final bool current;
  final Animation<double> fade;
  final Animation<double> line;
  final VoidCallback? onTap;

  const _TreeRow({
    required this.entry,
    required this.depth,
    required this.step,
    required this.size,
    required this.current,
    required this.fade,
    required this.line,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final left = _treeBase + depth * step;
    final title = current
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium!.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: KuberSpace.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: KuberShape.fullR),
                child: Text(
                  l.pathSheetCurrent,
                  style: theme.textTheme.labelSmall!.copyWith(color: cs.onSecondaryContainer),
                ),
              ),
            ],
          )
        : Text(
            entry.title,
            maxLines: MediaQuery.textScalerOf(context).scale(16) > 20 ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
          );
    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: size.row),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: left,
          end: KuberSpace.md,
          top: (size.row - size.tile) / 2,
          bottom: (size.row - size.tile) / 2,
        ),
        child: Row(
          children: [
            KuberIconTile(
              icon: entry.icon,
              size: size.tile,
              glyph: size.glyph,
              radius: size.radius,
              color: current ? cs.primary : cs.surfaceContainerHigh,
              iconColor: current ? cs.onPrimary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: KuberSpace.md),
            Expanded(child: title),
          ],
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      label: current ? '${entry.title}, ${l.pathSheetCurrent}' : entry.title,
      excludeSemantics: true,
      child: CustomPaint(
        painter: _TreeLinkPainter(
          depth: depth,
          step: step,
          tile: size.tile,
          current: current,
          color: cs.outlineVariant,
          progress: line,
        ),
        child: Stack(
          children: [
            if (onTap != null)
              PositionedDirectional(
                start: left - 6,
                end: 0,
                top: 4,
                bottom: 4,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(14),
                    overlayColor: kuberPressedLayer(cs),
                  ),
                ),
              ),
            IgnorePointer(
              child: FadeTransition(
                opacity: fade,
                child: AnimatedBuilder(
                  animation: fade,
                  builder: (_, c) => Transform.translate(
                    offset: Offset(-8 * (1 - fade.value), 0),
                    child: c,
                  ),
                  child: content,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The connectors: down from the parent's tile with a rounded elbow into this
/// row's tile, and on down towards the child. Redraws itself as they grow.
class _TreeLinkPainter extends CustomPainter {
  final int depth;
  final double step;
  final double tile;
  final bool current;
  final Color color;
  final Animation<double> progress;

  _TreeLinkPainter({
    required this.depth,
    required this.step,
    required this.tile,
    required this.current,
    required this.color,
    required this.progress,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t == 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final mid = size.height / 2;
    final left = _treeBase + depth * step;
    final path = Path();
    if (depth > 0) {
      final parent = left - step + tile / 2;
      final elbow = math.min(_elbow, math.max(0.0, left - parent));
      path
        ..moveTo(parent, 0)
        ..lineTo(parent, mid - elbow)
        ..quadraticBezierTo(parent, mid, parent + elbow, mid)
        ..lineTo(left, mid);
    }
    if (!current) {
      final x = left + tile / 2;
      path
        ..moveTo(x, mid + tile / 2)
        ..lineTo(x, size.height);
    }
    if (t >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height * t));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TreeLinkPainter old) =>
      old.depth != depth || old.step != step || old.tile != tile ||
      old.current != current || old.color != color;
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
