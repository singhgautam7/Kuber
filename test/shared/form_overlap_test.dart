// Pinned bottom buttons must never cover a form field: at 360x640, text scale
// 2.0, keyboard closed and open. See KuberFormScaffold / KuberBottomSheet.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/accounts/screens/edit_account_screen.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/budgets/screens/add_edit_budget_screen.dart';
import 'package:kuber/features/kuber_cards/providers/kuber_cards_provider.dart';
import 'package:kuber/features/kuber_cards/screens/add_edit_card_screen.dart';
import 'package:kuber/features/loans/screens/add_loan_screen.dart';
import 'package:kuber/features/loans/widgets/loan_adjust_sheet.dart';
import 'package:kuber/features/recurring/screens/add_recurring_screen.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/transactions/screens/add_transaction_screen.dart';
import 'package:kuber/features/transactions/widgets/notes_field.dart';
import 'package:kuber/features/tutorial/providers/tutorial_sandbox_provider.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/app_button.dart';
import 'package:kuber/shared/widgets/kuber_form_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/isar_test_helper.dart';
import '../helpers/test_factories.dart';

const _keyboard = 260.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Isar isar;
  setUpAll(initialiseIsarForTests);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    isar = await openTestIsar();
  });
  tearDown(() => closeAndCleanIsar(isar));

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 8; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 15)));
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> pump(WidgetTester t, Widget home, {List<Override> overrides = const []}) async {
    // Text scale 2.0 overflows some existing screens (not what this checks).
    final prev = FlutterError.onError;
    FlutterError.onError = (d) {
      if (d.exceptionAsString().contains('overflowed')) return;
      prev?.call(d);
    };
    addTearDown(() => FlutterError.onError = prev);
    t.view.physicalSize = const Size(360, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final c = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(isar),
      tutorialAwareIsarProvider.overrideWithValue(isar),
      ...overrides,
    ]);
    addTearDown(c.dispose);
    await t.runAsync(() async {
      await c.read(settingsProvider.future);
      await c.read(allAccountsProvider.future);
    });
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(const Locale('en')),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0)),
          child: child!,
        ),
        home: home,
      ),
    ));
    await settle(t);
  }

  // With the keyboard up Flutter scrolls the caret line (not the whole field)
  // into view, so only the field's first line must be clear.
  void expectClear(WidgetTester t, Finder field, Finder? button, {double bottomLimit = 640, bool caretOnly = false}) {
    final f = t.getRect(field);
    var limit = bottomLimit;
    if (button != null) {
      final b = t.getRect(button);
      if (b.top < limit) limit = b.top;
    }
    final probe = caretOnly ? Offset(f.center.dx, f.top + 20) : f.center;
    expect(caretOnly ? probe.dy : f.bottom, lessThanOrEqualTo(limit + 0.5), reason: 'field $f runs under the pinned button / keyboard ($limit)');
    expect(f.top, greaterThanOrEqualTo(0), reason: 'field $f above the screen');
    final hit = HitTestResult();
    t.binding.hitTestInView(hit, probe, t.view.viewId);
    final fieldRo = t.renderObject(field);
    bool inField(RenderObject? o) {
      for (; o != null; o = o.parent) {
        if (o == fieldRo) return true;
      }
      return false;
    }

    expect(
      hit.path.any((e) => e.target is RenderObject && inField(e.target as RenderObject)),
      isTrue,
      reason: 'field centre is not hit-testable (something covers it)',
    );
  }

  /// Keyboard closed (scrolled to the end), then open with the field focused.
  Future<void> checkForm(WidgetTester t, Finder field, Finder? button) async {
    // Worst case for a pinned button: the field scrolled to the very bottom.
    await t.runAsync(() async {
      Scrollable.ensureVisible(t.element(field), alignment: 1.0);
    });
    await settle(t);
    expectClear(t, field, button);

    // Focus while the field is visible, then the keyboard slides up.
    await t.tap(field, warnIfMissed: false);
    await settle(t);
    t.view.viewInsets = const FakeViewPadding(bottom: _keyboard);
    addTearDown(t.view.resetViewInsets);
    await t.pump();
    await settle(t);
    expectClear(t, field, button, bottomLimit: 640 - _keyboard, caretOnly: true);
  }

  testWidgets('Edit transaction: note field above Update Expense', (t) async {
    final tx = await t.runAsync(() async {
      late int accId, catId;
      await isar.writeTxn(() async {
        accId = await isar.accounts.put(makeAccount(name: 'Bank'));
        catId = await isar.categorys.put(makeCategory(name: 'Food'));
      });
      final tx = makeTransaction(accountId: '$accId', categoryId: '$catId', notes: 'lunch');
      await isar.writeTxn(() => isar.transactions.put(tx));
      return tx;
    });
    await pump(t, AddTransactionScreen(transaction: tx));
    final notes = find.descendant(of: find.byType(NotesField), matching: find.byType(TextField));
    await checkForm(t, notes, find.widgetWithText(AppButton, 'Update Expense'));
  });

  testWidgets('Loan form', (t) async {
    await pump(t, const AddLoanScreen());
    await checkForm(t, find.byType(TextField).last, find.byType(KuberSaveButton));
  });

  testWidgets('Recurring form', (t) async {
    await pump(t, const AddRecurringScreen());
    await checkForm(t, find.byType(TextField).last, find.byType(KuberSaveButton));
  });

  testWidgets('Budget form', (t) async {
    // No pinned button on this form: the check is the field vs the keyboard.
    await pump(t, const AddEditBudgetScreen());
    await checkForm(t, find.byType(TextField).last, null);
  });

  testWidgets('Account edit', (t) async {
    final acc = (await t.runAsync(() async {
      final a = makeAccount(name: 'Bank');
      await isar.writeTxn(() => isar.accounts.put(a));
      return a;
    }))!;
    await pump(t, EditAccountScreen(account: acc));
    await checkForm(t, find.byType(TextField).last, find.byType(AppButton).last);
  });

  testWidgets('Kuber Cards add', (t) async {
    await pump(t, const AddEditCardScreen(), overrides: [cardsUnlockedProvider.overrideWithValue(true)]);
    await checkForm(t, find.byType(TextField).last, find.byType(KuberSaveButton));
  });

  testWidgets('KuberBottomSheet form: loan Update outstanding', (t) async {
    final loan = (await t.runAsync(() async {
      final l = makeLoan();
      await isar.writeTxn(() => isar.loans.put(l));
      return l;
    }))!;
    await pump(
      t,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showUpdateOutstandingSheet(context, loan),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await settle(t);
    await checkForm(t, find.byType(TextField).last, find.byType(AppButton).last);
  });
}
