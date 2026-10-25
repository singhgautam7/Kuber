import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/when_picker.dart';

void main() {
  late WhenValue value;

  Future<void> pump(WidgetTester tester, WhenValue initial, {WhenVariant variant = WhenVariant.full}) async {
    value = initial;
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(const Locale('en')),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => KuberWhenPicker(
              value: value,
              variant: variant,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('monthly on the 31st clamps and says so', (tester) async {
    await pump(tester, WhenValue(start: DateTime(2030, 1, 31)));
    expect(find.text('31st of the month'), findsOneWidget);
    expect(find.text('28 Feb 2030'), findsOneWidget);
    expect(find.text('last day'), findsOneWidget);
    expect(find.text('In shorter months, this falls on the last day.'), findsOneWidget);
  });

  testWidgets('presets switch the unit; weekly shows weekday dots', (tester) async {
    await pump(tester, WhenValue(start: DateTime(2030, 1, 7)));
    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    expect(value.unit, ScheduleUnit.week);
    expect(find.text('ON'), findsOneWidget);
    await tester.tap(find.text('Quarterly'));
    await tester.pumpAndSettle();
    expect((value.count, value.unit), (3, ScheduleUnit.month));
  });

  testWidgets('custom 0 and empty end count show errors', (tester) async {
    await pump(tester, WhenValue(start: DateTime(2030, 1, 7)));
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '0');
    await tester.pumpAndSettle();
    expect(find.text('Enter 1 or more.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '10');
    await tester.pumpAndSettle();
    expect(find.text('Enter 1 or more.'), findsNothing);
    expect(value.count, 10);

    await tester.tap(find.text('After'));
    await tester.pumpAndSettle();
    expect(find.text('Enter how many times, 1 or more.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '4');
    await tester.pumpAndSettle();
    expect(value.toSchedule().endCount, 4);
    expect(find.textContaining('4 times'), findsWidgets);
  });

  testWidgets('end date before the start is an error', (tester) async {
    await pump(tester,
        WhenValue(start: DateTime(2030, 1, 7), endType: ScheduleEnd.onDate, endDate: DateTime(2029, 1, 1)));
    expect(find.text('End date must be after the start date.'), findsOneWidget);
  });

  testWidgets('EMI variant locks to monthly with no "Never" end', (tester) async {
    await pump(tester, WhenValue(start: DateTime(2030, 1, 5), endType: ScheduleEnd.afterCount, endCount: 12),
        variant: WhenVariant.emi);
    expect(find.text('Repeats every month'), findsOneWidget);
    expect(find.text('Never'), findsNothing);
    expect(find.text('Number of EMIs'), findsOneWidget);
    expect(find.text('Weekly'), findsNothing);
  });
}
