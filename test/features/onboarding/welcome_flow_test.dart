// November release B: first-install pages, every path that doesn't need a file
// picker, and that More > Why Kuber still replays only the animated pages.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/onboarding/pages/onboarding_data_terms_page.dart';
import 'package:kuber/features/onboarding/pages/onboarding_notifications_page.dart';
import 'package:kuber/features/onboarding/pages/onboarding_start_page.dart';
import 'package:kuber/features/onboarding/screens/onboarding_flow.dart';
import 'package:kuber/features/onboarding/widgets/onboarding_nav_bar.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  final l = lookupAppLocalizations(const Locale('en'));
  setUpAll(() async {
    await initialiseIsarForTests();
    isar = await openTestIsar();
  });
  tearDownAll(() => closeAndCleanIsar(isar));

  GoRouter routerFor(bool replay) => GoRouter(
        initialLocation: replay ? '/onboarding?replay=true' : '/onboarding',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('HOME'))),
          GoRoute(
            path: '/onboarding',
            builder: (_, s) => OnboardingFlow(isReplay: s.uri.queryParameters['replay'] == 'true'),
          ),
        ],
      );

  Future<void> pump(WidgetTester t, {bool replay = false}) async {
    await t.binding.setSurfaceSize(const Size(411, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferences.getInstance();
    });
    await t.pumpWidget(ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: MaterialApp.router(
        routerConfig: routerFor(replay),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await t.pump(const Duration(milliseconds: 700));
  }

  Finder primary(String label) =>
      find.descendant(of: find.byType(OnboardingNavBar), matching: find.text(label));

  testWidgets('first page: language, restore, CSV, Start fresh', (t) async {
    await pump(t);
    expect(find.byType(OnboardingStartPage), findsOneWidget);
    expect(find.text(l.obStartRestore), findsOneWidget);
    expect(find.text(l.obStartCsv), findsOneWidget);
    expect(primary(l.obStartFresh), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    await t.tap(primary(l.obStartFresh));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text(l.obStartRestore).hitTestable(), findsNothing);
    expect(primary(l.getStarted), findsOneWidget);
  });

  testWidgets('the replay shows only the animated pages', (t) async {
    await pump(t, replay: true);
    expect(find.byType(OnboardingStartPage), findsNothing);
    expect(find.byType(OnboardingNotificationsPage), findsNothing);
    expect(find.byType(OnboardingDataTermsPage), findsNothing);
    expect(primary(l.getStarted), findsOneWidget);
  });

  group('data responsibility page', () {
    Widget page(bool a, bool b, {ValueChanged<bool>? onA, ValueChanged<bool>? onB}) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: OnboardingDataTermsPage(
              backups: a,
              responsibility: b,
              onBackups: onA ?? (_) {},
              onResponsibility: onB ?? (_) {},
            ),
          ),
        );

    testWidgets('boxes start unchecked and report taps', (t) async {
      final got = <bool>[];
      await t.pumpWidget(page(false, false, onA: got.add));
      expect(t.widget<CheckboxListTile>(find.byType(CheckboxListTile).first).value, isFalse);
      await t.tap(find.text(l.obTermsCheck1));
      expect(got, [true]);
      expect(find.text(l.obTermsTitle), findsOneWidget);
      expect(find.text(l.obTermsPrivacy), findsOneWidget);
    });

    testWidgets('fits the largest font size without an overflow', (t) async {
      await t.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: page(true, false),
      ));
      await t.pump();
      expect(t.takeException(), isNull);
    });
  });

  test('the acceptance is versioned', () {
    expect(kDataTermsVersion, 1);
    expect(PrefsKeys.dataTermsAcceptedAt, isNot(PrefsKeys.onboarded));
  });
}
