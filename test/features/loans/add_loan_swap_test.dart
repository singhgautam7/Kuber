import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/loans/screens/add_loan_screen.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/tutorial/providers/tutorial_sandbox_provider.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Isar isar;

  setUpAll(() async {
    await initialiseIsarForTests();
    isar = await openTestIsar();
  });
  tearDownAll(() => closeAndCleanIsar(isar));

  // Amount fields group digits ("10,379"); compare without separators.
  Finder fieldWith(int value) => find.byWidgetPredicate(
      (w) => w is TextField && w.controller?.text.replaceAll(',', '') == '$value');

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('three numbers fill the fourth; a fourth typed swaps out the oldest',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final c = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(isar),
      tutorialAwareIsarProvider.overrideWithValue(isar),
    ]);
    addTearDown(c.dispose);
    await tester.runAsync(() async {
      await c.read(settingsProvider.future);
      await c.read(allAccountsProvider.future);
    });
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(const Locale('en')),
        home: const AddLoanScreen(amountPrefill: 500000, ratePrefill: 9, monthsPrefill: 60),
      ),
    ));
    await settle(tester);

    // Principal, rate and tenure given: the EMI is calculated.
    final emi = calculateEmi(500000, 9, 60).round();
    expect(emi, 10379);
    expect(fieldWith(emi), findsWidgets);
    expect(find.text('Calculated'), findsWidgets);
    expect(find.text('Filled in order: principal, interest rate, tenure.'), findsOneWidget);

    // Typing the EMI makes the oldest (principal) the calculated one.
    await tester.enterText(fieldWith(emi).last, '12000');
    await settle(tester);
    expect(find.textContaining('so principal (filled first) is now calculated'), findsOneWidget);
    final principal = solveLoan(rate: 9, months: 60, emi: 12000).principal.round();
    expect(fieldWith(principal), findsWidgets);
  });
}
