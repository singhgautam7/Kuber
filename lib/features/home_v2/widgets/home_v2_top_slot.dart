import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart' show onOpenBatchReadyProvider;
import '../providers/has_transactions_provider.dart';
import '../providers/home_suggestion_provider.dart';
import '../providers/home_v2_provider.dart';
import '../../../shared/widgets/app_scaffold.dart'
    show currentShellTabIndexProvider;
import 'get_started_card.dart';
import 'suggestion_card.dart';

/// The one Home v2 top slot between the greeting and the first widget
/// (suggestion-rules.md §1): Get started, its one-time success state, or a
/// suggestion. Only built for the v2 cohort.
class HomeV2TopSlot extends ConsumerStatefulWidget {
  const HomeV2TopSlot({super.key});

  @override
  ConsumerState<HomeV2TopSlot> createState() => _HomeV2TopSlotState();
}

class _HomeV2TopSlotState extends ConsumerState<HomeV2TopSlot> {
  Timer? _successTimer;

  void _resolve({bool force = false}) {
    // Never during Home's first frames: wait for the on-open batch gate.
    if (!ref.read(onOpenBatchReadyProvider)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(homeSuggestionProvider.notifier).resolve(force: force);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    ref.listenManual<bool>(
      onOpenBatchReadyProvider,
      (_, __) => _resolve(),
      fireImmediately: true,
    );
    ref.listenManual<int>(homeSessionProvider, (_, __) => _resolve());
    // Intro cards start at 2 (Quick Add) and 3 (SMS import) transactions:
    // look again when a count crosses one of those.
    ref.listenManual<AsyncValue<int>>(transactionCountProvider, (prev, next) {
      final a = prev?.valueOrNull;
      final b = next.valueOrNull;
      if (a == null || b == null) return;
      if ((a < 2 && b >= 2) || (a < 3 && b >= 3)) _resolve(force: true);
    });
    // Graduation (or the Settings switch) can make suggestions eligible.
    // Forced: the Why Kuber card shows in the same session (normal
    // suggestions still wait 24 h after graduation, so none can slip in).
    ref.listenManual<bool>(homeV2Provider.select((s) => s.gsEligible), (
      _,
      eligible,
    ) {
      if (!eligible) _resolve(force: true);
    });
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gsEligible = ref.watch(homeV2Provider.select((s) => s.gsEligible));
    final successPending = ref.watch(
      homeV2Provider.select(
        (s) => s.gsGraduated && !s.gsSuccessShown && s.isV2,
      ),
    );
    final sg = ref.watch(homeSuggestionProvider);
    // Tabs live in a PageView: an inactive Home tab keeps its tickers on.
    final active =
        ref.watch(currentShellTabIndexProvider.select((i) => i == 0)) &&
        TickerMode.valuesOf(context).enabled;

    // In-card success holds 1600 ms, then the card collapses.
    ref.listen<SuggestionView>(homeSuggestionProvider, (_, next) {
      _successTimer?.cancel();
      if (next.success) {
        _successTimer = Timer(
          const Duration(milliseconds: 1600),
          ref.read(homeSuggestionProvider.notifier).clearSuccess,
        );
      }
    });

    final Widget? card;
    if (gsEligible) {
      card = const GetStartedCard(key: ValueKey('gs'));
    } else if (successPending) {
      card = GetStartedDoneCard(
        key: const ValueKey('gs-done'),
        homeTabShowing: active,
        onDone: () => ref
            .read(homeV2Provider.notifier)
            .update((s) => s.copyWith(gsSuccessShown: true)),
      );
    } else if (sg.card != null) {
      card = SuggestionCard(
        key: ValueKey('sg-${sg.card!.key}'),
        candidate: sg.card!,
        success: sg.success,
      );
    } else {
      card = null;
    }

    // Collapse 230 ms / expand 240 ms easeOutCubic with a 150 ms fade;
    // reduced motion: 90 ms cross-fade (suggestion-rules.md §4).
    // While Home is not showing, swap with no transition.
    final instant = !active;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedSize(
      duration: Duration(milliseconds: instant ? 0 : (reduced ? 90 : 240)),
      reverseDuration: Duration(
        milliseconds: instant ? 0 : (reduced ? 90 : 230),
      ),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: instant ? 0 : (reduced ? 90 : 150)),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        child: card == null
            ? const SizedBox(width: double.infinity, key: ValueKey('empty'))
            : Padding(
                key: card.key,
                padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
                child: card,
              ),
      ),
    );
  }
}
