import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../kuber_list.dart' show kuberPressedLayer;
import 'quick_nav_model.dart';

// Row sizes from the design (v7.js trow). Rows are 44 dp; at the largest font
// the indent step drops from 20 to 16 and rows grow to fit 2 lines.
const double _rowH = 44;
const double _rowHBig = 60;
const double _pad = 8;
const double _step = 20;
const double _stepBig = 16;
const double _treeMax = 520;

bool _bigFont(BuildContext c) => MediaQuery.textScalerOf(c).scale(10) / 10 >= 1.3;

/// The tree, built once when the sheet opens: only the parents of the current
/// page are open, it opens already scrolled so the current row sits in the
/// upper third, and it is reset on every open.
class QuickNavTree extends StatefulWidget {
  final QuickNavModel model;
  final ValueChanged<QvNode> onJump;
  const QuickNavTree({super.key, required this.model, required this.onJump});

  @override
  State<QuickNavTree> createState() => _QuickNavTreeState();
}

class _QuickNavTreeState extends State<QuickNavTree> with SingleTickerProviderStateMixin {
  late final Set<String> _open;
  final _all = <String>{};
  late final AnimationController _enter;
  late ScrollController _scroll;
  late final Map<String, int> _order;
  var _rows = 0;
  // (scrolled away from the top, more below): drives the two edge fades.
  final _edges = ValueNotifier<(bool, bool)>((false, true));
  var _started = false;
  var _level = MotionLevel.expressive;

  @override
  void initState() {
    super.initState();
    _open = {for (final a in widget.model.current.ancestors) a.id};
    _order = {};
    var i = 0;
    void walk(QvNode n) {
      _order[n.id] = i++;
      if (!_open.contains(n.id)) return;
      final k = QuickNavKids.of(n, all: false);
      for (final c in k.shown) {
        walk(c);
      }
      if (k.remaining > 0) i++; // the Show remaining row
    }

    for (final r in widget.model.roots) {
      walk(r);
    }
    _rows = i;
    _enter = AnimationController(vsync: this);
  }

  /// Expressive: rows rise 8 dp and fade, 30 ms apart (first 6). Subtle: all
  /// at once, 4 dp. Off: nothing.
  Duration _enterDuration(MotionLevel l) {
    if (l != MotionLevel.expressive) return KuberMotion.fxFast;
    final steps = math.min(_rows, KuberMotion.staggerLimit) - 1;
    return KuberMotion.staggerStep * math.max(steps, 0) + KuberMotion.fxFast;
  }

  /// Top of the viewport that puts the current row a third of the way down.
  double _offsetFor(bool big) {
    final rh = big ? _rowHBig : _rowH;
    final total = _rows * rh;
    final avail = math.min(total, _treeMax);
    final at = (_order[widget.model.current.id] ?? 0) * rh;
    return math.max(0, math.min(total - avail, at - avail / 3));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final at = _offsetFor(_bigFont(context));
    _scroll = ScrollController(initialScrollOffset: at);
    _edges.value = (at > 0, true);
    final level = KuberMotion.levelOf(context);
    _level = level;
    if (level == MotionLevel.off) {
      _enter.value = 1;
    } else {
      _enter.duration = _enterDuration(level);
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _scroll.dispose();
    _edges.dispose();
    super.dispose();
  }

  bool _onMetrics(ScrollMetricsNotification n) => _onEdge(n.metrics);
  bool _onScrolled(ScrollNotification n) => _onEdge(n.metrics);
  bool _onEdge(ScrollMetrics m) {
    _edges.value = (m.pixels > 1, m.pixels < m.maxScrollExtent - 1);
    return false;
  }

  void _toggle(QvNode n) => setState(() => _open.contains(n.id) ? _open.remove(n.id) : _open.add(n.id));
  void _toggleAll(QvNode n) => setState(() => _all.contains(n.id) ? _all.remove(n.id) : _all.add(n.id));

  Widget _branch(QvNode n, int level) {
    final isOpen = _open.contains(n.id);
    final row = _Entrance(
      index: _order[n.id],
      animation: _enter,
      level: _level,
      child: _QnRow(
        n: n,
        level: level,
        open: isOpen,
        onTap: () => widget.onJump(n),
        onToggle: n.isFolder ? () => _toggle(n) : null,
      ),
    );
    if (!n.isFolder) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        _Reveal(open: isOpen, builder: () => _kids(n, level + 1)),
      ],
    );
  }

  Widget _kids(QvNode n, int level) {
    final all = _all.contains(n.id);
    final k = QuickNavKids.of(n, all: all);
    final base = all ? QuickNavKids.of(n, all: false).shown : k.shown;
    final full = n.kids;
    // A long list shows one section; "Show remaining" opens the rest in place
    // (before and after that section), "Show fewer" closes it again.
    final at = base.isEmpty ? 0 : math.max(0, full.indexOf(base.first));
    final before = base.length == full.length ? const <QvNode>[] : full.sublist(0, at);
    final after = base.length == full.length ? const <QvNode>[] : full.sublist(at + base.length);
    final l = context.l10n;
    final hasMore = full.length > base.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (before.isNotEmpty)
          _Reveal(
            open: all,
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final c in before) _branch(c, level)],
            ),
          ),
        for (final c in base) _branch(c, level),
        if (after.isNotEmpty)
          _Reveal(
            open: all,
            builder: () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final c in after) _branch(c, level)],
            ),
          ),
        if (hasMore)
          _QnMoreRow(
            level: level,
            label: k.showFewer ? l.pathSheetShowFewer : l.pathSheetShowRemaining('${k.remaining}'),
            less: k.showFewer,
            onTap: () => _toggleAll(n),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _treeMax),
      child: Stack(
        children: [
          NotificationListener<ScrollMetricsNotification>(
            onNotification: _onMetrics,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrolled,
              child: RawScrollbar(
            controller: _scroll,
            thumbVisibility: true,
            thickness: 4,
            radius: const Radius.circular(KuberShape.full),
            thumbColor: cs.onSurfaceVariant.withValues(alpha: 0.4),
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final r in widget.model.roots) _branch(r, 0)],
              ),
            ),
          ),
            ),
          ),
          _Fades(edges: _edges, color: cs.surfaceContainerLow),
        ],
      ),
    );
  }
}

