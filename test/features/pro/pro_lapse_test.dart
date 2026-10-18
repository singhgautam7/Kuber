import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/features/pro/services/purchase_service.dart';

/// Safe revoke: a lapsed subscription (e.g. a free promo month never paid
/// for) loses Pro only after two confirmed-empty Play checks an hour apart.
void main() {
  final t0 = DateTime(2026, 11, 19, 9);

  LapseAction decide({
    bool queryOk = true,
    bool hasActivePro = false,
    DateTime? missingSince,
    required DateTime now,
  }) =>
      decideLapse(
        queryOk: queryOk,
        hasActivePro: hasActivePro,
        missingSince: missingSince,
        now: now,
      );

  group('decideLapse', () {
    test('first empty answer only marks, never revokes', () {
      expect(decide(now: t0), LapseAction.markMissing);
    });

    test('second empty answer under an hour later keeps Pro', () {
      expect(
        decide(missingSince: t0, now: t0.add(const Duration(minutes: 59))),
        LapseAction.keep,
      );
    });

    test('second empty answer an hour or more later revokes', () {
      expect(
        decide(missingSince: t0, now: t0.add(const Duration(hours: 1))),
        LapseAction.revoke,
      );
      expect(
        decide(missingSince: t0, now: t0.add(const Duration(days: 3))),
        LapseAction.revoke,
      );
    });

    test('a failed query proves nothing, even with an old mark', () {
      expect(decide(queryOk: false, now: t0), LapseAction.keep);
      expect(
        decide(
          queryOk: false,
          missingSince: t0,
          now: t0.add(const Duration(days: 2)),
        ),
        LapseAction.keep,
      );
    });

    test('seeing the subscription again clears the mark', () {
      expect(
        decide(
          hasActivePro: true,
          missingSince: t0,
          now: t0.add(const Duration(hours: 5)),
        ),
        LapseAction.clear,
      );
      expect(decide(hasActivePro: true, now: t0), LapseAction.keep);
    });
  });

  group('what can lapse', () {
    test('only monthly and yearly subscriptions', () {
      expect(
        isRevocableSubscription(KuberProState.purchased(plan: ProPlan.monthly)),
        isTrue,
      );
      expect(
        isRevocableSubscription(KuberProState.purchased(plan: ProPlan.yearly)),
        isTrue,
      );
      expect(
        isRevocableSubscription(
          KuberProState.purchased(plan: ProPlan.lifetime),
        ),
        isFalse,
      );
      expect(isRevocableSubscription(KuberProState.promo()), isFalse);
      expect(isRevocableSubscription(const KuberProState()), isFalse);
    });
  });

  group('isActiveProPurchase', () {
    PurchaseDetails p(String id, PurchaseStatus status) => PurchaseDetails(
          productID: id,
          verificationData: PurchaseVerificationData(
            localVerificationData: '',
            serverVerificationData: 'token',
            source: 'google_play',
          ),
          transactionDate: null,
          status: status,
        );

    test('purchased, restored and pending Pro products count', () {
      expect(isActiveProPurchase(p(kProYearlyId, PurchaseStatus.purchased)),
          isTrue);
      expect(isActiveProPurchase(p(kProMonthlyId, PurchaseStatus.restored)),
          isTrue);
      expect(isActiveProPurchase(p(kProYearlyId, PurchaseStatus.pending)),
          isTrue);
      expect(isActiveProPurchase(p(kProLifetimeId, PurchaseStatus.purchased)),
          isTrue);
    });

    test('support tips and errored purchases do not', () {
      expect(
        isActiveProPurchase(p('kuber_support_coffee', PurchaseStatus.purchased)),
        isFalse,
      );
      expect(isActiveProPurchase(p(kProYearlyId, PurchaseStatus.error)),
          isFalse);
      expect(isActiveProPurchase(p(kProYearlyId, PurchaseStatus.canceled)),
          isFalse);
    });
  });
}
