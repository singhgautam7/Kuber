// v7.0.0 review fixes: chip shape follows selection (unselected pill,
// selected 12 dp squircle) and the header back button never leaves a blank
// screen when the page was opened with nothing below it.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:kuber/shared/widgets/kuber_chips.dart';

OutlinedBorder _shapeOf(WidgetTester t, String label) {
  final m = t.widget<Material>(find.ancestor(of: find.text(label), matching: find.byType(Material)).first);
  return m.shape! as OutlinedBorder;
}

void main() {
  testWidgets('unselected chip is a pill, selected chip is a 12 dp squircle', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(children: [
          KuberChip(label: 'Off', onTap: () {}),
          KuberChip(label: 'On', selected: true, onTap: () {}),
        ]),
      ),
    ));
    await t.pumpAndSettle();
    expect(_shapeOf(t, 'Off'), isA<StadiumBorder>());
    final on = _shapeOf(t, 'On');
    expect(on, isA<RoundedRectangleBorder>());
    expect((on as RoundedRectangleBorder).borderRadius, BorderRadius.circular(12));
  });

  testWidgets('back with nothing below goes Home instead of a blank page', (t) async {
    final router = GoRouter(initialLocation: '/form', routes: [
      GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('home'))),
      GoRoute(
        path: '/form',
        builder: (_, _) => const Scaffold(
          appBar: KuberAppBar(showBack: true, closeIcon: true, title: 'Form'),
        ),
      ),
    ]);
    await t.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.close_rounded));
    await t.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });
}
