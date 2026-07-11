import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';

/// Mounted in place of the three real `_PricingCard`s in `paywall_screen.dart`
/// while `productsLoadingProvider` is true (before `queryProductDetails()`
/// resolves). Feature clusters above this render immediately — they're
/// static copy, no Play Billing dependency.
class PaywallPricingSkeleton extends StatelessWidget {
  const PaywallPricingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Container(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KuberSkeleton(width: 90, height: 15),
                      const SizedBox(height: 8),
                      KuberSkeleton(width: 130, height: 12),
                    ],
                  ),
                ),
                KuberSkeleton(width: 64, height: 20),
              ],
            ),
          ),
          if (i != 2) const SizedBox(height: KuberSpacing.sm),
        ],
      ],
    );
  }
}

/// Mounted in place of `RestorePurchasesLink` while `productsLoadingProvider`
/// is true. Same footprint as the real link so nothing shifts when it
/// becomes interactive.
class RestorePurchasesLinkLoading extends StatelessWidget {
  const RestorePurchasesLinkLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 13,
          height: 13,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: KuberSpacing.sm),
        Text(
          'Restore purchases',
          style: localeFont(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
