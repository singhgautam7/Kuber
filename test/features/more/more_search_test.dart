// More search (board v4.4): matching accounts and categories, privacy mode,
// recent searches, and that card numbers and note text can never be found.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/categories/data/category_group.dart';
import 'package:kuber/features/kuber_cards/data/stored_card.dart';
import 'package:kuber/features/kuber_cards/providers/kuber_cards_provider.dart';
import 'package:kuber/features/more/more_search_index.dart';
import 'package:kuber/features/more/screens/more_search_screen.dart';
import 'package:kuber/features/notes/data/kuber_note.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

Account account(String name, {bool card = false}) => Account()
  ..id = name.hashCode.abs() % 1000
  ..name = name
  ..type = 'bank'
  ..isCreditCard = card
  ..initialBalance = 0;

Category category(String name, int? group) => Category()
  ..name = name
  ..icon = 'category'
  ..colorValue = 0xFF427CCF
  ..type = 'expense'
  ..groupId = group;

StoredCard card() => StoredCard()
  ..nickname = 'Axis Neo'
  ..last4 = '4242'
  ..numberEnc = '{"ct":"4111111111114242"}'
  ..cardholderEnc = '{"ct":"RAVI KUMAR"}'
  ..expiryEnc = '{"ct":"12/29"}';

KuberNote note() => KuberNote()
  ..title = 'Netbanking steps'
  ..content = '[{"insert":"my secret password hunter2"}]'
  ..createdAt = DateTime(2026, 11, 1)
  ..updatedAt = DateTime(2026, 11, 2);

