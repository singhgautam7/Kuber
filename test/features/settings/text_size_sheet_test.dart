import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/settings/widgets/text_size_sheet.dart';
import 'package:kuber/l10n/app_localizations.dart';

void main() {
  testWidgets('renders TextSizeSheet with 5 levels and slider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(const Locale('en')),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => TextSizeSheet.show(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Sheet title + the slider row label.
    expect(find.text('Text size'), findsNWidgets(2));
    // Level 3 of 5 is the default (100%).
    expect(find.text('Default (100%)'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 3);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('PREVIEW'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Tap Done to close
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Text size'), findsNothing);
  });
}
