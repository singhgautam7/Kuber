// Editing a loan and saving without touching its numbers must keep them.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
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

  Future<Loan> edit(WidgetTester t, Loan stored) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1080, 6000);
    t.view.devicePixelRatio = 2.5;
    addTearDown(t.view.reset);
    final c = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(isar),
      tutorialAwareIsarProvider.overrideWithValue(isar),
    ]);
    addTearDown(c.dispose);
    await t.runAsync(() async {
      await c.read(settingsProvider.future);
      await c.read(allAccountsProvider.future);
    });
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('list'))),
      GoRoute(path: '/edit', builder: (_, _) => AddLoanScreen(existing: stored)),
    ]);
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    router.push('/edit');
    for (var i = 0; i < 8; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
    await t.tap(find.text('Save changes'));
    for (var i = 0; i < 8; i++) {
      await t.pump(const Duration(milliseconds: 120));
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    }
    await drainIsarWrites(t, isar);
    final out = (await t.runAsync(() => isar.loans.get(stored.id)))!;
    // Let the saved snackbar's timer run out.
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 10));
    return out;
  }

  testWidgets('a rename-style save keeps principal, rate, tenure and start', (t) async {
    late Loan l;
    await t.runAsync(() async {
      await isar.writeTxn(() => isar.clear());
      final id = await isar.writeTxn(() => isar.accounts.put(Account()
        ..name = 'Bank'
        ..type = 'bank'));
      l = await LoanService(isar).save(
          Loan()
            ..name = 'Home'
            ..loanType = 'home'
            ..lenderName = 'B'
            ..accountId = '$id'
            ..principalAmount = 2500000
            ..emiAmount = 21696
            ..mode = LoanMode.advanced
            ..annualRate = 8.125
            ..tenureMonths = 240,
          scheduleFrom(start: DateTime(2030, 1, 5), endType: ScheduleEnd.afterCount, endCount: 240),
          isNew: true);
    });
    final saved = await edit(t, l);
    expect(saved.startingPoint, LoanStartingPoint.originalDetails);
    expect(saved.annualRate, 8.125);
    expect(saved.principalAmount, 2500000);
    expect(saved.tenureMonths, 240);
    expect(saved.mode, LoanMode.advanced);
    expect(saved.emiAmount, 21696);
  });

  testWidgets('an outstanding-today loan keeps its schedule and tenure', (t) async {
    late Loan l;
    await t.runAsync(() async {
      await isar.writeTxn(() => isar.clear());
      final id = await isar.writeTxn(() => isar.accounts.put(Account()
        ..name = 'Bank'
        ..type = 'bank'));
      l = await LoanService(isar).save(
          Loan()
            ..name = 'Car'
            ..loanType = 'vehicle'
            ..lenderName = 'B'
            ..accountId = '$id'
            ..principalAmount = 900000
            ..emiAmount = 18000
            ..mode = LoanMode.advanced
            ..annualRate = 9.25
            ..tenureMonths = 30
            ..alreadyRunning = true
            ..startingPoint = LoanStartingPoint.outstandingToday
            ..outstandingAtStart = 450000,
          scheduleFrom(start: DateTime(2027, 1, 5), endType: ScheduleEnd.afterCount, endCount: 30),
          isNew: true);
    });
    final saved = await edit(t, l);
    expect(saved.startingPoint, LoanStartingPoint.outstandingToday);
    expect(saved.tenureMonths, 30);
    expect(saved.schedule!.startDate, DateTime(2027, 1, 5));
    expect(saved.outstandingAtStart, 450000);
  });

  testWidgets('releases and pre-EMI settings survive an edit', (t) async {
    late Loan l;
    await t.runAsync(() async {
      await isar.writeTxn(() => isar.clear());
      final id = await isar.writeTxn(() => isar.accounts.put(Account()
        ..name = 'Bank'
        ..type = 'bank'));
      l = await LoanService(isar).save(
          Loan()
            ..name = 'Home'
            ..loanType = 'home'
            ..lenderName = 'B'
            ..accountId = '$id'
            ..principalAmount = 1700000
            ..emiAmount = 15782
            ..mode = LoanMode.advanced
            ..annualRate = 9.2
            ..tenureMonths = 240
            ..loanStartDate = DateTime(2017, 1, 12)
            ..releasedInParts = true
            ..preEmiMode = LoanPreEmi.addToLoan
            ..preEmiCycleDay = 12
            ..releases = [
              LoanRelease()
                ..date = DateTime(2017, 1, 12)
                ..amount = 500000,
            ],
          scheduleFrom(start: DateTime(2017, 11, 13), endType: ScheduleEnd.afterCount, endCount: 240),
          isNew: true);
    });
    final saved = await edit(t, l);
    expect(saved.releasedInParts, isTrue);
    expect(saved.releases.single.amount, 500000);
    expect(saved.preEmiMode, LoanPreEmi.addToLoan);
    expect(saved.preEmiCycleDay, 12);
    expect(saved.loanStartDate, DateTime(2017, 1, 12));
  });
}
