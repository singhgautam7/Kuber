import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/info_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../categories/data/category.dart';
import '../../models/ah_view.dart';
import '../../query/query_ast.dart';
import 'ah_motion.dart';

// Labels, icons and small widgets shared by the Advanced History dashboard.

String ahGroupName(AppLocalizations l, AhGroupBy g) => switch (g) {
      AhGroupBy.none => l.ahdNone,
      AhGroupBy.category => l.ahdCategory,
      AhGroupBy.account => l.ahdAccount,
      AhGroupBy.tag => l.ahdTag,
      AhGroupBy.type => l.ahdType,
      AhGroupBy.source => l.ahdSource,
      AhGroupBy.month => l.ahdMonth,
      AhGroupBy.year => l.ahdYear,
      AhGroupBy.day => l.ahdDay,
    };

String ahSplitLabel(AppLocalizations l, AhChartSplit s) => switch (s) {
      AhChartSplit.category => l.ahdCategory,
      AhChartSplit.account => l.ahdAccount,
      AhChartSplit.tag => l.ahdTag,
      AhChartSplit.type => l.ahdType,
      AhChartSplit.source => l.ahdSource,
      AhChartSplit.month => l.ahdMonth,
      AhChartSplit.year => l.ahdYear,
    };

String ahMeasureLabel(AppLocalizations l, AhChartMeasure m) => switch (m) {
      AhChartMeasure.total => l.ahdTotal,
      AhChartMeasure.count => l.ahdCount,
      AhChartMeasure.average => l.ahdAverage,
    };

String ahChartTypeLabel(AppLocalizations l, AhChartType t) => switch (t) {
      AhChartType.donut => l.ahdDonut,
      AhChartType.bars => l.ahdBars,
      AhChartType.line => l.ahdLine,
      AhChartType.heatmap => l.ahdChartHeatmap,
    };

/// The card's type label: "Stacked bars" / "Lines" when comparing values.
String ahSpecTypeLabel(AppLocalizations l, AhChartSpec s) => !s.isSeries
    ? ahChartTypeLabel(l, s.type)
    : s.type == AhChartType.bars
        ? l.ahdChartStacked
        : l.ahdChartLines;

String ahSortFieldLabel(AppLocalizations l, AhSortField f) => switch (f) {
      AhSortField.date => l.ahdDate,
      AhSortField.amount => l.ahdAmount,
      AhSortField.category => l.ahdCategory,
      AhSortField.account => l.ahdAccount,
      AhSortField.total => l.ahdTotal,
      AhSortField.count => l.ahdCount,
      AhSortField.name => l.ahdName,
    };

String ahKpiLabel(AppLocalizations l, AhKpi k) => switch (k) {
      AhKpi.transactions => l.ahdKpiTransactions,
      AhKpi.income => l.ahdKpiIncome,
      AhKpi.expense => l.ahdKpiExpense,
      AhKpi.net => l.ahdKpiNet,
      AhKpi.average => l.ahdKpiAverage,
      AhKpi.attachments => l.ahdKpiAttachments,
      AhKpi.largest => l.ahdKpiLargest,
    };

IconData ahGroupIcon(AhGroupBy g) => switch (g) {
      AhGroupBy.none => Icons.view_agenda_outlined,
      AhGroupBy.category => Icons.category_rounded,
      AhGroupBy.account => Icons.account_balance_wallet_rounded,
      AhGroupBy.tag => Icons.sell_rounded,
      AhGroupBy.type => Icons.swap_vert_rounded,
      AhGroupBy.source => Icons.input_rounded,
      AhGroupBy.month => Icons.calendar_month_rounded,
      AhGroupBy.year => Icons.event_rounded,
      AhGroupBy.day => Icons.today_rounded,
    };

IconData ahChartIcon(AhChartType t) => switch (t) {
      AhChartType.donut => Icons.donut_large_rounded,
      AhChartType.bars => Icons.bar_chart_rounded,
      AhChartType.line => Icons.show_chart_rounded,
      AhChartType.heatmap => Icons.calendar_view_month_rounded,
    };

bool ahIsTimeSplit(AhChartSplit s) =>
    s == AhChartSplit.month || s == AhChartSplit.year;

/// Line charts split by month or year only; donut and bars by the rest,
/// except stacked bars ([compare]), which run over months or years too.
/// The heatmap has no split (one square per day).
bool ahSplitAllowed(AhChartType t, AhChartSplit s, {bool compare = false}) {
  final time = ahIsTimeSplit(s);
  return switch (t) {
    AhChartType.line => time,
    AhChartType.bars => compare ? time : !time,
    AhChartType.donut => !time,
    AhChartType.heatmap => false,
  };
}

