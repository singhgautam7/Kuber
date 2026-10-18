import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/pro/data/user_entitlement.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuber/core/database/isar_service.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  group('ensureEntitlementBootstrap', () {
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

  group('no trial concept', () {
    late Isar isar;
    setUp(() async => isar = await openTestIsar());
    tearDown(() async => isar.close(deleteFromDisk: true));

    test('a legacy trial row (even "unexpired") reads as free', () async {
      await isar.writeTxn(() => isar.collection<UserEntitlement>().put(
            UserEntitlement()
              ..firstInstallAt = DateTime.now()
              ..tier = EntitlementTier.trial
              ..trialEndsAt = DateTime.now().add(const Duration(days: 5)),
          ));
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);
      final s = container.read(kuberProStateProvider);
      expect(s.isFree, isTrue);
      expect(s.hasProAccess, isFalse);
    });

    test('a yearly purchase clears the old client trial estimate', () async {
      await isar.writeTxn(() => isar.collection<UserEntitlement>().put(
            UserEntitlement()
              ..firstInstallAt = DateTime.now()
              ..tier = EntitlementTier.free
              ..trialEndsAt = DateTime.now().add(const Duration(days: 14)),
          ));
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);
      container
          .read(kuberProStateProvider.notifier)
          .applyPurchase(plan: ProPlan.yearly);
      final row = await isar.collection<UserEntitlement>().get(0);
      expect(row!.trialEndsAt, isNull);
      expect(container.read(kuberProStateProvider).isPro, isTrue);
    });

    test('free state has no Pro access', () {
      expect(const KuberProState().hasProAccess, isFalse);
    });
  });
}
