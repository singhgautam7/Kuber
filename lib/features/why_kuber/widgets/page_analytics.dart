import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../data/why_kuber_demo_data.dart';
import 'why_kuber_page.dart';
import 'why_kuber_stage.dart';

/// Page 4 · Your spending, at a glance (storyboards.md, 3900 ms): History
/// scrolls, search narrows to food, the list becomes the analytics card
/// (By category, Monthly, Compare), which splits into three minis.
class AnalyticsPage extends ConsumerWidget {
  final PageArgs a;
  const AnalyticsPage(this.a, {super.key});

  static const _total = 3900;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final demo = WhyKuberDemo.of(context, ref);
    final expense = context.kuberMoney.expense;
    final food = DemoCat.of(context, DemoCat.food);
    final groc = DemoCat.of(context, DemoCat.groceries);
    final fun = DemoCat.of(context, DemoCat.fun);
    final transport = DemoCat.of(context, DemoCat.transport);

    // History list: (header?, label, icon, colour, amount, isFood).
    final items = <_Item>[
      _Item.header(l.homeV33P4Today, keep: true),
      _Item(l.homeV33DMovie, Icons.movie_rounded, fun, 600, food: false),
      _Item(l.homeV33DCoffee, Icons.local_cafe_rounded, food, 120, food: true),
      _Item.header(l.homeV33P4Yesterday, keep: true),
      _Item(l.homeV33DFood, Icons.restaurant_rounded, food, 250, food: true),
      _Item(
        l.homeV33DAuto,
        Icons.local_taxi_rounded,
        transport,
        90,
        food: false,
      ),
      _Item.header(demo.day(10, 11), keep: false),
      _Item(
        l.homeV33DGroc,
        Icons.shopping_basket_rounded,
        groc,
        1180,
        food: false,
      ),
    ];
    final origY = <double>[];
    var y = 0.0;
    for (final it in items) {
      origY.add(y);
      y += it.isHeader ? 24 : 40;
    }
    final compactY = <double>[];
    y = 0;
    for (final it in items) {
      compactY.add(y);
      if (it.kept) y += it.isHeader ? 24 : 40;
    }
    final query = l.homeV33P4Query;
    final tabs = [l.homeV33P4ByCat, l.homeV33P4Monthly, l.homeV33P4Compare];
    final donut = [
      (5600.0, food),
      (3400.0, groc),
      (2300.0, fun),
      (1900.0, transport),
      (1800.0, cs.outline),
    ];
    final legend = [
      l.homeV33CFood,
      l.homeV33DGroc,
      l.homeV33CFun,
      l.homeV33CTransport,
    ];
    final months = [13200.0, 16100.0, 14400.0, 15000.0];
    final monthNames = [
      for (final m in [7, 8, 9, 10]) demo.month(m),
    ];
    final pairs = [(4800.0, 5600.0), (3600.0, 3400.0), (2100.0, 1900.0)];
    final total = demo.money(15000);

