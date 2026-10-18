import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import 'why_kuber_page.dart';
import 'why_kuber_stage.dart';

/// Page 3 · Track more than spending (storyboards.md, 3100 ms): five module
/// rows, each with a live visual (budget bar, SIP line, EMI ring, money lent
/// and borrowed, a subscription renewing).
class ModulesPage extends ConsumerWidget {
  final PageArgs a;
  const ModulesPage(this.a, {super.key});

  static const _total = 3100;

  static const _rowStart = [0.0, 560.0, 1120.0, 1680.0, 2240.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final demo = WhyKuberDemo.of(context, ref);
    final money = context.kuberMoney;
    final title = tt.bodyMedium!.copyWith(
      color: cs.onSurface,
      fontWeight: FontWeight.w600,
    );
    final sub = tt.bodySmall!.copyWith(color: cs.onSurfaceVariant);
    final limit = demo.money(8000);
    final emi = demo.money(24500);
    final subsAmount = l.homeV33P3SubsSub(demo.money(649));
    final renews = l.homeV33P3Renews(demo.day(10, 15));
    final next = l.homeV33P3Next(demo.day(11, 15));
    final lent = l.homeV33P3Lent('Rahul');
    final borrowed = l.homeV33P3Borrowed('Priya');

    Widget row(int i, double t, IconData icon, Widget texts, Widget trailing) {
      final p = seg(t, _rowStart[i], _rowStart[i] + 150);
      return Positioned(
        left: 0,
        top: 52.0 * i,
        width: 320,
        height: 48,
        child: Opacity(
          opacity: p,
          child: Transform.translate(
            offset: Offset(-8 * (1 - p), 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: KuberShape.mediumR,
                  ),
                  child: Icon(icon, size: 20, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: KuberSpace.md),
                Expanded(child: texts),
                const SizedBox(width: KuberSpace.sm),
                SizedBox(width: 96, child: trailing),
              ],
            ),
          ),
        ),
      );
    }

    Widget texts(String a, String b) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(a, maxLines: 1, overflow: TextOverflow.ellipsis, style: title),
        Text(b, maxLines: 1, overflow: TextOverflow.ellipsis, style: sub),
      ],
    );

    Widget frame(double t) {
      final budget = seg(t, 150, 390);
      final paid = seg(t, 1600, 1750) >= 0.5 ? 14 : 13;
      final ticker = seg(t, 1830, 2070, Curves.linear);
      final oldOut = seg(t, 2800, 2950);
      final newIn = seg(t, 2950, 3100);
      return SizedBox(
        width: 320,
        height: 256,
        child: Stack(
          children: [
            row(
              0,
              t,
              Icons.donut_large_rounded,
              texts(
                l.homeV33P3Budget,
                l.homeV33P3BudgetOf(demo.money((5600 * budget).round()), limit),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: LinearProgressIndicator(
                  value: 0.7 * budget,
                  minHeight: 8,
                  color: cs.primary,
                  backgroundColor: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(KuberShape.full),
                ),
              ),
            ),
            row(
              1,
              t,
              Icons.trending_up_rounded,
              texts(l.homeV33P3Inv, l.homeV33P3InvTypes),
              CustomPaint(
                size: const Size(96, 36),
                painter: _SipLine(
                  cs.primary,
                  seg(t, 710, 950),
                  seg(t, 950, 1040),
                ),
              ),
            ),
            row(
              2,
              t,
              Icons.home_rounded,
              texts(l.homeV33P3Loan, l.homeV33P3LoanSub(emi, paid, 60)),
              Align(
                alignment: Alignment.centerRight,
                child: CustomPaint(
                  size: const Size(32, 32),
                  painter: _Ring(
                    cs.primary,
                    cs.surfaceContainerHighest,
                    13 / 60 * seg(t, 1270, 1510) + 1 / 60 * seg(t, 1600, 1750),
                  ),
                ),
              ),
            ),
            row(
              3,
              t,
              Icons.handshake_rounded,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lent,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: title,
                  ),
                  Text(
                    borrowed,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sub,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var j = 0; j < 2; j++)
                    Transform.scale(
                      scale:
                          0.6 + 0.4 * seg(t, 1680 + 60.0 * j, 1830 + 60.0 * j),
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: j == 0
                            ? cs.tertiaryContainer
                            : cs.secondaryContainer,
                        child: Text(
                          j == 0 ? 'R' : 'P',
                          style: tt.labelSmall!.copyWith(
                            color: j == 0
                                ? cs.onTertiaryContainer
                                : cs.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: KuberSpace.xs),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+${demo.money((1500 * ticker).round())}',
                        style: tt.labelMedium!.copyWith(color: money.income),
                      ),
                      Text(
                        '-${demo.money((400 * ticker).round())}',
                        style: tt.labelMedium!.copyWith(color: money.expense),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            row(
              4,
              t,
              Icons.live_tv_rounded,
              texts(l.homeV33P3Subs, subsAmount),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 26,
                  width: 96,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      cs.surfaceContainerHigh,
                      cs.secondaryContainer,
                      newIn,
                    ),
                    borderRadius: KuberShape.smallR,
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 1 - oldOut,
                        child: Transform.translate(
                          offset: Offset(0, -8 * oldOut),
                          child: Text(
                            renews,
                            maxLines: 1,
                            style: tt.labelSmall!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: newIn,
                        child: Transform.translate(
                          offset: Offset(0, 8 * (1 - newIn)),
                          child: Text(
                            next,
                            maxLines: 1,
                            style: tt.labelSmall!.copyWith(
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
        semanticsLabel: l.homeV33P3A11y,
        builder: (context, t, reduced) =>
            frame(reduced ? _total.toDouble() : t),
      ),
      title: l.homeV33P3Title,
      sub: pageSub(context, l.homeV33P3Sub),
      tryLabel: l.homeV33P3Try,
      onTry: a.onTry,
    );
  }
}

/// SIP line drawn left to right, then its end dot.
class _SipLine extends CustomPainter {
  final Color color;
  final double progress;
  final double dot;
  const _SipLine(this.color, this.progress, this.dot);

  static const _points = [
    0.0,
    0.18,
    0.12,
    0.34,
    0.3,
    0.52,
    0.48,
    0.72,
    0.68,
    0.92,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var i = 0; i < _points.length; i++) {
      final x = size.width * i / (_points.length - 1);
      final y = size.height * (1 - _points[i]) - 2;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    drawPathPortion(
      canvas,
      path,
      progress,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (dot > 0) {
      canvas.drawCircle(
        Offset(size.width, size.height * (1 - _points.last) - 2),
        3.5 * dot,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_SipLine o) =>
      o.progress != progress || o.dot != dot || o.color != color;
}

/// EMI progress ring.
class _Ring extends CustomPainter {
  final Color color;
  final Color track;
  final double value;
  const _Ring(this.color, this.track, this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect.deflate(2),
      0,
      math.pi * 2,
      false,
      stroke..color = track,
    );
    canvas.drawArc(
      rect.deflate(2),
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      stroke..color = color,
    );
  }

  @override
  bool shouldRepaint(_Ring o) =>
      o.value != value || o.color != color || o.track != track;
}
