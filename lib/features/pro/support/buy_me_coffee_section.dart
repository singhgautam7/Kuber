import 'package:flutter/material.dart';
import '../../../shared/widgets/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../paywall/billing_ui_state.dart';
import '../services/purchase_service.dart';
import 'buy_me_coffee_loading.dart';
import 'support_success_sheets.dart';

/// Full-width entry point shown in the More tab, directly below the "Help us"
/// section. A one-time, no-strings way to support development that grants no
/// Pro features. Tapping opens [showBuyMeCoffeeSheet] with the four tiers.
class BuyMeCoffeeButton extends ConsumerWidget {
  const BuyMeCoffeeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always visible (round 3). If Play Billing is unreachable, picking a
    // tier shows the existing "Play Store unavailable" snackbar.
    // Board 3.7: a tonal 56 full-width button.
    return AppButton(
      label: 'Buy me a coffee',
      icon: Icons.local_cafe_rounded,
      fullWidth: true,
      onPressed: () => showBuyMeCoffeeSheet(context),
    );
  }
}

/// Bottom sheet with the four one-time support tiers. Modern, compact 2x2
/// grid. Picking a tier launches the Play Billing consumable flow; the
/// thank-you sheet is shown by [PurchaseService] once the purchase completes.
void showBuyMeCoffeeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return KuberBottomSheet(
        title: 'Buy me a coffee',
        description: 'SUPPORT THE DEVELOPER',
        leadingIcon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: KuberShape.mediumR,
          ),
          child: Icon(Icons.local_cafe_rounded, color: cs.onPrimary, size: 20),
        ),
        actions: AppButton(
          label: 'Maybe next time',
          type: AppButtonType.outline,
          fullWidth: true,
          onPressed: () => Navigator.pop(ctx),
        ),
        // Skeleton grid until the support products resolve, so the sheet
        // never shows tiles that can't yet be purchased.
        child: Consumer(
          builder: (context, ref, _) {
            final tt = Theme.of(context).textTheme;
            final intro = Padding(
              padding: const EdgeInsets.only(bottom: KuberSpace.lg),
              child: Text(
                'A one-time thank you, nothing more. It unlocks no Pro '
                'features and there is no subscription. Pick whatever feels '
                'right.',
                style: tt.bodyLarge!.copyWith(color: cs.onSurface),
              ),
            );
            if (ref.watch(productsLoadingProvider)) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [intro, const BuyMeCoffeeSkeletonGrid()],
              );
            }
            final grid = GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: KuberSpace.sm,
              mainAxisSpacing: KuberSpace.sm,
              childAspectRatio: kCoffeeTileAspect,
              children: SupportTier.values
                  .map((tier) => _SupportTierCard(tier: tier))
                  .toList(),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [intro, grid],
            );
          },
        ),
      );
    },
  );
}

/// Tier tile proportions, shared with the skeleton.
const double kCoffeeTileAspect = 1.2;

/// A tier tile (board 3.30): glyph tile, name, price.
class _SupportTierCard extends ConsumerWidget {
  final SupportTier tier;
  const _SupportTierCard({required this.tier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.cardR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Close the picker first, then launch the Play consumable flow; the
          // thank-you sheet is shown by PurchaseService on success.
          Navigator.of(context).pop();
          ref.read(purchaseServiceProvider).buySupport(tier.productId);
        },
        child: Padding(
          padding: const EdgeInsets.all(KuberSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KuberIconTile(icon: tier.icon, size: 32, glyph: 18),
              const Spacer(),
              Text(
                tier.label,
                style: tt.bodyMedium!.copyWith(color: cs.onSurface),
              ),
              Text(
                tier.price,
                style: tt.headlineSmall!.copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
