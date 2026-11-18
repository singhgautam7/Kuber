// Floating header setting (v7.0.0-c board v7c.S): the Look and feel row, the
// sheet's switch and option cards, the live previews and their lifecycle.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/database/seed_service.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/settings/screens/settings_pages.dart';
import 'package:kuber/features/settings/widgets/floating_header_sheet.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

late Isar _isar;

Future<ProviderContainer> _open(WidgetTester t, Widget home,
    {FloatingHeaderMode mode = FloatingHeaderMode.always, bool still = false}) async {
  t.view.physicalSize = const Size(400, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final c = ProviderContainer(overrides: [
    isarProvider.overrideWithValue(_isar),
    bootMotionProvider.overrideWithValue(MotionBoot(floatingHeader: mode)),
  ]);
  addTearDown(c.dispose);
  await t.runAsync(() async {
    await SharedPreferences.getInstance();
    await c.read(settingsProvider.future);
  });
  await t.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      theme: AppTheme.light(const Locale('en'), ThemeVariant.signature, null, true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(disableAnimations: still),
        child: child!,
      ),
      home: home,
    ),
  ));
  await t.pump();
  return c;
}

Widget _opener() => Builder(
      builder: (ctx) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => FloatingHeaderSheet.show(ctx),
            child: const Text('open'),
          ),
        ),
      ),
    );

Future<void> _openSheet(WidgetTester t) async {
  await t.tap(find.text('open'));
  await t.pump();
  await t.pump(const Duration(seconds: 1));
}

Finder _card(String label) => find.bySemanticsLabel('$label, preview of the header');

void main() {
  setUpAll(() async {
    await initialiseIsarForTests();
    SharedPreferences.setMockInitialValues({});
    _isar = await openTestIsar();
    await SeedService().seedInitialData(_isar);
  });
  tearDownAll(() => closeAndCleanIsar(_isar).timeout(const Duration(seconds: 3), onTimeout: () {}));

  testWidgets('Look and feel row shows the current value and opens the sheet', (t) async {
    final c = await _open(t, const LookAndFeelScreen(), mode: FloatingHeaderMode.scrollUp);
    expect(find.text('Floating header'), findsOneWidget);
    expect(find.text('When scrolling up'), findsOneWidget);
    await c.read(floatingHeaderProvider.notifier).set(FloatingHeaderMode.off);
    await t.pump();
    expect(find.text('Off'), findsWidgets);
    await t.ensureVisible(find.text('Floating header'));
    await t.tap(find.text('Floating header'));
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    expect(find.text('The header turns into a pill when you scroll'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('cards set the mode; switch off dims and ignores taps; on restores', (t) async {
    final c = await _open(t, _opener());
    await _openSheet(t);
    final sem = t.ensureSemantics();
    FloatingHeaderMode mode() => c.read(floatingHeaderProvider);

    expect(find.byType(KuberHeaderPage), findsNWidgets(3));
    expect(find.text('On'), findsOneWidget);

    await t.tap(find.text('When scrolling stops'));
    await t.pump();
    expect(mode(), FloatingHeaderMode.scrollStop);

    await t.tap(find.byType(Switch));
    await t.pump();
    expect(mode(), FloatingHeaderMode.off);
    expect(find.text('Off · the header scrolls away with the page'), findsOneWidget);
    final dim = t.widgetList<Opacity>(find.byType(Opacity)).where((o) => o.opacity == 0.38);
    expect(dim.length, 3);
    for (final p in t.widgetList<KuberHeaderPage>(find.byType(KuberHeaderPage))) {
      expect(p.mode, FloatingHeaderMode.off);
    }

    await t.tap(find.text('Always'));
    await t.pump();
    expect(mode(), FloatingHeaderMode.off);

    await t.tap(find.byType(Switch));
    await t.pump();
    expect(mode(), FloatingHeaderMode.scrollStop);

    // Semantics: radio group with the selected card announced.
    expect(
        t.getSemantics(_card('When scrolling stops')),
        matchesSemantics(
          label: 'When scrolling stops, preview of the header',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isSelected: true,
          hasSelectedState: true,
          isChecked: true,
          hasCheckedState: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ));
    expect(t.getSemantics(_card('Always')).getSemanticsData().flagsCollection.isChecked.toString(),
        isNot(contains('true')));
    expect(find.bySemanticsLabel('Categories, header'), findsNothing);
    sem.dispose();
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('previews scroll while open and stop with the sheet', (t) async {
    await _open(t, _opener());
    await _openSheet(t);
    ScrollableState s() => t.state<ScrollableState>(find.byType(Scrollable).last);
    await t.pump(const Duration(milliseconds: 1000));
    expect(s().position.pixels, greaterThan(0));
    await t.pumpWidget(const SizedBox());
    // Nothing left ticking: pump would throw on a leaked ticker at teardown.
  });

  testWidgets('Remove animations shows a still frame instead of looping', (t) async {
    await _open(t, _opener(), still: true);
    await _openSheet(t);
    await t.pump(const Duration(milliseconds: 100));
    final pos = t
        .stateList<ScrollableState>(find.byType(Scrollable))
        .map((s) => s.position)
        .where((p) => p.maxScrollExtent > 0)
        .toList();
    expect(pos, isNotEmpty);
    for (final p in pos) {
      expect(p.pixels, 300);
    }
    await t.pump(const Duration(seconds: 3));
    for (final p in pos) {
      expect(p.pixels, 300);
    }
    await t.pumpWidget(const SizedBox());
  });
}
