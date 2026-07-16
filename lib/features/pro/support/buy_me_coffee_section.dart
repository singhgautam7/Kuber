import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
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
    // Never render a broken support section: if the support products failed to
    // load, hide the entry entirely rather than opening a dead sheet.
    if (ref.watch(productsErrorProvider)) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(KuberRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showBuyMeCoffeeSheet(context),
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Ink(
          // Matches the Accounts hero card's background: neutral outline with
          // a soft diagonal accent-tint gradient (not a primary-colored
          // border).
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: cs.outline),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.alphaBlend(
                  cs.primary.withValues(alpha: 0.16),
                  cs.surfaceContainer,
                ),
                cs.surfaceContainer,
              ],
              stops: const [0.0, 0.75],
            ),
          ),
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.local_cafe_rounded, size: 22, color: cs.primary),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buy me a coffee',
                      style: localeFont(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your contribution helps me keep working on my side '
                      'project and supporting its development.',
                      style: localeFont(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
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
        subtitle: 'Support the developer',
        leadingIcon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Icon(Icons.local_cafe_rounded, color: cs.primary, size: 20),
        ),
        actions: SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
            ),
            child: Text(
              'Maybe next time',
              style: localeFont(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A one-time thank you, nothing more. It unlocks no Pro features '
              'and there is no subscription. Pick whatever feels right.',
              style: localeFont(
                fontSize: 13.5,
                color: cs.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
            // Skeleton grid until the support products resolve, so the sheet
            // never shows tiles that can't yet be purchased.
            Consumer(
              builder: (context, ref, _) {
                if (ref.watch(productsLoadingProvider)) {
                  return const BuyMeCoffeeSkeletonGrid();
                }
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: KuberSpacing.sm,
                  mainAxisSpacing: KuberSpacing.sm,
                  childAspectRatio: 1.55,
                  children: SupportTier.values
                      .map((tier) => _SupportTierCard(tier: tier))
                      .toList(),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class _SupportTierCard extends ConsumerWidget {
  final SupportTier tier;
  const _SupportTierCard({required this.tier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: () {
        // Close the picker first, then launch the Play consumable flow; the
        // thank-you sheet is shown by PurchaseService on success.
        Navigator.of(context).pop();
        ref.read(purchaseServiceProvider).buySupport(tier.productId);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        padding: const EdgeInsets.all(KuberSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
              child: Icon(tier.icon, size: 17, color: cs.primary),
            ),
            const Spacer(),
            Text(
              tier.label,
              style: localeFont(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tier.price,
              style: localeFont(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
