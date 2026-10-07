import 'package:flutter/material.dart';

import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';

/// The 4 Buy Me a Coffee support tiers.
enum SupportTier { coffee, dinner, feast, banquet }

extension SupportTierX on SupportTier {
  String get label => switch (this) {
    SupportTier.coffee => 'Coffee',
    SupportTier.dinner => 'Dinner',
    SupportTier.feast => 'Feast',
    SupportTier.banquet => 'Banquet',
  };

  String get price => switch (this) {
    SupportTier.coffee => '₹99',
    SupportTier.dinner => '₹249',
    SupportTier.feast => '₹599',
    SupportTier.banquet => '₹999',
  };

  IconData get icon => switch (this) {
    SupportTier.coffee => Icons.local_cafe_rounded,
    SupportTier.dinner => Icons.dinner_dining_rounded,
    SupportTier.feast => Icons.restaurant_rounded,
    SupportTier.banquet => Icons.celebration_rounded,
  };

  /// Play Console product ID (consumable). Namespaced `kuber_support_*` to
  /// match the strategy doc and the other `kuber_pro_*` product IDs.
  String get productId => switch (this) {
    SupportTier.coffee => 'kuber_support_coffee',
    SupportTier.dinner => 'kuber_support_dinner',
    SupportTier.feast => 'kuber_support_feast',
    SupportTier.banquet => 'kuber_support_banquet',
  };

  /// Resolves a support product id back to its tier, or null if unknown.
  static SupportTier? fromProductId(String id) => switch (id) {
    'kuber_support_coffee' => SupportTier.coffee,
    'kuber_support_dinner' => SupportTier.dinner,
    'kuber_support_feast' => SupportTier.feast,
    'kuber_support_banquet' => SupportTier.banquet,
    _ => null,
  };

  String get thankYouMessage => switch (this) {
    SupportTier.coffee =>
      "That's one coffee's worth of Kuber development. Every bit helps.",
    SupportTier.dinner =>
      "That covers a proper dinner while shipping the next update. Thank you.",
    SupportTier.feast => "You've made my week. Genuinely thank you.",
    SupportTier.banquet =>
      "This is generous beyond words. Thank you for believing in Kuber.",
  };
}

/// Shown after a successful Buy Me a Coffee purchase (Section 7). Grants no
/// Pro features, it is purely a thank-you.
void showSupportThankYouSheet(BuildContext context, SupportTier tier) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      final tt = Theme.of(ctx).textTheme;
      return KuberBottomSheet(
        title: 'Thank you',
        actions: AppButton(
          label: 'Done',
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: () => Navigator.pop(ctx),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(bottom: KuberSpace.lg),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: cs.onPrimary,
                size: 30,
              ),
            ),
            Text(
              tier.thankYouMessage,
              textAlign: TextAlign.center,
              style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    },
  );
}
