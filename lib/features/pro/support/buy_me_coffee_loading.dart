import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'buy_me_coffee_section.dart' show kCoffeeTileAspect;

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
      crossAxisSpacing: KuberSpace.sm,
      mainAxisSpacing: KuberSpace.sm,
      childAspectRatio: kCoffeeTileAspect,
      children: List.generate(
        4,
        (_) => Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: KuberShape.cardR,
          ),
        ),
      ),
    );
  }
}
