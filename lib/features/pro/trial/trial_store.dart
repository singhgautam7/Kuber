import 'dart:convert';
import 'dart:math';

import 'package:isar_community/isar.dart';

import '../data/user_entitlement.dart';
import 'block_store_channel.dart';
import 'trial_record.dart';
import 'trial_signer.dart';

/// Process-wide trial plumbing. Tests replace [blockStore] / [signer].
class TrialRuntime {
  static TrialBlockStore blockStore = ChannelTrialBlockStore();
  static TrialSigner? _signer;
  static set signer(TrialSigner? s) => _signer = s;
  static TrialSigner get signer => _signer ??= HmacTrialSigner(() => blockStore.keyPart());
}

/// What the three places say, after signature checks.
class TrialResolution {
  /// Earliest valid record from the row, Block Store and backup.
  final TrialRecord? record;

  /// Some record failed its check (or is malformed): counts as used.
  final bool invalid;

  /// False when Block Store could not be read (local row only).
  final bool blockReadable;

  /// The valid record Block Store holds, if any.
  final TrialRecord? blockRecord;
  const TrialResolution(this.record, this.invalid, this.blockReadable, [this.blockRecord]);

  /// Block Store is readable and does not yet hold [record].
  bool get blockNeedsWrite => blockReadable && record != null && blockRecord?.id != record!.id;

  bool get anyRecord => record != null || invalid;
}

UserEntitlement? _row(Isar isar) => isar.collection<UserEntitlement>().getSync(0);

TrialRecord? rowRecord(UserEntitlement? r) {
  if (r?.trialRecordId == null || r?.trialStartAt == null || r?.trialSig == null) return null;
  return TrialRecord(
    v: r!.trialVersion ?? 1,
    id: r.trialRecordId!,
    startMs: r.trialStartAt!.millisecondsSinceEpoch,
    sig: r.trialSig!,
  );
}

/// Reads and reconciles the trial record locations.
class TrialStore {
  final Isar isar;
  final TrialSigner signer;
  final TrialBlockStore blockStore;
  TrialStore(this.isar, {TrialSigner? signer, TrialBlockStore? blockStore})
      : signer = signer ?? TrialRuntime.signer,
        blockStore = blockStore ?? TrialRuntime.blockStore;

  /// Reads row, Block Store and [backupBlock] (a backup's `"trial"` value) and
  /// picks the earliest valid start. [readBlock] false skips Block Store.
  Future<TrialResolution> resolve({Object? backupBlock, bool readBlock = true}) async {
    final row = _row(isar);
    var invalid = row?.trialInvalidSeen ?? false;
    final valid = <TrialRecord>[];

    Future<void> consider(TrialRecord? r) async {
      if (r == null) {
        invalid = true;
      } else if (await signer.verify(r)) {
        valid.add(r);
      } else {
        invalid = true;
      }
    }

    final fromRow = rowRecord(row);
    if (fromRow != null) await consider(fromRow);

    var readable = false;
    TrialRecord? blockRec;
    if (readBlock) {
      final b = await blockStore.read();
      readable = !b.error;
      if (b.data != null && b.data!.isNotEmpty) {
        Object? decoded;
        try {
          decoded = jsonDecode(b.data!);
        } catch (_) {}
        final br = TrialRecord.tryParse(decoded);
        await consider(br);
        if (br != null && valid.contains(br)) blockRec = br;
      }
    }

    if (backupBlock != null) {
      await consider(TrialRecord.tryParse(backupBlock is Map ? backupBlock['record'] : null));
    }

    valid.sort((a, b) => a.startMs.compareTo(b.startMs));
    return TrialResolution(valid.isEmpty ? null : valid.first, invalid, readable, blockRec);
  }

  /// Writes [r] (the earliest valid record) to the row and, when it differs,
  /// to Block Store. [invalid] persists the "used" flag.
  Future<void> persist(TrialRecord? r, {bool invalid = false, bool writeBlock = true}) async {
    await isar.writeTxn(() async {
      final coll = isar.collection<UserEntitlement>();
      final row = await coll.get(0) ??
          (UserEntitlement()
            ..firstInstallAt = DateTime.now()
            ..tier = EntitlementTier.free);
      if (r != null) {
        row.trialRecordId = r.id;
        row.trialStartAt = r.start;
        row.trialSig = r.sig;
        row.trialVersion = r.v;
      }
      if (invalid) row.trialInvalidSeen = true;
      if (r == null) {
        // Nothing valid survived, so any record still in the row failed its check.
        row.trialRecordId = null;
        row.trialStartAt = null;
        row.trialSig = null;
        row.trialVersion = null;
      }
      await coll.put(row);
    });
    if (r != null && writeBlock) await blockStore.write(jsonEncode(r.toJson()));
  }

  /// Writes the resolution back: the earliest valid record to the row and to
  /// Block Store where it is missing, plus the "used" flag.
  Future<void> persistResolution(TrialResolution res) =>
      persist(res.record, invalid: res.invalid, writeBlock: res.blockRecord?.id != res.record?.id);

  /// Raises the clock guard to [now] when later than what is stored.
  /// Returns the effective "now".
  DateTime touchHighWater(DateTime now) {
    final row = _row(isar);
    final hwm = row?.trialHighWaterAt;
    if (hwm != null && !now.isAfter(hwm)) return hwm;
    isar.writeTxnSync(() {
      final r = _row(isar) ??
          (UserEntitlement()
            ..firstInstallAt = DateTime.now()
            ..tier = EntitlementTier.free);
      r.trialHighWaterAt = now;
      isar.collection<UserEntitlement>().putSync(r);
    });
    return now;
  }

  Future<TrialRecord> create(DateTime now) async {
    final rnd = Random.secure();
    final id = List.generate(16, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    final ms = now.toUtc().millisecondsSinceEpoch;
    return TrialRecord(v: 1, id: id, startMs: ms, sig: await signer.sign(1, id, ms));
  }
}

/// Clears the whole database except the entitlement row, so the paid tier and
/// the trial record survive restore / clear all. Call inside a write txn.
Future<void> clearKeepingEntitlement(Isar isar) async {
  final coll = isar.collection<UserEntitlement>();
  final row = await coll.get(0);
  await isar.clear();
  if (row != null) await coll.put(row);
}

/// The `"trial"` block for a backup, or null without a record.
Future<Map<String, dynamic>?> exportTrialBlock(Isar isar) async {
  final r = rowRecord(await isar.collection<UserEntitlement>().get(0));
  if (r == null) return null;
  return {'record': r.toJson(), 'backupCreatedAt': DateTime.now().toUtc().toIso8601String()};
}

/// Settings restore: merges a backup's block into the local record (earliest
/// valid start wins; a bad block marks "used"). Never starts a trial.
Future<void> mergeBackupTrial(Isar isar, Object? block, {TrialStore? store}) async {
  if (block == null) return;
  final s = store ?? TrialStore(isar);
  final res = await s.resolve(backupBlock: block);
  await s.persistResolution(res);
}
