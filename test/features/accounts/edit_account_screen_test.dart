import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/accounts/screens/edit_account_screen.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/tutorial/providers/tutorial_sandbox_provider.dart';
import 'package:kuber/l10n/app_localizations.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;

  setUpAll(() async => initialiseIsarForTests());

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    isar = await openTestIsar();
  });

  tearDown(() async => closeAndCleanIsar(isar));

  // The hero amount field autofocuses, so its blinking cursor is a perpetual
  // animation that would stall pumpAndSettle. Pump a bounded number of frames
  // instead — enough for async Isar writes and dialog routes to complete.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<ProviderContainer> buildContainer({String? defaultAccountId}) async {
    final container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(isar),
        tutorialAwareIsarProvider.overrideWithValue(isar),
        settingsProvider
            .overrideWith(() => _FakeSettingsNotifier(defaultAccountId)),
      ],
    );
    // Warm the async providers the screen reads synchronously in initState /
    // callbacks, so valueOrNull is populated by the time the widget builds.
    await container.read(settingsProvider.future);
    await container.read(allAccountsProvider.future);
    return container;
  }

  Future<void> pumpScreen(
      WidgetTester tester, ProviderContainer container, Account account) async {
    // Resolve the balance up front so the screen never shows its loading
    // spinner (a continuous animation that would stall pumpAndSettle).
    await container.read(accountBalanceProvider(account.id).future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(const Locale('en')),
          home: EditAccountScreen(account: account),
        ),
      ),
    );
    await settle(tester);
  }

  Future<Account> seedBankAccount({double initialBalance = 1000}) async {
    final account = makeAccount(initialBalance: initialBalance);
    await isar.writeTxn(() => isar.accounts.put(account));
    return account;
  }

  Future<int> adjustmentCount() => isar.transactions
      .filter()
      .isBalanceAdjustmentEqualTo(true)
      .count();

  testWidgets('blank name shows error and does not save', (tester) async {
    final account = await seedBankAccount();
    final container = await buildContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container, account);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('Save changes'));
    await tester.pump();

    expect(find.text('Please enter an account name'), findsOneWidget);
    expect(find.text('Create adjustment transaction?'), findsNothing);
  });

  testWidgets('unchanged balance creates no adjustment', (tester) async {
    final account = await seedBankAccount();
    final container = await buildContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container, account);

    // Do not touch the hero — it is seeded with the computed balance (1000).
    await tester.tap(find.text('Save changes'));
    await settle(tester);

    expect(find.text('Create adjustment transaction?'), findsNothing);
    expect(await adjustmentCount(), 0);
  });

  testWidgets('changed balance shows modal and creates the adjustment',
      (tester) async {
    final account = await seedBankAccount(initialBalance: 1000);
    final container = await buildContainer();
    addTearDown(container.dispose);
    await pumpScreen(tester, container, account);

    // Fields order for a bank account: name, identifier, hero.
    await tester.enterText(find.byType(TextField).at(2), '1500');
    await tester.pump();

    await tester.tap(find.text('Save changes'));
    await settle(tester);
    expect(find.text('Create adjustment transaction?'), findsOneWidget);

    await tester.tap(find.text('Create and save'));
    await settle(tester);

    final adjustments = await isar.transactions
        .filter()
        .isBalanceAdjustmentEqualTo(true)
        .findAll();
    expect(adjustments.length, 1);
    expect(adjustments.first.name, 'Balance Adjustment');
    expect(adjustments.first.type, 'income');
    expect(adjustments.first.amount, 500);
    expect(adjustments.first.accountId, account.id.toString());
  });

  testWidgets('deleting the default account prompts to pick a new default',
      (tester) async {
    final account = await seedBankAccount();
    // A second account so a replacement default exists.
    await isar.writeTxn(
        () => isar.accounts.put(makeAccount(name: 'Second')));
    final container =
        await buildContainer(defaultAccountId: account.id.toString());
    addTearDown(container.dispose);
    await pumpScreen(tester, container, account);

    // Delete now lives in the scrollable "Danger Zone" at the end of the form.
    await tester.ensureVisible(find.text('Delete Account'));
    await tester.pump();
    await tester.tap(find.text('Delete Account'));
    await settle(tester);

    expect(find.text('Pick a new default account'), findsOneWidget);
  });
}

class _FakeSettingsNotifier extends AsyncNotifier<SettingsState>
    implements SettingsNotifier {
  _FakeSettingsNotifier(this._defaultAccountId);

  String? _defaultAccountId;

  @override
  Future<SettingsState> build() async =>
      SettingsState(defaultAccountId: _defaultAccountId);

  @override
  Future<void> setDefaultAccountId(String? id) async {
    _defaultAccountId = id;
    state = AsyncData(SettingsState(defaultAccountId: id));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) async {}
}
