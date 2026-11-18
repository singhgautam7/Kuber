import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/pro/data/user_entitlement.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/features/pro/trial/block_store_channel.dart';
import 'package:kuber/features/pro/trial/trial_record.dart';
import 'package:kuber/features/pro/trial/trial_reminders.dart';
import 'package:kuber/features/pro/trial/trial_signer.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';
import 'package:kuber/features/pro/trial/trial_store.dart';

import '../../helpers/isar_test_helper.dart';

class FakeBlockStore implements TrialBlockStore {
  String? data;
  bool fail = false;
  @override
  Future<BlockRead> read() async => fail ? const BlockRead(null, error: true) : BlockRead(data);
  @override
  Future<bool> write(String d) async {
    if (fail) return false;
    data = d;
    return true;
  }

  @override
  Future<List<int>?> keyPart() async => null;

  /// Boot clock in ms; null = unavailable (non-Android).
  int? uptime;
  @override
  Future<int?> uptimeMs() async => uptime;
}

class FakeReminders implements TrialReminderScheduler {
  DateTime? scheduledFor;
  int cancels = 0;
  @override
  Future<void> schedule(DateTime start) async => scheduledFor = start;
  @override
  Future<void> cancel() async {
    scheduledFor = null;
    cancels++;
  }
}

class TrialHarness {
  final Isar isar;
  final FakeBlockStore block = FakeBlockStore();
  final FakeReminders reminders = FakeReminders();
  final TrialSigner signer = FixedKeyTrialSigner();
  DateTime clock;
  late final ProviderContainer container;

  TrialHarness._(this.isar, this.clock);

  static Future<TrialHarness> create({DateTime? now, void Function(UserEntitlement r)? row}) async {
    final isar = await openTestIsar();
    final h = TrialHarness._(isar, now ?? DateTime(2026, 11, 20, 12));
    final r = UserEntitlement()
      ..firstInstallAt = h.clock
      ..tier = EntitlementTier.free;
    row?.call(r);
    await isar.writeTxn(() => isar.collection<UserEntitlement>().put(r));
    TrialRuntime.blockStore = h.block;
    TrialRuntime.signer = h.signer;
    h.container = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(isar),
      trialClockProvider.overrideWithValue(() => h.clock),
      trialStoreProvider.overrideWith((ref) => TrialStore(isar, signer: h.signer, blockStore: h.block)),
      trialReminderSchedulerProvider.overrideWithValue(h.reminders),
    ]);
    return h;
  }

  ProTrialNotifier get notifier => container.read(proTrialProvider.notifier);
  TrialInfo get info => container.read(proTrialProvider);
  KuberProState get pro => container.read(kuberProStateProvider);
  UserEntitlement get row => isar.collection<UserEntitlement>().getSync(0)!;

  Future<void> setRow(void Function(UserEntitlement r) f) async {
    final r = row;
    f(r);
    await isar.writeTxn(() => isar.collection<UserEntitlement>().put(r));
    container.read(kuberProStateProvider.notifier).refreshFromRow();
  }

  Future<TrialRecord> signed(DateTime start, {String id = 'abc123'}) async {
    final ms = start.toUtc().millisecondsSinceEpoch;
    return TrialRecord(v: 1, id: id, startMs: ms, sig: await signer.sign(1, id, ms));
  }

  /// A record whose signature does not match.
  Future<TrialRecord> forged(DateTime start) async {
    final r = await signed(start);
    return TrialRecord(v: 1, id: r.id, startMs: r.startMs - 86400000, sig: r.sig);
  }

  Future<void> putRowRecord(TrialRecord r) => setRow((x) {
        x.trialRecordId = r.id;
        x.trialStartAt = r.start;
        x.trialSig = r.sig;
        x.trialVersion = r.v;
      });

  String blockJson(TrialRecord r) => jsonEncode(r.toJson());

  Future<void> dispose() async {
    container.dispose();
    TrialRuntime.blockStore = ChannelTrialBlockStore();
    TrialRuntime.signer = null;
    await closeAndCleanIsar(isar);
  }
}
