import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../data/why_kuber_demo_data.dart';
import 'why_kuber_page.dart';
import 'why_kuber_stage.dart';

/// Page 5 · Go further when you want (storyboards.md, 3740 ms): a spotlight
/// runs through five feature lines while the stage card shows each one
/// (Ask Kuber, Kuber Cards, Kuber Notes, Calculators, Reminders), then rests
/// on five icons. Stage and lines share one controller.
class FeaturesPage extends ConsumerWidget {
  final PageArgs a;
  const FeaturesPage(this.a, {super.key});

  /// Each feature gets 3 s (user review): its micro-animation is the
  /// storyboard's, stretched to play over 2 s, then holds for a 1 s gap
  /// before the next feature.
  static const _slotMs = 3000.0;
  static const _animMs = 2000.0;

  /// Where each storyboard micro-animation ends, from the slot start.
  static const _vignetteEnd = [630.0, 460.0, 660.0, 520.0, 400.0];
  static const _restStart = 300 + 5 * _slotMs; // 15300
  static const _total = 15540;

  /// Spotlight window per line (in, out).
  static final _spot = [
    for (var k = 0; k < 5; k++) (300 + k * _slotMs, 300 + (k + 1) * _slotMs),
  ];
  static const _icons = [
    Icons.auto_awesome_rounded,
    Icons.credit_card_rounded,
    Icons.sticky_note_2_rounded,
    Icons.calculate_rounded,
    Icons.notifications_rounded,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final demo = WhyKuberDemo.of(context, ref);
    final expense = context.kuberMoney.expense;
    final travel = DemoCat.of(context, DemoCat.travel);
    final lines = [
      (l.homeV33P5Ask, l.homeV33P5AskLine),
      (l.homeV33P5Cards, l.homeV33P5CardsLine),
      (l.homeV33P5Notes, l.homeV33P5NotesLine),
      (l.homeV33P5Calc, l.homeV33P5CalcLine),
      (l.homeV33P5Rem, l.homeV33P5RemLine),
    ];
    final question = l.homeV33P5AskQ;
    final answer = l.homeV33P5AskA(demo.money(5600));
    final inputs = [
      l.homeV33P5PerMonth(demo.money(5000)),
      l.homeV33P5Rate(12),
      l.homeV33P5Years(10),
    ];
    final remDue = l.homeV33P5RemDue(demo.money(1450));
    final body = tt.bodySmall!.copyWith(color: cs.onSurface);

    Widget bubble(String text, {required bool mine}) => Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpace.md,
          vertical: KuberSpace.sm,
        ),
        decoration: BoxDecoration(
          color: mine ? cs.primaryContainer : cs.surfaceContainerHigh,
          borderRadius: KuberShape.largeR,
        ),
        child: Text(
          text,
          style: tt.bodySmall!.copyWith(
            color: mine ? cs.onPrimaryContainer : cs.onSurface,
          ),
        ),
      ),
    );

    Widget vignette(int i, double t) {
      if (i < 5) {
        final b = _spot[i].$1;
        t = b + (t - b) * _vignetteEnd[i] / _animMs;
      }
      switch (i) {
        case 0: // Ask Kuber
          final b = _spot[0].$1;
          final typed = seg(t, b + 150, b + 450, Curves.linear);
          final chars = (question.length * typed).round();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              bubble(
                question.substring(0, chars) + (typed < 1 ? '|' : ''),
                mine: true,
              ),
              const SizedBox(height: KuberSpace.sm),
              fadeUp(seg(t, b + 480, b + 630), 8, bubble(answer, mine: false)),
            ],
          );
        case 1: // Kuber Cards: flip
          final b = _spot[1].$1;
          final f1 = seg(t, b + 160, b + 310);
          final f2 = seg(t, b + 310, b + 460);
          final back = f2 > 0;
          return Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(back ? f2 : 1 - f1, 1, 1),
              child: Container(
                width: 190,
                height: 112,
                padding: const EdgeInsets.all(KuberSpace.md),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: KuberShape.mediumR,
                ),
                child: back
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l.homeV33DBankName,
                                style: tt.labelMedium!.copyWith(
                                  color: cs.onPrimary,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.lock_rounded,
                                size: 16,
                                color: cs.onPrimary,
                              ),
                            ],
                          ),
                          const Spacer(),
                          FittedBox(
                            child: Text(
                              '•••• •••• •••• 5678',
                              style: tt.titleSmall!.copyWith(
                                color: cs.onPrimary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 30,
                          height: 22,
                          decoration: BoxDecoration(
                            color: cs.onPrimary.withValues(alpha: 0.4),
                            borderRadius: KuberShape.smallR,
                          ),
                        ),
                      ),
              ),
            ),
          );
        case 2: // Kuber Notes: lines add up, the result becomes a transaction
          final b = _spot[2].$1;
          final result = seg(t, b + 270, b + 420);
          final morph = seg(t, b + 420, b + 660);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l.homeV33P5NoteName,
                style: tt.titleSmall!.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: KuberSpace.xs),
              Text('${l.homeV33P5Hotel} ${demo.number(12400)}', style: body),
              Text('${l.homeV33P5Taxi} ${demo.number(2100)}', style: body),
              const SizedBox(height: KuberSpace.xs),
              SizedBox(
                height: 28,
                child: Stack(
                  children: [
                    Opacity(
                      opacity: result * (1 - morph),
                      child: Transform.scale(
                        alignment: Alignment.centerLeft,
                        scale: 0.9 + 0.1 * result,
                        child: Text(
                          '= ${demo.number(14500)}',
                          style: tt.titleSmall!.copyWith(color: cs.primary),
                        ),
                      ),
                    ),
                    if (morph > 0)
                      Opacity(
                        opacity: morph,
                        child: Transform.scale(
                          alignment: Alignment.centerLeft,
                          scale: 0.8 + 0.2 * morph,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(
                              4,
                              2,
                              KuberSpace.md,
                              2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius: KuberShape.smallR,
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DemoTile(
                                  Icons.flight_rounded,
                                  travel,
                                  size: 20,
                                ),
                                const SizedBox(width: KuberSpace.sm),
                                Text(
                                  '-${demo.money(14500)}',
                                  style: tt.labelMedium!.copyWith(
                                    color: expense,
                                  ),
                                ),
                                const SizedBox(width: KuberSpace.sm),
                                Text(
                                  l.homeV33P5Travel,
                                  style: tt.labelMedium!.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        case 3: // SIP calculator
          final b = _spot[3].$1;
          final count = seg(t, b + 280, b + 520, Curves.linear);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l.homeV33P5SipCalc,
                style: tt.titleSmall!.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: KuberSpace.sm),
              Wrap(
                spacing: KuberSpace.xs,
                runSpacing: KuberSpace.xs,
                children: [
                  for (var j = 0; j < 3; j++)
                    Opacity(
                      opacity: seg(t, b + 80 + 50.0 * j, b + 230 + 50.0 * j),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpace.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: KuberShape.smallR,
                        ),
                        child: Text(
                          inputs[j],
                          style: tt.labelMedium!.copyWith(color: cs.onSurface),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: KuberSpace.sm),
              Text(
                demo.money((1161695 * count).round()),
                style: tt.titleMedium!.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        case 4: // Reminders: the bell rings, a notification arrives
          final b = _spot[4].$1;
          final a1 = seg(t, b + 40, b + 120);
          final a2 = seg(t, b + 120, b + 200);
          final a3 = seg(t, b + 200, b + 280);
          final deg = -10 * a1 + 20 * a2 - 20 * a3;
          return Row(
            children: [
              Transform.rotate(
                angle: deg * math.pi / 180,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: KuberShape.mediumR,
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: cs.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: Opacity(
                  opacity: seg(t, b + 140, b + 400),
                  child: Transform.translate(
                    offset: Offset(0, -16 * (1 - seg(t, b + 140, b + 400))),
                    child: Container(
                      padding: const EdgeInsets.all(KuberSpace.sm),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: KuberShape.mediumR,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l.homeV33P5RemTitle,
                            style: tt.labelLarge!.copyWith(color: cs.onSurface),
                          ),
                          Text(
                            remDue,
                            style: tt.bodySmall!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        default: // rest: five feature icons
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final icon in _icons)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: KuberShape.mediumR,
                  ),
                  child: Icon(icon, color: cs.onSecondaryContainer),
                ),
            ],
          );
      }
    }

    Widget frame(double t) {
      final card = seg(t, 0, 260);
      final rest = seg(t, _restStart, _total.toDouble());
      final stage = SizedBox(
        width: 320,
        height: 150,
        child: Opacity(
          opacity: card,
          child: Container(
            padding: const EdgeInsets.all(KuberSpace.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: KuberShape.largeR,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Stack(
              children: [
                for (var i = 0; i < 6; i++)
                  Builder(
                    builder: (context) {
                      final o = i < 5
                          ? seg(t, _spot[i].$1, _spot[i].$1 + 150) *
                                (1 - seg(t, _spot[i].$2, _spot[i].$2 + 150))
                          : rest;
                      if (o <= 0) return const SizedBox.shrink();
                      return Positioned.fill(
                        child: Opacity(opacity: o, child: vignette(i, t)),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      );
      final list = Column(
        children: [
          for (var i = 0; i < 5; i++)
            Builder(
              builder: (context) {
                final s =
                    seg(t, _spot[i].$1, _spot[i].$1 + 150) *
                    (1 - seg(t, _spot[i].$2, _spot[i].$2 + 150));
                final fg = Color.lerp(
                  Color.lerp(cs.onSurfaceVariant, cs.onSurface, rest),
                  cs.onSecondaryContainer,
                  s,
                )!;
                return Opacity(
                  opacity: seg(t, 50.0 * i, 150 + 50.0 * i),
                  // Tap a feature once the tour has played: its slot plays
                  // again (user review).
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => WhyKuberStage.playRange(
                      context,
                      _spot[i].$1,
                      _spot[i].$2,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: KuberSpace.xs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpace.md,
                        vertical: KuberSpace.sm,
                      ),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer.withValues(alpha: s),
                        borderRadius: KuberShape.mediumR,
                      ),
                      child: Row(
                        children: [
                          Icon(_icons[i], size: 20, color: fg),
                          const SizedBox(width: KuberSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lines[i].$1,
                                  style: tt.labelLarge!.copyWith(
                                    color: fg,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  lines[i].$2,
                                  style: tt.bodySmall!.copyWith(color: fg),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: l.homeV33P5A11y,
            child: ExcludeSemantics(child: clampedText(stage)),
          ),
          const SizedBox(height: KuberSpace.xl),
          Text(
            l.homeV33P5Title,
            textAlign: TextAlign.center,
            style: tt.headlineSmall!.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: KuberSpace.md),
          SizedBox(width: 320, child: list),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WhyKuberStage(
          durationMs: _total,
          active: a.active,
          played: a.played,
          onPlayed: a.onPlayed,
          clampText: false,
          builder: (context, t, reduced) =>
              frame(reduced ? _total.toDouble() : t),
        ),
        if (a.onTry != null) ...[
          const SizedBox(height: KuberSpace.sm),
          TextButton.icon(
            onPressed: a.onTry,
            icon: const Icon(Icons.arrow_outward_rounded, size: 18),
            label: Text(l.homeV33P5Try),
          ),
        ],
      ],
    );
  }
}
