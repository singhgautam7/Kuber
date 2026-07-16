import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import 'pro_state.dart';

/// Top-of-screen banner shown on the paywall while the user is mid-trial.
/// Muted, not a hard sell, since they already have access.
class PaywallTrialBanner extends StatelessWidget {
  final KuberProState proState;
  const PaywallTrialBanner({super.key, required this.proState});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
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
          Icon(Icons.workspace_premium_rounded, size: 18, color: cs.primary),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Text(
              "You're on your Kuber Pro trial · "
              "${proState.trialDaysLeft} ${proState.trialDaysLeft == 1 ? 'day' : 'days'} left",
              style: localeFont(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
