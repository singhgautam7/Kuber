import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../purchase_states/restore_purchases_flow.dart';
import '../paywall/billing_ui_state.dart';
import '../paywall/pro_state.dart';
import 'kuber_pro_section_loading.dart';
import 'redeem_promo_code_sheet.dart';

/// New "Kuber Pro" section at the top of Settings, above every existing
/// section. Renders one of 4 card looks depending on entitlement, always
/// followed by the "Redeem promo code" row.
class KuberProSettingsSection extends ConsumerWidget {
  const KuberProSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final proState = ref.watch(kuberProStateProvider);
    final bootstrapLoading = ref.watch(proBootstrapLoadingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: KuberSpacing.xs),
          child: Text(
            'KUBER PRO',
            style: localeFont(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: cs.primary,
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        // The identity card depends on resolved entitlement state; show a
        // skeleton until the Pro bootstrap completes. The action rows below
        // are static and render immediately regardless.
        if (bootstrapLoading)
          const KuberProSettingsCardSkeleton()
        else
          InkWell(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          onTap: () => context.push('/pro'),
          child: Container(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title(proState),
                        style: localeFont(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(proState),
                        style: localeFont(
                          fontSize: 12,
                          color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onPrimaryContainer.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        _ProActionRow(
          icon: Icons.redeem_rounded,
          label: 'Redeem promo code',
          onTap: () => showRedeemPromoCodeSheet(context),
        ),
        const SizedBox(height: KuberSpacing.sm),
        // Recover a purchase Play knows about but this install forgot (e.g.
        // after a reinstall). Reads entitlement after the query and reports
        // the outcome via a snackbar.
        _ProActionRow(
          icon: Icons.restore_rounded,
          label: 'Restore purchases',
          onTap: () => restorePurchases(context, ref),
        ),
      ],
    );
  }

  String _title(KuberProState s) {
    // Covers both a legacy app trial and a Play Billing subscription in its
    // free-trial phase.
    if (s.inTrialPhase) return 'Kuber Pro trial · ${s.trialDaysLeft} days left';
    if (s.source == ProSource.purchased) return 'Kuber Pro active';
    if (s.source == ProSource.promo) return 'Kuber Pro (promo)';
    return 'Try Kuber Pro';
  }

  String _subtitle(KuberProState s) {
    if (s.inTrialPhase) {
      // A Play trial is a real subscription that just hasn't charged yet; a
      // legacy trial is unpaid and needs a plan chosen.
      return s.isPro
          ? 'Your plan begins when the free trial ends'
          : 'Tap to see plans before it ends';
    }
    if (s.source == ProSource.purchased) {
      final plan = switch (s.plan) {
        ProPlan.monthly => 'Monthly',
        ProPlan.yearly => 'Yearly',
        ProPlan.lifetime => 'Lifetime',
        null => 'Pro',
      };
      if (s.plan == ProPlan.yearly && s.expiryDate != null) {
        return '$plan · renews ${_shortDate(s.expiryDate!)}';
      }
      return plan;
    }
    if (s.source == ProSource.promo) {
      return s.promoEndsAt == null
          ? 'Free lifetime · Thanks!'
          : 'Free until ${_shortDate(s.promoEndsAt!)}';
    }
    return 'Unlock every feature, no account needed';
  }

  String _shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

/// Bordered tap row used for the "Redeem promo code" / "Restore purchases"
/// actions under the Pro card.
class _ProActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Text(
                label,
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
