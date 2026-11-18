// The Calendar under the floating header (v7.0.0-c, owner: only the header
// is sticky). Chips, month header, grid and day list all scroll with the
// page; nothing pins, so the old fold dead zone (grid stuck part-folded over
// the day list) can't happen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/upcoming_calendar_harness.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  setUp(setUpCalendarIsar);
  tearDown(tearDownCalendarIsar);

  testWidgets('everything scrolls; nothing pins under the header', (t) async {
    t.view.padding = const FakeViewPadding(top: 48 * 3, bottom: 24 * 3);
    t.view.viewPadding = const FakeViewPadding(top: 48 * 3, bottom: 24 * 3);
    await pumpCalendar(t);
    final scroll = find.byType(CustomScrollView).last;
    final month = find.text('November').first;
    final restTop = t.getTopLeft(month).dy;

    await t.timedDrag(scroll, const Offset(0, -500), const Duration(milliseconds: 600));
    await t.pumpAndSettle();
    final scrolled = restTop - t.getTopLeft(month).dy;

    final offset = t.state<ScrollableState>(
        find.descendant(of: scroll, matching: find.byType(Scrollable)).first).position.pixels;

    // The month header moved exactly as far as the content: it didn't stop
    // under the header.
    expect(offset, greaterThan(150));
    expect(scrolled, closeTo(offset, 0.5));
  });
}
