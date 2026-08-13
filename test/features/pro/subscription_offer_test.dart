import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/pro/paywall/subscription_offer.dart';

void main() {
  group('iso8601PeriodToDays', () {
    test('parses common billing periods', () {
      expect(iso8601PeriodToDays('P1Y'), 365);
      expect(iso8601PeriodToDays('P6M'), 180);
      expect(iso8601PeriodToDays('P1M'), 30);
      expect(iso8601PeriodToDays('P1W'), 7);
      expect(iso8601PeriodToDays('P14D'), 14);
      expect(iso8601PeriodToDays('P1Y6M'), 365 + 180);
    });

    test('unparseable period is zero', () {
      expect(iso8601PeriodToDays('garbage'), 0);
      expect(iso8601PeriodToDays(''), 0);
    });
  });

  group('period labels', () {
    test('counted labels read naturally', () {
      expect(countedBillingPeriod('P1Y'), '1 year');
      expect(countedBillingPeriod('P1M'), '1 month');
      expect(countedBillingPeriod('P14D'), '14 days');
    });

    test('human labels read naturally', () {
      expect(humanBillingPeriod('P1Y'), 'year');
      expect(humanBillingPeriod('P1M'), 'month');
      expect(humanBillingPeriod('P14D'), '14 days');
    });
  });

  group('SubscriptionOfferInfo.hasIntroBenefit', () {
    SubscriptionOfferInfo build(List<OfferPhase> phases) => SubscriptionOfferInfo(
          productId: 'kuber_pro_yearly',
          offerToken: 'tok',
          offerId: 'independence-day-gift',
          offerTags: const ['launch'],
          phases: phases,
        );

    test('free year then paid year is an intro benefit', () {
      final o = build(const [
        OfferPhase(
            formattedPrice: 'Free', priceAmountMicros: 0, billingPeriod: 'P1Y'),
        OfferPhase(
            formattedPrice: '₹1,099',
            priceAmountMicros: 1099000000,
            billingPeriod: 'P1Y'),
      ]);
      expect(o.hasIntroBenefit, isTrue);
      expect(o.firstPhase.isFree, isTrue);
      expect(o.firstPhase.durationLabel, '1 year');
      expect(o.recurringPhase.formattedPrice, '₹1,099');
      expect(o.recurringPhase.periodLabel, 'year');
    });

    test('a plain base plan (single phase) has no intro benefit', () {
      final o = build(const [
        OfferPhase(
            formattedPrice: '₹1,099',
            priceAmountMicros: 1099000000,
            billingPeriod: 'P1Y'),
      ]);
      expect(o.hasIntroBenefit, isFalse);
    });

    test('no benefit when the first phase is not cheaper', () {
      final o = build(const [
        OfferPhase(
            formattedPrice: '₹1,099',
            priceAmountMicros: 1099000000,
            billingPeriod: 'P1Y'),
        OfferPhase(
            formattedPrice: '₹1,099',
            priceAmountMicros: 1099000000,
            billingPeriod: 'P1Y'),
      ]);
      expect(o.hasIntroBenefit, isFalse);
    });
  });
}
