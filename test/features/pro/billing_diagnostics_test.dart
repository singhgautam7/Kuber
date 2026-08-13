import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart' show ProPlan;
import 'package:kuber/features/pro/services/billing_diagnostics.dart';
import 'package:kuber/features/pro/services/purchase_service.dart';

void main() {
  group('BillingDiagnostics', () {
    final diagnostics = BillingDiagnostics.instance;

    test('records queries and bounded log entries', () {
      diagnostics.recordQueryStart('test_query', source: 'unit_test');
      diagnostics.recordQueryEnd(
        'test_query',
        success: true,
        duration: const Duration(milliseconds: 150),
      );

      final logs = diagnostics.logs;
      expect(logs, isNotEmpty);
      expect(logs.any((l) => l.tag == 'QUERY_START'), isTrue);
      expect(logs.any((l) => l.tag == 'QUERY_SUCCESS'), isTrue);
    });

    test('records stream purchases with masked tokens', () {
      final purchase = PurchaseDetails(
        productID: kProLifetimeId,
        purchaseID: 'order_123',
        verificationData: PurchaseVerificationData(
          localVerificationData: 'local_token_data_long_123456789',
          serverVerificationData: 'server_token_data_long_123456789',
          source: 'play_store',
        ),
        transactionDate: '1700000000000',
        status: PurchaseStatus.purchased,
      );

      diagnostics.recordStreamPurchases([purchase]);
      final lastLog = diagnostics.logs.last;
      expect(lastLog.tag, 'STREAM_RECEIVED');
      expect(lastLog.details?['count'], 1);
      final list = lastLog.details?['purchases'] as List;
      expect(list.first['productId'], kProLifetimeId);
      expect(list.first['status'], 'purchased');
      expect(list.first['token'], contains('...'));
    });

    test('generates formatted text report', () async {
      final report = await diagnostics.generateDiagnosticsReport();
      expect(report, contains('=== KUBER PLAY BILLING DIAGNOSTICS ==='));
      expect(report, contains('App Version'));
      expect(report, contains('Recent Billing Logs'));
    });
  });

  group('Product Plan mappings', () {
    test('all Pro plan IDs correctly resolve', () {
      expect(planForProductId(kProMonthlyId), ProPlan.monthly);
      expect(planForProductId(kProYearlyId), ProPlan.yearly);
      expect(planForProductId(kProLifetimeId), ProPlan.lifetime);
      expect(planForProductId('unknown_id'), isNull);

      expect(productIdForPlan(ProPlan.monthly), kProMonthlyId);
      expect(productIdForPlan(ProPlan.yearly), kProYearlyId);
      expect(productIdForPlan(ProPlan.lifetime), kProLifetimeId);
    });
  });
}
