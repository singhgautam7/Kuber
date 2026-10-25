// Full-app smoke suite (specs/vcal/coverage-audit.md §3). Runs the real app
// on a device or emulator against a FRESH install, in order:
//   adb shell pm clear com.grs.kuber
//   flutter test integration_test/smoke_test.dart -d emulator-5554
// Demo data only. Each test boots main.dart again on the same database.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/kuber_cards/data/card_vault_meta.dart';
import 'package:kuber/features/kuber_cards/providers/kuber_cards_provider.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/notes/data/kuber_note.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/widgets/transfer_account_tile.dart';
import 'package:kuber/main.dart' as app;
import 'package:kuber/shared/widgets/app_scaffold.dart';

import 'smoke_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  smokeTest('onboarding: skip to setup, name, start', (t) async {
    app.main();
    await pumpUntil(t, find.text(en.getStarted), timeout: const Duration(seconds: 40));
    await tapText(t, en.getStarted);
    await tapText(t, en.skip);
    await pumpUntil(t, find.byType(TextFormField));
    await t.enterText(find.byType(TextFormField).first, 'Gaurav');
    await settle(t);
    await tapText(t, en.startJourney);
    await pumpUntil(t, find.byType(AppScaffold), timeout: const Duration(seconds: 30));
    expect(await db.accounts.count(), greaterThanOrEqualTo(3));
    expectNoErrors(t);
  });

  Future<int> catId(String type) async =>
      (await db.categorys.filter().typeEqualTo(type).findFirst())!.id;
  Future<int> accountId(String name) async =>
      (await db.accounts.filter().nameEqualTo(name).findFirst())!.id;

  smokeTest('transactions: expense, income and transfer through the form', (t) async {
    await boot(t);
    final cash = await accountId('Cash');
    final bank = await accountId('Bank');
    final before = await db.transactions.count();

    await push(t,
        '/add-transaction?type=expense&amount=240&name=Smoke%20lunch&accountId=$cash&categoryId=${await catId('expense')}');
    await tapText(t, en.saveExpense);
    await settle(t, const Duration(seconds: 1));
    expect(await db.transactions.count(), before + 1, reason: 'expense saved');
    await push(t,
        '/add-transaction?type=income&amount=50000&name=Smoke%20salary&accountId=$bank&categoryId=${await catId('income')}');
    await tapText(t, en.saveIncome);
    await settle(t, const Duration(seconds: 1));
    expect(await db.transactions.count(), before + 2, reason: 'income saved');

    // The transfer form does not take the prefill (same in 6ce4f0e): pick in UI.
    await push(t, '/add-transaction?type=transfer');
    await tapText(t, '+1000');
    await tapFinder(t, find.byType(TransferAccountTile).at(0));
    await tapText(t, 'Bank', last: true);
    await tapFinder(t, find.byType(TransferAccountTile).at(1));
    await tapText(t, 'Cash', last: true);
    await tapText(t, en.saveTransferBtn);
    await settle(t, const Duration(seconds: 2));

    final added = await db.transactions.where().findAll();
    expect(added.length, before + 4);
    final lunch = added.firstWhere((x) => x.name == 'Smoke lunch');
    expect((lunch.amount, lunch.type, lunch.accountId), (240.0, 'expense', '$cash'));
    expect(added.where((x) => x.name == 'Smoke salary').single.amount, 50000);
    expect(added.where((x) => x.isTransfer).length, 2);

    await go(t, '/history');
    await expectText(t, 'Smoke lunch');
    expectNoErrors(t);
  });

  smokeTest('SMS import: demo inbox is parsed and imported', (t) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final messenger = t.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('com.grs.kuber/sms'), (call) async {
      if (call.method == 'getInboxMessages') {
        return [
          {
            'address': 'VM-HDFCBK',
            'body': 'Rs.1,250.00 debited from a/c XX1234 on 20-10-26 to VPA zomato@hdfcbank. Ref 123456789012',
            'date': now - 86400000,
          },
          {
            'address': 'AD-ICICIB',
            'body': 'INR 45,000.00 credited to A/c XX9876 on 21-Oct-26. Info: SALARY. Avl Bal INR 1,20,000.00',
            'date': now - 3600000,
          },
        ];
      }
      return null;
    });
    messenger.setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'), (call) async {
      if (call.method == 'checkPermissionStatus') return 1;
      if (call.method == 'requestPermissions') {
        return {for (final p in (call.arguments as List)) p: 1};
      }
      if (call.method == 'shouldShowRequestPermissionRationale') return false;
      return 1;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(const MethodChannel('com.grs.kuber/sms'), null);
      messenger.setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'), null);
    });
    await boot(t);
    await go(t, '/more/sms-import');
    await settle(t, const Duration(seconds: 3));
    dumpTexts(t, 'sms');
    await pumpUntil(t, find.textContaining('1,250'), timeout: const Duration(seconds: 30));
    expectNoErrors(t);
  });

  smokeTest('Ask Kuber answers a question', (t) async {
    await boot(t);
    await go(t, '/more/ask-kuber');
    final field = find.byType(TextField);
    await pumpUntil(t, field);
    await t.enterText(field.last, 'How much did I spend this month?');
    await t.testTextInput.receiveAction(TextInputAction.send);
    await settle(t, const Duration(seconds: 4));
    dumpTexts(t, 'ask');
    await expectText(t, '240');
    expectNoErrors(t);
  });

  smokeTest('Notes: write a note, it is saved', (t) async {
    await boot(t);
    await push(t, '/notes/editor');
    await pumpUntil(t, find.byType(TextField));
    await t.enterText(find.byType(TextField).first, 'Smoke note');
    await settle(t, const Duration(seconds: 1));
    await back(t);
    await settle(t, const Duration(seconds: 1));
    expect(await db.kuberNotes.filter().titleEqualTo('Smoke note').count(), 1);
    await go(t, '/more/notes');
    await expectText(t, 'Smoke note');
    expectNoErrors(t);
  });

  Future<void> pin(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.tap(find.text('1').last, warnIfMissed: false);
      await t.pump(const Duration(milliseconds: 120));
    }
    await settle(t);
  }

  smokeTest('Kuber Cards: set a PIN, lock, unlock', (t) async {
    await boot(t);
    await push(t, '/cards');
    await settle(t, const Duration(seconds: 1));
    dumpTexts(t, 'cards');
    await tapText(t, 'Get started', last: true);
    await pin(t);
    await tapText(t, 'Continue', last: true);
    await pin(t);
    await tapText(t, 'Continue', last: true);
    await tapText(t, 'I understand there is no recovery.');
    await tapText(t, 'I understand', last: true);
    await settle(t, const Duration(seconds: 2));
    if (find.text('Skip for now').evaluate().isNotEmpty) {
      await tapText(t, 'Skip for now');
    }
    expect(await db.cardVaultMetas.count(), 1, reason: 'vault created');
    dumpTexts(t, 'cards home');
    // Lock (what the 60 s background relock does), then unlock with the PIN.
    await go(t, '/');
    container(t).read(cardSessionProvider.notifier).lock();
    await push(t, '/cards');
    await settle(t, const Duration(seconds: 1));
    expect(find.text('No cards yet'), findsNothing, reason: 'locked');
    await pin(t);
    await settle(t, const Duration(seconds: 3));
    await expectText(t, 'No cards yet');
    expectNoErrors(t);
  });

  smokeTest('Budgets: add a budget, it shows on the list', (t) async {
    await boot(t);
    await push(t, '/budgets/add');
    await tapText(t, 'Choose category');
    await pickCategory(t, 'Groceries');
    await enterField(t, 'BUDGET AMOUNT', '6000');
    await hideKeyboard(t);
    await tapText(t, en.saveBudget, last: true);
    await settle(t, const Duration(seconds: 2));
    expect(await db.budgets.count(), 1);
    await go(t, '/more/budgets');
    await expectText(t, 'Groceries');
    expectNoErrors(t);
  });

  smokeTest('Loans: add, open, extra payment sheet', (t) async {
    await boot(t);
    await push(t, '/loans/add');
    await settle(t);
    await enterField(t, en.msLoansName, 'Smoke car loan');
    await enterField(t, en.msLoansEmiAmount, '11200');
    await hideKeyboard(t);
    await tapText(t, 'Select Account');
    await tapText(t, 'Bank', last: true);
    dumpTexts(t, 'loan form');
    await tapText(t, en.msLoansSave, last: true);
    await settle(t, const Duration(seconds: 2));
    expect(await db.loans.filter().nameEqualTo('Smoke car loan').count(), 1);
    await go(t, '/more/loans');
    await dismissInfo(t);
    await tapText(t, 'Smoke car loan', last: true);
    await tapText(t, en.msLoansRecordExtra, last: true);
    dumpTexts(t, 'extra sheet');
    await expectText(t, en.msLoansExtraYes);
    await back(t);
    expectNoErrors(t);
  });

  smokeTest('Investments: add a fund, open its sheet', (t) async {
    await boot(t);
    await push(t, '/investments/add');
    await tapText(t, en.msInvTypeMutualFund);
    await enterField(t, en.msInvName, 'Smoke index fund');
    await enterField(t, en.msInvCurrentValue, '120000');
    await hideKeyboard(t);
    dumpTexts(t, 'inv form');
    await tapText(t, en.msInvSave, last: true);
    await settle(t, const Duration(seconds: 2));
    expect(await db.investments.filter().nameEqualTo('Smoke index fund').count(), 1);
    await go(t, '/more/investments');
    await dismissInfo(t);
    await tapText(t, 'Smoke index fund', last: true);
    await tapText(t, en.msInvUpdateValue, last: true);
    dumpTexts(t, 'update value');
    expectNoErrors(t);
  });

  smokeTest('Recurring: add a rule, skip next, pause', (t) async {
    await boot(t);
    await push(t, '/recurring/add');
    await enterField(t, en.msRecName, 'Smoke rent');
    await enterField(t, en.msRecAmount, '18000');
    await hideKeyboard(t);
    await tapText(t, en.selectCategoryTitle);
    await pickCategory(t, 'Rent');
    await tapText(t, 'Select Account');
    await tapText(t, 'Bank', last: true);
    dumpTexts(t, 'rec form');
    await tapText(t, en.msRecSave, last: true);
    await settle(t, const Duration(seconds: 2));
    expect(await db.recurringRules.filter().nameEqualTo('Smoke rent').count(), 1);
    await go(t, '/more/recurring');
    await dismissInfo(t);
    await tapText(t, 'Smoke rent', last: true);
    dumpTexts(t, 'rec sheet');
    await tapFinder(t, find.byIcon(Icons.more_horiz_rounded).last, reason: 'sheet overflow');
    await tapText(t, en.msRecSkipNextShort, last: true);
    await settle(t, const Duration(seconds: 1));
    final rule = (await db.recurringRules.filter().nameEqualTo('Smoke rent').findFirst())!;
    expect(rule.schedule!.skippedDates, isNotEmpty, reason: 'next date skipped');
    // Pause from the sheet.
    await tapText(t, 'Smoke rent', last: true);
    await tapText(t, en.msRecPause, last: true);
    await settle(t, const Duration(seconds: 1));
    final paused = (await db.recurringRules.filter().nameEqualTo('Smoke rent').findFirst())!;
    expect(paused.schedule!.paused, isTrue);
    expectNoErrors(t);
  });

  smokeTest('Upcoming events: Calendar, day, filter, legend, quick add', (t) async {
    final h = t.ensureSemantics();
    await boot(t);
    await go(t, '/more/upcoming-events');
    await dismissInfo(t);
    // Calendar is the default view.
    await pumpUntil(t, find.text(en.ueViewCalendar), reason: 'Calendar by default');
    await settle(t, const Duration(seconds: 2));
    final now = DateTime.now();
    await expectText(t, DateFormat('LLLL').format(now));
    expect(find.bySemanticsLabel(RegExp('^${en.ueA11yToday('')}')), findsOneWidget, reason: 'today cell');
    // Filter: EMIs only, then back to All.
    await tapText(t, en.ueFilter);
    await tapText(t, en.ueTypeEmis);
    await tapFinder(t, find.bySemanticsLabel('Close').last, reason: 'close filter');
    expect(find.text('1'), findsWidgets, reason: 'filter badge');
    await tapText(t, en.ueFilter);
    await tapText(t, en.ueTypeAll);
    await tapFinder(t, find.bySemanticsLabel('Close').last);
    // Legend from the overflow.
    await tapFinder(t, find.byIcon(Icons.more_vert_rounded).first, reason: 'overflow');
    await tapText(t, en.ueLegendTitle, last: true);
    await expectText(t, en.ueLegendIntro);
    await tapText(t, en.gotIt, last: true);
    // Long-press a day: New reminder with that date.
    await t.longPress(find.bySemanticsLabel(RegExp('^${en.ueA11yToday('')}')));
    await settle(t, const Duration(seconds: 1));
    await expectText(t, 'Save reminder');
    await back(t);
    // The choice is kept: switch to List and back.
    await tapText(t, en.ueViewCalendar);
    await tapText(t, en.ueViewList, last: true);
    await tapText(t, en.ueViewList);
    await tapText(t, en.ueViewCalendar, last: true);
    expectNoErrors(t);
    h.dispose();
  });

  smokeTest('Calculators: every tool opens', (t) async {
    await boot(t);
    for (final tool in [
      'emi-calculator', 'sip-calculator', 'sip-amount-finder', 'tip-calculator',
      'discount-calculator', 'gst-calculator', 'fd-rd-calculator', 'ppf-calculator',
      'salary-calculator', 'inflation-calculator', 'loan-prepayment', 'lumpsum-vs-sip',
      'goal-planner', 'retirement-corpus', 'breakeven-calculator', 'hra-calculator',
      'split-calculator', 'currency-converter', 'saved-calculations',
    ]) {
      await go(t, '/more/tools/$tool');
      await settle(t, const Duration(milliseconds: 600));
      expect(find.byType(Scaffold), findsWidgets, reason: tool);
      expectNoErrors(t);
    }
    await go(t, '/more/tools');
    expectNoErrors(t);
  });

  smokeTest('Backup: export and restore keep every transaction', (t) async {
    await boot(t);
    await go(t, '/more/data');
    await settle(t);
    dumpTexts(t, 'data');
    final before = await db.transactions.where().findAll();
    final json = await JsonBackupService().exportJson(db);
    final r = await JsonBackupService().importJson(db, json);
    expect(r.error, isNull);
    final after = await db.transactions.where().findAll();
    expect(after.length, before.length);
    expect(after.fold(0.0, (s, x) => s + x.amount), before.fold(0.0, (s, x) => s + x.amount));
    expectNoErrors(t);
  });

  smokeTest('Currency switch: format follows, amounts unchanged', (t) async {
    await boot(t);
    final sum = (await db.transactions.where().findAll()).fold(0.0, (s, x) => s + x.amount);
    await go(t, '/more/settings');
    await tapTextScroll(t, en.currencyLabel);
    final search = find.byType(TextField);
    await pumpUntil(t, search);
    await t.enterText(search.last, 'USD');
    await settle(t);
    dumpTexts(t, 'currency');
    await tapText(t, 'US Dollar', last: true);
    await go(t, '/history');
    await expectText(t, r'$');
    expect((await db.transactions.where().findAll()).fold(0.0, (s, x) => s + x.amount), sum);
    // Back to INR.
    await go(t, '/more/settings');
    await tapTextScroll(t, en.currencyLabel);
    await t.enterText(find.byType(TextField).last, 'INR');
    await settle(t);
    await tapText(t, 'Indian Rupee', last: true);
    expectNoErrors(t);
  });

  smokeTest('Language switch: Hindi and back', (t) async {
    await boot(t);
    await go(t, '/more/settings');
    await tapTextScroll(t, en.language);
    await tapText(t, 'हिन्दी');
    await settle(t, const Duration(seconds: 2));
    final hi = l10n(t);
    expect(hi.localeName, 'hi');
    await go(t, '/more/settings');
    await tapTextScroll(t, hi.language);
    await tapText(t, 'English');
    await settle(t, const Duration(seconds: 2));
    expect(l10n(t).localeName, 'en');
    expectNoErrors(t);
  });

  smokeTest('Themes: modes, Expressive colours, Pure black', (t) async {
    await boot(t);
    await go(t, '/more/settings/theme');
    ColorScheme cs() => Theme.of(t.element(find.byType(Scaffold).last)).colorScheme;
    Switch sw(String title) => t.widget<Switch>(find.descendant(
        of: find.ancestor(of: find.text(title), matching: find.byType(Container)).first,
        matching: find.byType(Switch)));
    Future<void> top() async {
      await t.drag(find.byType(Scrollable).first, const Offset(0, 800));
      await settle(t);
    }
    Future<void> mode(String label) async {
      await top();
      await tapText(t, label);
    }
    Future<void> toggle(String title) async {
      await top();
      await tapFinder(t, find.byWidget(sw(title)));
    }
    // Light: Pure black is disabled (no helper line).
    await mode(en.themeLightChoice);
    await settle(t, const Duration(seconds: 1));
    expect(cs().brightness, Brightness.light);
    expect(sw(en.themePureBlackTitle).onChanged, isNull);
    // Expressive off: white page.
    await toggle(en.themeExpressiveTitle);
    await settle(t, const Duration(seconds: 1));
    expect(cs().surface, const Color(0xFFFFFFFF));
    // Dark + Pure black: black page, cards stay dark grey.
    await mode(en.themeDarkChoice);
    await settle(t, const Duration(seconds: 1));
    await toggle(en.themePureBlackTitle);
    await settle(t, const Duration(seconds: 1));
    expect(cs().surface, const Color(0xFF000000));
    expect(cs().surfaceContainer, isNot(const Color(0xFF000000)));
    // Back to the defaults for the rest of the suite.
    await toggle(en.themePureBlackTitle);
    await toggle(en.themeExpressiveTitle);
    await mode(en.themeLightChoice);
    await settle(t, const Duration(seconds: 1));
    expect(cs().surface, isNot(const Color(0xFFFFFFFF)), reason: 'expressive tint back');
    expectNoErrors(t);
  });

  smokeTest('Privacy mode masks amounts on Home', (t) async {
    await boot(t);
    await go(t, '/');
    await tapFinder(t, find.byIcon(Icons.visibility_rounded), reason: 'privacy eye');
    await settle(t);
    await expectText(t, '****');
    await tapFinder(t, find.byIcon(Icons.visibility_off_rounded));
    expectNoErrors(t);
  });

  smokeTest('About and Feedback show the Telegram community link', (t) async {
    await boot(t);
    await push(t, '/more/about');
    await settle(t);
    await t.scrollUntilVisible(find.text(en.communityTelegramTitle), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text(en.communityTelegramTitle), findsOneWidget);
    await back(t);
    await push(t, '/more/feedback');
    await settle(t);
    await t.scrollUntilVisible(find.text(en.communityTelegramTitle), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text(en.communityTelegramSubtitle), findsOneWidget);
    expectNoErrors(t);
  });
}
