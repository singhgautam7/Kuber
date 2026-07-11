import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../paywall/pro_state.dart';
import 'promo_code_sheet.dart';

/// Persistent banner above the monthly-net hero on the Home tab while a
/// promo is running. Fully dismissible via the X; never blocks Home. Once
/// dismissed it stays hidden until the next cold start (see
/// [promoBannerDismissedProvider]).
///
/// Round 2: the CTA no longer grants Pro locally. "Get code" opens
/// [showPromoCodeSheet], which hands off to Play Store's own redemption —
/// see the security note in `promo_code_sheet.dart`.
class HomePromoBanner extends ConsumerWidget {
  const HomePromoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proState = ref.watch(kuberProStateProvider);
    final promo = ref.watch(promoConfigProvider);
    final dismissed = ref.watch(promoBannerDismissedProvider);

    if (promo == null || proState.isPro || dismissed) {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: KuberSpacing.lg),
      padding: const EdgeInsets.fromLTRB(
        KuberSpacing.lg,
        KuberSpacing.md,
        KuberSpacing.md,
        KuberSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(KuberRadius.sm),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.headline,
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  promo.message,
                  style: localeFont(
                    fontSize: 12.5,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: KuberSpacing.sm),
                GestureDetector(
                  onTap: () => showPromoCodeSheet(context, ref),
                  child: Text(
                    'Get code',
                    style: localeFont(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(promoBannerDismissedProvider.notifier).state = true,
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: cs.onPrimaryContainer.withValues(alpha: 0.7),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
          ),
        ],
      ),
    );
  }
}