/// Top fade (32 dp) once scrolled, bottom fade (40 dp) while more is below.
class _Fades extends StatelessWidget {
  final ValueListenable<(bool, bool)> edges;
  final Color color;
  const _Fades({required this.edges, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ValueListenableBuilder<(bool, bool)>(
          valueListenable: edges,
          builder: (_, e, _) => Stack(
            children: [
              if (e.$1) _fade(true, 32),
              if (e.$2) _fade(false, 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fade(bool top, double h) => Positioned(
        left: 0,
        right: 0,
        top: top ? 0 : null,
        bottom: top ? null : 0,
        height: h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: top ? Alignment.topCenter : Alignment.bottomCenter,
              end: top ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      );
}

/// One page of the tree.
class _QnRow extends StatelessWidget {
  final QvNode n;
  final int level;
  final bool open;
  final VoidCallback onTap;
  final VoidCallback? onToggle;
  const _QnRow({
    required this.n,
    required this.level,
    required this.open,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final big = _bigFont(context);
    final step = big ? _stepBig : _step;
    final cur = n.current;
    final left = _pad + level * step;
    final fg = cur ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    final here = Text(l.pathSheetCurrent, maxLines: 1, style: theme.textTheme.labelSmall!.copyWith(color: cs.onSecondaryContainer));
    final title = Text(
      n.node.title,
      maxLines: big ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: cur
          ? theme.textTheme.titleMedium!.copyWith(color: cs.onSecondaryContainer)
          : theme.textTheme.bodyLarge!.copyWith(color: cs.onSurface),
    );
    final label = cur ? '${n.node.title}, ${l.pathSheetCurrent}' : n.node.title;

    return Pressable(
      kind: PressKind.row,
      child: Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: big ? _rowHBig : _rowH),
        child: Stack(
          children: [
            if (level > 0)
              Positioned.fill(
                child: CustomPaint(painter: _Guides(level, step, cs.outlineVariant)),
              ),
            Positioned(
              top: 2,
              bottom: 2,
              left: left - 4,
              right: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cur ? cs.secondaryContainer : null,
                  borderRadius: BorderRadius.circular(KuberShape.medium),
                ),
                child: Semantics(
                  button: true,
                  selected: cur,
                  label: label,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(KuberShape.medium),
                    overlayColor: kuberPressedLayer(cs),
                    excludeFromSemantics: true,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: ExcludeSemantics(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(left, 2, 12, 2),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: (big ? _rowHBig : _rowH) - 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: n.isFolder
                              ? _Chevron(open: open, color: fg)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Icon(cur ? _filled(n.node.icon) : n.node.icon, size: 20, color: fg),
                        const SizedBox(width: 8),
                        Expanded(
                          child: big && cur
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [title, here],
                                )
                              : title,
                        ),
                        if (cur && !big) ...[const SizedBox(width: 8), here],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (onToggle != null)
              Positioned(
                left: left - 8,
                top: 0,
                bottom: 0,
                width: 40,
                child: Semantics(
                  button: true,
                  label: '${open ? l.pathSheetCollapse : l.pathSheetExpand} ${n.node.title}',
                  child: InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(KuberShape.medium),
                    overlayColor: kuberPressedLayer(cs),
                    excludeFromSemantics: true,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
          ],
        ),
      ),
    ));
  }
}

/// The "Show remaining N pages" / "Show fewer pages" row.
class _QnMoreRow extends StatelessWidget {
  final int level;
  final String label;
  final bool less;
  final VoidCallback onTap;
  const _QnMoreRow({required this.level, required this.label, required this.less, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final big = _bigFont(context);
    final step = big ? _stepBig : _step;
    final left = _pad + level * step;
    return Pressable(
      kind: PressKind.row,
      child: Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: big ? _rowHBig : _rowH),
        child: Stack(
          children: [
            if (level > 0) Positioned.fill(child: CustomPaint(painter: _Guides(level, step, cs.outlineVariant))),
            Positioned.fill(
              left: left - 4,
              right: 4,
              top: 2,
              bottom: 2,
              child: Semantics(
                button: true,
                label: label,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(KuberShape.medium),
                  overlayColor: kuberPressedLayer(cs),
                  excludeFromSemantics: true,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            IgnorePointer(
              child: ExcludeSemantics(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(left, 2, 12, 2),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: (big ? _rowHBig : _rowH) - 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 24 + 8),
                        Icon(less ? Icons.unfold_less_rounded : Icons.unfold_more_rounded, size: 20, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            maxLines: big ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge!.copyWith(color: cs.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

/// 1 px guide lines, one per level, at x = 8 + g * step + 11.
class _Guides extends CustomPainter {
  final int level;
  final double step;
  final Color color;
  _Guides(this.level, this.step, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var g = 0; g < level; g++) {
      final x = _pad + g * step + 11 + 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
  }

  @override
  bool shouldRepaint(_Guides o) => o.level != level || o.step != step || o.color != color;
}

// ---- Motion (kit: ChevronTurn, ExpandCollapse) ----

/// The filled twin of an outlined icon, for the current page's row.
IconData _filled(IconData i) => _filledIcons[i] ?? i;
final _filledIcons = <IconData, IconData>{
  Icons.account_balance_outlined: Icons.account_balance,
  Icons.article_outlined: Icons.article,
  Icons.backup_outlined: Icons.backup,
  Icons.bolt_outlined: Icons.bolt,
  Icons.cloud_sync_outlined: Icons.cloud_sync,
  Icons.event_note_outlined: Icons.event_note,
  Icons.help_outline_rounded: Icons.help_rounded,
  Icons.home_outlined: Icons.home,
  Icons.info_outline_rounded: Icons.info_rounded,
  Icons.insert_chart_outlined_rounded: Icons.insert_chart_rounded,
  Icons.notifications_active_outlined: Icons.notifications_active,
  Icons.notifications_outlined: Icons.notifications,
  Icons.palette_outlined: Icons.palette,
  Icons.shield_outlined: Icons.shield,
  Icons.sms_outlined: Icons.sms,
  Icons.sticky_note_2_outlined: Icons.sticky_note_2,
  Icons.widgets_outlined: Icons.widgets,
  Icons.add_circle_outline_rounded: Icons.add_circle_rounded,
};

/// chevron_right 20, turned 90 degrees when the folder is open.
class _Chevron extends StatelessWidget {
  final bool open;
  final Color color;
  const _Chevron({required this.open, required this.color});

  @override
  Widget build(BuildContext context) =>
      ChevronTurn(expanded: open, openDegrees: 90, size: 20, color: color);
}

/// Opens and closes a folder's (or a long list's extra) children with
/// [ExpandCollapse]. Nothing is built while closed: the children are built
/// when it opens and dropped once the collapse has settled.
class _Reveal extends StatefulWidget {
  final bool open;
  final Widget Function() builder;
  const _Reveal({required this.open, required this.builder});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> {
  Widget? _child;
  Timer? _drop;

  @override
  void dispose() {
    _drop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.open) {
      _drop?.cancel();
      _drop = null;
      _child = widget.builder();
    } else if (_child != null && _drop == null) {
      _drop = Timer(KuberMotion.standardCurve.settle + KuberMotion.fxFast, () {
        _drop = null;
        if (mounted && !widget.open) setState(() => _child = null);
      });
    }
    return ExpandCollapse(
      expanded: widget.open,
      child: _child ?? const SizedBox(width: double.infinity),
    );
  }
}

/// A row rising and fading in on open, [KuberMotion.staggerStep] after the
/// one above (first 6 rows). Subtle: no stagger, 4 dp. Off: nothing.
class _Entrance extends StatelessWidget {
  final int? index;
  final AnimationController animation;
  final MotionLevel level;
  final Widget child;
  const _Entrance({required this.index, required this.animation, required this.level, required this.child});

  @override
  Widget build(BuildContext context) {
    if (animation.isCompleted || index == null || level == MotionLevel.off) return child;
    final expressive = level == MotionLevel.expressive;
    final span = animation.duration!.inMilliseconds;
    final begin = expressive ? KuberMotion.staggerDelay(index!).inMilliseconds / span : 0.0;
    final end = math.min(1.0, begin + KuberMotion.fxFast.inMilliseconds / span);
    final curve = Interval(begin, end, curve: KuberMotion.curveEffects);
    final rise = expressive ? 8.0 : 4.0;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (_, c) {
        final t = curve.transform(animation.value);
        return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, rise * (1 - t)), child: c));
      },
    );
  }
}