AhChartSplit? ahSplitOfGroup(AhGroupBy g) => switch (g) {
      AhGroupBy.none => null,
      AhGroupBy.category => AhChartSplit.category,
      AhGroupBy.account => AhChartSplit.account,
      AhGroupBy.tag => AhChartSplit.tag,
      AhGroupBy.type => AhChartSplit.type,
      AhGroupBy.source => AhChartSplit.source,
      AhGroupBy.month => AhChartSplit.month,
      AhGroupBy.year => AhChartSplit.year,
      AhGroupBy.day => AhChartSplit.month,
    };

AhGroupBy ahGroupOfSplit(AhChartSplit s) => switch (s) {
      AhChartSplit.category => AhGroupBy.category,
      AhChartSplit.account => AhGroupBy.account,
      AhChartSplit.tag => AhGroupBy.tag,
      AhChartSplit.type => AhGroupBy.type,
      AhChartSplit.source => AhGroupBy.source,
      AhChartSplit.month => AhGroupBy.month,
      AhChartSplit.year => AhGroupBy.year,
    };

/// The split a chart of [type] starts with: the current group when allowed,
/// else Category (Month for a line).
AhChartSplit ahDefaultSplit(AhChartType type, AhGroupBy group) {
  final g = ahSplitOfGroup(group);
  if (g != null && ahSplitAllowed(type, g)) return g;
  return type == AhChartType.line ? AhChartSplit.month : AhChartSplit.category;
}

/// Number of filters in a tree (one per condition, like the Filter badge).
int ahFilterCount(QueryNode? n) => switch (n) {
      null => 0,
      ConditionNode() => 1,
      NotNode(:final child) => ahFilterCount(child),
      AndNode(:final children) =>
        children.fold(0, (s, c) => s + ahFilterCount(c)),
      OrNode(:final children) =>
        children.fold(0, (s, c) => s + ahFilterCount(c)),
    };

/// Sort fields valid for a grouping.
bool ahSortValidFor(AhSortField f, AhGroupBy g) => g == AhGroupBy.none
    ? const {
        AhSortField.date,
        AhSortField.amount,
        AhSortField.category,
        AhSortField.account,
      }.contains(f)
    : const {AhSortField.total, AhSortField.count, AhSortField.name}
        .contains(f);

/// "3 filters · grouped by Category · 2 charts" (parts left out when not
/// set; "sorted by {field}" when the sort is not the default).
String ahSummaryLine(
  AppLocalizations l, {
  required int filters,
  required AhGroupBy group,
  required AhSort sort,
  required int charts,
}) {
  final parts = [
    if (filters > 0) l.ahdSumFilters(filters),
    if (group != AhGroupBy.none) l.ahdSumGrouped(ahGroupName(l, group)),
    if (!sort.isDefaultFor(group))
      l.ahdSumSorted(ahSortFieldLabel(l, sort.field).toLowerCase()),
    if (charts > 0) l.ahdSumCharts(charts),
  ];
  return parts.isEmpty ? l.ahdSumEmpty : parts.join(' · ');
}

/// Tabular figures for every number on the page.
const kAhTabular = [FontFeature.tabularFigures()];

/// An "i" button that opens a [KuberInfoBottomSheet].
class AhInfoButton extends StatelessWidget {
  const AhInfoButton(this.config, {super.key});
  final KuberInfoConfig config;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(Icons.info_outline_rounded, color: cs.onSurfaceVariant),
      iconSize: 20,
      tooltip: context.l10n.ahdHelpTitle,
      visualDensity: VisualDensity.compact,
      onPressed: () => KuberInfoBottomSheet.show(context, config),
    );
  }
}

/// Description line at the top of a sheet body with an "i" at the end.
class AhSheetIntro extends StatelessWidget {
  const AhSheetIntro({super.key, this.text, this.info});
  final String? text;
  final KuberInfoConfig? info;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sm),
      child: Row(
        children: [
          Expanded(
            child: text == null
                ? const SizedBox.shrink()
                : Text(text!,
                    style: localeFont(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                        height: 1.4)),
          ),
          if (info != null) AhInfoButton(info!),
        ],
      ),
    );
  }
}

/// The info config for "Group by" / "Sort" / chart builder / saved views /
/// KPI cards: paragraphs separated by a blank line.
KuberInfoConfig ahInfoConfig(String title, List<String> paragraphs) =>
    KuberInfoConfig(title: title, description: paragraphs.join('\n\n'));

/// A digit-roll text (old digit up and out, new up and in, 300 ms
/// easeOutCubic, tabular). Position is counted from the end so a new leading
/// digit appears without rolling the others. Reduced motion: plain text.
class AhRollingText extends StatelessWidget {
  const AhRollingText(this.text, {super.key, required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final s = style.copyWith(fontFeatures: kAhTabular);
    if (AhMotion.reduced(context)) {
      return Text(text, style: s, maxLines: 1);
    }
    final chars = text.runes.map(String.fromCharCode).toList();
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < chars.length; i++)
            _RollChar(
                key: ValueKey('r${chars.length - i}'),
                char: chars[i],
                style: s),
        ],
      ),
    );
  }
}

