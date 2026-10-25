// theme-surfaces-v1 goldens: Home, in
// Kuber Signature, Ember and Slate, for every row of the surface rule
// (theme-surfaces.md §2). Regenerate after an approved change:
//   flutter test --update-goldens test/features/settings/theme_surfaces_goldens_test.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/database/seed_service.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/dashboard/screens/dashboard_screen.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/golden_fonts.dart';
import '../../helpers/isar_test_helper.dart';

const _rows = [
  ('r1_light_expressive', false, true, false),
  ('r2_light_neutral', false, false, false),
  ('r3_dark_expressive', true, true, false),
  ('r4_dark_expressive_black', true, true, true),
  ('r5_dark_neutral', true, false, false),
  ('r6_dark_neutral_black', true, false, true),
];
const _families = [ThemeVariant.signature, ThemeVariant.ember, ThemeVariant.slate];

late Isar _isar;

late ProviderContainer _container;

Future<void> _pump(WidgetTester t, Widget screen, ThemeData theme) async {
  t.view.physicalSize = const Size(412, 892);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final c = _container = ProviderContainer(overrides: [isarProvider.overrideWithValue(_isar)]);
  await t.runAsync(() async {
    // Create the prefs instance in the real zone (awaiting one first made
    // under fake async never completes).
    await SharedPreferences.getInstance();
    await c.read(settingsProvider.future);
  });
  final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => screen)]);
  await t.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  ));
  for (var i = 0; i < 8; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(milliseconds: 200));
  }
  await settleFonts(t);
}

/// Unmounts and lets pending database reads finish before Isar closes.
Future<void> _drain(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  _container.dispose();
  for (var i = 0; i < 10; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(milliseconds: 600));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  // Home shows clock-based text (greeting, days into the month). Up to 2% of
  // pixels may differ for that; a surface change recolours most of the screen.
  goldenFileComparator = _Tolerant(goldenFileComparator as LocalFileComparator);
  // One database for every Home test, never closed (see below).
  setUpAll(() async {
    await initialiseIsarForTests();
    await loadGoldenFonts();
    _isar = await openTestIsar();
    await SeedService().seedInitialData(_isar);
    final now = DateTime(2026, 10, 20, 9, 30); // fixed: goldens must not move
    await _isar.writeTxn(() => _isar.transactions.putAll([
          for (final (i, (name, amount, type)) in [
            ('Salary', 85000.0, 'income'),
            ('Groceries', 2340.0, 'expense'),
            ('Electricity', 1240.0, 'expense'),
            ('Coffee', 180.0, 'expense'),
          ].indexed)
            Transaction()
              ..name = name
              ..nameLower = name.toLowerCase()
              ..amount = amount
              ..type = type
              ..categoryId = '1'
              ..accountId = '1'
              ..createdAt = now.subtract(Duration(hours: i * 5))
              ..updatedAt = now,
        ]));
  });
  // Home starts background database work that cannot finish under fake
  // async, and closing Isar would wait on it: the file shares one throwaway
  // temp database and leaves it open; it runs only Home.

  for (final v in _families) {
    for (final (name, dark, expressive, black) in _rows) {
      ThemeData theme() => dark
          ? AppTheme.dark(const Locale('en'), v, black, null, expressive)
          : AppTheme.light(const Locale('en'), v, null, expressive);
      testWidgets('Home · ${v.name} · $name', (t) async {
        await _pump(t, const DashboardScreen(), theme());
        await expectLater(find.byType(MaterialApp),
            matchesGoldenFile('../../goldens/theme/home_${v.name}_$name.png'));
        await _drain(t);
      });
    }
  }
}

class _Tolerant extends LocalFileComparator {
  _Tolerant(LocalFileComparator base) : super(base.basedir.resolve('x_test.dart'));

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (result.passed || result.diffPercent <= 0.02) return true;
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
