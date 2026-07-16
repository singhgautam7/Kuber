import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';
import '../paywall/billing_ui_state.dart';
import '../paywall/pro_state.dart';

/// Replaces the "Ask Kuber" pill in [HomeHeader] (Home tab only — every other
/// screen keeps `KuberAppBar` unchanged). Ask Kuber gets its own dedicated
/// home widget now (`AskKuberHomeWidget`), so the header's scarce real estate
/// goes to surfacing Pro status instead. Always taps through to `/pro`; the
/// paywall itself decides free vs trial vs status view.
///
/// Placement per review: sits at the extreme left of the header row (first
/// child), with the privacy-mode toggle and notification bell pushed to the
/// right — `Row(children: [PremiumHomeButton(), Spacer(), _PrivacyToggle(),
/// _NotificationBell()])` in `home_header.dart`. Previously "Ask Kuber" sat
/// between those two icons on the right; that slot is retired along with
/// the pill itself.
class PremiumHomeButton extends ConsumerWidget {
  const PremiumHomeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // While entitlement is still resolving on cold start, show a pill-shaped
    // loader instead of guessing a tier (which would flash "Kuber Pro" at a
    // user who actually has Pro).
    if (ref.watch(proBootstrapLoadingProvider)) {
      return const KuberSkeleton(
        width: 96,
        height: 32,
        borderRadius: KuberRadius.md,
      );
    }

    final proState = ref.watch(kuberProStateProvider);

    // A trial (legacy app trial OR a Play Billing subscription in its
    // free-trial phase) shows the countdown; otherwise Pro vs the upsell label.
    final String label;
    final bool amber;
    if (proState.inTrialPhase) {
      label = 'TRIAL · ${proState.trialDaysLeft}d';
      amber = proState.trialEndingSoon;
    } else if (proState.isPro) {
      label = 'PRO';
      amber = false;
    } else {
      label = 'Kuber Pro';
      amber = false;
    }

    final tint = amber ? context.kuberColors.warning : cs.primary;
    final tintSubtle = amber
        ? context.kuberColors.warningSubtle
        : cs.primary.withValues(alpha: 0.10);

    return GestureDetector(
      onTap: () => context.push('/pro'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: tint.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(shape: BoxShape.circle, color: tintSubtle),
              child: Icon(Icons.workspace_premium_rounded, size: 12, color: tint),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: localeFont(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: proState.inTrialPhase ? 0.3 : 0,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
