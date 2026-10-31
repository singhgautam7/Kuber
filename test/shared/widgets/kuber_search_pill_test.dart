import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:kuber/shared/widgets/kuber_search_pill.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: AppTheme.light(const Locale('en')),
    home: Scaffold(body: Align(alignment: Alignment.topLeft, child: child)),
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('text, hint and cursor are vertically centred; clear works', (
    tester,
  ) async {
    final c = TextEditingController();
    final changes = <String>[];
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 360,
          height: 48,
          child: KuberSearchPill(
            controller: c,
            hint: 'Search things',
            onChanged: changes.add,
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    final pillY = tester.getCenter(find.byType(KuberSearchPill)).dy;
    expect(
      (tester.getCenter(find.byType(EditableText)).dy - pillY).abs(),
      lessThan(1),
    );
    expect(
      (tester.getCenter(find.text('Search things')).dy - pillY).abs(),
      lessThan(1),
    );

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Clear'));
    await tester.pumpAndSettle();
    expect(c.text, '');
    expect(changes.last, '');
  });

  testWidgets('KuberAppBar opens search pill and closes it with back', (
    tester,
  ) async {
    final c = TextEditingController();
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 360,
          child: KuberAppBar(
            title: 'Accounts',
            search: KuberHeaderSearch(
              controller: c,
              onChanged: (_) {},
              hint: 'Search accounts',
            ),
          ),
        ),
      ),
    );
    expect(find.byType(KuberSearchPill), findsNothing);
    await tester.tap(find.bySemanticsLabel('Search accounts'));
    await tester.pumpAndSettle();
    expect(find.byType(KuberSearchPill), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close search'));
    // Closing plays the opening backwards: the pill is still mostly wide at
    // 120 ms (the old ease-in close had it 77% gone by then, which read as no
    // animation), then collapses into the search icon at the trailing edge.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final pill = find.byType(KuberSearchPill);
    Rect clip() => tester.getRect(
      find.ancestor(of: pill, matching: find.byType(ClipRect)).first,
    );
    expect(clip().width, greaterThan(250));
    await tester.pump(const Duration(milliseconds: 100));
    expect(clip().width, inExclusiveRange(0, 250));
    expect(clip().right, closeTo(344, 1));
    await tester.pumpAndSettle();
    expect(find.byType(KuberSearchPill), findsNothing);
    expect(find.text('Accounts'), findsOneWidget);
  });
}
