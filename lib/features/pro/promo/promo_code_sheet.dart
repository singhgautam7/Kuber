import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/timed_snackbar.dart';
import '../paywall/pro_state.dart';
import '../purchase_states/purchase_failure_snackbar.dart';
import '../services/purchase_service.dart';

/// Opened from the Home promo banner's "Get code" and the paywall's promo
/// section. Replaces `promo_claim_modal.dart`'s local grant entirely — this
/// sheet never touches [kuberProStateProvider] itself. It only shows the
/// code and hands off to Play Store; Play verifies the code, and a
/// successful redemption arrives back through the normal purchase stream
/// (`PurchaseService._onPurchaseUpdated` → `_deliver()`), exactly like a
/// paid purchase or a restore. That is the entire security fix: there is no
/// path in the client that grants Pro from a value it parsed itself.
///
/// [PromoConfig] needs a new `code` field (the actual Play Store promo code
/// string) — it currently only carries display copy and a grant type/expiry
/// used for the local grant this round removes. Populate `code` from the
/// same remote config source.
void showPromoCodeSheet(BuildContext context, WidgetRef ref) {
  final promo = ref.read(promoConfigProvider);
  if (promo == null) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      // TODO(promo-code): replace with promo.code once PromoConfig carries it.
      final code = promo.code ?? 'KUBERPRO2026';

      return KuberBottomSheet(
        title: 'Get Kuber Pro',
        subtitle: 'Promo code',
        actions: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final uri = Uri.parse(
                    'https://play.google.com/redeem?code=$code',
                  );
                  final launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  if (!launched && context.mounted) {
                    showPlayStoreUnavailableSnackbar(context);
                  }
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                ),
                child: Text(
                  'Open Play Store',
                  style: localeFont(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  // Refreshes entitlement from Play; a redeemed code lands
                  // on the purchase stream and re-grants Pro there. This
                  // call only asks Play to re-report — it never grants
                  // anything itself.
                  await ref.read(purchaseServiceProvider).restorePurchases();
                  if (!context.mounted) return;
                  final current = ref.read(kuberProStateProvider);
                  showKuberSnackBar(
                    context,
                    current.isPro
                        ? 'Kuber Pro unlocked'
                        : "Didn't find a redeemed code yet",
                    isError: !current.isPro,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cs.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                ),
                child: Text(
                  "I've already redeemed",
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Redeem this promo code in Play Store to unlock Kuber Pro.',
              style: localeFont(
                fontSize: 13.5,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
            InkWell(
              borderRadius: BorderRadius.circular(KuberRadius.md),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: code));
                if (context.mounted) {
                  showKuberSnackBar(context, 'Code copied');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                  vertical: KuberSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        code,
                        style: localeFont(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.copy_rounded, size: 18, color: cs.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
