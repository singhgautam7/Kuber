// The Calendar under the floating header (v7.0.0-c): the List / Calendar and
// Filter chips scroll away (the floating header is the only sticky part of
// the page itself) and the calendar's own month header and grid pin right
// under the header, as they pinned under the top before.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/upcoming_calendar_harness.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  setUp(setUpCalendarIsar);
  tearDown(tearDownCalendarIsar);

  testWidgets('chips scroll away; the month header and grid pin under the header', (t) async {
    t.view.padding = const FakeViewPadding(top: 48 * 3, bottom: 24 * 3);
    t.view.viewPadding = const FakeViewPadding(top: 48 * 3, bottom: 24 * 3);
    await pumpCalendar(t);
    final scroll = find.byType(CustomScrollView).last;
    final month = find.text('November').first;
    final restTop = t.getTopLeft(month).dy;

    await t.timedDrag(scroll, const Offset(0, -420), const Duration(milliseconds: 600));
    await t.pumpAndSettle();

    // The chips scrolled away; only the header (now the pill) and the pinned
    // month header remain above the grid.
    expect(find.text('Filter').hitTestable(), findsNothing);
    final pinnedTop = t.getTopLeft(month).dy;
    expect(pinnedTop, lessThan(restTop));
    expect(pinnedTop, greaterThanOrEqualTo(48 + 74.0)); // below the header's rest bottom
    // The grid stays usable: the selected day (12 Nov) can be tapped.
    expect(find.text('12').hitTestable(), findsWidgets);
  });
}
