import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/pro/data/user_entitlement.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  group('ensureEntitlementBootstrap (Round 2: no app-managed trial)', () {
    late Isar isar;

    setUp(() async {
      isar = await openTestIsar();
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('a fresh install starts on FREE, not a local trial', () async {
      await ensureEntitlementBootstrap(isar);
      final row = await isar.collection<UserEntitlement>().get(0);
      expect(row, isNotNull);
      // The abusable "reinstall for another 14 days" trial is gone.
      expect(row!.tier, EntitlementTier.free);
      expect(row.trialEndsAt, isNull);
    });

    test('does not overwrite an existing (grandfathered) row', () async {
      final legacy = UserEntitlement()
        ..firstInstallAt = DateTime(2025, 1, 1)
        ..tier = EntitlementTier.trial
        ..trialEndsAt = DateTime(2025, 1, 15);
      await isar.writeTxn(
        () => isar.collection<UserEntitlement>().put(legacy),
      );

      await ensureEntitlementBootstrap(isar);

      final row = await isar.collection<UserEntitlement>().get(0);
      expect(row!.tier, EntitlementTier.trial); // untouched
    });
  });

  group('KuberProState trial phase', () {
    test('a purchased sub in its Play free-trial phase reads as Pro + in trial',
        () {
      final s = KuberProState.purchased(
        plan: ProPlan.yearly,
        trialEndsAt: DateTime.now().add(const Duration(days: 10)),
      );
      expect(s.isPro, isTrue); // a Play trial is a real subscription
      expect(s.inTrialPhase, isTrue); // ... currently in its trial phase
      expect(s.hasProAccess, isTrue);
      expect(s.trialDaysLeft, greaterThan(0));
    });

    test('a restored older sub (trial end in the past) is plain Pro', () {
      final s = KuberProState.purchased(
        plan: ProPlan.yearly,
        trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(s.isPro, isTrue);
      expect(s.inTrialPhase, isFalse);
    });

    test('legacy app trial: unpaid but full access, shows trial UI', () {
      final s = KuberProState.trial(
        endsAt: DateTime.now().add(const Duration(days: 5)),
      );
      expect(s.isPro, isFalse); // unpaid
      expect(s.isTrial, isTrue);
      expect(s.inTrialPhase, isTrue);
      expect(s.hasProAccess, isTrue);
    });

    test('free state is never in a trial phase', () {
      const s = KuberProState();
      expect(s.inTrialPhase, isFalse);
      // TEMPORARY: Pro gating is disabled (all features free) while billing KYC
      // is pending, so hasProAccess is hard-coded true. Restore this to isFalse
      // when re-enabling gating (see hasProAccess / specs/pro-gating-disabled.md).
      expect(s.hasProAccess, isTrue);
    });
  });
}
