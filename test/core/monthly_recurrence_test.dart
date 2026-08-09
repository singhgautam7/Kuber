import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/monthly_recurrence.dart';

void main() {
  group('daysInMonth', () {
    test('handles 30/31 day months', () {
      expect(daysInMonth(2024, 1), 31);
      expect(daysInMonth(2024, 4), 30);
      expect(daysInMonth(2024, 12), 31);
    });

    test('handles February leap vs non-leap', () {
      expect(daysInMonth(2024, 2), 29); // leap
      expect(daysInMonth(2023, 2), 28); // non-leap
      expect(daysInMonth(2000, 2), 29); // leap (÷400)
      expect(daysInMonth(1900, 2), 28); // non-leap (÷100 not ÷400)
    });
  });

  group('nextMonthlyOccurrence', () {
    test('same month when day is still ahead', () {
      final r = nextMonthlyOccurrence(15, DateTime(2024, 1, 10));
      expect(r, DateTime(2024, 1, 15));
    });

    test('returns today when day equals today', () {
      final r = nextMonthlyOccurrence(20, DateTime(2024, 1, 20, 14, 30));
      expect(r, DateTime(2024, 1, 20));
    });

    test('rolls to next month when day has passed', () {
      final r = nextMonthlyOccurrence(5, DateTime(2024, 1, 20));
      expect(r, DateTime(2024, 2, 5));
    });

    test('rolls across the year boundary', () {
      final r = nextMonthlyOccurrence(15, DateTime(2024, 12, 20));
      expect(r, DateTime(2025, 1, 15));
    });

    test('day 31 clamps to the last day of a short month (leap Feb)', () {
      final r = nextMonthlyOccurrence(31, DateTime(2024, 2, 5));
      expect(r, DateTime(2024, 2, 29));
    });

    test('day 31 clamps to the last day of a short month (non-leap Feb)', () {
      final r = nextMonthlyOccurrence(31, DateTime(2023, 2, 5));
      expect(r, DateTime(2023, 2, 28));
    });

    test('day 31 clamps to 30 in April', () {
      final r = nextMonthlyOccurrence(31, DateTime(2024, 4, 5));
      expect(r, DateTime(2024, 4, 30));
    });

    test('day 31 rolls from Jan into a clamped Feb', () {
      // On Feb 1 the "31st" of this month resolves to Feb 29 (leap).
      final r = nextMonthlyOccurrence(31, DateTime(2024, 2, 1));
      expect(r, DateTime(2024, 2, 29));
    });

    test('never overflows into the following month', () {
      // The old buggy impl produced 2024-03-02 for a 31st in February.
      final r = nextMonthlyOccurrence(31, DateTime(2024, 2, 10));
      expect(r.month, 2);
    });
  });

  group('ordinalDay', () {
    test('common ordinals', () {
      expect(ordinalDay(1), '1st');
      expect(ordinalDay(2), '2nd');
      expect(ordinalDay(3), '3rd');
      expect(ordinalDay(4), '4th');
      expect(ordinalDay(20), '20th');
      expect(ordinalDay(21), '21st');
      expect(ordinalDay(22), '22nd');
      expect(ordinalDay(23), '23rd');
      expect(ordinalDay(31), '31st');
    });

    test('teens are always th', () {
      expect(ordinalDay(11), '11th');
      expect(ordinalDay(12), '12th');
      expect(ordinalDay(13), '13th');
    });
  });
}
