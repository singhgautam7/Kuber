import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/core/utils/currency_data.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/dashboard/providers/dashboard_provider.dart';
import 'package:kuber/features/dashboard/widgets/balance_hero_card.dart';
import 'package:kuber/features/home_v2/providers/home_v2_provider.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_path.dart';

import 'balance_card_harness.dart' show balSummary;

/// Mirrors Home in the app: the card lives in a nested (branch) navigator, so
/// its own route never stops being current; sheets and dialogs go on the root
/// navigator, whose observer is [KuberPath.observer]. The root home route
/// stands in for the shell route.
final _rootKey = GlobalKey<NavigatorState>();

Widget _app() => ProviderScope(
      key: UniqueKey(),
      overrides: [
        monthlySummaryProvider.overrideWith((ref) async => balSummary()),
        formatterProvider.overrideWithValue(AppFormatter()),
        currencyProvider.overrideWithValue(kCurrencies.first),
        privacyModeProvider.overrideWithValue(false),
        isHomeV2Provider.overrideWithValue(false),
      ],
      child: MaterialApp(
        navigatorKey: _rootKey,
        navigatorObservers: [KuberPath.observer],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) =>
            MotionScope(level: MotionLevel.expressive, systemOff: false, child: child!),
        home: Builder(builder: (context) {
          KuberPath.shellRoute = ModalRoute.of(context);
          return Scaffold(
            body: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => ListView(children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Consumer(
                      builder: (c, ref, _) => ref.watch(monthlySummaryProvider).maybeWhen(
                            data: (s) => BalanceHeroCard(summary: s),
                            orElse: () => const SizedBox(),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2000),
                ]),
              ),
            ),
          );
        }),
      ),
    );

Future<void> _pump(WidgetTester t) async {
  t.view.physicalSize = const Size(412, 892);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(_app());
  await t.pumpAndSettle();
}

Future<void> _focusExpense(WidgetTester t) async {
  await t.tap(find.byKey(const Key('balBarExpense')));
  await t.pumpAndSettle();
  expect(find.text('EXPENSE'), findsOneWidget);
}

void main() {
  tearDown(() => KuberPath.shellRoute = null);

  testWidgets('control: focus is kept when nothing is pushed', (t) async {
    await _pump(t);
    await _focusExpense(t);
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(find.text('EXPENSE'), findsOneWidget);
    expect(find.text('NET'), findsNothing);
  });

  testWidgets('a bottom sheet on the root navigator takes the card back to net', (t) async {
    await _pump(t);
    await _focusExpense(t);
    showModalBottomSheet<void>(
      context: _rootKey.currentContext!,
      useRootNavigator: true,
      builder: (_) => const SizedBox(height: 200, child: Text('a sheet')),
    );
    await t.pumpAndSettle();
    expect(find.text('a sheet'), findsOneWidget);
    expect(find.text('NET'), findsOneWidget);
    expect(find.text('EXPENSE'), findsNothing);
  });

  testWidgets('a dialog on the root navigator takes the card back to net', (t) async {
    await _pump(t);
    await _focusExpense(t);
    showDialog<void>(
      context: _rootKey.currentContext!,
      useRootNavigator: true,
      builder: (_) => const AlertDialog(content: Text('a dialog')),
    );
    await t.pumpAndSettle();
    expect(find.text('a dialog'), findsOneWidget);
    expect(find.text('NET'), findsOneWidget);
    expect(find.text('EXPENSE'), findsNothing);
  });

  testWidgets('the card can be focused again after the sheet closes', (t) async {
    await _pump(t);
    await _focusExpense(t);
    showDialog<void>(
      context: _rootKey.currentContext!,
      builder: (_) => const AlertDialog(content: Text('a dialog')),
    );
    await t.pumpAndSettle();
    _rootKey.currentState!.pop();
    await t.pumpAndSettle();
    expect(find.text('NET'), findsOneWidget);
    await _focusExpense(t);
  });
}
