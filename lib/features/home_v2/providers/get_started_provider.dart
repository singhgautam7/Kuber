import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../pro/paywall/pro_state.dart';
import '../../sms_import/data/sms_import_usage.dart';
import '../../sms_import/providers/sms_import_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/home_v2_state.dart';
import 'home_v2_provider.dart';

/// Get started card states (suggestion-rules.md §2 State resolution).
enum GsState { fresh, oneDone, twoDone, denied, blocked }

class GsData {
  final bool step1;
  final bool step2;
  final bool step3;
  final int txCount;
  final GsState state;

  /// Free weekly SMS allowance used up while bank SMS wait (limit tile).
  final bool limit;
  final int staged;
  final DateTime? resetDate;
  final bool smsGranted;

  const GsData({
    required this.step1,
    required this.step2,
    required this.step3,
    required this.txCount,
    required this.state,
    this.limit = false,
    this.staged = 0,
    this.resetDate,
    this.smsGranted = false,
  });

  int get done => [step1, step2, step3].where((x) => x).length;
  bool get allDone => done == 3;
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

/// Bumped after returning from SMS import / phone settings so permission
/// and staged counts are read again.
final gsRefreshProvider = StateProvider<int>((ref) => 0);

/// Get started data. Null (and no work at all) unless the card is eligible:
/// v1, graduated and switched-off installs never run this.
final getStartedProvider = FutureProvider<GsData?>((ref) async {
  final eligible = ref.watch(homeV2Provider.select((s) => s.gsEligible));
  if (!eligible) return null;
  ref.watch(gsRefreshProvider);
  final balanceSet = ref.watch(homeV2Provider.select((s) => s.balanceSet));
  final smsRequested = ref.watch(
    homeV2Provider.select((s) => s.smsRequested),
  );
  final hasPro = ref.watch(
    kuberProStateProvider.select((s) => s.hasProAccess),
  );
  final txns = await ref.watch(transactionListProvider.future);
  final steps = gsStepsFrom(txns);
  final step1 = steps.sms;
  final step2 = steps.manual;
  final step3 = balanceSet || steps.adjusted;

  var granted = false;
  var permanentlyDenied = false;
  if (ref.read(smsInboxServiceProvider).isSupported) {
    final status = await Permission.sms.status;
    granted = status.isGranted;
    permanentlyDenied = status.isPermanentlyDenied;
  }
  final staged = await ref.read(smsImportRepositoryProvider).countUnreviewed();
  final remaining = hasPro ? 1 : await SmsImportUsage.remainingThisWeek();
  final reset = await SmsImportUsage.resetDate();

  final done = [step1, step2, step3].where((x) => x).length;
  final GsState state;
  if (!step1 && permanentlyDenied) {
    state = GsState.blocked;
  } else if (!step1 && !granted && smsRequested) {
    state = GsState.denied;
  } else {
    state = switch (done) {
      0 => GsState.fresh,
      1 => GsState.oneDone,
      _ => GsState.twoDone,
    };
  }
  return GsData(
    step1: step1,
    step2: step2,
    step3: step3,
    txCount: txns.length,
    state: state,
    limit: !hasPro && remaining == 0 && staged > 0,
    staged: staged,
    resetDate: reset,
    smsGranted: granted,
  );
});
