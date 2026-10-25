// Characterization fixtures for the schedule rules Kuber used before the
// shared engine. Recorded once from the pre-vNext code (base 6ce4f0e) with
//   KUBER_RECORD_FIXTURES=1 flutter test test/core/schedule/legacy_fixtures_test.dart
// and afterwards only compared. The legacy copy in
// lib/core/schedule/legacy_schedules.dart must reproduce them exactly.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/schedule/legacy_schedules.dart';

import 'schedule_fixture_cases.dart';

const _dir = 'test/fixtures/schedules';
final _record = Platform.environment['KUBER_RECORD_FIXTURES'] == '1';

void main() {
  test('recurring chains match the recorded fixtures', () {
    final actual = {
      for (final c in recurringCases()) c.id: legacyChain(c).map(fmtDay).toList()
    };
    _compareOrRecord('recurring_chains.json', actual);
  });

  test('recurring catch-up (paused, missed periods) matches fixtures', () {
    final actual = <String, Object>{};
    for (final c in catchUpCases()) {
      final r = legacyRecurringCatchUp(
        count: c.base.count,
        unit: c.base.unit,
        startDate: c.base.start,
        nextDueAt: c.nextDueAt,
        endType: c.base.endType,
        endAfter: c.base.endAfter,
        endDate: c.base.endDate,
        executionCount: c.executionCount,
        isPaused: c.isPaused,
        now: c.now,
      );
      actual[c.id] = {
        'posted': r.posted.map(fmtDay).toList(),
        'nextDueAt': r.nextDueAt.toIso8601String(),
        'executionCount': r.executionCount,
      };
    }
    _compareOrRecord('recurring_catch_up.json', actual);
  });

  test('loan EMI / SIP same-day postings match fixtures', () {
    final actual = {
      for (final day in sameDayDays)
        'day$day': legacySameDayPostings(
                day, DateTime(2025, 1, 1), DateTime(2027, 12, 31))
            .take(24)
            .map(fmtDay)
            .toList()
    };
    _compareOrRecord('loan_sip_same_day.json', actual);
  });
}

void _compareOrRecord(String name, Map<String, Object> actual) {
  final file = File('$_dir/$name');
  if (_record) {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
        const JsonEncoder.withIndent(' ').convert(actual));
    return;
  }
  final expected = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  expect(actual.keys.toSet(), expected.keys.toSet());
  for (final k in expected.keys) {
    expect(jsonEncode(actual[k]), jsonEncode(expected[k]), reason: k);
  }
}
