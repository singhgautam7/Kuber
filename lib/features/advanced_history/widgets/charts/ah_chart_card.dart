import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_icon_button.dart';
import '../../../../shared/widgets/kuber_menu.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../../query/query_labels.dart';
import '../../services/ah_results.dart';
import '../common/ah_common.dart';
import 'package:kuber/core/motion/motion.dart';
import '../dashboard/ah_group_detail_sheet.dart';
import 'ah_chart_view.dart';

/// Tells a chart card it is being dragged (scale / background are drawn by
/// the list's proxy decorator).
class AhLiftScope extends InheritedWidget {
  const AhLiftScope({super.key, required this.lifted, required super.child});
  final bool lifted;

  static bool of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<AhLiftScope>()?.lifted ?? false;

  @override
  bool updateShouldNotify(AhLiftScope o) => o.lifted != lifted;
}

/// One chart card: header (handle, title, sub, menu) and the chart or its
/// in-card state. Grows in (height + fade, expressive spring, [delay] after
/// mount) and collapses out (fade 90 ms, then height, standard spring).
class AhChartCard extends ConsumerStatefulWidget {
  const AhChartCard({
    super.key,
    required this.index,
    required this.count,
    required this.spec,
    required this.handle,
    required this.onEdit,
    required this.onMove,
    required this.onRemove,
    required this.onQuickSplitMonth,
    this.delay = Duration.zero,
  });
  final int index;
  final int count;
  final AhChartSpec spec;

  /// The drag-handle widget (wrapped in a drag listener by the list).
  final Widget Function(bool lifted) handle;
  final VoidCallback onEdit;
  final void Function(int delta) onMove;
  final VoidCallback onRemove;
  final VoidCallback onQuickSplitMonth;
  final Duration delay;

  @override
  ConsumerState<AhChartCard> createState() => _AhChartCardState();
}

