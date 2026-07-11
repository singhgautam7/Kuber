import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../paywall/pro_state.dart';

/// Kuber Pro entry point for the More tab, in both layouts.
///
/// Same title/subtitle logic as `KuberProSettingsSection` (Settings screen)
/// so the copy a user sees for "trial / active / promo / free" is identical
/// wherever they run into it. Both variants route to `/pro` (the paywall).
///
/// - [MorePremiumHeroCard] — Modern layout. Matches the `_HeroTile` look
///   used for Accounts: full-bleed gradient card, eyebrow + big title.
///   Mount above "01 / MANAGE".
/// - [MorePremiumCardClassic] — Simple layout. Matches the identity card
///   from `KuberProSettingsSection`: bordered `primaryContainer` row with
///   icon chip + two text lines. Mount above the first `_MenuSection`.
String _title(KuberProState s) {
  if (s.inTrialPhase) return 'Kuber Pro trial · ${s.trialDaysLeft} days left';
  if (s.source == ProSource.purchased) return 'Kuber Pro active';
  if (s.source == ProSource.promo) return 'Kuber Pro (promo)';
  return 'Try Kuber Pro';
}

String _subtitle(KuberProState s) {
  if (s.inTrialPhase) {
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

class MorePremiumHeroCard extends ConsumerWidget {
  const MorePremiumHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final proState = ref.watch(kuberProStateProvider);
    final accentColor = cs.primary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(KuberRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/pro'),
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: accentColor.withValues(alpha: 0.35)),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.alphaBlend(
                  accentColor.withValues(alpha: 0.22),
                  cs.surfaceContainer,
                ),
                cs.surfaceContainer,
              ],
              stops: const [0.0, 0.75],
            ),
          ),
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(KuberRadius.lg),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 26,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KUBER PRO',
                      style: localeFont(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _title(proState),
                      style: localeFont(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(proState),
                      style: localeFont(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MorePremiumCardClassic extends ConsumerWidget {
  const MorePremiumCardClassic({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final proState = ref.watch(kuberProStateProvider);

    return InkWell(
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
    );
  }
}
