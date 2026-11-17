import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/advanced_history/providers/ah_providers.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/screens/ah_filter_page.dart';
import 'package:kuber/features/advanced_history/widgets/filter/value_pickers.dart';
import 'package:kuber/features/advanced_history/widgets/token_field/token_filter_field.dart';
import 'package:kuber/features/advanced_history/widgets/token_field/operator_bar.dart';
import 'package:kuber/features/categories/data/category_group.dart';
import 'package:kuber/features/categories/providers/category_provider.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/tags/providers/tag_providers.dart';
import 'package:kuber/l10n/app_localizations.dart';

import '../../../helpers/golden_fonts.dart';

class _Counts {
  final calls = <QueryNode?>[];
  Completer<int>? pending;
  int value = 221;
}

Future<(ProviderContainer, _Counts)> openPage(
  WidgetTester t, {
  String initial = '',
  int? countValue,
  bool hold = false,
  List<String> groups = const [],
}) async {
  await loadGoldenFonts();
  final counts = _Counts();
  if (countValue != null) counts.value = countValue;
  final container = ProviderContainer(overrides: [
    formatterProvider.overrideWithValue(AppFormatter()),
    categoryListProvider.overrideWith(() => _EmptyCats()),
    categoryGroupListProvider.overrideWith(() => _Groups(groups)),
    allAccountsProvider.overrideWith(() => _EmptyAccounts()),
    tagListProvider.overrideWith((ref) => Stream.value(const [])),
    ahCountProvider.overrideWith((ref, node) {
      counts.calls.add(node);
      if (hold) {
        counts.pending = Completer<int>();
        return counts.pending!.future;
      }
      return Future.value(counts.value);
    }),
    ahSuggestionsProvider.overrideWith((ref, q) async => const []),
  ]);
  addTearDown(container.dispose);
  if (initial.isNotEmpty) {
    container.read(ahViewProvider.notifier).setFilter(initial);
  }
  await t.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AhFilterPage())),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  ));
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
  return (container, counts);
}

class _EmptyCats extends CategoryListNotifier {
  @override
  Future<List<Category>> build() async => const <Category>[];
}

class _Groups extends CategoryGroupListNotifier {
  _Groups(this.names);
  final List<String> names;
  @override
  Future<List<CategoryGroup>> build() async =>
      [for (final n in names) CategoryGroup()..name = n];
}

class _EmptyAccounts extends AccountListNotifier {
  @override
  Future<List<Account>> build() async => const <Account>[];
}

TokenFilterField fieldWidget(WidgetTester t) =>
    t.widget<TokenFilterField>(find.byType(TokenFilterField));

void add(WidgetTester t, QueryField f, String v) => fieldWidget(t)
    .controller
    .insert(itemsOf(ConditionNode(f, QueryOp.eq, [v])), trailingAnd: true);

