import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/pro/data/user_entitlement.dart';
import 'package:kuber/features/pro/debug/trial_debug.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';

import '../../helpers/isar_test_helper.dart';
import 'trial_harness.dart';

void main() {
  setUpAll(() async => initialiseIsarForTests());

  group('eligibility by user type', () {
    Future<void> expectEligible(void Function(UserEntitlement) row) async {
      final h = await TrialHarness.create(row: row);
      addTearDown(h.dispose);
      await h.notifier.reconcile();
      expect(h.info.eligible, isTrue);
      expect(h.info.status, TrialStatus.none);
    }

    test('new install', () => expectEligible((r) {}));
    test('legacy trial tier', () => expectEligible((r) => r.tier = EntitlementTier.trial));
    test('paid plan ended', () => expectEligible((r) {
          r.tier = EntitlementTier.free;
          r.activatedAt = DateTime(2026, 1, 1);
        }));
    test('promo ended', () => expectEligible((r) {
          r.tier = EntitlementTier.proPromo;
          r.proExpiresAt = DateTime(2026, 1, 1);
        }));

    for (final tier in [
      EntitlementTier.proMonthly,
      EntitlementTier.proYearly,
      EntitlementTier.proLifetime,
      EntitlementTier.proPromo,
    ]) {
      test('Pro user ($tier) is not eligible, no reminders', () async {
        final h = await TrialHarness.create(row: (r) {
          r.tier = tier;
          r.proExpiresAt = tier == EntitlementTier.proLifetime ? null : DateTime(2027, 6, 1);
        });
        addTearDown(h.dispose);
        final out = await h.notifier.claim();
        expect(out, TrialStartOutcome.notEligible);
        expect(h.info.eligible, isFalse);
        expect(h.reminders.scheduledFor, isNull);
        expect(h.row.trialRecordId, isNull);
        final out2 = await h.notifier.startAfterSetup();
        expect(out2, TrialStartOutcome.notEligible);
      });
    }
  });

  group('start', () {
    test('startAfterSetup starts a trial: gate, row, Block Store, reminders', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      expect(await h.notifier.startAfterSetup(), TrialStartOutcome.started);
      expect(h.info.isActive, isTrue);
      expect(h.info.endAt, h.info.startAt!.add(kTrialLength));
      expect(h.row.tier, EntitlementTier.proTrial);
      expect(h.pro.hasProAccess, isTrue);
      expect(h.pro.isTrialActive, isTrue);
      expect(h.pro.isPro, isFalse);
      expect(h.block.data, isNotNull);
      expect(h.reminders.scheduledFor, h.info.startAt);
      expect(h.info.eligible, isFalse);
      // second claim never restarts
      expect(await h.notifier.claim(), TrialStartOutcome.continued);
    });

    test('Block Store unreadable: local row only, still starts', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      h.block.fail = true;
      expect(await h.notifier.claim(), TrialStartOutcome.started);
      expect(h.block.data, isNull);
    });

    test('earliest valid start wins across row, Block Store and backup', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      final early = await h.signed(DateTime(2026, 11, 15), id: 'early');
      final mid = await h.signed(DateTime(2026, 11, 17), id: 'mid');
      final late = await h.signed(DateTime(2026, 11, 19), id: 'late');
      await h.putRowRecord(late);
      h.block.data = h.blockJson(mid);
      final out = await h.notifier.startAfterSetup(backupTrialBlock: {
        'record': early.toJson(),
        'backupCreatedAt': '2026-11-16T00:00:00Z',
      });
      expect(out, TrialStartOutcome.continued);
      expect(h.info.startAt, early.start);
      expect(h.row.trialRecordId, 'early');
      expect(h.block.data, contains('early'));
    });

    test('ended record -> alreadyUsed, never a second trial', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      await h.putRowRecord(await h.signed(DateTime(2026, 10, 1)));
      expect(await h.notifier.claim(), TrialStartOutcome.alreadyUsed);
      expect(h.info.isEnded, isTrue);
      expect(h.info.eligible, isFalse);
      expect(h.pro.hasProAccess, isFalse);
    });

    test('bad signature counts as used (row, Block Store, backup)', () async {
      for (final where in ['row', 'block', 'backup']) {
        final h = await TrialHarness.create();
        final bad = await h.forged(DateTime(2026, 11, 19));
        Map<String, dynamic>? backup;
        if (where == 'row') {
          await h.putRowRecord(bad);
        } else if (where == 'block') {
          h.block.data = h.blockJson(bad);
        } else {
          backup = {'record': bad.toJson()};
        }
        final out = await h.notifier.startAfterSetup(backupTrialBlock: backup);
        expect(out, TrialStartOutcome.alreadyUsed, reason: where);
        expect(h.info.isEnded, isTrue, reason: where);
        expect(h.pro.hasProAccess, isFalse, reason: where);
        expect(h.row.trialInvalidSeen, isTrue, reason: where);
        await h.dispose();
      }
    });

    test('malformed backup block (no record) counts as used', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      expect(await h.notifier.startAfterSetup(backupTrialBlock: {}), TrialStartOutcome.alreadyUsed);
    });
  });

  group('clock', () {
    test('set back never gives days back; forward ends it sooner', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      await h.notifier.claim();
      final start = h.info.startAt!;
      h.clock = start.add(const Duration(days: 10));
      await h.notifier.evaluate();
      expect(h.info.daysLeft, 4);
      h.clock = start; // user sets the clock back
      await h.notifier.evaluate();
      expect(h.info.now.isAtSameMomentAs(start.add(const Duration(days: 10))), isTrue);
      expect(h.info.daysLeft, 4);
      h.clock = start.add(const Duration(days: 13, hours: 23));
      await h.notifier.evaluate();
      expect(h.info.isActive, isTrue);
      h.clock = start.add(const Duration(days: 14, minutes: 1));
      await h.notifier.evaluate();
      expect(h.info.isEnded, isTrue);
      expect(h.pro.hasProAccess, isFalse);
      expect(h.row.tier, EntitlementTier.free);
      h.clock = start; // back again: still ended
      await h.notifier.evaluate();
      expect(h.info.isEnded, isTrue);
    });
  });

  group('clock guard with the boot clock', () {
    test('set forward, claim, set back: days still count in real time', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      final real = h.clock;
      h.block.uptime = 1000;
      h.clock = real.add(const Duration(days: 365)); // clock set a year ahead
      await h.notifier.claim();
      expect(h.info.daysLeft, 14);
      // Back to the real date, 5 real days later (boot clock moved 5 days).
      h.clock = real.add(const Duration(days: 5));
      h.block.uptime = 1000 + const Duration(days: 5).inMilliseconds;
      await h.notifier.evaluate();
      expect(h.info.daysLeft, 9);
      // 15 real days after the claim: over, although the wall clock is still
      // eleven months before the claimed start.
      h.clock = real.add(const Duration(days: 15));
      h.block.uptime = 1000 + const Duration(days: 15).inMilliseconds;
      await h.notifier.evaluate();
      expect(h.info.isEnded, isTrue);
      expect(h.pro.hasProAccess, isFalse);
    });

    test('clock set back 10 days: no days added, time keeps counting', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      h.block.uptime = 0;
      await h.notifier.claim();
      final start = h.info.startAt!;
      h.clock = start.subtract(const Duration(days: 10)); // set back at once
      h.block.uptime = const Duration(hours: 1).inMilliseconds;
      await h.notifier.evaluate();
      expect(h.info.isActive, isTrue);
      expect(h.info.daysLeft, 14); // nothing added, nothing lost
      h.block.uptime = const Duration(days: 14, hours: 1).inMilliseconds;
      await h.notifier.evaluate();
      expect(h.info.isEnded, isTrue);
    });

    test('a reboot (boot clock restarts) never moves time backwards', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      h.block.uptime = const Duration(days: 3).inMilliseconds;
      await h.notifier.claim();
      final start = h.info.startAt!;
      h.clock = start.add(const Duration(days: 4));
      h.block.uptime = const Duration(days: 4).inMilliseconds;
      await h.notifier.evaluate();
      expect(h.info.daysLeft, 10);
      h.clock = start; // clock back and the phone rebooted
      h.block.uptime = 5000;
      await h.notifier.evaluate();
      expect(h.info.daysLeft, 10);
    });
  });

  group('purchase and lapse', () {
    test('purchase during trial: paid wins, record kept, reminders cancelled, no second trial', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      await h.notifier.claim();
      expect(h.reminders.scheduledFor, isNotNull);
      h.container.read(kuberProStateProvider.notifier).applyPurchase(
            plan: ProPlan.monthly,
            expiryDate: h.clock.add(const Duration(days: 30)),
          );
      h.notifier.onEntitlementChanged();
      expect(h.pro.isPro, isTrue);
      expect(h.pro.isTrialActive, isFalse);
      expect(h.reminders.scheduledFor, isNull);
      expect(h.row.trialRecordId, isNotNull);
      expect(h.info.eligible, isFalse);
      // paid plan lapses days later: the trial stays used
      h.container.read(kuberProStateProvider.notifier).revoke();
      h.notifier.onEntitlementChanged();
      await h.notifier.evaluate();
      expect(h.pro.hasProAccess, isFalse);
      expect(await h.notifier.claim(), TrialStartOutcome.alreadyUsed);
    });

    test('paid plan ended with no trial record: eligible', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      h.container.read(kuberProStateProvider.notifier).applyPurchase(plan: ProPlan.yearly);
      await h.notifier.reconcile();
      expect(h.info.eligible, isFalse);
      h.container.read(kuberProStateProvider.notifier).revoke();
      h.notifier.onEntitlementChanged();
      expect(h.info.eligible, isTrue);
    });
  });

  group('state', () {
    test('trial end flips hasProAccess false; nothing else changes', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      await h.notifier.claim();
      expect(h.pro.hasProAccess, isTrue);
      h.clock = h.clock.add(kTrialLength + const Duration(hours: 1));
      await h.notifier.evaluate();
      expect(h.pro.hasProAccess, isFalse);
      expect(h.info.endedNoticeShown, isFalse);
      await h.notifier.markEndedNoticeShown();
      expect(h.info.endedNoticeShown, isTrue);
    });

    test('legacy trial tier reads as free', () async {
      final h = await TrialHarness.create(row: (r) => r.tier = EntitlementTier.trial);
      addTearDown(h.dispose);
      expect(h.pro.hasProAccess, isFalse);
    });
  });

  group('debug tools', () {
    test('debugTrialToolsAllowed = false: grant and reset are no-ops', () async {
      final h = await TrialHarness.create();
      addTearDown(h.dispose);
      final was = debugTrialToolsAllowed;
      addTearDown(() => debugTrialToolsAllowed = was);
      debugTrialToolsAllowed = false;
      await h.notifier.debugGrant(daysUsed: 3);
      expect(h.row.trialRecordId, isNull);
      await h.notifier.claim();
      final id = h.row.trialRecordId;
      await h.notifier.debugReset();
      expect(h.row.trialRecordId, id);
      debugTrialToolsAllowed = true;
      await h.notifier.debugReset();
      expect(h.row.trialRecordId, isNull);
    });
  });
}
