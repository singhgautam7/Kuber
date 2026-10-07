import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../paywall/pro_state.dart';

/// Slim Kuber Pro strip (board 3.7, both More layouts): icon + "Kuber Pro"
/// on the left, the state on the right ("Upgrade" for free users, days left
/// on a trial, "Active" / "Promo" otherwise).
class MorePremiumHeroCard extends ConsumerWidget {
  const MorePremiumHeroCard({super.key});

  static String _status(KuberProState s) {
    if (s.inTrialPhase) return '${s.trialDaysLeft}d left';
    if (s.source == ProSource.purchased) return 'Active';
    if (s.source == ProSource.promo) return 'Promo';
    return 'Upgrade';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final proState = ref.watch(kuberProStateProvider);
    final fg = cs.onSecondaryContainer;
    return Material(
      color: cs.secondaryContainer,
      shape: const RoundedRectangleBorder(borderRadius: KuberShape.largeR),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/pro'),
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Row(
              children: [
                Icon(Icons.workspace_premium_outlined, size: 22, color: fg),
                const SizedBox(width: KuberSpace.md),
                Expanded(
                  child: Text(
                    'Kuber Pro',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium!.copyWith(color: fg),
                  ),
                ),
                Text(
                  _status(proState),
                  style: theme.textTheme.titleMedium!.copyWith(color: fg),
                ),
                const SizedBox(width: KuberSpace.xs),
                Icon(Icons.chevron_right_rounded, size: 22, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
