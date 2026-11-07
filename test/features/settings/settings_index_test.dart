// November release C3: the search index against the rows every Settings page
// really renders, so a setting can never go missing from search.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/kuber_cards/data/card_vault_meta.dart';
import 'package:kuber/features/kuber_cards/providers/kuber_cards_provider.dart';
import 'package:kuber/features/settings/screens/data_management_screen.dart';
import 'package:kuber/features/settings/screens/settings_pages.dart';
import 'package:kuber/features/settings/screens/settings_screen.dart';
import 'package:kuber/features/settings/settings_index.dart';
import 'package:kuber/features/settings/widgets/settings_anchor.dart';
import 'package:kuber/features/settings/widgets/settings_section.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'kuber_onboarded': true});
    // Created here: first use inside fake async deadlocks.
    await SharedPreferences.getInstance();
    await initialiseIsarForTests();
    isar = await openTestIsar();
  });
  tearDownAll(() => closeAndCleanIsar(isar));

  Widget host(Widget page) => ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          // A vault exists: the card rows show.
          cardVaultMetaProvider.overrideWith((ref) => CardVaultMeta()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: page,
        ),
      );

  Future<Set<String>> anchors(WidgetTester t, Widget page) async {
    await t.pumpWidget(host(page));
    await t.pump(const Duration(milliseconds: 50));
    await t.pump(const Duration(milliseconds: 50));
    final ids = t.widgetList<SettingsAnchor>(find.byType(SettingsAnchor)).map((a) => a.id).toSet();
    // Every tile on the page is an anchor (Settings' own group rows aside).
    final tiles = find.byType(SettingsTile).evaluate().length;
    final inside = find
        .descendant(of: find.byType(SettingsAnchor), matching: find.byType(SettingsTile))
        .evaluate()
        .length;
    if (page is! SettingsScreen) expect(inside, tiles, reason: '$page has a row with no anchor');
    await t.pumpWidget(const SizedBox());
    await drainIsarWrites(t, isar);
    return ids;
  }

  Set<String> indexed(SettingsArea a) =>
      {for (final e in kSettingsIndex) if (e.area == a) e.id};

  final pages = <SettingsArea, Widget>{
    SettingsArea.main: const SettingsScreen(),
    SettingsArea.look: const LookAndFeelScreen(),
    SettingsArea.prefs: const AppPreferencesScreen(),
    SettingsArea.privacy: const PrivacySecurityScreen(),
    SettingsArea.drawer: const AppDrawerScreen(),
    SettingsArea.notifications: const NotificationsSettingsScreen(),
    SettingsArea.activity: const ActivitySettingsScreen(),
    SettingsArea.data: const DataManagementScreen(),
  };

  for (final e in pages.entries) {
    testWidgets('index matches the rows on ${e.key.name}', (t) async {
      final rendered = await anchors(t, e.value);
      // Home v2 rows only show for Home v2 installs.
      const conditional = {'getStarted', 'suggestions'};
      expect(rendered.difference(conditional), indexed(e.key).difference(conditional));
    });
  }

  test('every area of the index has a page or is the Pro page', () {
    for (final a in SettingsArea.values) {
      if (a == SettingsArea.pro) continue;
      expect(pages.containsKey(a), isTrue, reason: a.name);
    }
    final ids = kSettingsIndex.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'ids are unique');
  });

  group('search', () {
    final l = lookupAppLocalizations(const Locale('en'));
    final s = SettingsSearch.of(l);
    Iterable<String> find(String q) => s.search(q).map((e) => e.id);

    for (final (q, id) in [
      ('dark', 'theme'),
      ('lock', 'biometric'),
      ('fingerprint', 'cardsBiometric'),
      ('backup', 'backup'),
      ('rupee', 'currency'),
      ('lakh', 'numberFormat'),
      ('font', 'textSize'),
      ('hindi', 'language'),
      ('tutorial', 'tutorial'),
      ('calendar', 'upcoming'),
      ('promo', 'redeem'),
    ]) {
      test('"$q" finds $id', () => expect(find(q), contains(id)));
    }

    test('results carry the path', () {
      final e = kSettingsIndex.firstWhere((e) => e.id == 'biometric');
      expect(settingsPath(e.area, l, l.settingsTitle), 'Settings › Privacy and security');
      final main = kSettingsIndex.firstWhere((e) => e.id == 'name');
      expect(settingsPath(main.area, l, l.settingsTitle), 'Settings');
    });

    test('nothing for an empty query or nonsense', () {
      expect(find('  '), isEmpty);
      expect(find('zzqq'), isEmpty);
    });

    test('it stays fast: 10,000 searches well under a frame each', () {
      final sw = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        s.search('fingerprint');
      }
      expect(sw.elapsedMilliseconds / 10000, lessThan(1));
    });

    test('translated in every language', () {
      for (final code in ['hi', 'mr', 'bn', 'pa', 'ta', 'te', 'ml', 'kn']) {
        final tr = lookupAppLocalizations(Locale(code));
        for (final e in kSettingsIndex) {
          expect(e.keywords(tr), isNotEmpty, reason: '$code ${e.id}');
        }
      }
    });
  });
}
