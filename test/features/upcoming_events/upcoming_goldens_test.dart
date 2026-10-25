// Image goldens for the Upcoming events calendar (upcoming-calendar-v1).
// Regenerate after an approved visual change:
//   flutter test --update-goldens test/features/upcoming_events/upcoming_goldens_test.dart
// Rendered on macOS; text uses the bundled Inter.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/core/theme/theme_families.dart';
import 'package:kuber/features/upcoming_events/widgets/event_row_bits.dart';
import 'package:kuber/features/upcoming_events/widgets/upcoming_day_cell.dart';
import 'package:kuber/l10n/app_localizations.dart';

import '../../helpers/golden_fonts.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/upcoming_calendar_harness.dart';

const _states = <(String, DayCellState)>[
  ('Default', DayCellState(day: 15, dots: [DayDot('emi'), DayDot('recurring')])),
  ('Empty', DayCellState(day: 15)),
  ('Today', DayCellState(day: 12, today: true, dots: [DayDot('emi')])),
  ('Selected', DayCellState(day: 15, selected: true, dots: [DayDot('emi'), DayDot('recurring')])),
  ('Today + selected', DayCellState(day: 12, today: true, selected: true, dots: [DayDot('emi'), DayDot('recurring')])),
  ('Past', DayCellState(day: 3, past: true, dots: [DayDot('emi')])),
  ('Other month', DayCellState(day: 1, otherMonth: true, dots: [DayDot('emi')])),
  ('Overdue', DayCellState(day: 8, past: true, overdue: true, dots: [DayDot('reminder')])),
  ('Many (+2)', DayCellState(day: 5, past: true, dots: [
    DayDot('emi'), DayDot('creditCard'), DayDot('emi'), DayDot('recurring'), DayDot('recurring'),
  ])),
  ('Skipped', DayCellState(day: 7, past: true, dots: [DayDot('recurring', skipped: true)])),
  ('Selected + overdue', DayCellState(day: 8, past: true, selected: true, overdue: true, dots: [DayDot('reminder')])),
];

Widget _app(ThemeData theme, Widget child) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  setUpAll(() async {
    await initialiseIsarForTests();
    await loadGoldenFonts();
  });

  for (final dark in [false, true]) {
    final name = dark ? 'dark' : 'light';
    testWidgets('day cell states ($name)', (t) async {
      t.view.physicalSize = const Size(1200, 900);
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      final theme = dark ? AppTheme.dark(const Locale('en')) : AppTheme.light(const Locale('en'));
      await t.pumpWidget(_app(
        theme,
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(spacing: 16, runSpacing: 16, children: [
            for (final (label, s) in _states)
              SizedBox(
                width: 120,
                child: Column(children: [
                  UpcomingDayCell(state: s),
                  const SizedBox(height: 6),
                  Text(label, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                ]),
              ),
          ]),
        ),
      ));
      await settleFonts(t);
      await expectLater(find.byType(Scaffold), matchesGoldenFile('../../goldens/upcoming/day_cells_$name.png'));
    });

    // Decision 8: the dots depend only on light / dark, never on the family.
    testWidgets('type colours in every theme family ($name)', (t) async {
      t.view.physicalSize = const Size(1400, 1500);
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      await t.pumpWidget(_app(
        dark ? AppTheme.dark(const Locale('en')) : AppTheme.light(const Locale('en')),
        ListView(padding: const EdgeInsets.all(12), children: [
          for (final v in kSelectableVariants)
            Builder(builder: (context) {
              final theme = dark ? AppTheme.dark(const Locale('en'), v) : AppTheme.light(const Locale('en'), v);
              return Theme(
                data: theme,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: theme.colorScheme.surface,
                  child: Row(children: [
                    SizedBox(width: 120, child: Text(v.name, style: theme.textTheme.bodySmall)),
                    for (final type in kUpcomingTypes) ...[
                      EventTypeTile(sourceType: type, size: 28),
                      const SizedBox(width: 6),
                      const UpcomingDayCell(state: DayCellState(day: 9), width: 36),
                    ],
                  ]),
                ),
              );
            }),
        ]),
      ));
      await settleFonts(t);
      await expectLater(find.byType(Scaffold), matchesGoldenFile('../../goldens/upcoming/type_colours_$name.png'));
    });
  }

  group('calendar screen', () {
    setUp(setUpCalendarIsar);
    tearDown(tearDownCalendarIsar);
    for (final (name, dark, privacy) in [('light', false, false), ('dark', true, false), ('privacy', false, true)]) {
      testWidgets('November, today selected ($name)', (t) async {
        await pumpCalendar(t, dark: dark, privacy: privacy);
        await settleFonts(t);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('../../goldens/upcoming/calendar_$name.png'));
      });
    }
  });
}
