// v4 · Nov release goldens: every new screen and state, in Kuber Signature
// light and dark, Ember, and at the largest font size.
//   flutter test --update-goldens test/goldens_nov_design_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/database/seed_service.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/kuber_cards/data/card_vault_meta.dart';
import 'package:kuber/features/kuber_cards/providers/kuber_cards_provider.dart';
import 'package:kuber/features/kuber_cards/data/stored_card.dart';
import 'package:kuber/features/more/screens/more_search_screen.dart';
import 'package:kuber/features/notes/data/kuber_note.dart';
import 'package:kuber/features/onboarding/pages/onboarding_data_terms_page.dart';
import 'package:kuber/features/onboarding/pages/onboarding_notifications_page.dart';
import 'package:kuber/features/onboarding/pages/onboarding_start_page.dart';
import 'package:kuber/features/onboarding/widgets/onboarding_nav_bar.dart';
import 'package:kuber/features/pro/paywall/billing_ui_state.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/settings/screens/data_management_screen.dart';
import 'package:kuber/features/settings/screens/settings_pages.dart';
import 'package:kuber/features/settings/screens/settings_screen.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_option_card.dart';
import 'package:kuber/shared/widgets/kuber_path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/golden_fonts.dart';
import 'helpers/isar_test_helper.dart';

class _Look {
  final String name;
  final ThemeData Function() theme;
  final double scale;
  const _Look(this.name, this.theme, {this.scale = 1});
}

class _Pro extends KuberProStateNotifier {
  final KuberProState value;
  _Pro(this.value);
  @override
  KuberProState build() => value;
}

ThemeData _light(ThemeVariant v) => AppTheme.light(const Locale('en'), v, null, true);
ThemeData _dark(ThemeVariant v) => AppTheme.dark(const Locale('en'), v, false, null, true);

final _looks = [
  _Look('light', () => _light(ThemeVariant.signature)),
  _Look('dark', () => _dark(ThemeVariant.signature)),
  _Look('ember', () => _light(ThemeVariant.ember)),
  _Look('large', () => _light(ThemeVariant.signature), scale: 2),
];

late Isar _isar;

/// One state: what to show, and how to set it up.
class _State {
  final String name;
  final Widget Function(BuildContext)? page;
  final String? query;
  final List<Override> overrides;
  const _State(this.name, {this.page, this.query, this.overrides = const []});
}

Widget _welcome(Widget page, {required String label, bool dots = true, int at = 8, bool arrow = true, String? second, bool enabled = true, bool back = false}) =>
    Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: page),
            OnboardingNavBar(
              currentPage: at,
              pageCount: 10,
              showDots: dots,
              compactBack: true,
              showBack: back,
              primaryLabel: label,
              onPrimary: () {},
              onBack: () {},
              showArrow: arrow,
              primaryEnabled: enabled,
              secondaryLabel: second,
            ),
          ],
        ),
      ),
    );

Widget _start({StartJob? job, StartJob? failed}) => OnboardingStartPage(
      job: job,
      failed: failed,
      fileName: 'kuber_backup_2026-11-05.json',
      onRestore: () {},
      onImportCsv: () {},
      onCancelImport: () {},
      onLocaleChanged: (_) {},
    );

Widget _terms(bool a, bool b) => OnboardingDataTermsPage(
      backups: a,
      responsibility: b,
      onBackups: (_) {},
      onResponsibility: (_) {},
    );

Widget _path(List<(IconData, String)> pages, {bool notification = false}) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: KuberPathSheet(
          entries: [for (final (i, t) in pages) KuberPathEntry(i, t, tabLocation: '/')],
          router: GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())]),
          fromNotification: notification,
        ),
      ),
    );

const _p5 = [
  (Icons.home_rounded, 'Home'),
  (Icons.grid_view_rounded, 'More'),
  (Icons.settings_rounded, 'Settings'),
  (Icons.palette_outlined, 'Look and feel'),
  (Icons.contrast_rounded, 'Theme'),
];
const _p8 = [
  ..._p5,
  (Icons.history_rounded, 'SIP history'),
  (Icons.event_rounded, 'SIP on 5 Nov 2026'),
  (Icons.edit_rounded, 'Edit transaction'),
];

