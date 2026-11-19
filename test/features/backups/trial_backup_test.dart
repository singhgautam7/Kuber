import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/services/data_service.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/pro/data/user_entitlement.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';
import 'package:kuber/features/pro/trial/trial_store.dart';

import '../../helpers/isar_test_helper.dart';
import '../pro/trial_harness.dart';

void main() {
  setUpAll(() async => initialiseIsarForTests());
  final service = JsonBackupService();

  Future<Map<String, dynamic>> exported(TrialHarness h) async =>
      jsonDecode(await service.exportJson(h.isar)) as Map<String, dynamic>;

  test('backup round trip carries the signed record (and only the record)', () async {
    final h = await TrialHarness.create();
    addTearDown(h.dispose);
    await h.notifier.claim();
    final json = await exported(h);
    expect(json['trial']['record']['id'], h.row.trialRecordId);
    expect(json['trial']['backupCreatedAt'], isA<String>());
    expect(jsonEncode(json), isNot(contains('activePurchaseToken')));

    // restore into a fresh install: the record merges, it never starts a trial
    final fresh = await TrialHarness.create();
    addTearDown(fresh.dispose);
    final res = await service.importJson(fresh.isar, jsonEncode(json));
    expect(res.error, isNull);
    expect(fresh.row.trialRecordId, h.row.trialRecordId);
    expect(fresh.row.trialStartAt, h.row.trialStartAt);
  });

  test('no record, no block; older backup without a block restores as today', () async {
    final h = await TrialHarness.create();
    addTearDown(h.dispose);
    final json = await exported(h);
    expect(json.containsKey('trial'), isFalse);
    final res = await service.importJson(h.isar, jsonEncode(json));
    expect(res.error, isNull);
    expect(h.row.trialRecordId, isNull);
    expect(h.row.trialInvalidSeen, isFalse);
  });

  test('older backup falls back to Block Store, fresh trial only if eligible', () async {
    final h = await TrialHarness.create();
    addTearDown(h.dispose);
    final rec = await h.signed(DateTime(2026, 11, 18), id: 'inblock');
    h.block.data = h.blockJson(rec);
    expect(await h.notifier.startAfterSetup(), TrialStartOutcome.continued);
    expect(h.info.startAt, rec.start);

    final h2 = await TrialHarness.create();
    addTearDown(h2.dispose);
    expect(await h2.notifier.startAfterSetup(), TrialStartOutcome.started);
  });

  test('edited backup block counts as used and data still restores', () async {
    final src = await TrialHarness.create();
    addTearDown(src.dispose);
    await src.isar.writeTxn(() => src.isar.accounts.put(Account()
      ..name = 'HDFC'
      ..type = 'bank'));
    await src.notifier.claim();
    final json = await exported(src);
    // user edits the start date to gain time
    json['trial']['record']['start'] = (json['trial']['record']['start'] as int) + 5 * 86400000;

    final h = await TrialHarness.create();
    addTearDown(h.dispose);
    final res = await service.importJson(h.isar, jsonEncode(json));
    expect(res.error, isNull);
    expect(await h.isar.accounts.count(), 1);
    expect(h.row.trialInvalidSeen, isTrue);
    expect(h.row.trialRecordId, isNull);
    // setup path: same block handed to startAfterSetup
    final h2 = await TrialHarness.create();
    addTearDown(h2.dispose);
    expect(await h2.notifier.startAfterSetup(backupTrialBlock: Map<String, dynamic>.from(json['trial'])),
        TrialStartOutcome.alreadyUsed);
    expect(h2.pro.hasProAccess, isFalse);
  });

  test('Settings restore merges: earliest valid start wins, never starts a trial', () async {
    final h = await TrialHarness.create();
    addTearDown(h.dispose);
    await h.putRowRecord(await h.signed(DateTime(2026, 11, 19), id: 'local'));
    final older = await h.signed(DateTime(2026, 11, 10), id: 'older');
    await mergeBackupTrial(h.isar, {'record': older.toJson()});
    expect(h.row.trialRecordId, 'older');
    // a later backup record does not extend it
    final newer = await h.signed(DateTime(2026, 11, 25), id: 'newer');
    await mergeBackupTrial(h.isar, {'record': newer.toJson()});
    expect(h.row.trialRecordId, 'older');
    // a block without a record on a clean phone starts nothing
    final clean = await TrialHarness.create();
    addTearDown(clean.dispose);
    await mergeBackupTrial(clean.isar, null);
    expect(clean.row.trialRecordId, isNull);
  });

  test('restore keeps the entitlement row (paid tier + trial record)', () async {
    final h = await TrialHarness.create(row: (r) {
      r.tier = EntitlementTier.proLifetime;
      r.activeProductId = 'kuber_pro_lifetime';
    });
    addTearDown(h.dispose);
    await h.putRowRecord(await h.signed(DateTime(2026, 11, 1), id: 'keep'));
    final json = await exported(h);
    json.remove('trial');
    final res = await service.importJson(h.isar, jsonEncode(json));
    expect(res.error, isNull);
    expect(h.row.tier, EntitlementTier.proLifetime);
    expect(h.row.trialRecordId, 'keep');

    // failure path: garbage after the clear still keeps the row
    final bad = await service.importJson(h.isar, jsonEncode({'transactions': 'nope'}));
    expect(bad.error, isNotNull);
    expect(h.row.tier, EntitlementTier.proLifetime);
    expect(h.row.trialRecordId, 'keep');
  });

  test('CSV import (override) and clear all do not touch the trial or the tier', () async {
    final h = await TrialHarness.create(row: (r) => r.tier = EntitlementTier.proYearly);
    addTearDown(h.dispose);
    await h.putRowRecord(await h.signed(DateTime(2026, 11, 1), id: 'csv'));
    final data = DataService(h.isar);
    await data.importData('date,amount,type,category,account,note\n2026-11-01,100,expense,Food,Cash,x\n',
        override: true);
    expect(h.row.trialRecordId, 'csv');
    expect(h.row.tier, EntitlementTier.proYearly);
    await data.clearAllData();
    expect(h.row.trialRecordId, 'csv');
    expect(h.row.tier, EntitlementTier.proYearly);
  });
}
