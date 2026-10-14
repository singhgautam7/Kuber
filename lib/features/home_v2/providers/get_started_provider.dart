import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/home_v2_state.dart';
import 'home_v2_provider.dart';

/// Get started card states (suggestion-rules.md §2). Two steps since
/// Home v3.3: SMS import has its own intro card (after Quick Add), so the
/// SMS step, its permission states and the free-limit tile are gone.
enum GsState { fresh, oneDone }

class GsData {
  /// Add a transaction yourself (manual or Quick Add). Second on the card.
  final bool step2;

  /// Set up accounts: Accounts opened (or a balance set). First on the card.
  final bool step3;
  final int txCount;
  final GsState state;

  const GsData({
    required this.step2,
    required this.step3,
    required this.txCount,
    required this.state,
  });

  int get done => [step2, step3].where((x) => x).length;
  bool get allDone => done == 2;
}

/// Step flags from the transactions already in memory for the Balance card.
({bool sms, bool manual, bool adjusted}) gsStepsFrom(List<Transaction> txns) {
  var sms = false, manual = false, adjusted = false;
  for (final t in txns) {
    if (t.isBalanceAdjustment) {
      adjusted = true;
    } else if (t.importSource == 'sms') {
      sms = true;
    } else if (t.importSource == 'quick_add' ||
        (t.importSource == null &&
            t.linkedRuleId == null &&
            t.linkedRuleType == null &&
            t.sourceNoteId == null)) {
      manual = true;
    }
    if (sms && manual && adjusted) break;
  }
  return (sms: sms, manual: manual, adjusted: adjusted);
}

/// Graduation (suggestion-rules.md §2), other than `dismissed` which the
/// card's Close sets. Pure, so it is unit-tested.
GsGraduation? gsGraduationFor(
  GsData d, {
  required DateTime? firstShownAt,
  required DateTime now,
}) {
  if (d.allDone) return GsGraduation.completed;
  if (d.txCount >= 10) return GsGraduation.transactions;
  if (firstShownAt != null &&
      now.difference(firstShownAt) >= const Duration(days: 14) &&
      d.txCount >= 1) {
    return GsGraduation.timeout;
  }
  return null;
}

/// Bumped after returning from Add transaction / the account editor so the
/// steps are read again.
final gsRefreshProvider = StateProvider<int>((ref) => 0);

/// Get started data. Null (and no work at all) unless the card is eligible:
/// v1, graduated and switched-off installs never run this.
final getStartedProvider = FutureProvider<GsData?>((ref) async {
  final eligible = ref.watch(homeV2Provider.select((s) => s.gsEligible));
  if (!eligible) return null;
  ref.watch(gsRefreshProvider);
  final balanceSet = ref.watch(homeV2Provider.select((s) => s.balanceSet));
  final txns = await ref.watch(transactionListProvider.future);
  final steps = gsStepsFrom(txns);
  final step2 = steps.manual;
  final step3 = balanceSet || steps.adjusted;
  final done = [step2, step3].where((x) => x).length;
  return GsData(
    step2: step2,
    step3: step3,
    txCount: txns.length,
    state: done == 0 ? GsState.fresh : GsState.oneDone,
  );
});
