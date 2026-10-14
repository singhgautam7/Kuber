import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../home_v2/data/tracking_choices.dart';
import '../widgets/onboarding_fit.dart';
import '../widgets/onboarding_skip_button.dart';

/// "What do you want to track?" (home-v3 board HV3.2, chips per v3.1).
/// Multi-select; Continue is enabled after the first pick (the nav bar);
/// Skip moves on without saving picks.
class OnboardingTrackingPage extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onSkip;

  const OnboardingTrackingPage({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        OnboardingSkipButton(onSkip: onSkip),
        Expanded(
          child: OnboardingFit(
            child: TrackingChips(
              selected: selected,
              onToggle: onToggle,
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.homeV3TrkTitle,
                    style: tt.headlineLarge!.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: KuberSpace.md),
                  Text(
                    l.homeV3TrkBody,
                    style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: KuberSpace.xl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The five filter chips, shared with Edit widgets › What you track.
class TrackingChips extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final Widget? header;

  const TrackingChips({
    super.key,
    required this.selected,
    required this.onToggle,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ?header,
        Wrap(
          spacing: KuberSpace.sm,
          runSpacing: KuberSpace.sm,
          children: [
            for (final key in kTrackingChoices)
              FilterChip(
                label: Text(trackingLabel(l, key)),
                selected: selected.contains(key),
                onSelected: (_) => onToggle(key),
              ),
          ],
        ),
      ],
    );
  }
}
