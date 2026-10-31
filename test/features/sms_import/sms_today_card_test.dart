import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/sms_import/providers/sms_today_summary.dart';
import 'package:kuber/features/sms_import/widgets/sms_today_card.dart';
import 'package:kuber/l10n/app_localizations.dart';

final _today = DateTime(2026, 10, 31);
final _summary = StateProvider<SmsTodaySummary?>((ref) => null);

SmsTodaySummary _s({double spent = 0, int count = 0, bool reviewed = false}) =>
    SmsTodaySummary(
      day: _today,
      spent: spent,
      count: count,
      reviewedToday: reviewed,
    );

Future<ProviderContainer> _pump(
  WidgetTester tester,
  SmsTodaySummary initial, {
  bool reduced = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      smsTodaySummaryProvider.overrideWith((ref) => ref.watch(_summary)),
    ],
  );
  container.read(_summary.notifier).state = initial;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light(const Locale('en')),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Scaffold(body: SmsTodayCard()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('opening in caught-up state shows the rest frame', (t) async {
    await _pump(t, _s(reviewed: true));
    expect(find.text('All caught up for today'), findsOneWidget);
    expect(find.text('Every SMS today is sorted.'), findsOneWidget);
    expect(t.hasRunningAnimations, isFalse);
  });

  testWidgets('no SMS today shows the resting none state', (t) async {
    await _pump(t, _s());
    expect(find.text('No bank SMS today so far.'), findsOneWidget);
  });

  testWidgets('last message leaving: counts down, then caught up', (t) async {
    final c = await _pump(t, _s(spent: 412, count: 1));
    expect(find.text('1 SMS not added yet'), findsOneWidget);

    c.read(_summary.notifier).state = _s(reviewed: true);
    await t.pump();
    await t.pump(const Duration(milliseconds: 120));
    // Still the summary layout while the values count to zero.
    expect(find.text('All caught up for today'), findsNothing);
    expect(find.text('UNTRACKED TODAY'), findsOneWidget);

    await t.pump(const Duration(milliseconds: 200));
    expect(find.text('All caught up for today'), findsOneWidget);
    await t.pumpAndSettle();
    expect(find.text('UNTRACKED TODAY'), findsNothing);
    expect(t.hasRunningAnimations, isFalse);
  });

  testWidgets('an equal summary does not replay anything', (t) async {
    final c = await _pump(t, _s(reviewed: true));
    c.read(_summary.notifier).state = _s(reviewed: true);
    await t.pump();
    expect(t.hasRunningAnimations, isFalse);
  });

  testWidgets('reduced motion: straight cross-fade, no count-down', (t) async {
    final c = await _pump(t, _s(spent: 412, count: 1), reduced: true);
    c.read(_summary.notifier).state = _s(reviewed: true);
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(find.text('All caught up for today'), findsOneWidget);
    await t.pumpAndSettle();
    expect(find.text('UNTRACKED TODAY'), findsNothing);
  });

  testWidgets('Undo brings the summary back from caught up', (t) async {
    final c = await _pump(t, _s(reviewed: true));
    c.read(_summary.notifier).state = _s(spent: 412, count: 1);
    await t.pumpAndSettle();
    expect(find.text('1 SMS not added yet'), findsOneWidget);
    expect(find.text('All caught up for today'), findsNothing);
  });
}
