import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';

/// Mounted in place of the real `GridView.count` of `_SupportTierCard`s in
/// `support/buy_me_coffee_section.dart`'s sheet while `productsLoadingProvider`
/// is true. Same 2x2 grid, same `_SupportTierCard` shape (icon chip + label
/// line + price line).
///
/// Separately — not shown here since it renders nothing — the
/// `BuyMeCoffeeButton` entry row in the More tab must watch
/// `productsErrorProvider` and return `SizedBox.shrink()` when true. Per
/// spec: never show a broken support section, just don't show one. Loading
/// is fine to show the entry row (tapping it opens the sheet, which owns its
/// own skeleton below); only a load failure hides it.
class BuyMeCoffeeSkeletonGrid extends StatelessWidget {
  const BuyMeCoffeeSkeletonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: KuberSpacing.sm,
      mainAxisSpacing: KuberSpacing.sm,
      childAspectRatio: 1.55,
      children: List.generate(4, (_) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          padding: const EdgeInsets.all(KuberSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KuberSkeleton(width: 32, height: 32, borderRadius: KuberRadius.sm),
              const Spacer(),
              KuberSkeleton(width: 60, height: 13),
              const SizedBox(height: 6),
              KuberSkeleton(width: 40, height: 11),
            ],
          ),
        );
      }),
    );
  }
}
