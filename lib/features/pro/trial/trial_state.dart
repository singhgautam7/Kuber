// v7.0.0-b app-managed 14-day Pro trial: the public contract.
//
// CONTRACT FILE (specs/v7.0.0-b/plan.md): the B-core owner implements the
// notifier body; the public names and shapes below are what the trial UI
// (B-UI) and the main agent's wiring compile against. Do not rename.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart';
import '../data/user_entitlement.dart';
import '../debug/trial_debug.dart';
import '../paywall/pro_state.dart';
import 'trial_reminders.dart';
import 'trial_store.dart';

/// Length of the trial: 14 x 24 hours from the start (B1).
const Duration kTrialLength = Duration(days: 14);

enum TrialStatus {
  /// No trial record anywhere (row, Block Store, backup).
  none,

  /// A valid record whose end is still ahead of max(now, high-water mark).
  active,

  /// A record exists and its time is used up, or the record failed its
  /// signature check (fail closed: counts as used).
  ended,
}

/// What [proTrialProvider.notifier].claim / startAfterSetup did.
enum TrialStartOutcome {
  /// A fresh trial started now (show the "trial started" sheet).
  started,

  /// A record already existed with days left (show "trial continues").
  continued,

  /// A record existed and is used up, or is invalid ("already used").
  alreadyUsed,

  /// The user has paid / promo Pro right now: nothing happens, no UI.
  notEligible,
}

class TrialInfo {
  final TrialStatus status;
  final DateTime? startAt;

  /// startAt + [kTrialLength]. Pro stops at this instant.
  final DateTime? endAt;

  /// The "now" used for every count: max(clock, high-water mark).
  final DateTime now;

  /// True when a claim would start a trial: not Pro, no record in the row,
  /// none in Block Store. False until Block Store has been read.
  final bool eligible;

  /// The ended sheet has already been shown once.
  final bool endedNoticeShown;

  const TrialInfo({
    required this.status,
    required this.now,
    this.startAt,
    this.endAt,
    this.eligible = false,
    this.endedNoticeShown = false,
  });

  static TrialInfo none(DateTime now) => TrialInfo(status: TrialStatus.none, now: now);

  bool get isActive => status == TrialStatus.active;
  bool get isEnded => status == TrialStatus.ended;

  /// Day of the trial by local calendar date, 1 = start day (handoff: badge
  /// "N days left" = 15 - day). Access itself ends at [endAt] (start + 14 x
  /// 24 h, i.e. on day 15 at the start time), so day 15 still counts as the
  /// last day until then. 0 when not active.
  int get day {
    if (!isActive || startAt == null) return 0;
    final s = startAt!.toLocal();
    final n = now.toLocal();
    final d = DateTime(n.year, n.month, n.day).difference(DateTime(s.year, s.month, s.day)).inHours;
    return ((d / 24).round() + 1).clamp(1, 15);
  }

  /// 1..14 while active ("N days left"), 0 otherwise.
  int get daysLeft => isActive ? (15 - day).clamp(1, 14) : 0;

  /// Day 14 or the remaining hours of day 15 ("Pro trial · last day").
  bool get isLastDay => isActive && day >= 14;
}

final trialStoreProvider = Provider<TrialStore>((ref) => TrialStore(ref.read(isarProvider)));

final trialReminderSchedulerProvider =
    Provider<TrialReminderScheduler>((ref) => NotificationTrialReminders());

/// Reactive trial state. The row is the source of truth for gating (read
/// synchronously); [reconcile] verifies signatures and merges Block Store.
final proTrialProvider =
    NotifierProvider<ProTrialNotifier, TrialInfo>(ProTrialNotifier.new);

class ProTrialNotifier extends Notifier<TrialInfo> {
  Timer? _timer;

  /// Block Store has been read (or failed to be) at least once.
  bool _blockChecked = false;

  Isar get _isar => ref.read(isarProvider);
  TrialStore get _store => ref.read(trialStoreProvider);
  DateTime _clock() => ref.read(trialClockProvider)();
  UserEntitlement? _row() => _isar.collection<UserEntitlement>().getSync(0);

  @override
  TrialInfo build() {
    ref.onDispose(() => _timer?.cancel());
    ref.listen(kuberProStateProvider.select((s) => s.isPro), (_, isPro) {
      if (isPro) ref.read(trialReminderSchedulerProvider).cancel();
      _publish();
    });
    return _compute();
  }

  TrialInfo _compute() {
    final row = _row();
    var now = _clock();
    final hwm = row?.trialHighWaterAt;
    if (hwm != null && hwm.isAfter(now)) now = hwm;
    final rec = rowRecord(row);
    final invalid = row?.trialInvalidSeen ?? false;
    final notice = row?.proTrialEndedNoticeShown ?? false;
    if (rec == null) {
      return TrialInfo(
        status: invalid ? TrialStatus.ended : TrialStatus.none,
        now: now,
        eligible: _blockChecked && !invalid && !ref.read(kuberProStateProvider).isPro,
        endedNoticeShown: notice,
      );
    }
    final end = rec.start.add(kTrialLength);
    return TrialInfo(
      status: now.isBefore(end) && !invalid ? TrialStatus.active : TrialStatus.ended,
      now: now,
      startAt: rec.start,
      endAt: end,
      endedNoticeShown: notice,
    );
  }

