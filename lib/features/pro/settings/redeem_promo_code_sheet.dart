import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../purchase_states/purchase_failure_snackbar.dart';

/// "Redeem promo code" row in Settings > Kuber Pro. Google Play promo codes
/// are validated by Play itself, not by Kuber, so this only needs to collect
/// the code (for the user's own reference) and hand off to Play's native
/// redemption page. No in-app validation.
void showRedeemPromoCodeSheet(BuildContext context) {
  final controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return KuberBottomSheet(
        title: 'Redeem promo code',
        subtitle: 'Google Play',
        actions: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final code = controller.text.trim();
              final uri = Uri.parse(
                code.isEmpty
                    ? 'https://play.google.com/redeem'
                    : 'https://play.google.com/redeem?code=$code',
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
              'Redeem',
              style: localeFont(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your code and continue. Google Play handles "
              "redemption, Kuber just opens the right page.",
              style: localeFont(
                fontSize: 13.5,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              style: localeFont(fontSize: 15, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Promo code',
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  borderSide: BorderSide(color: cs.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  borderSide: BorderSide(color: cs.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
