import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/categories/providers/category_provider.dart';
import 'package:kuber/features/history/screens/advanced_filter_screen.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/tags/providers/tag_providers.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_chips.dart';

import '../../helpers/test_factories.dart';

Future<void> pump(WidgetTester t) async {
  t.view.physicalSize = const Size(900, 2400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final cats = [
    makeCategory(id: 1, name: 'Food'),
    makeCategory(id: 2, name: 'Travel'),
  ];
  await t.pumpWidget(ProviderScope(
    overrides: [
      formatterProvider.overrideWithValue(AppFormatter()),
      accountListProvider.overrideWithValue(
          AsyncValue.data([makeAccount(id: 1, name: 'HDFC')])),
      categoryListProvider.overrideWith(() => _Cats(cats)),
      tagListProvider.overrideWith(
          (ref) => Stream.value([makeTag(id: 1, name: 'trip')])),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(const Locale('en')),
      home: const AdvancedFilterScreen(),
    ),
  ));
  await t.pumpAndSettle();
}

class _Cats extends CategoryListNotifier {
  _Cats(this.list);
  final List<dynamic> list;
  @override
  Future<List<Category>> build() async => list.cast();
}

Future<void> open(WidgetTester t, String title) async {
  await t.tap(find.textContaining(title).first);
  await t.pumpAndSettle();
}

void main() {
  testWidgets('sections start collapsed, one open at a time', (t) async {
    await pump(t);
    expect(find.textContaining('· All'), findsNWidgets(3));
    expect(find.text('Food'), findsNothing);
    expect(find.byType(TextField).evaluate().length, 3); // name + min + max

    await open(t, 'Categories');
    expect(find.text('Food').first, findsOneWidget);
    expect(find.text('Search categories'), findsOneWidget);

    await open(t, 'Tags');
    expect(find.text('Food'), findsNothing);
    expect(find.text('#trip').first, findsOneWidget);

    await open(t, 'Tags');
    expect(find.text('#trip'), findsNothing);
  });

  testWidgets('selected count, chips, remove chip', (t) async {
    await pump(t);
    await open(t, 'Categories');
    await t.tap(find.text('Food').first);
    await t.pumpAndSettle();
    await open(t, 'Categories'); // collapse
    expect(find.textContaining('· 1 selected'), findsOneWidget);
    final chip = find.widgetWithIcon(KuberChip, Icons.close_rounded);
    expect(chip, findsOneWidget);
    expect(find.descendant(of: chip, matching: find.text('Food').first),
        findsOneWidget);
    await t.tap(find.descendant(
        of: chip, matching: find.byIcon(Icons.close_rounded)));
    await t.pumpAndSettle();
    expect(find.widgetWithIcon(KuberChip, Icons.close_rounded), findsNothing);
    expect(find.textContaining('· 1 selected'), findsNothing);
  });

  testWidgets('search matches anywhere, ignores case, shows empty text',
      (t) async {
    await pump(t);
    await open(t, 'Categories');
    await t.enterText(find.byType(TextField).at(3), 'AV');
    await t.pumpAndSettle();
    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Food'), findsNothing);
    await t.enterText(find.byType(TextField).at(3), 'zzz');
    await t.pumpAndSettle();
    expect(find.text('No categories match “zzz”'), findsOneWidget);
  });

  testWidgets('Custom Dashboard link is present', (t) async {
    await pump(t);
    await t.ensureVisible(find.textContaining('Custom Dashboard'));
    expect(find.textContaining('Need AND / OR filters?'), findsOneWidget);
  });
}
