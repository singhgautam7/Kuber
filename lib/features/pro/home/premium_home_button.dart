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

  /// Skeleton -> badge (and label changes) cross-fade instead of popping in.
  static Widget _fade(Widget child) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // While entitlement is still resolving on cold start, show a pill-shaped
    // loader instead of guessing a tier (which would flash "Kuber Pro" at a
    // user who actually has Pro).
    if (ref.watch(proBootstrapLoadingProvider)) {
      return _fade(
        const KuberSkeleton(
          key: ValueKey('pro-skeleton'),
          width: 96,
          height: 32,
          borderRadius: KuberShape.full,
        ),
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

    // Board 3.2d: 32 pill, primaryContainer, workspace_premium + labelLarge.
    // Trial ending soon swaps to the warning container.
    final bg = amber
        ? context.kuberMoney.warningContainer
        : cs.primaryContainer;
    final fg = amber
        ? context.kuberMoney.onWarningContainer
        : cs.onPrimaryContainer;

    return _fade(Semantics(
      key: ValueKey(label),
      button: true,
      label: label,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/pro'),
          child: Container(
            height: 32,
            padding: const EdgeInsets.only(left: 8, right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded, size: 18, color: fg),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: label == 'Kuber Pro' ? 0.1 : 0.8,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
