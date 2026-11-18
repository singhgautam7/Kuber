import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/charts/providers/home_income_expense_provider.dart';
import 'package:kuber/features/charts/widgets/income_expense_home_section.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/expressive_chart/expressive_chart.dart';

import '../../shared/expressive_chart/expressive_chart_test.dart' show samplePeriods, tapColumn;

Widget host(List<ExpressivePeriod> periods, {List<ExpressivePeriod> days = const []}) => ProviderScope(
      overrides: [
        monthlyChartPeriodsProvider.overrideWith((ref) => periods),
        dailyChartPeriodsProvider.overrideWith((ref) => days),
      ],
      child: MaterialApp(
        theme: AppTheme.light(const Locale('en')),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 200, 20, 600),
            child: IncomeExpenseHomeSection(),
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows title, menus, legend and selects a column', (t) async {
    t.view.physicalSize = const Size(412, 892);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(host(samplePeriods(8, firstKey: 1004)));
    await t.pumpAndSettle();
    expect(find.text('INCOME & EXPENSE'), findsOneWidget);
    expect(find.text('6M'), findsOneWidget);
    expect(find.text('Bar'), findsOneWidget);
    expect(find.text('Higher one on top'), findsOneWidget);
    await tapColumn(t, 1);
    expect(find.byKey(kExpressiveChartTooltipKey), findsOneWidget);
  });

  testWidgets('empty history shows the empty note', (t) async {
    t.view.physicalSize = const Size(412, 892);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(host(const []));
    await t.pumpAndSettle();
    expect(find.text('No income or expense yet'), findsOneWidget);
  });

  testWidgets('6M shows exactly 6 months, 1Y 12 and 7D the last 7 days', (t) async {
    t.view.physicalSize = const Size(412, 892);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final days = samplePeriods(7, firstKey: 5000);
    await t.pumpWidget(host(samplePeriods(30, firstKey: 1000), days: days));
    await t.pumpAndSettle();
    int shown() => t.widget<ExpressiveChart>(find.byType(ExpressiveChart)).periods.length;
    expect(shown(), 6);
    final c = ProviderScope.containerOf(t.element(find.byType(IncomeExpenseHomeSection)));
    c.read(homeChartRangeProvider.notifier).state = HomeChartRange.months12;
    await t.pumpAndSettle();
    expect(shown(), 12);
    c.read(homeChartRangeProvider.notifier).state = HomeChartRange.days7;
    await t.pumpAndSettle();
    expect(shown(), 7);
    expect(t.widget<ExpressiveChart>(find.byType(ExpressiveChart)).hasMoreOlder, isFalse);
  });
}