class _RollChar extends StatelessWidget {
  const _RollChar({super.key, required this.char, required this.style});
  final String char;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: AhMotion.digitRoll,
        switchInCurve: AhMotion.decelerate,
        switchOutCurve: AhMotion.decelerate,
        transitionBuilder: (child, anim) {
          final incoming = child.key == ValueKey(char);
          final slide = Tween<Offset>(
            begin: incoming ? const Offset(0, 0.7) : const Offset(0, -0.7),
            end: Offset.zero,
          ).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: Text(char, key: ValueKey(char), style: style, maxLines: 1),
      ),
    );
  }
}

/// Shows nothing until [delay] has passed (skeletons only appear after
/// 150 ms), then fades in.
class AhDelayed extends StatefulWidget {
  const AhDelayed({super.key, required this.child, this.delay = AhMotion.fast});
  final Widget child;
  final Duration delay;

  @override
  State<AhDelayed> createState() => _AhDelayedState();
}

class _AhDelayedState extends State<AhDelayed> {
  bool _show = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(widget.delay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: _show ? 1 : 0,
        duration: AhMotion.dur(context, AhMotion.fast),
        child: _show ? widget.child : const SizedBox.shrink(),
      );
}

/// Fades (and rises 8 dp) its child in once, after [delay]. Reduced motion:
/// a 90 ms fade only. [sliver] wraps the child in a sliver fade.
class AhFadeIn extends StatefulWidget {
  const AhFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AhMotion.fast,
    this.shift = 8,
  });
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double shift;

  @override
  State<AhFadeIn> createState() => _AhFadeInState();
}

class _AhFadeInState extends State<AhFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduced = AhMotion.reduced(context);
    final total = reduced
        ? AhMotion.instant
        : widget.delay + widget.duration;
    _c.duration = total;
    if (total.inMilliseconds == 0) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AhMotion.reduced(context);
    final total = reduced ? AhMotion.instant : widget.delay + widget.duration;
    final start = reduced || total.inMilliseconds == 0
        ? 0.0
        : widget.delay.inMilliseconds / total.inMilliseconds;
    final curve = CurvedAnimation(
        parent: _c, curve: Interval(start, 1, curve: AhMotion.decelerate));
    return AnimatedBuilder(
      animation: curve,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, reduced ? 0 : (1 - curve.value) * widget.shift),
          child: child,
        ),
      ),
    );
  }
}

/// A pressable filled shape (the action row buttons): colour animates 150 ms.
class AhPill extends StatelessWidget {
  const AhPill({
    super.key,
    required this.color,
    required this.radius,
    required this.child,
    this.onTap,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.semanticLabel,
    this.border,
  });
  final Color color;
  final BorderRadius radius;
  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: AnimatedContainer(
        duration: AhMotion.dur(context, AhMotion.fast),
        curve: AhMotion.decelerate,
        height: height,
        decoration:
            BoxDecoration(color: color, borderRadius: radius, border: border),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  },
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Dashed rounded outline (the KPI Edit tile, the empty "Add a chart" row).
class AhDashedBorder extends CustomPainter {
  AhDashedBorder(this.color, this.radius);
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final m in p.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(AhDashedBorder old) =>
      old.color != color || old.radius != radius;
}

/// "Newest first", "Highest first", "A to Z" (and the reverse) for [s].
String ahOrderLabel(AppLocalizations l, AhSort s) {
  switch (s.field) {
    case AhSortField.date:
      return s.descending ? l.ahdNewest : l.ahdOldest;
    case AhSortField.category:
    case AhSortField.account:
    case AhSortField.name:
      return s.descending ? l.ahdZtoA : l.ahdAtoZ;
    case AhSortField.amount:
    case AhSortField.total:
    case AhSortField.count:
      return s.descending ? l.ahdHighest : l.ahdLowest;
  }
}

/// Two of the user's expense categories for the example chips ("Fuel over
/// ₹500 this year"), picked at random once per app run so the chips don't
/// change while the user looks at them. Empty when there are none.
List<String> ahExampleCategories(List<Category> all) {
  final pool = [
    for (final c in all)
      if (c.effectiveType != 'income') c.name,
  ]..sort();
  if (pool.isEmpty) return const [];
  final r = math.Random(_exampleSeed);
  final a = pool[r.nextInt(pool.length)];
  final rest = [...pool]..remove(a);
  return [a, if (rest.isNotEmpty) rest[r.nextInt(rest.length)]];
}

final _exampleSeed = DateTime.now().microsecondsSinceEpoch;