/// The option card's states side by side (restore progress needs a run).
Widget _cards() => Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 12,
          children: [
            const KuberOptionCard(icon: Icons.settings_backup_restore_rounded, title: 'Restore from backup', subtitle: 'Bring back your data from a Kuber backup'),
            const KuberOptionCard(
              icon: Icons.settings_backup_restore_rounded,
              title: 'Restoring your data',
              subtitle: 'kuber_backup_2026-11-05.json',
              state: KuberOptionState.busy,
              progress: 0.62,
              step: '1,248 of 2,010 transactions',
            ),
            KuberOptionCard(
              icon: Icons.upload_file_rounded,
              title: 'Importing your CSV',
              subtitle: 'statement_hdfc_oct.csv',
              state: KuberOptionState.busy,
              progress: 0.31,
              step: '342 of 1,120 rows',
              cancelLabel: 'Cancel',
              onCancel: () {},
            ),
            const KuberOptionCard(icon: Icons.upload_file_rounded, title: 'Import from CSV', subtitle: 'Move in from another app or a spreadsheet', state: KuberOptionState.disabled),
          ],
        ),
      ),
    );

final _vault = cardVaultMetaProvider.overrideWith((ref) => CardVaultMeta()..biometricEnabled = true);
final _bio = biometricEnrolledProvider.overrideWith((ref) => true);
final _noBio = biometricEnrolledProvider.overrideWith((ref) => false);
final _notifOn = notificationsAllowedProvider.overrideWith((ref) => true);
final _notifOff = notificationsAllowedProvider.overrideWith((ref) => false);
final _version = appVersionProvider.overrideWith((ref) => '1.6.0');

final _states = <_State>[
  _State('welcome_first', page: (c) => _welcome(_start(), label: 'Start fresh', dots: false)),
  // The language sheet needs every regional font, which tests don't bundle:
  // it's checked on the emulator (screenshots/after/welcome/01b).
  _State('welcome_restore_busy', page: (c) => _welcome(_start(job: StartJob.restore), label: 'Start fresh', dots: false, enabled: false)),
  _State('welcome_restore_failed', page: (c) => _welcome(_start(failed: StartJob.restore), label: 'Start fresh', dots: false)),
  _State('welcome_import_busy', page: (c) => _welcome(_start(job: StartJob.csv), label: 'Start fresh', dots: false, enabled: false)),
  _State('welcome_cards', page: (c) => _cards()),
  _State('welcome_notifications', page: (c) => _welcome(const OnboardingNotificationsPage(), label: 'Allow notifications', arrow: false, second: 'Not now')),
  _State('welcome_notifications_old_android', page: (c) => _welcome(const OnboardingNotificationsPage(), label: 'Continue', arrow: false)),
  _State('welcome_data_none', page: (c) => _welcome(_terms(false, false), label: 'Agree and continue', at: 9, arrow: false, enabled: false, back: true)),
  _State('welcome_data_one', page: (c) => _welcome(_terms(true, false), label: 'Agree and continue', at: 9, arrow: false, enabled: false, back: true)),
  _State('welcome_data_both', page: (c) => _welcome(_terms(true, true), label: 'Agree and continue', at: 9, back: true)),
  _State('path_5', page: (c) => _path(_p5)),
  _State('path_2', page: (c) => _path(_p5.take(2).toList())),
  _State('path_long', page: (c) => _path([..._p5.take(3), (Icons.account_balance_rounded, 'HDFC Bank Salary Account, joint with Priya Sharma'), (Icons.receipt_long_rounded, 'Swiggy Instamart order, Tuesday 4 November 2026')])),
  _State('path_8', page: (c) => _path(_p8)),
  _State('path_notification', page: (c) => _path(_p5.take(2).toList(), notification: true)),
  _State('settings_main', page: (c) => const SettingsScreen(), overrides: [_notifOn, _version]),
  _State('settings_main_pro', page: (c) => const SettingsScreen(), overrides: [
    _notifOn,
    _version,
    kuberProStateProvider.overrideWith(() => _Pro(KuberProState.purchased(plan: ProPlan.lifetime, activatedAt: DateTime(2026, 8, 12)))),
  ]),
  _State('settings_main_notifications_off', page: (c) => const SettingsScreen(), overrides: [_notifOff, _version]),
  _State('settings_look', page: (c) => const LookAndFeelScreen()),
  _State('settings_preferences', page: (c) => const AppPreferencesScreen()),
  _State('settings_privacy', page: (c) => const PrivacySecurityScreen(), overrides: [_vault, _bio]),
  _State('settings_privacy_no_fingerprint', page: (c) => const PrivacySecurityScreen(), overrides: [_noBio]),
  _State('settings_drawer', page: (c) => const AppDrawerScreen()),
  _State('settings_data', page: (c) => const DataManagementScreen()),
  _State('settings_notifications_off', page: (c) => const NotificationsSettingsScreen(), overrides: [_notifOff]),
  _State('settings_notifications_on', page: (c) => const NotificationsSettingsScreen(), overrides: [_notifOn]),
  _State('settings_help', page: (c) => const HelpSettingsScreen()),
  _State('settings_activity', page: (c) => const ActivitySettingsScreen()),
  _State('search_empty', page: (c) => MoreSearchScreen(hostContext: c)),
  _State('search_results', page: (c) => MoreSearchScreen(hostContext: c), query: 'hdfc'),
  _State('search_keyword', page: (c) => MoreSearchScreen(hostContext: c), query: 'dark'),
  _State('search_none', page: (c) => MoreSearchScreen(hostContext: c), query: 'zomato gold'),
];

