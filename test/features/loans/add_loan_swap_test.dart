import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/loans/data/loan.dart';
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

  // Regression (specs/vcal/regressions.md R1): saving a new loan in the
  // default mode (no loan numbers) threw on the unset principal.
  testWidgets('a new loan without numbers saves', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.runAsync(() => isar.writeTxn(() => isar.accounts.put(Account()
      ..name = 'Bank'
      ..type = 'bank')));
    final c = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(isar),
      tutorialAwareIsarProvider.overrideWithValue(isar),
    ]);
    addTearDown(c.dispose);
    await tester.runAsync(() async {
      await c.read(settingsProvider.future);
      await c.read(allAccountsProvider.future);
    });
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const AddLoanScreen()),
      GoRoute(path: '/more/loans', builder: (_, _) => const Text('loans')),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(const Locale('en')),
      ),
    ));
    await settle(tester);
    final l = lookupAppLocalizations(const Locale('en'));
    await tester.enterText(find.widgetWithText(TextField, l.loanNameHint), 'Car loan');
    await tester.enterText(find.widgetWithText(TextField, '0').first, '11200');
    await settle(tester);
    await tester.tap(find.text('Select Account'));
    await settle(tester);
    await tester.tap(find.text('Bank').last);
    await settle(tester);
    await tester.tap(find.text(l.msLoansSave));
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.takeException(), isNull);
    final saved = await tester.runAsync(() => isar.loans.filter().nameEqualTo('Car loan').findFirst());
    expect(saved, isNotNull);
    expect(saved!.principalAmount, 0);
    expect(saved.emiAmount, 11200);
    expect(saved.mode, LoanMode.simple);
    // Let the saved snackbar's timer run out.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
