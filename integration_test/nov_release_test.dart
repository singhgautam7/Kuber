// November release on a device: fresh install through the welcome flow, then
// loans, Settings, links, search, path sheet, themes and the Pro FAQ.
//   adb shell pm clear com.grs.kuber
//   flutter test integration_test/nov_release_test.dart -d emulator-5554
// A host script takes a screenshot on each KUBER_SHOT line
// (specs/nov-release/perf-harness/shots.sh).
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/core/theme/theme_families.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/kuber_cards/data/stored_card.dart';
import 'package:kuber/features/kuber_cards/providers/kuber_cards_provider.dart';
import 'package:kuber/features/ledger/data/ledger.dart';
import 'package:kuber/features/ledger/providers/ledger_provider.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:kuber/features/loans/providers/loan_provider.dart';
import 'package:kuber/features/loans/widgets/loan_add_sheet.dart';
import 'package:kuber/features/loans/widgets/loan_sheet.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/services/notification_service.dart' show KuberChannel;
import 'package:kuber/features/dev/providers/dev_mode_provider.dart';
import 'package:kuber/features/notifications/data/app_notification.dart';
import 'package:kuber/features/notifications/data/notification_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kuber/features/notes/data/kuber_note.dart';
import 'package:kuber/features/notes/providers/notes_provider.dart';
import 'package:kuber/features/notifications/utils/notification_routes.dart';
import 'package:kuber/features/reminders/data/reminder.dart';
import 'package:kuber/features/reminders/providers/reminders_provider.dart';
import 'package:kuber/features/tags/data/tag.dart';
import 'package:kuber/features/tags/providers/tag_providers.dart';
import 'package:kuber/features/pro/paywall/pro_faq_section.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/settings/settings_index.dart';
import 'package:kuber/features/settings/widgets/settings_anchor.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/helpers/transaction_filters.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:kuber/main.dart' as app;
import 'package:kuber/shared/widgets/app_scaffold.dart';
import 'package:kuber/shared/widgets/kuber_path.dart';
import 'package:kuber/shared/widgets/money_widgets.dart';

import 'smoke_helpers.dart';

/// Waits for the screenshot taken from the host.
Future<void> shot(WidgetTester t, String name) async {
  debugPrint('KUBER_SHOT $name');
  await settle(t, const Duration(milliseconds: 1500));
}

LoanRelease part(int y, int m, int d, double amount, [String? account]) => LoanRelease()
  ..date = DateTime(y, m, d)
  ..amount = amount
  ..accountId = account;

LoanEvent ev(LoanEventKind k, int y, int m, int d, double amount) => LoanEvent()
  ..kind = k
  ..date = DateTime(y, m, d)
  ..amount = amount;

