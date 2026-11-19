import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import 'chart_model.dart';

/// Where the tooltip goes, in chart-local coordinates (origin = the chart's
/// top-left, y down). Pure so it can be tested without a widget tree.
@immutable
class TooltipPlacement {
  const TooltipPlacement({
    required this.left,
    required this.top,
    required this.flipped,
    required this.pointerX,
  });

  final double left;
  final double top;

  /// Below the month labels with the pointer on top.
  final bool flipped;

  /// Pointer centre, from the tooltip's left edge.
  final double pointerX;
}

const double kTooltipGap = 12;
const double kTooltipFlipGap = 8;
const double kTooltipEdge = 8;
const double kTooltipPointerInset = 18;
const double kTooltipPointer = 12;

/// Handoff "Tooltip placement":
/// - bottom edge [kTooltipGap] above [columnTop] (highest point of the
///   selected column, or the line point);
/// - flipped below the month labels ([labelsBottom] + 8) when its top would
///   be above [viewportTop] (global y of the page's scroll viewport);
/// - centred on [cx], then clamped 8 dp from both screen edges; the pointer
///   stays on [cx] but 18 dp from the tooltip's corners.
/// [chartGlobal] is the chart's top-left in screen coordinates.
TooltipPlacement placeTooltip({
  required double cx,
  required double columnTop,
  required double labelsBottom,
  required Size tip,
  required Offset chartGlobal,
  required double screenWidth,
  required double viewportTop,
}) {
  final aboveTop = columnTop - kTooltipGap - tip.height;
  final flipped = chartGlobal.dy + aboveTop < viewportTop;
  final top = flipped ? labelsBottom + kTooltipFlipGap : aboveTop;
  final minLeft = kTooltipEdge - chartGlobal.dx;
  final maxLeft = screenWidth - kTooltipEdge - chartGlobal.dx - tip.width;
  var left = cx - tip.width / 2;
  left = maxLeft < minLeft ? minLeft : left.clamp(minLeft, maxLeft);
  final px = (cx - left).clamp(kTooltipPointerInset, tip.width - kTooltipPointerInset);
  return TooltipPlacement(left: left, top: top, flipped: flipped, pointerX: px.toDouble());
}

/// Tooltip card: inverseSurface, 16 dp corners, a 12 dp pointer rotated 45°.
class ChartTooltipCard extends StatelessWidget {
  const ChartTooltipCard({
    super.key,
    required this.period,
    required this.series,
    required this.width,
    required this.pointerX,
    required this.flipped,
    required this.formatAmount,
    this.showNet = true,
  });

  final ExpressivePeriod period;
  final List<ExpressiveSeries> series;
  final double width;
  final double pointerX;
  final bool flipped;
  final String Function(double) formatAmount;

  /// Saved / Overspent row (two series only).
  final bool showNet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l10n = context.l10n;
    final on = cs.onInverseSurface;
    final money = context.kuberMoney;
    final two = series.length == 2;
    final net = two ? period.values[0] - period.values[1] : 0.0;
    final netTone = net >= 0 ? money.inverseIncome : money.inverseExpense;

    Widget row(Color dot, String name, String value, {bool bold = false, Color? valueColor}) =>
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 20),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: KuberSpace.sm),
              Expanded(
                child: Text(name, style: tt.bodyMedium!.copyWith(color: on)),
              ),
              Text(
                value,
                maxLines: 1,
                style: (bold ? tt.titleSmall! : tt.bodyMedium!)
                    .copyWith(color: valueColor ?? on),
              ),
            ],
          ),
        );

    final title = period.isCurrent
        ? l10n.chartTipSoFar(period.fullLabel)
        : period.fullLabel;

    final body = <Widget>[
      Text(
        title,
        style: tt.labelMedium!.copyWith(color: on.withValues(alpha: 0.8)),
      ),
      const SizedBox(height: 6),
      if (period.noData)
        Text(l10n.chartTipNoData, style: tt.bodyMedium!.copyWith(color: on))
      else ...[
        for (var s = 0; s < series.length; s++)
          row(series[s].inverseColor, series[s].name,
              formatAmount(period.values[s])),
        if (two && showNet) ...[
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: KuberSpace.xs),
            color: on.withValues(alpha: 0.2),
          ),
          row(netTone, net >= 0 ? l10n.chartTipSaved : l10n.chartTipOverspent,
              formatAmount(net.abs()),
              bold: true, valueColor: netTone),
        ],
      ],
    ];

    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.inverseSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: body,
              ),
            ),
          ),
          Positioned(
            left: pointerX - kTooltipPointer / 2,
            top: flipped ? -5 : null,
            bottom: flipped ? null : -5,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: kTooltipPointer,
                height: kTooltipPointer,
                decoration: BoxDecoration(
                  color: cs.inverseSurface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
