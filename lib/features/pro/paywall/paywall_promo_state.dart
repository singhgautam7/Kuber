import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../promo/promo_code_sheet.dart';
import 'pro_state.dart';

/// Large promo banner shown at the top of the paywall when a promo is
/// active. Round 2: drops the "Claim free Pro" button (the local-grant exploit)
/// entirely. "Get code" opens the same [showPromoCodeSheet] as the Home
/// banner. The paid pricing cards (`_PricingCard`s in `paywall_screen.dart`)
/// already render directly below this section, unchanged — a promo user
/// always has a real purchase path too, they're just not funneled into one
/// via a fake "or pay instead" link anymore.
class PaywallPromoSection extends ConsumerWidget {
  final PromoConfig promo;
  const PaywallPromoSection({super.key, required this.promo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Text(
                  promo.headline,
                  style: localeFont(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.sm),
          Text(
            promo.message,
            style: localeFont(
              fontSize: 13.5,
              color: cs.onPrimaryContainer.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => showPromoCodeSheet(context, ref),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                  ),
                  child: Text(
                    'Get code',
                    style: localeFont(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.sm),
          Center(
            child: Text(
              'Or pick a plan below to buy Kuber Pro directly.',
              style: localeFont(
                fontSize: 12,
                color: cs.onPrimaryContainer.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
