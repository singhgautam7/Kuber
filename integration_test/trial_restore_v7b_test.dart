// v7.0.0-b: restoring a JSON backup can't give Kuber Pro for free. Runs on a
// device so the real signing key (native half) and boot clock are used.
//   flutter test integration_test/trial_restore_v7b_test.dart -d <id>
// Never on Kuber_QA: it replaces the data.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/pro/data/user_entitlement.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'smoke_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  smokeTest('restore from JSON never gives Pro for free', (t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboarded, true);
    await boot(t);
    final c = container(t);
    final trial = c.read(proTrialProvider.notifier);
    final svc = JsonBackupService();
    TrialInfo info() => c.read(proTrialProvider);
    bool pro() => c.read(kuberProStateProvider).hasProAccess;
    UserEntitlement row() => db.collection<UserEntitlement>().getSync(0)!;
    void log(String step) => debugPrint('KUBER_RESTORE $step: status=${info().status} '
        'daysLeft=${info().daysLeft} pro=${pro()} start=${info().startAt}');

    await trial.debugReset();
    await trial.reconcile();
    expect(await trial.claim(), TrialStartOutcome.started);
    final start = info().startAt!;
    expect(pro(), isTrue);
    expect(row().trialHighWaterUptimeMs, isNotNull, reason: 'native boot clock');
    log('claimed');

    // The backup carries the signed record.
    final backup = jsonDecode(await svc.exportJson(db)) as Map<String, dynamic>;
    final block = backup['trial'] as Map<String, dynamic>;
    expect(block['record'], isNotNull);

    // 1. Settings restore of a backup with the trial block deleted: the
    //    trial stays exactly as it was (the record lives in the kept row).
    final noBlock = Map<String, dynamic>.from(backup)..remove('trial');
    expect((await svc.importJson(db, jsonEncode(noBlock))).error, isNull);
    await trial.reconcile();
    log('restore without block');
    expect(info().isActive, isTrue);
    expect(info().startAt!.isAtSameMomentAs(start), isTrue);

    // 2. Settings restore of a backup whose start was edited to look newer:
    //    bad signature, the trial counts as used, Pro goes away, data restores.
    final edited = jsonDecode(jsonEncode(backup)) as Map<String, dynamic>;
    final rec = (edited['trial'] as Map)['record'] as Map;
    final startKey = rec.keys.firstWhere((k) => '$k'.contains('start'));
    rec[startKey] = DateTime.now().add(const Duration(days: 30)).toUtc().millisecondsSinceEpoch;
    final r2 = await svc.importJson(db, jsonEncode(edited));
    expect(r2.error, isNull);
    expect(r2.successCount, greaterThan(0));
    await trial.reconcile();
    log('restore edited block');
    expect(info().isEnded, isTrue);
    expect(pro(), isFalse);

    // 3. New phone (nothing local): restoring a backup taken during the trial
    //    continues that trial with its own days, it never starts a new one.
    await trial.debugReset();
    expect(await trial.startAfterSetup(backupTrialBlock: block), TrialStartOutcome.continued);
    log('setup restore valid block');
    expect(info().startAt!.isAtSameMomentAs(start), isTrue);
    expect(info().daysLeft, 14);

    // 4. New phone with an edited block: already used, no Pro.
    await trial.debugReset();
    expect(await trial.startAfterSetup(backupTrialBlock: (edited['trial'] as Map).cast<String, dynamic>()),
        TrialStartOutcome.alreadyUsed);
    log('setup restore edited block');
    expect(pro(), isFalse);

    // 5. New phone, backup's trial ended long ago: used, no Pro.
    await trial.debugReset();
    await trial.debugGrant(daysUsed: 20);
    final old = (jsonDecode(await svc.exportJson(db)) as Map<String, dynamic>)['trial']
        as Map<String, dynamic>;
    await trial.debugReset();
    expect(await trial.startAfterSetup(backupTrialBlock: old), TrialStartOutcome.alreadyUsed);
    log('setup restore ended block');
    expect(pro(), isFalse);

    // 6. Settings restore of that old ended block over an active trial: the
    //    earliest start wins, so the active trial ends (no stacking).
    await trial.debugReset();
    expect(await trial.claim(), TrialStartOutcome.started);
    final withOld = Map<String, dynamic>.from(noBlock)..['trial'] = old;
    expect((await svc.importJson(db, jsonEncode(withOld))).error, isNull);
    await trial.reconcile();
    log('settings restore ended block over active');
    expect(info().isEnded, isTrue);
    expect(pro(), isFalse);

    await trial.debugReset();
    expectNoErrors(t);
  }, );
}
