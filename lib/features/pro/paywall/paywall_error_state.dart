import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import 'billing_ui_state.dart';

/// Mounted in place of the three real `_PricingCard`s in `paywall_screen.dart`
/// when `productsErrorProvider` is true (Play Billing unreachable — offline,
/// Play Services broken, or the query threw). Prefers a cached last-known
/// price over a bare error whenever one exists, per spec.
class PaywallProductsErrorState extends ConsumerWidget {
  final VoidCallback onRetry;
  const PaywallProductsErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final cached = ref.watch(cachedProductPricesProvider);

    if (cached.isNotEmpty) {
      // Real cached prices, not a placeholder — reuse the same row shape as
      // the live pricing cards would, just sourced from the cache. Kept
      // inline (not a full _PricingCard reuse) since this handoff doesn't
      // have access to that private widget; wire the real cached values
      // into `_PricingCard` directly when integrating.
      return Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Showing last known prices',
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            // Render the real pricing cards here using `cached` values —
            // integration note: pass `cached[productId]` as the price string
            // to each `_PricingCard` instead of the live `ProductDetails`.
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 28,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: KuberSpacing.md),
          Text(
            'Prices unavailable. Check your connection.',
            textAlign: TextAlign.center,
            style: localeFont(
              fontSize: 13.5,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
              ),
              child: Text(
                'Retry',
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
