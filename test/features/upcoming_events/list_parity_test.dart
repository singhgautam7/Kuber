// Parity (vcal Part 2): the List view shows the same events in the same order
// before and after the occurrencesBetween refactor. The golden was written by
// the aggregator as it was before the refactor (UPDATE_GOLDEN=1 rewrites it;
// only do that for an approved change).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/upcoming_events/engine/event_aggregator.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/upcoming_fixture.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  late Isar isar;
  setUp(() async {
    isar = await openTestIsar();
    await seedUpcomingFixture(isar);
  });
  tearDown(() => closeAndCleanIsar(isar));

  const golden = 'test/fixtures/upcoming/list_golden.json';

  String line(UpcomingEvent e) =>
      '${e.date.toIso8601String()}|${e.sourceType}|${e.sourceId}|${e.title}|${e.amount}';

  test('list events match the pre-refactor golden', () async {
    final out = <String, List<String>>{};
    final clocks = {
      'start': DateTime(2026, 11, 12),
      'mid': upcomingNow,
      'late': DateTime(2026, 11, 12, 23, 59),
      'monthEnd': DateTime(2026, 11, 30, 8),
    };
    for (final c in clocks.entries) {
      for (final days in [7, 30, 90]) {
        for (final f in [null, 'reminder', 'emi', 'sip', 'recurring', 'ledger', 'creditCard']) {
          final events = await UpcomingEventsAggregator(isar).getUpcomingEvents(
            window: Duration(days: days),
            sourceFilters: f == null ? null : {f},
            at: c.value,
          );
          // FD maturity is new in the List (upcoming-calendar-v1 copy.md,
          // "Changed in List view"); every other row must match.
          out['${c.key}/$days/${f ?? 'all'}'] =
              events.where((e) => e is! InvestmentMaturityEvent).map(line).toList();
        }
      }
    }
    final file = File(golden);
    if (Platform.environment['UPDATE_GOLDEN'] == '1' || !file.existsSync()) {
      file
        ..createSync(recursive: true)
        ..writeAsStringSync(const JsonEncoder.withIndent(' ').convert(out));
    }
    final expected = (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, (v as List).cast<String>()));
    expect(out.keys.toSet(), expected.keys.toSet());
    for (final k in expected.keys) {
      expect(out[k], expected[k], reason: k);
    }
    expect(expected['mid/30/all'], isNotEmpty);
  });

  test('FD maturity shows once in the List, under SIPs, as money in', () async {
    final events = await UpcomingEventsAggregator(isar).getUpcomingEvents(
        window: const Duration(days: 30), at: upcomingNow);
    final fd = events.whereType<InvestmentMaturityEvent>().single;
    expect(fd.date, DateTime(2026, 11, 25));
    expect(fd.amount, greaterThan(48500));
    expect(fd.sourceType, 'sip');
    final i = events.indexOf(fd);
    expect(events[i - 1].date.isAfter(fd.date), isFalse);
    expect(events[i + 1].date.isBefore(fd.date), isFalse);
    final sipsOnly = await UpcomingEventsAggregator(isar).getUpcomingEvents(
        window: const Duration(days: 30), sourceFilters: {'sip'}, at: upcomingNow);
    expect(sipsOnly.whereType<InvestmentMaturityEvent>(), hasLength(1));
  });
}