class _AhChartCardState extends ConsumerState<AhChartCard>
    with TickerProviderStateMixin {
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: KuberMotion.defaultCurve.settle,
    reverseDuration: KuberMotion.standardCurve.settle,
  );
  late final AnimationController _fade = AnimationController(
      vsync: this, duration: KuberMotion.fxInstant, value: 1);
  Timer? _t;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final level = KuberMotion.levelOf(context);
    if (level == MotionLevel.subtle) {
      _grow.duration = KuberMotion.subtleCurve.settle;
      _grow.reverseDuration = KuberMotion.subtleCurve.settle;
    } else if (level == MotionLevel.off) {
      _grow.duration = KuberMotion.fxInstant;
      _grow.reverseDuration = KuberMotion.fxInstant;
    }
    if (widget.delay == Duration.zero) {
      _grow.forward();
    } else {
      _t = Timer(widget.delay, () {
        if (mounted) _grow.forward();
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _grow.dispose();
    _fade.dispose();
    super.dispose();
  }

  Future<void> _exit() async {
    await _fade.reverse();
    if (!mounted) return;
    await _grow.reverse();
    if (mounted) widget.onRemove();
  }

  String _splitHint(AppLocalizations l) => switch (widget.spec.split) {
        AhChartSplit.tag => l.ahdStNoTags,
        AhChartSplit.account => l.ahdStNoAccounts,
        AhChartSplit.category => l.ahdStNoCategories,
        _ => l.ahdStNothing,
      };

  Future<void> _menu(BuildContext anchor) async {
    final l = context.l10n;
    final pick = await showKuberMenu<String>(
      context: anchor,
      entries: [
        KuberMenuEntry(
            value: 'edit', label: l.editLabel, icon: Icons.edit_outlined),
        if (widget.index > 0)
          KuberMenuEntry(
              value: 'up',
              label: l.ahdMoveUp,
              icon: Icons.arrow_upward_rounded),
        if (widget.index < widget.count - 1)
          KuberMenuEntry(
              value: 'down',
              label: l.ahdMoveDown,
              icon: Icons.arrow_downward_rounded),
        KuberMenuEntry(
            value: 'remove',
            label: l.ahdRemove,
            icon: Icons.delete_outline_rounded,
            destructive: true),
      ],
    );
    switch (pick) {
      case 'edit':
        widget.onEdit();
      case 'up':
        widget.onMove(-1);
      case 'down':
        widget.onMove(1);
      case 'remove':
        _exit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final lifted = AhLiftScope.of(context);
    final spec = widget.spec;
    final data = ref.watch(ahChartDataProvider(spec));
    final fmt = ref.watch(formatterProvider);
    final d = data.valueOrNull;

    final heat = spec.type == AhChartType.heatmap;
    // The heatmap's points are days; everything else is split as set.
    final pointGroup = heat ? AhGroupBy.day : ahGroupOfSplit(spec.split);
    final title = l.ahdCardTitle(
        ahMeasureLabel(l, spec.measure),
        (heat ? l.ahdDay : ahSplitLabel(l, spec.split)).toLowerCase());
    final typeLabel = ahSpecTypeLabel(l, spec);
    final sub = (d != null && d.state == AhChartState.ok)
        ? l.ahdCardSub(typeLabel, l.ahdTxnN(d.count))
        : typeLabel;

    String money(double v) => spec.measure == AhChartMeasure.count
        ? fmt.formatNumber(v)
        : fmt.formatCompactCurrency(v);

    Widget body;
    if (d == null) {
      body = data.hasError
          ? _StateBlock(
              icon: Icons.error_outline_rounded,
              text: l.ahdErrorTitle,
              actions: [
                  (l.ahdTryAgain, () => ref.invalidate(ahChartDataProvider(spec)))
                ])
          : const AhDelayed(child: _ChartSkeleton());
    } else {
      body = switch (d.state) {
        AhChartState.loading => const AhDelayed(child: _ChartSkeleton()),
        AhChartState.ok => AhChartView(
            type: spec.type,
            seriesName: ahMeasureLabel(l, spec.measure),
            points: [
              for (final p in d.points)
                AhChartPoint(p.key, ahGroupLabel(pointGroup, p.key, p.label, l),
                    p.value,
                    colorValue: p.colorValue),
            ],
            series: [
              for (final x in d.series)
                AhChartSeries(
                    x.key,
                    ahGroupLabel(
                        ahGroupOfSplit(spec.seriesBy!), x.key, x.label, l),
                    x.values,
                    colorValue: x.colorValue),
            ],
            dayLabel: (k) => ahGroupLabel(AhGroupBy.day, k, k, l),
            fmt: money,
            fullFmt: spec.measure == AhChartMeasure.count
                ? fmt.formatNumber
                : fmt.formatCurrency,
            axisFmt: spec.measure == AhChartMeasure.count
                ? fmt.formatNumber
                : (v) => fmt.formatCompactCurrency(v, symbol: '').trim(),
            onView: (p) {
              showAhGroupDetail(context,
                  groupKey: AhGroupKey(pointGroup, p.key),
                  title: p.label);
            },
          ),
        AhChartState.notEnoughData =>
          _StateBlock(icon: Icons.show_chart_rounded, text: l.ahdStLine),
        AhChartState.nothingToSplit =>
          _StateBlock(icon: Icons.layers_clear_outlined, text: _splitHint(l)),
        AhChartState.wrongCombo => _StateBlock(
            icon: Icons.tune_rounded,
            text: l.ahdStWrongCombo,
            actions: [
              if (spec.type == AhChartType.line)
                (l.ahdSplitByMonth, widget.onQuickSplitMonth),
              (l.ahdChangeChart, widget.onEdit),
            ]),
        AhChartState.noResults => _StateBlock(
            icon: Icons.search_off_rounded, text: l.ahdStNoResults),
      };
    }

    final card = AnimatedContainer(
      duration: KuberMotion.of(context, KuberMotion.fxFast),
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: lifted ? cs.surfaceContainerHigh : cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              widget.handle(lifted),
              const SizedBox(width: KuberSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: cs.onSurface)),
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Builder(
                builder: (anchor) => AppIconButton(
                  icon: Icons.more_vert_rounded,
                  semanticLabel: title,
                  kind: AppIconButtonKind.plain,
                  onPressed: () => _menu(anchor),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.md),
          // Edit, and skeleton to chart: cross-fade fx.default.
          AnimatedSwitcher(
            duration: KuberMotion.of(context, KuberMotion.fxDefault),
            switchInCurve: KuberMotion.curveEffects,
            switchOutCurve: KuberMotion.curveEffects,
            child: KeyedSubtree(
                key: ValueKey((spec, d?.state)), child: body),
          ),
        ],
      ),
    );

    return RepaintBoundary(
      child: SizeTransition(
        alignment: Alignment.topCenter,
        sizeFactor: CurvedAnimation(
          parent: _grow,
          curve: KuberMotion.spatialCurve(
                  KuberMotion.levelOf(context), KuberMotion.defaultCurve)
              .clamped,
          reverseCurve: KuberMotion.spatialCurve(
                  KuberMotion.levelOf(context), KuberMotion.standardCurve)
              .clamped,
        ),
        child: FadeTransition(
          opacity: _fade.drive(CurveTween(curve: Curves.linear)),
          child: FadeTransition(
            opacity: _grow,
            child: Padding(
              padding: const EdgeInsets.only(bottom: KuberSpace.md),
              child: card,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) => const Row(
        children: [
          KuberSkeleton(width: 120, height: 120, borderRadius: 60),
          SizedBox(width: KuberSpace.lg),
          Expanded(
            child: Column(
              children: [
                KuberSkeleton(height: 14),
                SizedBox(height: 10),
                KuberSkeleton(height: 14),
                SizedBox(height: 10),
                KuberSkeleton(height: 14),
                SizedBox(height: 10),
                KuberSkeleton(height: 14),
                SizedBox(height: 10),
                KuberSkeleton(height: 14),
              ],
            ),
          ),
        ],
      );
}

/// In-card state (never a dialog): a 44 dp tile, one line, optional quick
/// fix buttons. Min height 136.
class _StateBlock extends StatelessWidget {
  const _StateBlock({required this.icon, required this.text, this.actions});
  final IconData icon;
  final String text;
  final List<(String, VoidCallback)>? actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 136),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh, shape: BoxShape.circle),
              child: Icon(icon, color: cs.onSurfaceVariant, size: 22),
            ),
            const SizedBox(height: KuberSpace.sm),
            Text(text,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: cs.onSurfaceVariant)),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: KuberSpace.sm),
              Wrap(
                spacing: KuberSpace.sm,
                alignment: WrapAlignment.center,
                children: [
                  for (final a in actions!)
                    AppButton(
                      label: a.$1,
                      type: AppButtonType.normal,
                      height: 40,
                      onPressed: a.$2,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
