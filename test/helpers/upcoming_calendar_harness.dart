// Pumps Upcoming events on the demo month (test/helpers/upcoming_fixture.dart).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/upcoming_events/providers/upcoming_calendar_provider.dart';
import 'package:kuber/features/upcoming_events/providers/upcoming_events_provider.dart';
import 'package:kuber/features/upcoming_events/screens/upcoming_events_full_screen.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'isar_test_helper.dart';
import 'upcoming_fixture.dart';

late Isar _isar;

Future<void> setUpCalendarIsar() async {
  _isar = await openTestIsar();
  await seedUpcomingFixture(_isar);
}

Future<void> tearDownCalendarIsar() => closeAndCleanIsar(_isar);


/// Pumps Upcoming events in Calendar view. Returns the container.
Future<ProviderContainer> pumpCalendar(
  WidgetTester t, {
  bool dark = false,
  bool privacy = false,
  String view = 'calendar',
  Locale locale = const Locale('en'),
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues({
    if (view.isNotEmpty) PrefsKeys.upcomingEventsView: view,
    ...prefs,
  });
  t.view.physicalSize = const Size(1080, 2340);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  final c = ProviderContainer(overrides: [
    isarProvider.overrideWithValue(_isar),
    upcomingClockProvider.overrideWithValue(() => upcomingNow),
    // The List's live Isar stream does not settle under fake async; the List
    // itself is covered by list_parity_test and the smoke suite.
    upcomingEventsProvider.overrideWith((ref) => Stream.value(const [])),
  ]);
  addTearDown(c.dispose);
  await t.runAsync(() async {
    await c.read(settingsProvider.future);
    if (privacy) await c.read(settingsProvider.notifier).togglePrivacyMode();
    await c.read(upcomingCalendarViewProvider.future);
    await c.read(calendarFirstMonthProvider.future);
    for (final m in [202610, 202611, 202612]) {
      c.listen(calendarMonthProvider(m), (_, __) {});
      await c.read(calendarMonthProvider(m).future);
    }
  });
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => const UpcomingEventsFullScreen()),
    GoRoute(
        path: '/reminders/add',
        builder: (_, s) => Scaffold(body: Text('new reminder ${s.uri.queryParameters['date']}'))),
  ]);
  await t.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(locale),
      darkTheme: AppTheme.dark(locale),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    ),
  ));
  await settle(t);
  return c;
}

Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 6; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await t.pump(const Duration(milliseconds: 100));
  }
}