Future<void> _settle(WidgetTester t, {int rounds = 8}) async {
  for (var i = 0; i < rounds; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await t.pump(const Duration(milliseconds: 150));
  }
}

void main() {
  setUpAll(() async {
    await initialiseIsarForTests();
    await loadGoldenFonts();
    EditableText.debugDeterministicCursor = true;
    SharedPreferences.setMockInitialValues({});
    _isar = await openTestIsar();
    await SeedService().seedInitialData(_isar);
    await _isar.writeTxn(() async {
      await _isar.accounts.put(Account()
        ..name = 'HDFC Savings'
        ..type = 'bank'
        ..initialBalance = 84210);
      await _isar.storedCards.put(StoredCard()
        ..nickname = 'HDFC Millennia'
        ..last4 = '4242');
      await _isar.kuberNotes.put(KuberNote()
        ..title = 'HDFC netbanking steps'
        ..content = '[]'
        ..createdAt = DateTime(2026, 11, 2)
        ..updatedAt = DateTime(2026, 11, 2));
    });
  });
  tearDownAll(() => closeAndCleanIsar(_isar).timeout(const Duration(seconds: 3), onTimeout: () {}));

  for (final look in _looks) {
    for (final s in _states) {
      testWidgets('${s.name} · ${look.name}', (t) async {
        t.view.physicalSize = const Size(360, 780);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final c = ProviderContainer(overrides: [
          isarProvider.overrideWithValue(_isar),
          ...s.overrides,
        ]);
        await t.runAsync(() async {
          await SharedPreferences.getInstance();
          await c.read(settingsProvider.future);
        });
        c.read(proBootstrapLoadingProvider.notifier).state = false;
        await t.pumpWidget(UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: look.theme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(look.scale)),
              child: child!,
            ),
            home: Builder(builder: s.page!),
          ),
        ));
        await _settle(t);
        if (s.query != null) {
          await t.pump(const Duration(milliseconds: 400));
          await _settle(t, rounds: 10);
          await t.enterText(find.byType(EditableText), s.query!);
          await _settle(t);
        }
        await settleFonts(t);
        await t.pump(const Duration(seconds: 2));
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/nov_design/${s.name}_${look.name}.png'));
        await t.pumpWidget(const SizedBox());
        c.dispose();
        await _settle(t, rounds: 4);
      });
    }
  }
}
