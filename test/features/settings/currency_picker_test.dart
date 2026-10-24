import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/settings/widgets/currency_selector_sheet.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark(const Locale('en')),
        home: Consumer(
          builder: (context, ref, _) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showCurrencyPicker(
                    context: context, ref: ref, currentCode: 'INR', onSelected: (_) {}),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('Suggested first, then all currencies', (tester) async {
    await open(tester);
    expect(find.text('SUGGESTED'), findsOneWidget);
    expect(find.text('ALL CURRENCIES'), findsOneWidget);
    expect(find.text('Indian Rupee'), findsWidgets);
  });

  testWidgets('search by name, code and country', (tester) async {
    await open(tester);
    final search = find.byType(TextField);

    await tester.enterText(search, 'kenya');
    await tester.pumpAndSettle();
    expect(find.text('SUGGESTED'), findsNothing);
    expect(find.text('KES'), findsOneWidget);

    await tester.enterText(search, 'kwd');
    await tester.pumpAndSettle();
    expect(find.text('Kuwaiti Dinar'), findsOneWidget);

    await tester.enterText(search, 'japan');
    await tester.pumpAndSettle();
    expect(find.text('JPY'), findsOneWidget);

    await tester.enterText(search, 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('No currency matches'), findsOneWidget);
  });
}