  void _publish() {
    final next = _compute();
    _timer?.cancel();
    _timer = null;
    if (next.isActive) {
      final left = next.endAt!.difference(next.now) + const Duration(seconds: 1);
      _timer = Timer(left, () => evaluate());
    }
    state = next;
  }

  /// Raises the clock guard, flips the tier when the trial started / ended and
  /// republishes. Cheap and safe to call on open, on resume and from the timer.
  Future<void> evaluate() async {
    final now = _store.touchHighWater(_clock());
    final row = _row();
    if (row != null) {
      final granting = stateFromEntitlementRow(row, now: now).isPro;
      if (!granting) {
        final rec = rowRecord(row);
        final active = rec != null && !row.trialInvalidSeen && now.isBefore(rec.start.add(kTrialLength));
        final want = active ? EntitlementTier.proTrial : (row.tier == EntitlementTier.proTrial ? EntitlementTier.free : null);
        if (want != null && row.tier != want) {
          await _isar.writeTxn(() async {
            final r = await _isar.collection<UserEntitlement>().get(0);
            if (r == null) return;
            r.tier = want;
            await _isar.collection<UserEntitlement>().put(r);
          });
        }
      }
    }
    ref.read(kuberProStateProvider.notifier).refreshFromRow();
    _publish();
  }

  /// A paid / promo entitlement changed (purchase, restore, lapse).
  void onEntitlementChanged() {
    if (ref.read(kuberProStateProvider).isPro) ref.read(trialReminderSchedulerProvider).cancel();
    _publish();
  }

  /// Reads row + Block Store (+ [backupBlock]), writes the earliest valid
  /// record back to the row and Block Store where missing, updates the clock
  /// guard and reschedules reminders. Safe to call repeatedly.
  Future<TrialResolution> reconcile({Object? backupBlock}) async {
    final res = await _store.resolve(backupBlock: backupBlock);
    _blockChecked = true;
    if (res.anyRecord || rowRecord(_row()) != null) await _store.persistResolution(res);
    await evaluate();
    await _reschedule();
    return res;
  }

  Future<void> _reschedule() async {
    final reminders = ref.read(trialReminderSchedulerProvider);
    if (state.isActive && !ref.read(kuberProStateProvider).isPro) {
      await reminders.schedule(state.startAt!);
    } else {
      await reminders.cancel();
    }
  }

  Future<TrialStartOutcome> _begin(Object? backup) async {
    if (ref.read(kuberProStateProvider).isPro) return TrialStartOutcome.notEligible;
    final res = await reconcile(backupBlock: backup);
    if (res.record != null) return state.isActive ? TrialStartOutcome.continued : TrialStartOutcome.alreadyUsed;
    if (res.invalid) return TrialStartOutcome.alreadyUsed;
    final now = _store.touchHighWater(_clock());
    await _store.persist(await _store.create(now));
    await evaluate();
    await _reschedule();
    return TrialStartOutcome.started;
  }

  /// Existing free user taps "Claim 14 days of Pro, free".
  Future<TrialStartOutcome> claim() => _begin(null);

  /// End of Welcome / setup. [backupTrialBlock] is the trial block of the
  /// backup restored during setup, if any. A non-null block without a valid
  /// signed record counts as "used".
  Future<TrialStartOutcome> startAfterSetup({Map<String, dynamic>? backupTrialBlock}) =>
      _begin(backupTrialBlock);

  /// The ended sheet was shown; never show it again.
  Future<void> markEndedNoticeShown() async {
    await _isar.writeTxn(() async {
      final r = await _isar.collection<UserEntitlement>().get(0);
      if (r == null) return;
      r.proTrialEndedNoticeShown = true;
      await _isar.collection<UserEntitlement>().put(r);
    });
    _publish();
  }

  /// DEBUG ONLY ([debugTrialToolsAllowed]): a trial that started [daysUsed]
  /// days ago, replacing whatever the row holds.
  Future<void> debugGrant({int daysUsed = 0}) async {
    if (!debugTrialToolsAllowed) return;
    final now = _clock();
    final rec = await _store.create(now.subtract(Duration(days: daysUsed)));
    await _store.persist(rec);
    await evaluate();
    await _reschedule();
  }

  /// DEBUG ONLY ([debugTrialToolsAllowed]): forgets the trial everywhere.
  Future<void> debugReset() async {
    if (!debugTrialToolsAllowed) return;
    await _isar.writeTxn(() async {
      final r = await _isar.collection<UserEntitlement>().get(0);
      if (r == null) return;
      r.trialRecordId = null;
      r.trialStartAt = null;
      r.trialSig = null;
      r.trialVersion = null;
      r.trialHighWaterAt = null;
      r.trialInvalidSeen = false;
      r.proTrialEndedNoticeShown = false;
      if (r.tier == EntitlementTier.proTrial) r.tier = EntitlementTier.free;
      await _isar.collection<UserEntitlement>().put(r);
    });
    await _store.blockStore.write('');
    await evaluate();
    await _reschedule();
  }
}
