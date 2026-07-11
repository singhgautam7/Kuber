import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../paywall/pro_state.dart';

/// Small persistent pill for the Home tab's top-right area. Muted while
/// mid-trial, turns amber in the last 3 days. Disappears entirely once the
/// trial has ended (renders nothing — the caller doesn't need to branch).
class TrialPillIndicator extends ConsumerWidget {
  const TrialPillIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proState = ref.watch(kuberProStateProvider);
    if (!proState.inTrialPhase) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final ending = proState.trialEndingSoon;
    final warn = context.kuberColors.warning;
    final warnSubtle = context.kuberColors.warningSubtle;

    return InkWell(
      onTap: () => context.push('/pro'),
      borderRadius: BorderRadius.circular(KuberRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: ending ? warnSubtle : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.full),
          border: Border.all(
            color: ending ? warn.withValues(alpha: 0.4) : cs.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 12,
              color: ending ? warn : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Text(
              'TRIAL · ${proState.trialDaysLeft} ${proState.trialDaysLeft == 1 ? 'day' : 'days'}',
              style: localeFont(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: ending ? warn : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
