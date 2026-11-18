// Loads Generate mock data into an onboarded install (website screenshots).
//   flutter test integration_test/demo_data_test.dart -d <id> --no-uninstall
// Never on Kuber_QA: it replaces the data (keeps the entitlement row).
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kuber/core/services/mock_data_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

import 'smoke_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('load demo data', (t) async {
    await boot(t);
    await MockDataService.generate(db);
    await settle(t, const Duration(seconds: 3));
    expect(await db.transactions.count(), greaterThan(10));
  });
}
