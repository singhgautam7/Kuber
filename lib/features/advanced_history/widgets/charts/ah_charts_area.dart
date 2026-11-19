import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/timed_snackbar.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../common/ah_common.dart';
import 'package:kuber/core/motion/motion.dart';
import 'ah_chart_builder.dart';
import 'ah_chart_card.dart';

/// 0 to 4 chart cards plus the Add button, as one sliver (it sits inside the
/// page's scroll view). Keeps a stable id per card so reordering slides the
/// cards instead of rebuilding them.
class AhChartsArea extends ConsumerStatefulWidget {
  const AhChartsArea({super.key});

  @override
  ConsumerState<AhChartsArea> createState() => _AhChartsAreaState();
}

class _AhChartsAreaState extends ConsumerState<AhChartsArea> {
  var _ids = <int>[];

  var _next = 0;
  List<AhChartSpec> _last = const [];

  /// What the list will be after an operation done here, so the resulting
  /// provider change keeps the ids; any other change (apply a saved view,
  /// clear all, undo) gets fresh ids, so the cards grow in again.
  List<AhChartSpec>? _expected;

  void _sync(List<AhChartSpec> specs) {
    if (_listEq(specs, _last) && _ids.length == specs.length) return;
    final exp = _expected;
    final n = _ids.length;
    if (exp != null && _listEq(specs, exp) && n == specs.length) {
      // Done here (move, remove, undo, quick fix): ids already updated.
    } else if (specs.length == n + 1 &&
        _listEq(specs.sublist(1), _last.take(n).toList())) {
      _ids = [_next++, ..._ids]; // the builder added a chart (at the top)
    } else if (specs.length == n && n == _last.length && _oneDiff(specs)) {
      // The builder edited one chart: same card, content cross-fades.
    } else {
      _ids = [for (var i = 0; i < specs.length; i++) _next++];
    }
    _expected = null;
    _last = List.of(specs);
  }

  bool _oneDiff(List<AhChartSpec> specs) {
    var d = 0;
    for (var i = 0; i < specs.length; i++) {
      if (specs[i] != _last[i]) d++;
    }
    return d == 1;
  }

  bool _listEq(List<AhChartSpec> a, List<AhChartSpec> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  AhViewNotifier get _n => ref.read(ahViewProvider.notifier);

  void _move(int from, int to) {
    if (from == to) return;
    final specs = List.of(ref.read(ahViewProvider).charts);
    final exp = List.of(specs)..insert(to, specs.removeAt(from));
    KuberHaptics.tick();
    setState(() {
      _ids.insert(to, _ids.removeAt(from));
      _expected = exp;
    });
    _n.moveChart(from, to);
  }

  void _remove(int i) {
    final specs = ref.read(ahViewProvider).charts;
    final spec = specs[i];
    setState(() {
      _ids.removeAt(i);
      _expected = List.of(specs)..removeAt(i);
    });
    _n.removeChart(i);
    final l = context.l10n;
    showKuberSnackBar(
      context,
      l.ahdChartRemoved,
      actionLabel: l.ahdUndo,
      duration: const Duration(seconds: 7),
      onAction: () {
        if (!mounted) return;
        final cur = ref.read(ahViewProvider).charts;
        if (cur.length >= kAhMaxCharts) return;
        final at = i.clamp(0, cur.length);
        setState(() {
          _ids.insert(at, _next++);
          _expected = List.of(cur)..insert(at, spec);
        });
        _n.insertChart(at, spec);
      },
    );
  }

  void _quickMonth(int i) {
    final specs = ref.read(ahViewProvider).charts;
    final spec = specs[i].copyWith(split: AhChartSplit.month);
    setState(() => _expected = List.of(specs)..[i] = spec);
    _n.updateChart(i, spec);
  }

  void _add() => showAhChartBuilder(context);

  void _edit(int i) =>
      showAhChartBuilder(context, editIndex: i, onRemove: () => _remove(i));

  @override
  Widget build(BuildContext context) {
    final specs = ref.watch(ahViewProvider.select((v) => v.charts));
    _sync(specs);
    final cs = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
      sliver: SliverMainAxisGroup(
        slivers: [
          // Right under the KPIs, so it's in the same place however many
          // charts there are; a new chart grows in just below it.
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: specs.isEmpty ? 0 : KuberSpace.md),
              child: AnimatedSwitcher(
              duration: KuberMotion.of(context, KuberMotion.fxFast),
              child: specs.length >= kAhMaxCharts
                  ? Padding(
                      key: const ValueKey('full'),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(context.l10n.ahdChartsFull,
                          textAlign: TextAlign.center,
                          style: localeFont(
                              fontSize: 13, color: cs.onSurfaceVariant)),
                    )
                  : _AddButton(
                      key: ValueKey(specs.isEmpty),
                      count: specs.length,
                      onTap: _add,
                    ),
              ),
            ),
          ),
          SliverReorderableList(
            itemCount: specs.length,
            onReorderStart: (_) => KuberHaptics.longPress(),
            onReorderItem: _move,
            proxyDecorator: (child, index, anim) => AnimatedBuilder(
              animation: anim,
              child: child,
              builder: (context, child) {
                final t = Curves.easeOutCubic.transform(anim.value);
                return Transform.scale(
                  scale: 1 + 0.02 * t,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: KuberShape.cardR,
                      // The design's drag-lift shadow (the one exception to
                      // "no shadows").
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.20 * t),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AhLiftScope(lifted: true, child: child!),
                  ),
                );
              },
            ),
            itemBuilder: (context, i) {
              return ReorderableDelayedDragStartListener(
                key: ValueKey(_ids[i]),
                index: i,
                child: AhChartCard(
                  index: i,
                  count: specs.length,
                  spec: specs[i],
                  delay: Duration(milliseconds: 40 * i),
                  handle: (lifted) => ReorderableDragStartListener(
                    index: i,
                    child: _Handle(lifted: lifted),
                  ),
                  onEdit: () => _edit(i),
                  onMove: (d) => _move(i, i + d),
                  onRemove: () => _remove(i),
                  onQuickSplitMonth: () => _quickMonth(i),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: KuberSpace.md)),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.lifted});
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: context.l10n.ahdMoveUp,
      child: AnimatedContainer(
        duration: KuberMotion.of(context, KuberMotion.fxFast),
        width: 32,
        height: 40,
        decoration: BoxDecoration(
          color: lifted ? cs.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.drag_indicator_rounded,
            color: lifted ? cs.onSecondaryContainer : cs.onSurfaceVariant,
            size: 22),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({super.key, required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final empty = count == 0;
    final label = empty ? l.ahdAddChartEmpty : l.ahdAddChartN(count);
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_chart_rounded, color: cs.onSurfaceVariant, size: 22),
        const SizedBox(width: 10),
        Text(label,
            style: localeFont(
                fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
        if (empty) ...[
          Text(' · ',
              style: localeFont(fontSize: 13, color: cs.onSurfaceVariant)),
          Flexible(
            child: Text(l.ahdAddChartHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: localeFont(fontSize: 13, color: cs.onSurfaceVariant)),
          ),
        ],
      ],
    );
    final h = 52.0;
    return Semantics(
      button: true,
      child: empty
          ? CustomPaint(
              painter: AhDashedBorder(cs.outline, 26),
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: onTap,
                child: SizedBox(height: h, child: content),
              ),
            )
          : AhPill(
              color: cs.surfaceContainer,
              radius: BorderRadius.circular(26),
              height: h,
              onTap: onTap,
              child: content,
            ),
    );
  }
}
