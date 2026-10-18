import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/migrations.dart';
import 'package:kuber/features/recurring/data/recurring_interval.dart';
import 'package:kuber/features/recurring/data/recurring_repository.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

RecurringRule rule(int count, RecurrenceUnit unit, {DateTime? start}) =>
    makeRecurringRule(frequency: 'custom', customDays: count, startDate: start)
      ..intervalUnit = unit.name;

/// The first [n] dates after [from], chained like RecurringProcessor does.
List<DateTime> chain(RecurringRule r, DateTime from, int n) {
  final out = <DateTime>[];
  var d = from;
  for (var i = 0; i < n; i++) {
    d = RecurringRepository.computeNextDue(r, d);
    out.add(d);
  }
  return out;
}

void main() {
  group('next dates per unit', () {
    test('day: every 1 and every 10 days keep the time of day', () {
      final from = DateTime(2026, 10, 18, 21, 41, 26);
      expect(chain(rule(1, RecurrenceUnit.day), from, 2), [
        DateTime(2026, 10, 19, 21, 41, 26),
        DateTime(2026, 10, 20, 21, 41, 26),
      ]);
      expect(chain(rule(10, RecurrenceUnit.day), from, 2), [
        DateTime(2026, 10, 28, 21, 41, 26),
        DateTime(2026, 11, 7, 21, 41, 26),
      ]);
    });

    test('week: every 1 and every 2 weeks', () {
      final from = DateTime(2026, 12, 25);
      expect(chain(rule(1, RecurrenceUnit.week), from, 2),
          [DateTime(2027, 1, 1), DateTime(2027, 1, 8)]);
      expect(chain(rule(2, RecurrenceUnit.week), from, 2),
          [DateTime(2027, 1, 8), DateTime(2027, 1, 22)]);
    });

    test('day / week across a DST change keep the wall-clock time', () {
      // US DST starts 8 Mar 2026, EU 29 Mar 2026. Calendar arithmetic keeps
      // 09:00 in any zone (a 24 h Duration would land on 08:00 or 10:00).
      for (final from in [DateTime(2026, 3, 7, 9), DateTime(2026, 3, 28, 9)]) {
        expect(RecurringRepository.computeNextDue(rule(1, RecurrenceUnit.day), from).hour, 9);
        expect(RecurringRepository.computeNextDue(rule(1, RecurrenceUnit.week), from).hour, 9);
      }
    });

    test('month: quarterly and every 6 months', () {
      final from = DateTime(2026, 11, 15);
      expect(chain(rule(3, RecurrenceUnit.month), from, 3), [
        DateTime(2027, 2, 15),
        DateTime(2027, 5, 15),
        DateTime(2027, 8, 15),
      ]);
      expect(chain(rule(6, RecurrenceUnit.month), from, 2),
          [DateTime(2027, 5, 15), DateTime(2027, 11, 15)]);
    });

    test('month: 31st anchor goes 31 Jan, 28/29 Feb, 31 Mar (no drift)', () {
      final start = DateTime(2027, 1, 31);
      final r = rule(1, RecurrenceUnit.month, start: start);
      expect(chain(r, start, 4), [
        DateTime(2027, 2, 28),
        DateTime(2027, 3, 31),
        DateTime(2027, 4, 30),
        DateTime(2027, 5, 31),
      ]);
      final leap = rule(1, RecurrenceUnit.month, start: DateTime(2028, 1, 31));
      expect(chain(leap, DateTime(2028, 1, 31), 2),
          [DateTime(2028, 2, 29), DateTime(2028, 3, 31)]);
    });

    test('month: 30th anchor and 29th anchor', () {
      final s30 = DateTime(2027, 1, 30);
      expect(chain(rule(1, RecurrenceUnit.month, start: s30), s30, 2),
          [DateTime(2027, 2, 28), DateTime(2027, 3, 30)]);
      final s29 = DateTime(2027, 1, 29);
      expect(chain(rule(1, RecurrenceUnit.month, start: s29), s29, 2),
          [DateTime(2027, 2, 28), DateTime(2027, 3, 29)]);
    });

    test('month: every 2 months from the 31st', () {
      final s = DateTime(2026, 12, 31);
      expect(chain(rule(2, RecurrenceUnit.month, start: s), s, 3), [
        DateTime(2027, 2, 28),
        DateTime(2027, 4, 30),
        DateTime(2027, 6, 30),
      ]);
    });

    test('year: 29 Feb lands on 28 Feb, back to 29 Feb in leap years', () {
      final s = DateTime(2028, 2, 29);
      expect(chain(rule(1, RecurrenceUnit.year, start: s), s, 4), [
        DateTime(2029, 2, 28),
        DateTime(2030, 2, 28),
        DateTime(2031, 2, 28),
        DateTime(2032, 2, 29),
      ]);
    });

    test('year: every 2 years', () {
      final s = DateTime(2026, 6, 15);
      expect(chain(rule(2, RecurrenceUnit.year, start: s), s, 2),
          [DateTime(2028, 6, 15), DateTime(2030, 6, 15)]);
    });

    test('a count below 1 is treated as 1 (no infinite catch-up loop)', () {
      final from = DateTime(2026, 1, 1);
      expect(RecurringRepository.computeNextDue(rule(0, RecurrenceUnit.day), from),
          DateTime(2026, 1, 2));
      expect(
          RecurringRepository.computeNextDue(
              makeRecurringRule(frequency: 'custom', customDays: 0), from),
          DateTime(2026, 1, 2));
    });
  });

  group('legacy rules', () {
    const legacy = <String, RecurrenceInterval>{
      'daily': RecurrenceInterval(1, RecurrenceUnit.day),
      'weekly': RecurrenceInterval(1, RecurrenceUnit.week),
      'biweekly': RecurrenceInterval(2, RecurrenceUnit.week),
      'monthly': RecurrenceInterval(1, RecurrenceUnit.month),
      'yearly': RecurrenceInterval(1, RecurrenceUnit.year),
    };

    test('map to the equivalent count + unit', () {
      legacy.forEach((freq, expected) {
        expect(RecurrenceInterval.legacy(freq, null), expected, reason: freq);
      });
      expect(RecurrenceInterval.legacy('custom', 10),
          const RecurrenceInterval(10, RecurrenceUnit.day));
      expect(RecurrenceInterval.legacy('custom', null),
          const RecurrenceInterval(1, RecurrenceUnit.day));
    });

    group('migration', () {
      late Isar isar;
      setUpAll(() async => initialiseIsarForTests());
      setUp(() async => isar = await openTestIsar());
      tearDown(() async => closeAndCleanIsar(isar));

      test('every old rule type keeps the same next dates', () async {
        // Rules as the base build stored them (emulator snapshot shapes).
        final rules = [
          makeRecurringRule(frequency: 'daily',
              startDate: DateTime(2026, 10, 18, 21, 41, 26),
              nextDueAt: DateTime(2026, 10, 19, 21, 41, 26)),
          makeRecurringRule(frequency: 'weekly',
              startDate: DateTime(2026, 10, 18, 21, 44),
              nextDueAt: DateTime(2026, 10, 25, 21, 44)),
          makeRecurringRule(frequency: 'biweekly',
              startDate: DateTime(2026, 10, 18, 21, 50),
              nextDueAt: DateTime(2026, 11, 1, 21, 50)),
          makeRecurringRule(frequency: 'monthly',
              startDate: DateTime(2026, 10, 18), nextDueAt: DateTime(2026, 11, 18)),
          makeRecurringRule(frequency: 'monthly',
              startDate: DateTime(2026, 10, 31), nextDueAt: DateTime(2026, 10, 31)),
          makeRecurringRule(frequency: 'yearly',
              startDate: DateTime(2026, 10, 18), nextDueAt: DateTime(2027, 10, 18)),
          makeRecurringRule(frequency: 'custom', customDays: 10,
              startDate: DateTime(2026, 10, 18, 21, 50),
              nextDueAt: DateTime(2026, 10, 28, 21, 50)),
        ];
        final ids = await isar.writeTxn(() => isar.recurringRules.putAll(rules));
        final before = {
          for (final r in await isar.recurringRules.getAll(ids))
            r!.id: (r.nextDueAt, chain(r, r.nextDueAt, 6)),
        };

        await MigrationService.migrateRecurringIntervals(isar);

        for (final r in await isar.recurringRules.getAll(ids)) {
          expect(r!.intervalUnit, isNotNull, reason: r.frequency);
          expect(r.nextDueAt, before[r.id]!.$1, reason: r.frequency);
          expect(chain(r, r.nextDueAt, 6), before[r.id]!.$2,
              reason: r.frequency);
        }
        final byFreq = {
          for (final r in await isar.recurringRules.getAll(ids))
            r!.frequency + (r.customDays == 10 ? '10' : ''):
                RecurrenceInterval.of(r),
        };
        expect(byFreq['biweekly'], const RecurrenceInterval(2, RecurrenceUnit.week));
        expect(byFreq['custom10'], const RecurrenceInterval(10, RecurrenceUnit.day));
      });
    });
  });

  group('presets and labels', () {
    final l = AppLocalizationsEn();

    test('editing a rule selects the matching preset', () {
      expect(RecurrenceInterval.of(rule(3, RecurrenceUnit.month)).presetKey,
          'quarterly');
      expect(RecurrenceInterval.of(rule(6, RecurrenceUnit.month)).presetKey,
          'half_yearly');
      expect(RecurrenceInterval.of(makeRecurringRule(frequency: 'monthly'))
          .presetKey, 'monthly');
      expect(RecurrenceInterval.of(rule(2, RecurrenceUnit.week)).presetKey,
          'custom');
      expect(RecurrenceInterval.of(makeRecurringRule(frequency: 'biweekly'))
          .presetKey, 'custom');
    });

    test('readable descriptions', () {
      expect(const RecurrenceInterval(3, RecurrenceUnit.month).describe(l),
          'Every 3 months');
      expect(const RecurrenceInterval(6, RecurrenceUnit.month).describe(l),
          'Every 6 months');
      expect(const RecurrenceInterval(2, RecurrenceUnit.week).describe(l),
          'Every 2 weeks');
      expect(const RecurrenceInterval(10, RecurrenceUnit.day).describe(l),
          'Every 10 days');
      expect(const RecurrenceInterval(1, RecurrenceUnit.month).describe(l),
          'Monthly');
    });

    test('monthly estimate for every preset', () {
      double monthly(String preset) =>
          1200 * kRecurrencePresets[preset]!.monthlyFactor;
      expect(monthly('daily'), 36000); // x30, unchanged
      expect(monthly('weekly'), closeTo(5200, 1e-9)); // x52/12
      expect(monthly('monthly'), 1200); // unchanged
      expect(monthly('quarterly'), 400); // /3
      expect(monthly('half_yearly'), 200); // /6
      expect(monthly('yearly'), 100); // /12
      expect(
          1200 * const RecurrenceInterval(10, RecurrenceUnit.day).monthlyFactor,
          3600); // custom x30/N, unchanged
    });
  });
}
