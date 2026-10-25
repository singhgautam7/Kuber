// Calendar view widget tests on the demo month (today Thu 12 Nov 2026).
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/upcoming_events/providers/upcoming_events_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/upcoming_calendar_harness.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  setUp(setUpCalendarIsar);
  tearDown(tearDownCalendarIsar);

  testWidgets('opens on the current month with today selected', (t) async {
    await pumpCalendar(t);
    expect(find.text('November'), findsWidgets);
    expect(find.textContaining('TODAY, 12 NOVEMBER'), findsOneWidget);
    expect(find.text('Mobile recharge'), findsOneWidget);
    expect(find.text('Needs confirmation'), findsOneWidget);
    expect(find.text('Water purifier service'), findsOneWidget);
    expect(find.textContaining('₹68,015'), findsOneWidget, reason: 'month out');
    expect(t.takeException(), isNull);
  });

  testWidgets('tapping a day shows its list; overdue and skipped states', (t) async {
    await pumpCalendar(t);
    await t.tap(find.bySemanticsLabel(RegExp(r'^Sunday 8 November')));
    await settle(t);
    expect(find.text('Electricity bill'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    await t.tap(find.bySemanticsLabel(RegExp(r'^Saturday 7 November')));
    await settle(t);
    expect(find.text('Skipped'), findsOneWidget);
    await t.tap(find.bySemanticsLabel(RegExp(r'^Thursday 5 November')));
    await settle(t);
    for (final s in ['Home loan EMI', 'Spotify', 'Broadband', 'Payment due · HDFC Regalia']) {
      expect(find.text(s), findsOneWidget, reason: s);
    }
    expect(find.text('₹812'), findsOneWidget, reason: 'actual posted amount');
  });

  testWidgets('spoken labels carry totals, overdue and confirmation', (t) async {
    final h = t.ensureSemantics();
    await pumpCalendar(t);
    expect(find.bySemanticsLabel('Sunday 8 November, 1 event, ₹1,240 out, 1 overdue'), findsOneWidget);
    expect(
        find.bySemanticsLabel(
            'Today, Thursday 12 November, selected, 2 events, ₹349 due, 1 needs confirmation'),
        findsOneWidget);
    // November 2026 ends on a Monday: the last row ends with 1 to 5 December.
    expect(find.bySemanticsLabel('1 December, next month'), findsOneWidget);
    h.dispose();
  });

  testWidgets('privacy masks every amount, spoken as hidden', (t) async {
    final h = t.ensureSemantics();
    await pumpCalendar(t, privacy: true);
    expect(find.textContaining('₹'), findsNothing);
    expect(find.textContaining('****'), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('amounts hidden')), findsWidgets);
    h.dispose();
  });

  testWidgets('filter applies to the grid, summary and day list', (t) async {
    final c = await pumpCalendar(t);
    c.read(upcomingEventsSourceFilterProvider.notifier).state = 'emi';
    await settle(t);
    expect(find.text('Mobile recharge'), findsNothing);
    // Only the home loan EMI on 5 Nov (the pre-vNext car loan shows future
    // dates only, and its 5 Nov is past).
    expect(find.textContaining('₹21,696'), findsWidgets);
    expect(find.textContaining('₹68,015'), findsNothing);
  });

  testWidgets('next month selects the 1st; long-press opens New reminder', (t) async {
    await pumpCalendar(t);
    await t.tap(find.byTooltip('Next month, December 2026'));
    await settle(t);
    await t.pump(const Duration(milliseconds: 400));
    await settle(t);
    expect(find.textContaining('TUE, 1 DECEMBER'), findsOneWidget);
    await t.longPress(find.bySemanticsLabel(RegExp(r'^Monday 28 December')));
    await settle(t);
    expect(find.text('new reminder 2026-12-28'), findsOneWidget);
  });

  testWidgets('Calendar is the default view', (t) async {
    await pumpCalendar(t, view: '');
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.textContaining('TODAY, 12 NOVEMBER'), findsOneWidget);
  });

  testWidgets('the List / Calendar choice is saved', (t) async {
    await pumpCalendar(t, view: 'list');
    expect(find.text('List'), findsOneWidget);
    await t.tap(find.text('List'));
    await settle(t);
    await t.tap(find.text('Calendar').last);
    await settle(t);
    await t.pump(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PrefsKeys.upcomingEventsView), 'calendar');
    expect(find.textContaining('TODAY, 12 NOVEMBER'), findsOneWidget);
  });

  testWidgets('every day cell is a 48 × 54 button with a spoken label', (t) async {
    final h = t.ensureSemantics();
    await pumpCalendar(t);
    final cell = find.bySemanticsLabel('Friday 20 November, 1 event, ₹1,500 in');
    expect(cell, findsOneWidget);
    final size = t.getSize(cell);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(54));
    expect(t.getSemantics(cell),
        isSemantics(isButton: true, hasTapAction: true, hasLongPressAction: true,
            label: 'Friday 20 November, 1 event, ₹1,500 in'));
    h.dispose();
  });
}