    Widget search(int chars, {bool clear = false}) => Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberShape.full),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: KuberSpace.sm),
          Expanded(
            child: Text(
              chars == 0
                  ? l.homeV33P4Search
                  : query.substring(0, math.min(chars, query.length)),
              style: tt.bodyMedium!.copyWith(
                color: chars == 0 ? cs.onSurfaceVariant : cs.onSurface,
              ),
            ),
          ),
          Icon(
            clear ? Icons.close_rounded : Icons.tune_rounded,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
        ],
      ),
    );

    Widget itemView(_Item it) => it.isHeader
        ? SizedBox(
            height: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                it.label.toUpperCase(),
                style: tt.labelSmall!.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          )
        : SizedBox(
            height: 40,
            child: Row(
              children: [
                DemoTile(it.icon!, it.color!, size: 28),
                const SizedBox(width: KuberSpace.md),
                Expanded(
                  child: Text(
                    it.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium!.copyWith(color: cs.onSurface),
                  ),
                ),
                Text(
                  '-${demo.money(it.amount)}',
                  style: tt.bodyMedium!.copyWith(color: expense),
                ),
              ],
            ),
          );

    Widget charts(double t, {required int only, double scale = 1}) {
      // only: -1 = the animated card, 0..2 = one static mini.
      final mini = only >= 0;
      final donutO = mini ? (only == 0 ? 1.0 : 0.0) : 1 - seg(t, 2700, 2930);
      final barsO = mini
          ? (only == 1 ? 1.0 : 0.0)
          : seg(t, 2700, 2930) * (1 - seg(t, 3200, 3430));
      final pairsO = mini ? (only == 2 ? 1.0 : 0.0) : seg(t, 3200, 3430);
      return Stack(
        children: [
          if (donutO > 0)
            Opacity(
              opacity: donutO,
              child: Row(
                children: [
                  SizedBox(
                    width: mini ? 80 : 128,
                    height: mini ? 80 : 128,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size.square(mini ? 80 : 128),
                          painter: _Donut(
                            donut,
                            mini ? 1 : seg(t, 2140, 2380),
                            mini ? 10 : 16,
                          ),
                        ),
                        if (!mini)
                          Opacity(
                            opacity: seg(t, 2300, 2380),
                            child: Text(
                              total,
                              style: tt.labelLarge!.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!mini) ...[
                    const SizedBox(width: KuberSpace.lg),
                    Expanded(
                      child: Opacity(
                        opacity: seg(t, 2380, 2530),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < legend.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: donut[i].$2,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: KuberSpace.sm),
                                    Expanded(
                                      child: Text(
                                        legend[i],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: tt.bodySmall!.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (barsO > 0)
            Opacity(
              opacity: barsO,
              child: CustomPaint(
                size: Size(mini ? 85 : 288, mini ? 80 : 128),
                painter: _Bars(
                  months,
                  [
                    for (var i = 0; i < 4; i++)
                      mini ? 1.0 : seg(t, 2780 + 40.0 * i, 3020 + 40.0 * i),
                  ],
                  cs.primaryContainer,
                  cs.primary,
                  mini ? null : monthNames,
                  tt.labelSmall!.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ),
          if (pairsO > 0)
            Opacity(
              opacity: pairsO,
              child: CustomPaint(
                size: Size(mini ? 85 : 288, mini ? 80 : 128),
                painter: _Pairs(
                  pairs,
                  mini ? 1 : seg(t, 3280, 3400),
                  mini ? 1 : seg(t, 3400, 3520),
                  cs.primaryContainer,
                  cs.primary,
                ),
              ),
            ),
        ],
      );
    }

    Widget frame(double t) {
      final appear = seg(t, 0, 260);
      final chars = (4 * seg(t, 1000, 1300, Curves.linear)).round();
      final fadeOut = seg(t, 1300, 1450);
      final close = seg(t, 1450, 1680);
      final scroll =
          (36 * seg(t, 300, 560) + 36 * seg(t, 640, 900)) * (1 - close);
      final toCard = seg(t, 1900, 2140);
      final split = seg(t, 3600, 3830);
      final back = seg(t, 3660, 3810);
      final tab = seg(t, 2700, 2930) + seg(t, 3200, 3430);
      final cardRect = Rect.lerp(
        const Rect.fromLTWH(0, 48, 320, 212),
        const Rect.fromLTWH(0, 0, 320, 260),
        toCard,
      )!;
      return SizedBox(
        width: 320,
        height: 260,
        child: Stack(
          children: [
            // Phase A: search + History list.
            if (toCard < 1)
              Positioned.fill(
                child: Opacity(
                  opacity: appear * (1 - toCard),
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - appear)),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          width: 320,
                          child: search(chars, clear: chars > 0),
                        ),
                        Positioned(
                          left: 0,
                          top: 48,
                          width: 320,
                          height: 212,
                          child: ClipRect(
                            child: Stack(
                              children: [
                                for (var i = 0; i < items.length; i++)
                                  if (items[i].kept || fadeOut < 1)
                                    Positioned(
                                      left: 0,
                                      width: 320,
                                      top:
                                          (items[i].kept
                                              ? origY[i] +
                                                    (compactY[i] - origY[i]) *
                                                        close
                                              : origY[i]) -
                                          scroll,
                                      child: Opacity(
                                        opacity: items[i].kept
                                            ? 1
                                            : 1 - fadeOut,
                                        child: itemView(items[i]),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Phase B: the analytics card.
            if (toCard > 0 && split < 1)
              Positioned.fromRect(
                rect: cardRect,
                child: Opacity(
                  opacity: toCard * (1 - split),
                  child: Container(
                    padding: const EdgeInsets.all(KuberSpace.md),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: KuberShape.largeR,
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: 236,
                      minHeight: 236,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 32,
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final w = c.maxWidth / 3;
                                return Stack(
                                  children: [
                                    Positioned(
                                      left: w * tab,
                                      width: w,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: cs.secondaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            KuberShape.full,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        for (var i = 0; i < 3; i++)
                                          SizedBox(
                                            width: w,
                                            child: Center(
                                              child: Text(
                                                tabs[i],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: tt.labelMedium!.copyWith(
                                                  color: (tab - i).abs() < 0.5
                                                      ? cs.onSecondaryContainer
                                                      : cs.onSurfaceVariant,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: KuberSpace.xl),
                          SizedBox(height: 140, child: charts(t, only: -1)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Rest: filtered history over three minis.
            if (split > 0)
              for (var i = 0; i < 3; i++)
                Positioned(
                  left: 109.5 * i,
                  top: 134,
                  width: 101,
                  height: 120,
                  child: Opacity(
                    opacity: split,
                    child: Transform.scale(
                      scale: 0.9 + 0.1 * split,
                      child: Container(
                        padding: const EdgeInsets.all(KuberSpace.sm),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: KuberShape.mediumR,
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tabs[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.labelSmall!.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: KuberSpace.xs),
                            Expanded(
                              child: Center(child: charts(t, only: i)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            if (back > 0)
              Positioned(
                left: 0,
                top: 0,
                width: 320,
                height: 128,
                child: Opacity(
                  opacity: back,
                  child: Column(
                    children: [
                      search(4, clear: true),
                      const SizedBox(height: KuberSpace.sm),
                      itemView(items[2]),
                      itemView(items[4]),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return PageLayout(
      stage: WhyKuberStage(
        durationMs: _total,
        active: a.active,
        played: a.played,
        onPlayed: a.onPlayed,
        semanticsLabel: l.homeV33P4A11y,
        builder: (context, t, reduced) =>
            frame(reduced ? _total.toDouble() : t),
      ),
      title: l.homeV33P4Title,
      sub: pageSub(context, l.homeV33P4Sub),
      tryLabel: l.homeV33P4Try,
      onTry: a.onTry,
    );
  }
}

class _Item {
  final String label;
  final IconData? icon;
  final Color? color;
  final double amount;
  final bool isHeader;

  /// Still listed after the search narrows to food.
  final bool kept;

  _Item(this.label, this.icon, this.color, this.amount, {required bool food})
    : isHeader = false,
      kept = food;
  _Item.header(this.label, {required bool keep})
    : icon = null,
      color = null,
      amount = 0,
      isHeader = true,
      kept = keep;
}

/// Category donut; arcs sweep clockwise in order as [progress] goes 0 → 1.
class _Donut extends CustomPainter {
  final List<(double, Color)> parts;
  final double progress;
  final double stroke;
  const _Donut(this.parts, this.progress, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final sum = parts.fold<double>(0, (s, p) => s + p.$1);
    final rect = (Offset.zero & size).deflate(stroke / 2);
    var start = -math.pi / 2;
    var left = progress * math.pi * 2;
    for (final (v, c) in parts) {
      final sweep = v / sum * math.pi * 2;
      final draw = math.min(sweep, left);
      if (draw <= 0) break;
      canvas.drawArc(
        rect,
        start,
        math.max(0, draw - 0.03),
        false,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
      left -= sweep;
    }
  }

  @override
  bool shouldRepaint(_Donut o) => o.progress != progress || o.parts != parts;
}

/// Monthly bars growing from 0; the last month in [last].
class _Bars extends CustomPainter {
  final List<double> values;
  final List<double> grow;
  final Color base;
  final Color last;
  final List<String>? labels;
  final TextStyle labelStyle;
  const _Bars(
    this.values,
    this.grow,
    this.base,
    this.last,
    this.labels,
    this.labelStyle,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = values.reduce(math.max);
    final labelH = labels == null ? 0.0 : 16.0;
    final h = size.height - labelH;
    final slot = size.width / values.length;
    final w = slot * 0.5;
    for (var i = 0; i < values.length; i++) {
      final bh = h * values[i] / maxV * grow[i];
      final x = slot * i + (slot - w) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, h - bh, w, bh),
          const Radius.circular(4),
        ),
        Paint()..color = i == values.length - 1 ? last : base,
      );
      if (labels != null) {
        final tp = TextPainter(
          text: TextSpan(text: labels![i], style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(slot * i + (slot - tp.width) / 2, h + 2));
      }
    }
  }

  @override
  bool shouldRepaint(_Bars o) =>
      o.grow != grow || o.base != base || o.last != last;
}

/// Month-to-month pairs (Sep, Oct) growing from the left.
class _Pairs extends CustomPainter {
  final List<(double, double)> pairs;
  final double sep;
  final double oct;
  final Color sepColor;
  final Color octColor;
  const _Pairs(this.pairs, this.sep, this.oct, this.sepColor, this.octColor);

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = pairs.fold<double>(
      0,
      (m, p) => math.max(m, math.max(p.$1, p.$2)),
    );
    final rowH = size.height / pairs.length;
    final barH = rowH * 0.28;
    for (var i = 0; i < pairs.length; i++) {
      final top = rowH * i + rowH * 0.18;
      void bar(double y, double v, double g, Color c) => canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, y, size.width * v / maxV * g, barH),
          const Radius.circular(3),
        ),
        Paint()..color = c,
      );
      bar(top, pairs[i].$1, sep, sepColor);
      bar(top + barH + 3, pairs[i].$2, oct, octColor);
    }
  }

  @override
  bool shouldRepaint(_Pairs o) =>
      o.sep != sep || o.oct != oct || o.sepColor != sepColor;
}
