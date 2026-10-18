import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_v2_state.dart';

/// Snapshot read in `_bootstrap` (cohort decided there), overridden in
/// `main.dart`. v1 by default so tests and any un-overridden scope see
/// today's Home.
final homeV2BootProvider = Provider<HomeV2Snapshot>(
  (ref) => HomeV2Snapshot.v1,
);

/// Home v2 state for this install. For v1 it stays [HomeV2Snapshot.v1] and
/// every setter below is a no-op, so existing users never get v2 prefs
/// written or v2 work scheduled.
class HomeV2Notifier extends Notifier<HomeV2Snapshot> {
  @override
  HomeV2Snapshot build() => ref.read(homeV2BootProvider);

  Future<void> _persist() async => (await HomeV2Store.open()).write(state);

  /// Applies [f] to the v2 state and persists it. Ignored for v1.
  Future<void> update(HomeV2Snapshot Function(HomeV2Snapshot s) f) async {
    if (!state.isV2) return;
    state = f(state);
    await _persist();
  }

  /// Replaces the whole snapshot (cohort switches: restore, Dev tools).
  Future<void> replace(HomeV2Snapshot s) async {
    state = s;
    final store = await HomeV2Store.open();
    if (s.isV2) {
      await store.write(s);
    } else {
      await store.writeCohort(HomeCohort.v1);
    }
  }

  /// Get started › Set up accounts: Accounts opened, or a balance set.
  Future<void> markBalanceSet() async {
    if (state.isV2 && !state.balanceSet) {
      await update((s) => s.copyWith(balanceSet: true));
    }
  }

  Future<void> markSmsRequested() async {
    if (state.isV2 && !state.smsRequested) {
      await update((s) => s.copyWith(smsRequested: true));
    }
  }

  Future<void> markAskOpened() async {
    if (state.isV2 && !state.askOpened) {
      await update((s) => s.copyWith(askOpened: true));
    }
  }

  Future<void> markVoiceUsed() async {
    if (state.isV2 && !state.voiceUsed) {
      await update((s) => s.copyWith(voiceUsed: true));
    }
  }
}

final homeV2Provider = NotifierProvider<HomeV2Notifier, HomeV2Snapshot>(
  HomeV2Notifier.new,
);

final isHomeV2Provider = Provider<bool>(
  (ref) => ref.watch(homeV2Provider.select((s) => s.isV2)),
);

/// Home session counter (suggestion-rules.md Definitions): starts at 1 on
/// cold start and is bumped by `KuberApp` when the app returns to the
/// foreground after at least 30 minutes in the background.
final homeSessionProvider = StateProvider<int>((ref) => 1);
