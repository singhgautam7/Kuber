import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../data/why_kuber_demo_data.dart';
import 'why_kuber_page.dart';
import 'why_kuber_stage.dart';

/// Page 2 · Every account, every category (storyboards.md, 2740 ms): bank,
/// cash and a credit card with balance or due, the card's billing cycle and
/// due date, then a new Pet care category is created.
class AccountsPage extends ConsumerWidget {
  final PageArgs a;
  const AccountsPage(this.a, {super.key});

  static const _total = 2740;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final demo = WhyKuberDemo.of(context, ref);
    final expense = context.kuberMoney.expense;
    final tiles = [
      (
        Icons.account_balance_rounded,
        l.homeV33ABank,
        l.homeV33P2Balance,
        42350,
      ),
      (Icons.payments_rounded, l.homeV33ACash, l.homeV33P2Balance, 1200),
      (Icons.credit_card_rounded, l.homeV33ACard, l.homeV33P2Due, 8640),
    ];
    final cats = [
      (
        Icons.restaurant_rounded,
        l.homeV33CFood,
        DemoCat.of(context, DemoCat.food),
      ),
      (
        Icons.directions_bus_rounded,
        l.homeV33CTransport,
        DemoCat.of(context, DemoCat.transport),
      ),
      (
        Icons.shopping_bag_rounded,
        l.homeV33CShopping,
        DemoCat.of(context, DemoCat.shopping),
      ),
    ];
    final pet = DemoCat.of(context, DemoCat.petCare);
    final cycle = l.homeV33P2Cycle(demo.day(9, 16), demo.day(10, 15));
    final dueOn = l.homeV33P2DueOn(demo.day(11, 5));
    final petLabel = l.homeV33P2PetCare;

    Widget chip(
      IconData icon,
      String label,
      Color color, {
      Color? fill,
      Widget? border,
      double iconTint = 1,
    }) => Stack(
      children: [
        if (border != null) Positioned.fill(child: border),
        Container(
          height: 32,
          padding: const EdgeInsets.fromLTRB(4, 4, KuberSpace.md, 4),
          decoration: BoxDecoration(
            color: fill ?? cs.surface,
            borderRadius: KuberShape.smallR,
            border: border == null
                ? Border.all(color: cs.outlineVariant)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DemoTile(
                icon,
                Color.lerp(cs.onSurfaceVariant, color, iconTint)!,
                size: 24,
              ),
              const SizedBox(width: KuberSpace.sm),
              Text(label, style: tt.labelLarge!.copyWith(color: cs.onSurface)),
            ],
          ),
        ),
      ],
    );

    Widget frame(double t) {
      final cardBorder = seg(t, 900, 1140);
      final strip = seg(t, 1000, 1260);
      final fill = seg(t, 1260, 1500);
      return SizedBox(
        width: 320,
        height: 276,
        child: Stack(
          children: [
            for (var i = 0; i < 3; i++)
              Positioned(
                left: 110.0 * i,
                top: 0,
                width: 100,
                height: 92,
                child: fadeUp(
                  seg(t, 60.0 * i, 260 + 60.0 * i),
                  12,
                  Container(
                    padding: const EdgeInsets.all(KuberSpace.sm),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: KuberShape.mediumR,
                      border: Border.all(
                        color: i == 2
                            ? Color.lerp(
                                cs.outlineVariant,
                                cs.primary,
                                cardBorder,
                              )!
                            : cs.outlineVariant,
                        width: i == 2 ? 1 + cardBorder : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(tiles[i].$1, size: 20, color: cs.primary),
                        const Spacer(),
                        Text(
                          tiles[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelMedium!.copyWith(color: cs.onSurface),
                        ),
                        Text(
                          tiles[i].$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // IntTween-style ticker: whole units arrive evenly.
                            demo.money(
                              (tiles[i].$4 *
                                      seg(
                                        t,
                                        140 + 60.0 * i,
                                        380 + 60.0 * i,
                                        Curves.linear,
                                      ))
                                  .round(),
                            ),
                            style: tt.titleSmall!.copyWith(
                              color: i == 2 ? expense : cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Billing cycle strip grows out of the card tile.
            Positioned(
              left: 0,
              top: 100,
              width: 320,
              height: 64 * strip,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: 64,
                  child: Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(
                      horizontal: KuberSpace.md,
                      vertical: KuberSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: KuberShape.mediumR,
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cycle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall!.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: fill,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: KuberSpace.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.secondaryContainer,
                                  borderRadius: KuberShape.smallR,
                                ),
                                child: Text(
                                  dueOn,
                                  style: tt.labelSmall!.copyWith(
                                    color: cs.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        LinearProgressIndicator(
                          value: 0.93 * fill,
                          minHeight: 6,
                          color: cs.primary,
                          backgroundColor: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(KuberShape.full),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Categories, then the new one.
            Positioned(
              left: 0,
              top: 180,
              width: 320,
              child: Wrap(
                spacing: KuberSpace.sm,
                runSpacing: KuberSpace.sm,
                children: [
                  for (var i = 0; i < 3; i++)
                    fadeUp(
                      seg(t, 1700 + 50.0 * i, 1850 + 50.0 * i),
                      8,
                      chip(cats[i].$1, cats[i].$2, cats[i].$3),
                    ),
                  _newChip(t, chip, pet, petLabel),
                ],
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
        semanticsLabel: l.homeV33P2A11y,
        builder: (context, t, reduced) =>
            frame(reduced ? _total.toDouble() : t),
      ),
      title: l.homeV33P2Title,
      sub: pageSub(context, l.homeV33P2Sub),
      tryLabel: l.homeV33P2Try,
      onTry: a.onTry,
    );
  }

  Widget _newChip(
    double t,
    Widget Function(
      IconData,
      String,
      Color, {
      Color? fill,
      Widget? border,
      double iconTint,
    })
    chip,
    Color pet,
    String label,
  ) {
    final appear = seg(t, 2050, 2290);
    final typed = seg(t, 2100, 2400, Curves.linear);
    final select = seg(t, 2500, 2740);
    final chars = (label.length * typed).round();
    final text =
        label.substring(0, chars) + (typed > 0 && typed < 1 ? '|' : '');
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Opacity(
          opacity: appear,
          child: Transform.scale(
            scale: 0.8 + 0.2 * appear,
            child: chip(
              Icons.pets_rounded,
              text.isEmpty ? ' ' : text,
              pet,
              iconTint: select,
              fill: Color.lerp(cs.surface, cs.secondaryContainer, select),
              border: CustomPaint(
                painter: DashedRRectPainter(
                  cs.primary,
                  KuberShape.small,
                  1 - select,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
