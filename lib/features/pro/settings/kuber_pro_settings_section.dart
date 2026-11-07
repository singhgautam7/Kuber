import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../paywall/billing_ui_state.dart';
import '../paywall/pro_state.dart';
import 'kuber_pro_section_loading.dart';

/// "Kuber Pro" row at the top of Settings. Renders one of 4 card looks
/// depending on entitlement. Redeem and Restore live on the Pro page.
class KuberProSettingsSection extends ConsumerWidget {
  const KuberProSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final proState = ref.watch(kuberProStateProvider);
    final bootstrapLoading = ref.watch(proBootstrapLoadingProvider);

    // Board 3.11: the Pro card leads Settings (no section label).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The identity card depends on resolved entitlement state; show a
        // skeleton until the Pro bootstrap completes.
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
      ],
    );
  }

  String _title(KuberProState s) {
    if (s.source == ProSource.purchased) return 'Kuber Pro active';
    if (s.source == ProSource.promo) return 'Kuber Pro (promo)';
    return 'Try Kuber Pro';
  }

  String _subtitle(KuberProState s) {
    if (s.source == ProSource.purchased) {
      final plan = switch (s.plan) {
        ProPlan.monthly => 'Monthly',
        ProPlan.yearly => 'Yearly',
        ProPlan.lifetime => 'Lifetime',
        null => 'Pro',
      };
      final renewal = s.renewalLabel();
      return renewal == null ? plan : '$plan · ${renewal[0].toLowerCase()}${renewal.substring(1)}';
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