void main() {
  setUpAll(() => initializeDateFormatting());
  final l = lookupAppLocalizations(const Locale('en'));
  final fmt = AppFormatter();
  List<MoreSearchItem> items(MoreSearchData d) => MoreSearchItems.build(
        d,
        l: l,
        fmt: fmt,
        mask: '₹ ••••',
        locale: 'en',
        typeOf: (_) => 'Stocks',
      );

  group('matching', () {
    test('accounts by name, any case, with type and balance', () {
      final a = account('HDFC Savings');
      final found = MoreSearchItems.match(items(MoreSearchData(accounts: [a], balances: {a.id: 84210})), 'hdfc');
      final row = found[MoreSearchKind.accounts]!.single;
      expect(row.title, 'HDFC Savings');
      expect(row.subtitle, l.accountTypeBank);
      expect(row.amount, fmt.formatCurrency(84210));
    });

    test('a credit card reads as one and its dues read as money owed', () {
      final a = account('HDFC Millennia', card: true);
      final row = items(MoreSearchData(accounts: [a], balances: {a.id: -12480})).single;
      expect(row.subtitle, l.accountTypeCreditCard);
      expect(row.tone, MoreSearchTone.expense);
    });

    test('categories show the parent group', () {
      final g = CategoryGroup()
        ..id = 7
        ..name = 'Shopping';
      final found = MoreSearchItems.match(
        items(MoreSearchData(categories: [category('Clothes', 7), category('Rent', null)], groups: [g])),
        'cloth',
      );
      expect(found[MoreSearchKind.categories]!.single.subtitle, 'Shopping');
    });

    test('an empty query finds nothing; kinds keep their order', () {
      final all = items(MoreSearchData(accounts: [account('Fees')], categories: [category('Fees', null)]));
      expect(MoreSearchItems.match(all, '  '), isEmpty);
      expect(MoreSearchItems.match(all, 'fee').keys.toList(), [MoreSearchKind.accounts, MoreSearchKind.categories]);
    });

    test('10,000 keystrokes over 500 rows stay far under a frame each', () {
      final all = items(MoreSearchData(accounts: [for (var i = 0; i < 500; i++) account('Account $i')]));
      final sw = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        MoreSearchItems.match(all, 'acc');
      }
      expect(sw.elapsedMicroseconds / 10000, lessThan(1000));
    });
  });

  group('privacy', () {
    test('a recurring row has a masked second line', () {
      final r = RecurringRule()
        ..name = 'HDFC Life premium'
        ..amount = 3450
        ..frequency = 'monthly';
      final row = items(MoreSearchData(rules: [r])).single;
      expect(row.subtitle, contains('3,450'));
      expect(row.maskedSubtitle, isNot(contains('3,450')));
      expect(row.maskedSubtitle, contains('₹ ••••'));
    });
  });

  group('never searched', () {
    List<MoreSearchItem> everything() => items(MoreSearchData(cards: [card()], notes: [note()]));

    test('card numbers, holder and expiry', () {
      for (final q in ['4242', '4111', 'ravi', '12/29']) {
        expect(MoreSearchItems.match(everything(), q), isEmpty, reason: q);
      }
    });

    test('note text', () {
      for (final q in ['secret', 'hunter2', 'password']) {
        expect(MoreSearchItems.match(everything(), q), isEmpty, reason: q);
      }
    });

    test('card names and note titles are found, with nothing else on the row', () {
      final all = everything();
      expect(MoreSearchItems.match(all, 'axis')[MoreSearchKind.cards]!.single.title, 'Axis Neo');
      expect(MoreSearchItems.match(all, 'netbank')[MoreSearchKind.notes]!.single.title, 'Netbanking steps');
      for (final i in all) {
        final text = '${i.title} ${i.subtitle} ${i.maskedSubtitle} ${i.amount}';
        for (final secret in ['4242', '4111', 'RAVI', 'hunter2']) {
          expect(text, isNot(contains(secret)));
        }
      }
    });
  });

  group('recent searches', () {
    test('newest first, no repeats, at most 10', () {
      var list = <String>[];
      for (var i = 0; i < 12; i++) {
        list = MoreSearchRecents.added(list, 'q$i');
      }
      expect(list.length, MoreSearchRecents.max);
      expect(list.first, 'q11');
      list = MoreSearchRecents.added(list, 'Q5');
      expect(list.first, 'Q5');
      expect(list.where((x) => x.toLowerCase() == 'q5').length, 1);
      expect(MoreSearchRecents.added(list, '   '), list);
    });

    test('stored on the phone and cleared', () async {
      SharedPreferences.setMockInitialValues({});
      await MoreSearchRecents.save(['theme', 'hdfc']);
      expect(await MoreSearchRecents.load(), ['theme', 'hdfc']);
      await MoreSearchRecents.save(const []);
      expect(await MoreSearchRecents.load(), isEmpty);
    });
  });

  group('on the page', () {
    late Isar isar;
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({'kuber_onboarded': true});
      await SharedPreferences.getInstance();
      await initialiseIsarForTests();
      isar = await openTestIsar();
      await isar.writeTxn(() async {
        await isar.accounts.put(Account()
          ..name = 'HDFC Savings'
          ..type = 'bank'
          ..initialBalance = 84210);
        await isar.storedCards.put(card());
        await isar.kuberNotes.put(note());
      });
    });
    tearDownAll(() => closeAndCleanIsar(isar).timeout(const Duration(seconds: 3), onTimeout: () {}));

    late ProviderContainer last;
    Future<void> open(WidgetTester t, {required bool privacy}) async {
      final c = last = ProviderContainer(overrides: [isarProvider.overrideWithValue(isar)]);
      addTearDown(c.dispose);
      await t.runAsync(() async {
        await c.read(settingsProvider.future);
        if (privacy != c.read(privacyModeProvider)) {
          await c.read(settingsProvider.notifier).togglePrivacyMode();
        }
      });
      await t.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(builder: (ctx) => MoreSearchScreen(hostContext: ctx)),
        ),
      ));
      for (var i = 0; i < 8; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> type(WidgetTester t, String q) async {
      await t.enterText(find.byType(EditableText), q);
      for (var i = 0; i < 6; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
        await t.pump(const Duration(milliseconds: 150));
      }
    }

    testWidgets('a balance shows, and hides in privacy mode', (t) async {
      await open(t, privacy: false);
      await type(t, 'hdfc');
      expect(find.textContaining('84,210'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));

      await open(t, privacy: true);
      await type(t, 'hdfc');
      expect(find.textContaining('84,210'), findsNothing);
      expect(find.textContaining('••••'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
    });

    testWidgets('a card from search always asks for the PIN or fingerprint', (t) async {
      await open(t, privacy: false);
      last.read(cardSessionProvider.notifier).unlock(List.filled(32, 1));
      expect(last.read(cardSessionProvider).isUnlocked, isTrue);
      await type(t, 'axis');
      await t.tap(find.byIcon(Icons.lock_outline_rounded).first);
      await t.pump();
      // This host has no router to open Kuber Cards; the lock comes first.
      t.takeException();
      expect(last.read(cardSessionProvider).isUnlocked, isFalse);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
    });

    testWidgets('a card shows a lock and never its number', (t) async {
      await open(t, privacy: false);
      await type(t, 'axis');
      expect(find.textContaining('Axis Neo'), findsWidgets);
      expect(find.byIcon(Icons.lock_outline_rounded), findsWidgets);
      expect(find.textContaining('4242'), findsNothing);
      await type(t, '4242');
      expect(find.text(l.searchNoResults('4242')), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
    });
  });
}
