import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/why_kuber_demo_data.dart';
import 'why_kuber_page.dart';
import 'why_kuber_stage.dart';

/// Page 1 · Kuber-ifying your notes (storyboards.md, 3000 ms): a pen writes
/// three rows in a notebook, the rows lift off and become transaction cards.
class NotebookPage extends ConsumerWidget {
  final PageArgs a;
  const NotebookPage(this.a, {super.key});

  static const _total = 3000;

  static const _rowY = [48.0, 84.0, 120.0];
  static const _slotY = [32.0, 100.0, 168.0];
  // Pen writes each row over these windows (after a 90 ms drop for rows 2, 3).
  static const _write = [(400.0, 1000.0), (1150.0, 1560.0), (1710.0, 2120.0)];
  static const _stroke = [(640.0, 790.0), (1300.0, 1450.0), (1860.0, 2010.0)];
  static const _cols = [16.0, 72.0, 140.0, 236.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final demo = WhyKuberDemo.of(context, ref);
    final sms = ref.watch(currencyProvider).code == 'INR';
    final expense = context.kuberMoney.expense;
    final rows = [
      _Row(
        demo.day(10, 12),
        demo.money(250),
        l.homeV33DFood,
        l.homeV33CFood,
        l.homeV33ABank,
        Icons.restaurant_rounded,
        DemoCat.of(context, DemoCat.food),
      ),
      _Row(
        demo.day(10, 12),
        demo.money(90),
        l.homeV33DAuto,
        l.homeV33CTransport,
        l.homeV33ACash,
        Icons.local_taxi_rounded,
        DemoCat.of(context, DemoCat.transport),
      ),
      _Row(
        demo.day(10, 13),
        demo.money(600),
        l.homeV33DMovie,
        l.homeV33CFun,
        l.homeV33ACard,
        Icons.movie_rounded,
        DemoCat.of(context, DemoCat.fun),
      ),
    ];
    final small = tt.bodySmall!.copyWith(color: cs.onSurface);
    // Amount stroke widths follow the measured text (once per build).
    final strokeW = [
      for (final r in rows)
        (TextPainter(
          text: TextSpan(text: r.amount, style: small),
          textDirection: TextDirection.ltr,
        )..layout()).width,
    ];

    Widget card(_Row r, double h) => SizedBox(
      width: 320,
      height: h,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: KuberSpace.md),
        child: Row(
          children: [
            DemoTile(r.icon, r.color, size: 36),
            const SizedBox(width: KuberSpace.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium!.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${r.cat} · ${r.account}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${r.amount}',
                  style: tt.bodyMedium!.copyWith(
                    color: expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  r.date,
                  style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    Widget line(_Row r, TextStyle s) => Row(
      children: [
        SizedBox(
          width: _cols[1] - _cols[0],
          child: Text(r.date, style: s, maxLines: 1),
        ),
        SizedBox(
          width: _cols[2] - _cols[1],
          child: Text(r.amount, style: s, maxLines: 1),
        ),
        SizedBox(
          width: _cols[3] - _cols[2],
          child: Text(
            r.name,
            style: s,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Text(
            r.cat,
            style: s,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final caps = tt.labelSmall!.copyWith(
      color: cs.onSurfaceVariant,
      letterSpacing: 0.8,
    );
    final headers = [
      l.homeV33P1ColDate,
      l.homeV33P1ColAmount,
      l.homeV33P1ColSpent,
      l.homeV33P1ColCat,
    ];

    Widget headerRow() => Row(
      children: [
        for (var i = 0; i < 4; i++)
          i < 3
              ? SizedBox(
                  width: _cols[i + 1] - _cols[i],
                  child: Text(
                    headers[i].toUpperCase(),
                    style: caps,
                    maxLines: 1,
                  ),
                )
              : Expanded(
                  child: Text(
                    headers[i].toUpperCase(),
                    style: caps,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
      ],
    );

    // Reduced motion: compact notebook, arrow, three cards.
    Widget staticFrame() => SizedBox(
      width: 320,
      height: 324,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              KuberSpace.lg,
              KuberSpace.xs,
              KuberSpace.sm,
              KuberSpace.xs,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: KuberShape.mediumR,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                SizedBox(height: 24, child: headerRow()),
                for (final r in rows)
                  SizedBox(height: 26, child: line(r, small)),
              ],
            ),
          ),
          const SizedBox(height: KuberSpace.xs),
          Icon(Icons.arrow_downward_rounded, color: cs.primary),
          const SizedBox(height: KuberSpace.xs),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: KuberSpace.sm),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: KuberShape.largeR,
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: card(r, 52),
              ),
            ),
        ],
      ),
    );

    Widget animated(double t) {
      final paper = seg(t, 0, 260) * (1 - seg(t, 2400, 2640));
      final paperRise = 16 * (1 - seg(t, 0, 260));
      // Pen: the row it is on, its progress, and the 90 ms drop between rows
      // (it travels back to the row start while dropping 36 px).
      var penX = 8.0;
      var penY = _rowY[0];
      var penV = 0.0;
      for (var i = 0; i < 3; i++) {
        final (s, e) = _write[i];
        final dropFrom = i == 0 ? s : s - 90;
        if (t < dropFrom) break;
        penV = seg(t, s, e, Curves.linear);
        final drop = i == 0 ? 1.0 : seg(t, s - 90, s);
        final prevY = _rowY[math.max(0, i - 1)];
        penY = prevY + (_rowY[i] - prevY) * drop;
        penX = drop < 1 ? 8 + 304 * (1 - drop) : 8 + 304 * penV;
      }
      final penIn = seg(t, 260, 410);
      final penLift = seg(t, 2120, 2270);
      final wobble = math.sin(penV * math.pi * 8) * 1.5;

      final children = <Widget>[
        // E1 notebook paper, rules, margin line and headers.
        Positioned(
          left: 0,
          top: 0,
          width: 320,
          height: 160,
          child: Opacity(
            opacity: paper,
            child: Transform.translate(
              offset: Offset(0, paperRise),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: KuberShape.mediumR,
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Stack(
                  children: [
                    for (final y in _rowY)
                      Positioned(
                        left: 8,
                        right: 8,
                        top: y + 31,
                        child: Container(height: 1, color: cs.outlineVariant),
                      ),
                    Positioned(
                      left: 10,
                      top: 8,
                      bottom: 8,
                      child: Container(
                        width: 1,
                        color: cs.tertiary.withValues(alpha: 0.5),
                      ),
                    ),
                    Positioned(
                      left: _cols[0],
                      top: 14,
                      right: 8,
                      child: headerRow(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ];

      for (var i = 0; i < 3; i++) {
        final r = rows[i];
        final (s, e) = _write[i];
        final write = seg(t, s, e, Curves.linear);
        final lift = seg(t, 2300 + 80.0 * i, 2540 + 80.0 * i);
        final morph = seg(t, 2540 + 80.0 * i, 2780 + 80.0 * i);
        final textOut = 1 - seg(t, 2540 + 80.0 * i, 2690 + 80.0 * i);
        final cardIn = seg(t, 2630 + 80.0 * i, 2780 + 80.0 * i);
        final from = Rect.fromLTWH(8, _rowY[i] - 6 * lift, 304, 32);
        final to = Rect.fromLTWH(0, _slotY[i], 320, 60);
        final rect = Rect.lerp(from, to, morph)!;
        final scale = 1 + 0.02 * lift * (1 - morph);
        children.add(
          Positioned.fromRect(
            rect: rect,
            child: Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainer.withValues(alpha: lift),
                  borderRadius: BorderRadius.circular(12 + 4 * morph),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: lift),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Notebook text, revealed left to right by the pen.
                    if (textOut > 0)
                      Positioned(
                        left: _cols[0] - 8,
                        top: 0,
                        bottom: 0,
                        child: Opacity(
                          opacity: textOut,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ClipRect(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: write,
                                child: SizedBox(
                                  width: 296,
                                  child: line(r, small),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // E6 amount stroke.
                    if (textOut > 0)
                      Positioned(
                        left: _cols[1] - 8,
                        top: 24,
                        child: Opacity(
                          opacity: textOut,
                          child: Container(
                            width:
                                strokeW[i] *
                                seg(t, _stroke[i].$1, _stroke[i].$2),
                            height: 2,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    if (cardIn > 0)
                      Positioned.fill(
                        child: Opacity(
                          opacity: cardIn,
                          child: OverflowBox(
                            alignment: Alignment.topLeft,
                            maxWidth: 320,
                            maxHeight: 60,
                            child: card(r, 60),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // E5 pen, riding the clip edge.
      final pen = penIn * (1 - penLift);
      if (pen > 0) {
        children.add(
          Positioned(
            left: penX - 4,
            top: penY - 18 + wobble - 8 * penLift,
            child: Opacity(
              opacity: pen,
              child: Transform.rotate(
                angle: -14 * math.pi / 180 * penLift,
                child: Icon(Icons.edit, size: 24, color: cs.primary),
              ),
            ),
          ),
        );
      }
      return SizedBox(
        width: 320,
        height: 260,
        child: Stack(clipBehavior: Clip.none, children: children),
      );
    }

    return PageLayout(
      stage: WhyKuberStage(
        durationMs: _total,
        active: a.active,
        played: a.played,
        onPlayed: a.onPlayed,
        semanticsLabel: l.homeV33P1A11y,
        builder: (context, t, reduced) => reduced ? staticFrame() : animated(t),
      ),
      title: l.homeV33P1Title,
      sub: pageSub(context, sms ? l.homeV33P1SubSms : l.homeV33P1Sub),
      tryLabel: l.homeV33P1Try,
      onTry: a.onTry,
    );
  }
}

class _Row {
  final String date;
  final String amount;
  final String name;
  final String cat;
  final String account;
  final IconData icon;
  final Color color;
  const _Row(
    this.date,
    this.amount,
    this.name,
    this.cat,
    this.account,
    this.icon,
    this.color,
  );
}
