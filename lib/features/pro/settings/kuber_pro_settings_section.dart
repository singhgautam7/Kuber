import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../paywall/billing_ui_state.dart';
import '../paywall/pro_state.dart';
import 'kuber_pro_section_loading.dart';

/// Top of Settings (Components 2m): primaryContainer, 48 tile, the plan as a
/// pill once there is one.
class KuberProCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? pill;
  final String subtitle;
  final VoidCallback onTap;

  const KuberProCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.pill,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.primaryContainer,
      borderRadius: KuberShape.cardR,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        overlayColor: kuberPressedLayer(cs),
        child: Padding(
          padding: const EdgeInsets.all(KuberSpace.lg),
          child: Row(
            children: [
              KuberIconTile(
                icon: icon,
                size: 48,
                glyph: 24,
                radius: 14,
                color: cs.primary,
                iconColor: cs.onPrimary,
              ),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: KuberSpace.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium!.copyWith(color: cs.onPrimaryContainer)),
                        if (pill != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: KuberSpace.sm),
                            decoration: BoxDecoration(color: cs.primary, borderRadius: KuberShape.fullR),
                            child: Text(pill!, style: theme.textTheme.labelSmall!.copyWith(color: cs.onPrimary)),
                          ),
                      ],
                    ),
                    Text(subtitle, style: theme.textTheme.bodyMedium!.copyWith(color: cs.onPrimaryContainer)),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpace.lg),
              Icon(Icons.chevron_right_rounded, size: 20, color: cs.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Kuber Pro" at the top of Settings. Redeem and Restore live on the Pro page.
class KuberProSettingsSection extends ConsumerWidget {
  const KuberProSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(kuberProStateProvider);
    // Depends on resolved entitlement state; a skeleton until the Pro
    // bootstrap completes.
    if (ref.watch(proBootstrapLoadingProvider)) return const KuberProSettingsCardSkeleton();
    final purchased = s.source == ProSource.purchased;
    final promo = s.source == ProSource.promo;
    String since() => s.activatedAt == null
        ? ''
        : DateFormat('d MMM y', l.localeName).format(s.activatedAt!);
    final renewal = purchased ? s.renewalLabel() : null;
    return KuberProCard(
      icon: purchased || promo ? Icons.verified_rounded : Icons.workspace_premium_rounded,
      title: purchased || promo ? 'Kuber Pro' : l.proCardTry,
      pill: purchased
          ? switch (s.plan) {
              ProPlan.monthly => l.proCardMonthly,
              ProPlan.yearly => l.proCardYearly,
              ProPlan.lifetime => l.proCardLifetime,
              null => null,
            }
          : promo
              ? l.proCardPromo
              : null,
      subtitle: switch ((purchased, promo)) {
        (true, _) => renewal ?? l.proCardActive(since()),
        (_, true) => s.promoEndsAt == null
            ? l.proCardPromoForever
            : l.proCardPromoUntil(DateFormat('d MMM y', l.localeName).format(s.promoEndsAt!)),
        _ => l.proCardTrySub,
      },
      onTap: () => context.push('/pro'),
    );
  }
}
