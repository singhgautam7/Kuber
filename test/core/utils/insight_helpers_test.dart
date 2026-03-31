import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/insight_helpers.dart';
import '../../helpers/test_factories.dart';

void main() {
  group('median', () {
    test('returns 0 for empty list', () {
      expect(median([]), 0);
    });

    test('returns single element for list of 1', () {
      expect(median([42]), 42);
    });

    test('returns middle value for odd-length list', () {
      expect(median([1, 3, 5]), 3);
    });

    test('returns average of middle two for even-length list', () {
      expect(median([1, 2, 3, 4]), 2.5);
    });

    test('handles unsorted input', () {
      expect(median([5, 1, 3]), 3);
    });

    test('handles duplicate values', () {
      expect(median([2, 2, 2]), 2);
    });
  });

  group('removeOutliers', () {
    test('returns input unchanged if fewer than 4 items', () {
      expect(removeOutliers([1.0, 2.0, 3.0]), [1.0, 2.0, 3.0]);
    });

    test('removes values > 3x median', () {
      final result = removeOutliers([10.0, 12.0, 11.0, 100.0]);
      // median of [10,11,12,100] = (11+12)/2 = 11.5; 3*11.5 = 34.5
      expect(result, isNot(contains(100.0)));
      expect(result, containsAll([10.0, 12.0, 11.0]));
    });

    test('keeps values at or below 3x median', () {
      final result = removeOutliers([10.0, 12.0, 11.0, 33.0]);
      // median=11.5, 3*11.5=34.5, 33 <= 34.5 → kept
      expect(result, contains(33.0));
    });

    test('returns all values if median is 0', () {
      final input = [0.0, 0.0, 0.0, 100.0];
      expect(removeOutliers(input), input);
    });
  });

  group('formatDelta', () {
    test('formats positive percentage', () {
      expect(formatDelta(25), '25% more');
    });

    test('formats negative percentage', () {
      expect(formatDelta(-30), '30% less');
    });

    test('caps at 150% with "significantly more"', () {
      expect(formatDelta(150), 'significantly more');
      expect(formatDelta(200), 'significantly more');
    });

    test('caps at -150% with "significantly less"', () {
      expect(formatDelta(-150), 'significantly less');
      expect(formatDelta(-300), 'significantly less');
    });

    test('truncates to int', () {
      expect(formatDelta(33.7), '33% more');
    });
  });

  group('window', () {
    test('excludes transfers', () {
      final txns = [
        makeTransaction(isTransfer: true, transferId: 'x'),
        makeTransaction(name: 'Groceries'),
      ];
      final result = window(txns, days: 30);
      expect(result.length, 1);
      expect(result.first.name, 'Groceries');
    });

    test('excludes balance adjustments', () {
      final txns = [
        makeTransaction(isBalanceAdjustment: true),
        makeTransaction(name: 'Normal'),
      ];
      final result = window(txns, days: 30);
      expect(result.length, 1);
    });

    test('filters to expenses only by default', () {
      final txns = [
        makeTransaction(type: 'income'),
        makeTransaction(type: 'expense', name: 'Food'),
      ];
      final result = window(txns, days: 30);
      expect(result.length, 1);
      expect(result.first.name, 'Food');
    });

    test('includes all types when expenseOnly is false', () {
      final txns = [
        makeTransaction(type: 'income'),
        makeTransaction(type: 'expense'),
      ];
      final result = window(txns, days: 30, expenseOnly: false);
      expect(result.length, 2);
    });

    test('filters transactions older than window', () {
      final old = makeTransaction(
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );
      final recent = makeTransaction();
      final result = window([old, recent], days: 30);
      expect(result.length, 1);
    });
  });
}