void main() {
  testWidgets('a category group name is a valid category value', (t) async {
    await openPage(t, initial: 'category:food', groups: ['Food']);
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.textContaining('No category called'), findsNothing);
    expect(find.text('Show 221 transactions'), findsOneWidget);
  });

  testWidgets('keyboard open: operator bar docks, bottom button hides', (t) async {
    await openPage(t, initial: 'type:expense');
    OperatorBar bar() => t.widget<OperatorBar>(find.byType(OperatorBar).last);
    expect(bar().docked, isFalse);
    expect(find.textContaining('Show'), findsOneWidget);
    // The Scaffold strips the inset from its body: the page must still see it.
    t.view.viewInsets = const FakeViewPadding(bottom: 800);
    addTearDown(t.view.resetViewInsets);
    await t.pumpAndSettle();
    expect(bar().docked, isTrue);
    expect(find.textContaining('Show'), findsNothing);
  });

  testWidgets('header: How to use opens the full guide', (t) async {
    await openPage(t);
    expect(find.text('No filters yet'), findsNothing);
    await t.tap(find.byKey(const ValueKey('ahf-how-to-use')));
    await t.pumpAndSettle();
    for (final s in ['THE BASICS', 'COMPARE AMOUNTS AND DATES',
        'COMBINE FILTERS', 'FIELDS YOU CAN USE']) {
      expect(find.text(s), findsOneWidget, reason: s);
    }
    expect(find.text('amount>500'), findsOneWidget);
    expect(find.text('category=food'), findsOneWidget);
  });

  testWidgets('no suggestions until something is typed', (t) async {
    await openPage(t);
    await t.showKeyboard(find.byKey(const ValueKey('ahf-input')));
    await t.pumpAndSettle();
    expect(find.text('FIELDS'), findsNothing);
  });

  testWidgets('Clear all clears with an Undo snackbar, no confirmation',
      (t) async {
    await openPage(t, initial: 'has:attachment and type:expense');
    final c = fieldWidget(t).controller;
    expect(c.filterCount, 2);
    await t.tap(find.byKey(const ValueKey('ahf-clear-all')));
    await t.pump();
    expect(c.items, isEmpty);
    expect(find.text('Filters cleared'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('Undo'));
    await t.pump();
    expect(c.filterCount, 2);
    await t.pump(const Duration(seconds: 8));
  });

  testWidgets('closing asks to discard only when the draft changed',
      (t) async {
    await openPage(t, initial: 'has:attachment');
    // unchanged: closes without a dialog
    await t.tap(find.byIcon(Icons.close_rounded).first);
    await t.pumpAndSettle();
    expect(find.byType(AhFilterPage), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);

    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    add(t, QueryField.type, 'expense');
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.close_rounded).first);
    await t.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await t.tap(find.text('Keep editing'));
    await t.pumpAndSettle();
    expect(find.byType(AhFilterPage), findsOneWidget);
    await t.tap(find.byIcon(Icons.close_rounded).first);
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('ahf-discard')));
    await t.pumpAndSettle();
    expect(find.byType(AhFilterPage), findsNothing);
  });

  testWidgets('live count waits 300 ms, shows a loader after 150 ms',
      (t) async {
    final (container, counts) = await openPage(t, hold: true);
    counts.calls.clear();
    add(t, QueryField.type, 'expense');
    await t.pump();
    await t.pump(const Duration(milliseconds: 299));
    expect(counts.calls, isEmpty);
    await t.pump(const Duration(milliseconds: 2));
    expect(counts.calls, hasLength(1));
    expect(find.byKey(const ValueKey('ahf-count-loader')), findsNothing);
    await t.pump(const Duration(milliseconds: 160));
    expect(find.text('Show transactions'), findsWidgets);
    expect(find.byKey(const ValueKey('ahf-count-loader')), findsOneWidget);
    counts.pending!.complete(221);
    await t.pumpAndSettle();
    expect(find.text('Show 221 transactions'), findsOneWidget);
    expect(find.byKey(const ValueKey('ahf-count-loader')), findsNothing);

    // Typing on within the debounce window cancels the stale count.
    counts.calls.clear();
    add(t, QueryField.has, 'note');
    await t.pump(const Duration(milliseconds: 200));
    add(t, QueryField.has, 'attachment');
    await t.pump(const Duration(milliseconds: 200));
    expect(counts.calls, isEmpty);
    await t.pump(const Duration(milliseconds: 150));
    expect(counts.calls, hasLength(1));
    counts.pending!.complete(5);
    await t.pumpAndSettle();

    // Apply: the view takes the draft and the page closes.
    await t.tap(find.text('Show 5 transactions'));
    await t.pumpAndSettle();
    expect(find.byType(AhFilterPage), findsNothing);
    expect(container.read(ahViewProvider).queryText,
        contains('type:expense'));
  });

  testWidgets('0 matches disables the button; empty box shows Done',
      (t) async {
    await openPage(t, countValue: 0);
    expect(find.byKey(const ValueKey('ahf-done')), findsOneWidget);
    add(t, QueryField.type, 'expense');
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('No transactions match'), findsOneWidget);
    final btn = find.ancestor(
        of: find.text('No transactions match'),
        matching: find.byType(InkWell));
    expect(t.widget<InkWell>(btn.first).onTap, isNull);
  });

  testWidgets('field list opens the Type picker and inserts at the cursor',
      (t) async {
    await openPage(t);
    final c = fieldWidget(t).controller;
    await t.dragUntilVisible(find.byKey(const ValueKey('ahf-field-type')),
        find.byType(ListView).first, const Offset(0, -200));
    await t.tap(find.byKey(const ValueKey('ahf-field-type')));
    await t.pumpAndSettle();
    expect(find.text('Filter by'.toUpperCase()), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('ahf-opt-expense')));
    await t.tap(find.byKey(const ValueKey('ahf-opt-income')));
    await t.pump();
    expect(find.text('Add filter · 2 selected'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('ahf-picker-cta')));
    await t.pumpAndSettle();
    expect(find.byType(AhFilterPage), findsOneWidget);
    expect(c.text, 'type:expense,income');
    expect(c.cursor, c.items.length); // after the token and its "and"
  });
}
