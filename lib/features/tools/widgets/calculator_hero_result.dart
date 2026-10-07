import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';

/// A single large hero number with a small-caps label, auto-shrinking to fit.
class ToolHero extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? sub;

  const ToolHero({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // Result hero (board 3.32): primaryContainer, radius 28. [color] is kept
    // for API compatibility; on the container everything reads
    // onPrimaryContainer.
    return _HeroShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: tt.bodyMedium!.copyWith(color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: KuberSpace.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            // Plain Text (no rolling animation): the hero is inside a lazily
            // built SliverList, so an implicit animation would re-trigger
            // every time the card scrolls back into view.
            child: Text(
              value,
              style: tt.displaySmall!.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: KuberSpace.xs),
            Text(
              sub!,
              style: tt.bodyMedium!.copyWith(color: cs.onPrimaryContainer),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroShell extends StatelessWidget {
  final Widget child;
  const _HeroShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.screenMargin),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }
}

/// One side of a dual hero.
class HeroSide {
  final String label;
  final String value;
  final Color color;
  final String? sub;
  const HeroSide({
    required this.label,
    required this.value,
    required this.color,
    this.sub,
  });
}

/// Two side-by-side hero results with an optional winner/info banner below.
class ToolDualHero extends StatelessWidget {
  final HeroSide left;
  final HeroSide right;
  final String? bannerText;

  /// Tints the banner green for a "winner" message, else primary.
  final bool bannerIsPositive;

  const ToolDualHero({
    super.key,
    required this.left,
    required this.right,
    this.bannerText,
    this.bannerIsPositive = true,
  });

  Widget _side(BuildContext context, HeroSide s) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.label,
            maxLines: 2,
            style: tt.bodyMedium!.copyWith(color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: KuberSpace.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              s.value,
              style: tt.headlineMedium!.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (s.sub != null)
            Text(
              s.sub!,
              style: tt.bodySmall!.copyWith(color: cs.onPrimaryContainer),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bannerColor = bannerIsPositive
        ? context.kuberMoney.income
        : cs.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroShell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _side(context, left),
              const SizedBox(width: KuberSpace.md),
              _side(context, right),
            ],
          ),
        ),
        if (bannerText != null) ...[
          const SizedBox(height: KuberSpace.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpace.md,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.12),
              borderRadius: KuberShape.cardR,
            ),
            child: Text(
              bannerText!,
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: bannerColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class StatCol {
  final String label;
  final String value;
  final Color? color;
  const StatCol(this.label, this.value, {this.color});
}

/// A 2–3 column stat grid with 1px vertical dividers, on a muted surface.
class ToolStatCols extends StatelessWidget {
  final List<StatCol> items;
  const ToolStatCols({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.cardR,
      ),
      // IntrinsicHeight gives the Row a bounded height so the equal-height
      // columns (CrossAxisAlignment.stretch + vertical dividers) don't try to
      // grow to infinity inside the scroll view.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpace.md,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: i == 0
                          ? BorderSide.none
                          : BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        items[i].label,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          items[i].value,
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(color: items[i].color ?? cs.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
