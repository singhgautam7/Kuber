// Regression: Close loan from the loan sheet did nothing (the sheet closed
// first and its disposed ref was used after the confirm dialog). A closed
// loan's sheet shows Re-open loan on the second row; the overflow keeps Edit
// and Delete.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:kuber/features/loans/widgets/loan_sheet.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/l10n/app_localizations_en.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  setUpAll(initialiseIsarForTests);
  setUp(() async => isar = await openTestIsar());
  tearDown(() => closeAndCleanIsar(isar));
  final l = AppLocalizationsEn();

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 8; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('Close loan works from the sheet; Re-open brings it back', (t) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.5;
    addTearDown(t.view.reset);
    final loan = (await t.runAsync(() async {
      await SharedPreferences.getInstance();
      final start = DateTime.now().subtract(const Duration(days: 40));
      return LoanService(isar).save(
          Loan()
            ..name = 'Car loan'
            ..loanType = 'vehicle'
            ..lenderName = 'SBI'
            ..accountId = '1'
            ..principalAmount = 0
            ..emiAmount = 11200,
          scheduleFrom(start: start)..autoRecord = true,
          isNew: true);
    }))!;
    final c = ProviderContainer(overrides: [isarProvider.overrideWithValue(isar)]);
    addTearDown(c.dispose);
    await t.runAsync(() => c.read(settingsProvider.future));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: AppTheme.light(const Locale('en')),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Consumer(
          builder: (context, ref, _) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  final fresh = await isar.loans.filter().uidEqualTo(loan.uid).findFirst();
                  if (context.mounted) showLoanSheet(context, ref, fresh!);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    Future<void> open() async {
      await t.tap(find.text('open'));
      await settle(t);
    }

    // Close loan: overflow -> Close loan -> confirm.
    await open();
    expect(find.text(l.msLoansRecordExtra), findsOneWidget);
    await t.tap(find.byIcon(Icons.more_horiz_rounded).last);
    await settle(t);
    await t.tap(find.text(l.msLoansCloseLoan).last);
    await settle(t);
    await t.tap(find.text(l.msLoansCloseLoan).last); // dialog confirm
    await settle(t);
    Loan? saved = await t.runAsync<Loan?>(() => isar.loans.filter().uidEqualTo(loan.uid).findFirst());
    expect(saved!.closedAt, isNotNull, reason: 'Close loan must close it');
    expect(t.takeException(), isNull);

    // Closed: Re-open on the second row; overflow has Edit and Delete only.
    await open();
    expect(find.text(l.msLoansRecordExtra), findsNothing);
    expect(find.text(l.msLoansReopen), findsOneWidget);
    await t.tap(find.byIcon(Icons.more_horiz_rounded).last);
    await settle(t);
    expect(find.text(l.editLabel), findsOneWidget);
    expect(find.text(l.deleteLabel), findsOneWidget);
    expect(find.text(l.msLoansCloseLoan), findsNothing);
    expect(find.text(l.msLoansChangeRate), findsNothing);
    await t.tapAt(const Offset(10, 10)); // dismiss the menu
    await settle(t);

    // Re-open: confirm, it is active again.
    await t.tap(find.text(l.msLoansReopen));
    await settle(t);
    await t.tap(find.text(l.msLoansReopen).last); // dialog confirm
    await settle(t);
    saved = await t.runAsync<Loan?>(() => isar.loans.filter().uidEqualTo(loan.uid).findFirst());
    expect(saved!.closedAt, isNull);
    expect(saved.isCompleted, isFalse);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 5));
  });
}
