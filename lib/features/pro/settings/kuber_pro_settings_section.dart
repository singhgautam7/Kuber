import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../../settings/widgets/settings_section.dart' show SettingsTile;
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

    // Board 3.11: the Pro card leads Settings (no section label), then the
    // two purchase utilities as one grouped list.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The identity card depends on resolved entitlement state; show a
        // skeleton until the Pro bootstrap completes. The action rows below
        // are static and render immediately regardless.
        if (bootstrapLoading)
          const KuberProSettingsCardSkeleton()
        else
          KuberGroup(
            children: [
              KuberListRow(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: KuberShape.mediumR,
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: cs.onPrimary,
                    size: 20,
                  ),
                ),
                title: _title(proState),
                subtitle: _subtitle(proState),
                subtitleLines: 2,
                trailing: const KuberChevron(),
                onTap: () => context.push('/pro'),
              ),
            ],
          ),
        const SizedBox(height: KuberSpace.md),
        KuberGroup(
          children: [
            SettingsTile(
              icon: Icons.redeem_rounded,
              label: 'Redeem promo code',
              trailing: const KuberChevron(),
              onTap: () => showRedeemPromoCodeSheet(context, ref),
            ),
            // Recover a purchase Play knows about but this install forgot
            // (e.g. after a reinstall). Reads entitlement after the query and
            // reports the outcome via a snackbar.
            SettingsTile(
              icon: Icons.restore_rounded,
              label: 'Restore purchases',
              trailing: const KuberChevron(),
              onTap: () => restorePurchases(context, ref),
            ),
          ],
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
