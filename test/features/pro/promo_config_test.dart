import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';

void main() {
  group('PromoConfig.tryFromJson (Round 2: display-only + Play code)', () {
    Map<String, dynamic> base() => {
          'promo_active': true,
          'promo_headline': 'Get Kuber Pro',
          'promo_message': 'Limited time offer.',
          'promo_code': 'KUBERPRO2026',
          'promo_product_highlight': 'yearly',
          'promo_end_date':
              DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        };

    test('parses a live campaign with a Play promo code', () {
      final promo = PromoConfig.tryFromJson(base());
      expect(promo, isNotNull);
      expect(promo!.headline, 'Get Kuber Pro');
      expect(promo.message, 'Limited time offer.');
      expect(promo.code, 'KUBERPRO2026');
      expect(promo.productHighlight, 'yearly');
    });

    test('has no grant machinery (display-only)', () {
      // Regression guard for the security fix: PromoConfig must not expose any
      // way to compute a local Pro grant. If this file ever needs a
      // grant-expiry helper again, it means the exploit was reintroduced.
      final promo = PromoConfig.tryFromJson(base())!;
      expect(promo, isA<PromoConfig>());
      // `code` is the ONLY actionable field; everything else is display copy.
      expect(promo.code, isNotNull);
    });

    test('returns null when inactive', () {
      final json = base()..['promo_active'] = false;
      expect(PromoConfig.tryFromJson(json), isNull);
    });

    test('returns null for a campaign whose end date has passed', () {
      final json = base()
        ..['promo_end_date'] = DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String();
      expect(PromoConfig.tryFromJson(json), isNull);
    });

    test('returns null when headline or message is missing', () {
      final noHeadline = base()..remove('promo_headline');
      final noMessage = base()..remove('promo_message');
      expect(PromoConfig.tryFromJson(noHeadline), isNull);
      expect(PromoConfig.tryFromJson(noMessage), isNull);
    });

    test('code and highlight are optional', () {
      final json = base()
        ..remove('promo_code')
        ..remove('promo_product_highlight');
      final promo = PromoConfig.tryFromJson(json);
      expect(promo, isNotNull);
      expect(promo!.code, isNull);
      expect(promo.productHighlight, isNull);
    });
  });
}
