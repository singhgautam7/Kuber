import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/pro/data/user_entitlement.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  final now = DateTime(2026, 10, 19, 10);

  group('nextRenewalDate', () {
    test('monthly: a month after purchase, then each month', () {
      expect(
        nextRenewalDate(DateTime(2026, 10, 18, 9), ProPlan.monthly, now),
        DateTime(2026, 11, 18, 9),
      );
      // Bought months ago: the next anniversary after now.
      expect(
        nextRenewalDate(DateTime(2026, 3, 25, 9), ProPlan.monthly, now),
        DateTime(2026, 10, 25, 9),
      );
    });

    test('monthly from the 31st clamps to short months', () {
      expect(
        nextRenewalDate(DateTime(2027, 1, 31), ProPlan.monthly,
            DateTime(2027, 2, 1)),
        DateTime(2027, 2, 28),
      );
      expect(
        nextRenewalDate(DateTime(2027, 1, 31), ProPlan.monthly,
            DateTime(2027, 3, 1)),
        DateTime(2027, 3, 31),
      );
    });

    test('yearly: a year after purchase; 29 Feb clamps', () {
      expect(
        nextRenewalDate(DateTime(2026, 10, 1), ProPlan.yearly, now),
        DateTime(2027, 10, 1),
      );
      expect(
        nextRenewalDate(DateTime(2028, 2, 29), ProPlan.yearly,
            DateTime(2028, 3, 1)),
        DateTime(2029, 2, 28),
      );
    });
  });

  group('renewalLabel', () {
    KuberProState sub(ProPlan plan, DateTime? expiry, {bool? renewing}) =>
        KuberProState.purchased(
          plan: plan,
          expiryDate: expiry,
          autoRenewing: renewing,
        );

    test('auto-renewing: "Renews on"', () {
      expect(
        sub(ProPlan.monthly, DateTime(2026, 11, 18), renewing: true)
            .renewalLabel(now: now),
        'Renews on 18 Nov 2026',
      );
    });

    test('bought yesterday, cancelled today: "Expires on" in a month', () {
      expect(
        sub(ProPlan.monthly, DateTime(2026, 11, 18), renewing: false)
            .renewalLabel(now: now),
        'Expires on 18 Nov 2026',
      );
      expect(
        sub(ProPlan.monthly, DateTime(2026, 10, 18), renewing: false)
            .renewalLabel(now: now),
        'Expired on 18 Oct 2026',
      );
    });

    test('a renewal date that passed offline rolls forward', () {
      expect(
        sub(ProPlan.yearly, DateTime(2026, 10, 17), renewing: true)
            .renewalLabel(now: now),
        'Renews on 17 Oct 2027',
      );
    });

    test('unknown for lifetime, promo, or no date yet', () {
      expect(KuberProState.purchased(plan: ProPlan.lifetime).renewalLabel(),
          isNull);
      expect(KuberProState.promo().renewalLabel(), isNull);
      expect(sub(ProPlan.monthly, null).renewalLabel(), isNull);
    });
  });

  group('offline grace', () {
    late Isar isar;
    setUpAll(() async => initialiseIsarForTests());
    setUp(() async => isar = await openTestIsar());
    tearDown(() async => closeAndCleanIsar(isar));

    Future<KuberProState> stateWithExpiry(DateTime expiry) async {
      await isar.writeTxn(() => isar.collection<UserEntitlement>().put(
            UserEntitlement()
              ..firstInstallAt = DateTime(2026, 1, 1)
              ..tier = EntitlementTier.proMonthly
              ..proExpiresAt = expiry
              ..autoRenewing = true,
          ));
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);
      return container.read(kuberProStateProvider);
    }

    test('renewal day passed under 3 days ago: still Pro', () async {
      final s = await stateWithExpiry(
        DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(s.isPro, isTrue);
    });

    test('more than 3 days past with no Play check: free', () async {
      final s = await stateWithExpiry(
        DateTime.now().subtract(const Duration(days: 4)),
      );
      expect(s.isPro, isFalse);
    });
  });
}