Future<Loan> federal() async {
  final s = scheduleFrom(start: DateTime(2017, 11, 13), endType: ScheduleEnd.afterCount, endCount: 240)
    ..autoRecord = false;
  final l = Loan()
    ..name = 'Home Loan'
    ..loanType = 'home'
    ..lenderName = 'Federal Bank'
    ..accountId = '${(await db.accounts.where().findFirst())!.id}'
    ..principalAmount = 1700000
    ..emiAmount = 15782
    ..mode = LoanMode.advanced
    ..annualRate = 9.2
    ..tenureMonths = 240
    ..loanStartDate = DateTime(2017, 1, 12)
    ..releasedInParts = true
    ..preEmiMode = LoanPreEmi.addToLoan
    ..preEmiCycleDay = 12
    ..alreadyRunning = true
    ..releases = [
      part(2017, 1, 12, 500000),
      part(2017, 3, 28, 500000),
      part(2017, 5, 6, 500000),
      part(2017, 6, 19, 200000),
    ]
    ..events = [
      ev(LoanEventKind.chargeAdded, 2017, 1, 21, 1328),
      ev(LoanEventKind.prepayment, 2017, 1, 23, 1328),
      ev(LoanEventKind.prepayment, 2017, 3, 3, 5000),
      ev(LoanEventKind.prepayment, 2017, 5, 5, 9500),
      ev(LoanEventKind.prepayment, 2017, 10, 13, 12435),
    ];
  return LoanService(db).save(l, s, isNew: true);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  smokeTest('B: fresh install, Start fresh, notifications, data page', (t) async {
    app.main();
    await pumpUntil(t, find.text(en.obStartFresh), timeout: const Duration(seconds: 40));
    await shot(t, 'welcome/01-first-page');
    // Language switches at once.
    await tapText(t, 'English');
    await settle(t);
    await shot(t, 'welcome/01b-language-sheet');
    await tapText(t, 'हिन्दी');
    await settle(t, const Duration(seconds: 2));
    await shot(t, 'welcome/02-first-page-hindi');
    await tapText(t, 'हिन्दी');
    await tapText(t, 'English');
    await settle(t, const Duration(seconds: 2));
    await tapText(t, en.obStartFresh);
    await pumpUntil(t, find.text(en.getStarted));
    await tapText(t, en.getStarted);
    await tapText(t, en.skip);
    await pumpUntil(t, find.byType(TextFormField));
    await t.enterText(find.byType(TextFormField).first, 'Gaurav');
    await settle(t);
    await tapText(t, en.homeV33TourNext);
    await pumpUntil(t, find.text(en.obNotifTitle));
    await hideKeyboard(t);
    await settle(t, const Duration(seconds: 1));
    await shot(t, 'welcome/03-notifications');
    await tapText(t, en.obNotifLater);
    await pumpUntil(t, find.text(en.obTermsTitle));
    await shot(t, 'welcome/04-data-page-locked');
    // The button stays off until both are checked.
    await tapText(t, en.obTermsAgree);
    expect(find.text(en.obTermsTitle), findsOneWidget);
    await tapText(t, en.obTermsCheck1);
    await shot(t, 'welcome/04b-data-page-one');
    await tapText(t, en.obTermsAgree);
    expect(find.text(en.obTermsTitle), findsOneWidget);
    await tapText(t, en.obTermsCheck2);
    await shot(t, 'welcome/05-data-page-ready');
    await tapText(t, en.obTermsAgree);
    await pumpUntil(t, find.byType(AppScaffold), timeout: const Duration(seconds: 30));
    expectNoErrors(t);
  });

  smokeTest('A6: Federal Bank through the app', (t) async {
    await boot(t);
    final l = await federal();
    container(t).invalidate(loanListProvider);
    await go(t, '/more');
    await push(t, '/more/loans');
    await dismissInfo(t);
    await shot(t, 'loans/01-list');
    showMoneySheet<void>(rootContext(t), LoanSheet(loan: l));
    await settle(t, const Duration(seconds: 1));
    await shot(t, 'loans/02-sheet');
    final a = loanAmortization(l)!;
    final st = loanStatus(l, const [], now: DateTime(2017, 10, 20));
    debugPrint('KUBER_NUM federal balance=${a.preEmi!.balance} interest=${a.preEmi!.addedInterest} '
        'charges=${a.addedCharges} outstandingOct=${st.outstanding}');
    expect((a.preEmi!.balance - 1759591).abs(), lessThanOrEqualTo(15));
    await tapText(t, en.msLoansViewSchedule);
    await settle(t, const Duration(seconds: 2));
    await shot(t, 'loans/03-schedule-today');
    await t.fling(find.byType(Scrollable).first, const Offset(0, 3000), 3000);
    await settle(t);
    await tapText(t, en.msLoansYear);
    await shot(t, 'loans/05-schedule-years');
    await tapText(t, en.msLoansMonth);
    await tapFinder(t, find.byIcon(Icons.arrow_drop_down_rounded));
    await tapText(t, '2017', last: true);
    await settle(t, const Duration(seconds: 1));
    await shot(t, 'loans/04-schedule-2017');
    expectNoErrors(t);
  });

  smokeTest('A6: personal loan paid into an account, totals untouched', (t) async {
    await boot(t);
    final account = (await db.accounts.where().findFirst())!;
    final before = (await db.transactions.where().findAll()).validForCalculations.length;
    final balances = await container(t).read(accountBalancesProvider.future);
    final start = balances[account.id] ?? 0;
    final today = DateTime.now();
    final d1 = DateTime(today.year, today.month - 2, 1), d2 = DateTime(today.year, today.month - 1, 1);
    final s = scheduleFrom(start: DateTime(today.year, today.month + 1, 5),
        endType: ScheduleEnd.afterCount, endCount: 36)..autoRecord = false;
    final l = await LoanService(db).save(
        Loan()
          ..name = 'Personal'
          ..loanType = 'personal'
          ..lenderName = 'Bank'
          ..accountId = '${account.id}'
          ..principalAmount = 500000
          ..emiAmount = 0
          ..mode = LoanMode.advanced
          ..annualRate = 12
          ..tenureMonths = 36
          ..loanStartDate = d1
          ..releasedInParts = true
          ..releases = [
            part(d1.year, d1.month, 1, 200000, '${account.id}'),
            part(d2.year, d2.month, 1, 300000, '${account.id}'),
          ],
        s,
        isNew: true);
    container(t)
      ..invalidate(transactionListProvider)
      ..invalidate(loanListProvider);
    await settle(t);
    final after = await container(t).read(accountBalancesProvider.future);
    expect(after[account.id], closeTo(start + 500000, 0.01));
    expect((await db.transactions.where().findAll()).validForCalculations.length, before);
    expect(loanAmortization(l)!.openingBalance, 500000);
    await go(t, '/history');
    await settle(t, const Duration(seconds: 1));
    await shot(t, 'loans/06-history-disbursement');
    expectNoErrors(t);
  });

  smokeTest('A3: Add to loan sheet', (t) async {
    await boot(t);
    final l = (await db.loans.filter().nameEqualTo('Home Loan').findFirst())!;
    showAddToLoanSheet(rootContext(t), l);
    await settle(t, const Duration(seconds: 1));
    await shot(t, 'loans/07-add-to-loan');
    await back(t);
    await go(t, '/more/loans');
    await push(t, '/loans/edit', extra: l);
    await settle(t);
    final form = find.byType(Scrollable).first;
    await t.scrollUntilVisible(find.text(en.msLoansAddPart), 300, scrollable: form, maxScrolls: 40);
    await settle(t);
    await shot(t, 'loans/08-form-parts');
    await t.scrollUntilVisible(find.text(en.msLoansPreEmiAdd), 300, scrollable: form, maxScrolls: 40);
    await settle(t);
    await shot(t, 'loans/09-form-pre-emi');
    expectNoErrors(t);
  });

  const pages = {
    'main': '/more/settings',
    'look': '/more/settings/look',
    'preferences': '/more/settings/preferences',
    'privacy': '/more/settings/privacy',
    'app-drawer': '/more/settings/app-drawer',
    'notifications': '/more/settings/notifications',
    'help': '/more/settings/help',
    'activity': '/more/settings/activity',
    'data': '/more/data',
  };

  smokeTest('C: every Settings page, light and dark', (t) async {
    await boot(t);
    final settings = container(t).read(settingsProvider.notifier);
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await settings.setThemeMode(mode);
      for (final e in pages.entries) {
        await go(t, '/more');
        await push(t, e.value);
        await settle(t);
        await shot(t, 'settings/${e.key}-${mode.name}');
      }
    }
    await settings.setThemeMode(ThemeMode.light);
    await go(t, '/more');
    await settle(t);
    await shot(t, 'settings/more-tab');
    expectNoErrors(t);
  });

  smokeTest('C: moved settings still take effect', (t) async {
    await boot(t);
    final c = container(t);
    await go(t, '/more');
    await push(t, '/more/settings/privacy');
    final was = c.read(privacyModeProvider);
    await tapFinder(t, find.byType(Switch).first);
    expect(c.read(privacyModeProvider), !was);
    await tapFinder(t, find.byType(Switch).first);
    expect(c.read(privacyModeProvider), was);
    await go(t, '/more');
    await push(t, '/more/settings/preferences');
    final code = c.read(settingsProvider).valueOrNull!.showCurrencyCode;
    await tapFinder(t, find.byType(Switch).first);
    expect(c.read(settingsProvider).valueOrNull!.showCurrencyCode, !code);
    await tapFinder(t, find.byType(Switch).first);
    await go(t, '/more');
    await push(t, '/more/settings/look');
    await tapText(t, en.setBottomNav);
    await tapText(t, en.setNavStandard, last: true);
    expect(c.read(settingsProvider).valueOrNull!.navBarStyle, NavBarStyle.classic);
    await tapText(t, en.setBottomNav);
    await tapText(t, en.setNavFloating, last: true);
    expect(c.read(settingsProvider).valueOrNull!.navBarStyle, NavBarStyle.modern);
    await tapText(t, en.setMoreLayout);
    await tapText(t, en.setLayoutHero, last: true);
    expect(c.read(moreTabLayoutProvider), MoreTabLayout.modern);
    await tapText(t, en.setMoreLayout);
    await tapText(t, en.simpleLabel, last: true);
    expect(c.read(moreTabLayoutProvider), MoreTabLayout.simple);
    await go(t, '/more');
    await push(t, '/more/settings/preferences');
    final swipe = find.descendant(of: find.byWidgetPredicate((w) => w is SettingsAnchor && w.id == 'swipe'), matching: find.byType(Switch));
    await t.scrollUntilVisible(swipe, 300, scrollable: find.byType(Scrollable).first, maxScrolls: 20);
    await settle(t);
    await tapFinder(t, swipe);
    expect(c.read(settingsProvider).valueOrNull!.swipeMode, SwipeMode.performActions);
    await tapFinder(t, swipe);
    expect(c.read(settingsProvider).valueOrNull!.swipeMode, SwipeMode.changeTabs);
    await t.scrollUntilVisible(find.text(en.setNumberFormat), -300, scrollable: find.byType(Scrollable).first, maxScrolls: 20);
    await settle(t);
    await tapText(t, en.setNumberFormat);
    await tapText(t, en.setNumMillion, last: true);
    expect(c.read(settingsProvider).valueOrNull!.numberSystem, NumberSystem.international);
    await tapText(t, en.setNumberFormat);
    await tapText(t, en.setNumLakh, last: true);
    expect(c.read(settingsProvider).valueOrNull!.numberSystem, NumberSystem.indian);
    await go(t, '/more');
    await push(t, '/more/settings/notifications');
    await settle(t);
    // The rows show the phone's categories, no switches of Kuber's own.
    expect(find.byType(Switch), findsNothing);
    expect(find.text(en.obNotifEmi), findsOneWidget);
    expect(find.text(en.setNotifLedger), findsOneWidget);
    await shot(t, 'settings/notifications-categories');
    final android = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!;
    final channels = {for (final ch in (await android.getNotificationChannels())!) ch.id: ch.name};
    debugPrint('KUBER_NUM channels $channels');
    for (final ch in KuberChannel.values) {
      expect(channels[ch.id], ch.text(en).$1);
    }
    expect(channels.containsKey('kuber_recurring'), isFalse);
    expect(channels.containsKey('kuber_loan_emi'), isFalse);
    expectNoErrors(t);
  });

  smokeTest('C1: every old link lands', (t) async {
    await boot(t);
    const links = {
      '/more/data': 'Data and backup',
      '/more/data/automatic-backups': null,
      '/more/widgets-gallery': null,
      '/more/upcoming-events': null,
      '/more/stories-archive': null,
      '/settings/quick-actions': null,
      '/settings/add-menu': null,
      '/widget-editor/home': null,
      '/widget-editor/analytics': null,
      // These scroll to the row, so the row is what must show.
      '/more/settings/preferences?row=language': 'Language',
      '/more/settings/preferences?row=defaultAccount': 'Default account',
      '/more/settings/preferences?row=currency': 'Currency',
      '/more/settings/look?row=theme': 'Theme',
      '/more/settings/privacy?row=privacyMode': 'Privacy',
      '/more/about': null,
      '/pro': null,
      '/widgets-gallery': null,
      '/upcoming-events': null,
    };
    for (final e in links.entries) {
      await go(t, '/more');
      await push(t, e.key);
      await settle(t, const Duration(milliseconds: 600));
      if (e.value != null) await expectText(t, e.value!);
      expectNoErrors(t);
    }
    await go(t, '/more');
    await go(t, resolveNotificationRoute('background:backup').page);
    expectNoErrors(t);
  });

  smokeTest('C3: search finds settings by keyword, opens and flashes the row', (t) async {
    await boot(t);
    const searches = {
      'dark': 'theme', 'lock': 'biometric', 'hindi': 'language', 'lakh': 'numberFormat', 'font': 'textSize',
      'backup': 'backup', 'calendar': 'upcoming', 'swipe': 'swipe', 'alerts': 'notifPermission', 'pin': 'cardsPin',
    };
    for (final e in searches.entries) {
      await go(t, '/');
      await go(t, '/more');
      await tapFinder(t, find.byIcon(Icons.search_rounded));
      await t.enterText(find.byType(EditableText).last, e.key);
      await settle(t);
      final entry = kSettingsIndex.firstWhere((x) => x.id == e.value);
      final title = entry.title(en);
      final row = find.text(title, findRichText: true);
      await pumpUntil(t, row, reason: title);
      if (e.key == 'lock') await shot(t, 'settings/search-results');
      if (entry.id == 'cardsPin') {
        // Shown once a vault exists.
        await back(t);
        continue;
      }
      await tapFinder(t, row.last);
      await settle(t, const Duration(milliseconds: 500));
      if (e.key == 'lock') await shot(t, 'settings/search-highlight');
      expect(find.byType(SettingsAnchor), findsWidgets, reason: e.key);
      await settle(t, const Duration(seconds: 2));
      expectNoErrors(t);
    }
  });

  smokeTest('C4: search across every kind of result', (t) async {
    await boot(t);
    final c = container(t);
    final bank = (await db.accounts.where().findFirst())!;
    await db.writeTxn(() async {
      await db.accounts.putAll([
        Account()
          ..name = 'HDFC Savings'
          ..type = 'bank'
          ..initialBalance = 84210
          ..icon = 'account_balance',
        Account()
          ..name = 'HDFC Millennia'
          ..type = 'bank'
          ..isCreditCard = true
          ..initialBalance = 0
          ..icon = 'credit_card',
      ]);
      await db.tags.put(Tag()
        ..name = "Rahul's wedding"
        ..createdAt = DateTime(2026, 10, 1));
      await db.ledgers.put(Ledger()
        ..uid = 'search-ledger'
        ..personName = 'Rahul Verma'
        ..personNameLower = 'rahul verma'
        ..type = 'lent'
        ..originalAmount = 5000
        ..accountId = '${bank.id}'
        ..categoryId = '1'
        ..expectedDate = DateTime(2026, 11, 30)
        ..createdAt = DateTime(2026, 10, 1)
        ..updatedAt = DateTime(2026, 10, 1));
      await db.reminders.put(Reminder()
        ..title = 'Renew HDFC FD'
        ..dueAt = DateTime(2026, 11, 18, 9)
        ..status = 'pending'
        ..createdAt = DateTime(2026, 10, 1)
        ..updatedAt = DateTime(2026, 10, 1));
      await db.storedCards.put(StoredCard()
        ..nickname = 'HDFC Millennia'
        ..last4 = '4242'
        ..cardType = 'credit');
      await db.kuberNotes.put(KuberNote()
        ..title = 'HDFC netbanking steps'
        ..content = '[{"insert":"my hidden text"}]'
        ..createdAt = DateTime(2026, 11, 2)
        ..updatedAt = DateTime(2026, 11, 2));
    });
    for (final p in <ProviderOrFamily>[allAccountsProvider, accountBalancesProvider, tagListProvider, ledgerListProvider, remindersStreamProvider, storedCardsProvider, notesStreamProvider]) {
      c.invalidate(p);
    }
    Future<void> openSearch() async {
      await go(t, '/');
      await go(t, '/more');
      await tapFinder(t, find.byIcon(Icons.search_rounded));
      await settle(t, const Duration(seconds: 1));
    }

    Future<void> search(String q, String shotName) async {
      t.state<EditableTextState>(find.byType(EditableText).last).userUpdateTextEditingValue(
          TextEditingValue(text: q, selection: TextSelection.collapsed(offset: q.length)),
          SelectionChangedCause.keyboard);
      await settle(t, const Duration(milliseconds: 900));
      FocusManager.instance.primaryFocus?.unfocus();
      await settle(t, const Duration(milliseconds: 400));
      await shot(t, 'search/$shotName');
    }

    final privacy = c.read(privacyModeProvider);
    if (privacy) await c.read(settingsProvider.notifier).togglePrivacyMode();
    await openSearch();
    await shot(t, 'search/01-empty');
    await search('hdfc', '02-hdfc');
    expect(find.text('HDFC Savings', findRichText: true), findsOneWidget);
    await search('rah', '03-rah');
    await search('emi', '04-emi');
    await search('card', '05-card');
    await search('dark', '06-keyword-dark');
    expect(find.textContaining('Matches', findRichText: true), findsWidgets);
    await search('4242', '07-never-a-card-number');
    expect(find.text(en.searchNoResults('4242'), findRichText: true), findsOneWidget);
    await search('hidden', '08-never-note-text');
    await search('zomato gold', '09-no-results');
    await search('groceries', '10-category');
    await search('hdfc', '02b-hdfc');
    await tapText(t, en.menuAccounts);
    await settle(t, const Duration(milliseconds: 600));
    await shot(t, 'search/11-filter-accounts');
    await tapText(t, en.searchAll);
    await settle(t);
    // Open one of each kind.
    await tapFinder(t, find.text('HDFC Savings', findRichText: true).first);
    await settle(t, const Duration(seconds: 1));
    await shot(t, 'search/12-account-opened');
    await back(t);
    await settle(t);
    await openSearch();
    await shot(t, 'search/13-recent');
    await search('groceries', '10b-category');
    await tapFinder(t, find.text('Groceries', findRichText: true).first);
    await settle(t, const Duration(seconds: 1));
    await shot(t, 'search/14-category-opened');
    await back(t);
    await settle(t);
    // Privacy mode hides every amount.
    await c.read(settingsProvider.notifier).togglePrivacyMode();
    await openSearch();
    await search('hdfc', '15-hdfc-privacy');
    expect(find.textContaining('84,210'), findsNothing);
    expect(find.textContaining('••••'), findsWidgets);
    await c.read(settingsProvider.notifier).togglePrivacyMode();
    expectNoErrors(t);
  });

  smokeTest('F: path sheet from 5 depths and a deep link', (t) async {
    await boot(t);
    await go(t, '/more');
    Future<void> open(String name) async {
      final title = find.byWidgetPredicate((w) => w is Semantics && w.properties.hint == en.pathSheetHint);
      await tapFinder(t, title.last);
      await pumpUntil(t, find.byType(KuberPathSheet));
      await shot(t, 'path-sheet/$name');
    }

    // Closes the sheet, leaving the page under it.
    Future<void> close() async {
      Navigator.of(rootContext(t)).pop();
      await settle(t);
    }

    await push(t, '/more/settings');
    await open('depth-1');
    await close();
    await push(t, '/more/settings/look');
    await open('depth-2');
    await close();
    await push(t, '/more/settings/theme');
    await open('depth-3');
    await close();
    await push(t, '/more/loans');
    await dismissInfo(t);
    await open('depth-4');
    await close();
    await push(t, '/more/data');
    await push(t, '/more/data/automatic-backups');
    await open('depth-5');
    // Jump back to Settings, closing what's between.
    await tapText(t, en.setGroupData);
    await settle(t);
    await expectText(t, en.setGroupData);
    await go(t, '/more');
    await settle(t);
    await go(t, resolveNotificationRoute('budget:1').page);
    await dismissInfo(t);
    await open('deep-link');
    await tapText(t, en.navHome);
    await settle(t, const Duration(seconds: 1));
    expect(find.byType(KuberPathSheet), findsNothing);
    expectNoErrors(t);
  });

  smokeTest('D2: final theme list, light and dark', (t) async {
    await boot(t);
    final settings = container(t).read(settingsProvider.notifier);
    for (final v in kSelectableVariants) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await settings.setThemeVariant(v);
        await settings.setThemeMode(mode);
        await go(t, '/');
        await settle(t, const Duration(milliseconds: 900));
        await shot(t, 'themes/${v.name}-${mode.name}');
        expectNoErrors(t);
      }
    }
    await settings.setThemeVariant(ThemeVariant.signature);
    await settings.setThemeMode(ThemeMode.light);
    // The widget re-tint is debounced: let it run before the app is torn down.
    await settle(t, const Duration(seconds: 3));
  });

  smokeTest('E: Pro page FAQ', (t) async {
    await boot(t);
    await go(t, '/more');
    await push(t, '/pro');
    await settle(t, const Duration(seconds: 2));
    await t.scrollUntilVisible(find.byType(ProFaqSection), 400, scrollable: find.byType(Scrollable).first, maxScrolls: 60);
    await tapText(t, en.proFaqLifetimeQ);
    await settle(t);
    await shot(t, 'pro/faq-open');
    expect(find.text(en.proFaqLifetimeA), findsOneWidget);
    await tapText(t, en.proFaqLifetimeQ);
    await settle(t);
    expectNoErrors(t);
  });

  smokeTest('R2: second review', (t) async {
    await boot(t);
    final c = container(t);
    // Settings: Permissions under About; Dev Tools only once unlocked.
    await go(t, '/more');
    expect(find.text(en.menuPermissions), findsNothing);
    await push(t, '/more/settings');
    await settle(t);
    // Permission granted by the run: the row reads On, refreshed on open.
    expect(find.text(en.setOn), findsOneWidget);
    final perm = find.text(en.menuPermissions);
    await t.scrollUntilVisible(perm, 300, scrollable: find.byType(Scrollable).first, maxScrolls: 30);
    await settle(t);
    expect(find.text(en.menuDevTools), findsNothing);
    (await SharedPreferences.getInstance()).setBool('kuber_dev_mode', true);
    c.invalidate(devModeProvider);
    await settle(t);
    expect(find.text(en.menuDevTools), findsOneWidget);
    await shot(t, 'r2/settings-bottom');
    await tapFinder(t, perm);
    await settle(t);
    await go(t, '/more');
    // The currency code example follows the currency.
    final settings = c.read(settingsProvider.notifier);
    await settings.setCurrency('USD');
    await push(t, '/more/settings/preferences');
    await settle(t);
    expect(find.text(r'USD 500 instead of $500'), findsOneWidget);
    await shot(t, 'r2/currency-code-usd');
    await settings.setCurrency('INR');
    await go(t, '/more');
    // Phone notifications: a new EMI row shows on the phone, in its category.
    final repo = NotificationRepository(c.read(isarProvider));
    await repo.add(type: NotificationType.loanEmi, title: 'R2 on EMI', body: 'R2 check', payload: 'loan:r2on');
    await settle(t, const Duration(seconds: 2));
    final active = await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
        .getActiveNotifications();
    final emi = active.where((n) => n.title == 'R2 on EMI').toList();
    debugPrint('KUBER_NUM R2 on phone: ${emi.map((n) => n.channelId)}');
    expect(emi.single.channelId, KuberChannel.payments.id);
    expectNoErrors(t);
    // Last, as it leaves the app: a row opens that category on the phone.
    await push(t, '/more/settings/notifications');
    await settle(t);
    await tapText(t, en.obNotifEmi);
    await Future<void>.delayed(const Duration(seconds: 2));
    debugPrint('KUBER_SHOT r2/android-category-page');
    await Future<void>.delayed(const Duration(seconds: 3));
    // The host turns the category off on that page and comes back.
    debugPrint('KUBER_TAP_OFF');
    await Future<void>.delayed(const Duration(seconds: 6));
    await settle(t, const Duration(seconds: 2));
    final emiRow = find.ancestor(of: find.text(en.obNotifEmi), matching: find.byType(SettingsAnchor));
    expect(find.descendant(of: emiRow, matching: find.text(en.setOff)), findsOneWidget);
    await shot(t, 'r2/category-off-in-app');
  });
}
