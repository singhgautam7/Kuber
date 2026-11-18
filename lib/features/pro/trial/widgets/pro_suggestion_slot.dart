import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../paywall/pro_state.dart';
import '../trial_checklist.dart';
import '../trial_state.dart';
import '../trial_suggestions.dart';
import 'pro_suggestion_card.dart';

export '../trial_suggestions.dart' show ProSuggestionPlace;

/// One place a trial card can appear. Drop it where the card goes (Home under
/// the balance card, top of History / Analytics / More). It renders nothing
/// (SizedBox.shrink) for Pro users, outside a trial, or when no rule allows a
/// card: at most one card per screen and one new card per day.
class ProSuggestionSlot extends ConsumerStatefulWidget {
  const ProSuggestionSlot({super.key, required this.place});
  final ProSuggestionPlace place;

  @override
  ConsumerState<ProSuggestionSlot> createState() => _ProSuggestionSlotState();
}

class _ProSuggestionSlotState extends ConsumerState<ProSuggestionSlot> {
  SlotContent? _shown;

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(kuberProStateProvider.select((s) => s.isPro));
    final trial = ref.watch(proTrialProvider);
    final tried = ref.watch(triedFeaturesProvider);
    final state = ref.watch(trialSuggestionsProvider);
    final now = resolveSlot(
      place: widget.place,
      isPro: isPro,
      trial: trial,
      tried: tried,
      state: state,
      sheetShownThisSession: TrialSession.sheetShown,
    );

    if (now is SlotSuggestion && state.dayKey != trialDayKey(trial.now)) {
      final key = trialDayKey(trial.now);
      Future.microtask(() {
        if (mounted) ref.read(trialSuggestionsProvider.notifier).commitDay(key, now.feature);
      });
    }

    if (now == null && _shown == null) return const SizedBox.shrink();
    final shown = now ?? _shown!;
    if (now != null) _shown = now;

    return KuberAnimatedListItem(
      key: ValueKey(shown.id),
      animateIn: true,
      present: now != null,
      onRemoved: () {
        if (mounted) setState(() => _shown = null);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: KuberSpace.md),
        child: switch (shown) {
          SlotReminder(:final last) => TrialReminderCard(last: last),
          SlotSuggestion(:final feature) => ProSuggestionCard(feature: feature),
        },
      ),
    );
  }
}
