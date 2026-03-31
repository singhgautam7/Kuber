import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/history/models/history_filter.dart';

void main() {
  group('HistoryFilter', () {
    test('isEmpty is true for default filter', () {
      expect(const HistoryFilter().isEmpty, true);
    });

    test('isEmpty is false when types are set', () {
      expect(const HistoryFilter(types: {'expense'}).isEmpty, false);
    });

    test('isEmpty is false when searchQuery is set', () {
      expect(
        const HistoryFilter(searchQuery: 'food').isEmpty,
        false,
      );
    });

    test('isEmpty is false when date range is set', () {
      final f = HistoryFilter(from: DateTime(2024, 1, 1));
      expect(f.isEmpty, false);
    });

    test('isAdvanced with date range', () {
      final f = HistoryFilter(from: DateTime(2024, 1, 1));
      expect(f.isAdvanced, true);
    });

    test('isAdvanced with multiple types', () {
      const f = HistoryFilter(types: {'expense', 'income'});
      expect(f.isAdvanced, true);
    });

    test('isAdvanced is false for single type only', () {
      const f = HistoryFilter(types: {'expense'});
      expect(f.isAdvanced, false);
    });

    test('isAdvanced with accountIds', () {
      const f = HistoryFilter(accountIds: {'1'});
      expect(f.isAdvanced, true);
    });

    test('isAdvanced with categoryIds', () {
      const f = HistoryFilter(categoryIds: {'1'});
      expect(f.isAdvanced, true);
    });

    test('isAdvanced with tagIds', () {
      const f = HistoryFilter(tagIds: {1});
      expect(f.isAdvanced, true);
    });

    group('activeFiltersCount', () {
      test('is 0 for default filter', () {
        expect(const HistoryFilter().activeFiltersCount, 0);
      });

      test('counts types as 1', () {
        const f = HistoryFilter(types: {'expense', 'income'});
        expect(f.activeFiltersCount, 1);
      });

      test('counts date range as 1', () {
        final f = HistoryFilter(
          from: DateTime(2024, 1, 1),
          to: DateTime(2024, 12, 31),
        );
        expect(f.activeFiltersCount, 1);
      });

      test('counts each accountId individually', () {
        const f = HistoryFilter(accountIds: {'1', '2', '3'});
        expect(f.activeFiltersCount, 3);
      });

      test('counts each categoryId individually', () {
        const f = HistoryFilter(categoryIds: {'1', '2'});
        expect(f.activeFiltersCount, 2);
      });

      test('counts each tagId individually', () {
        const f = HistoryFilter(tagIds: {1, 2});
        expect(f.activeFiltersCount, 2);
      });

      test('counts isRecurring', () {
        const f = HistoryFilter(isRecurring: true);
        expect(f.activeFiltersCount, 1);
      });

      test('counts searchQuery', () {
        const f = HistoryFilter(searchQuery: 'food');
        expect(f.activeFiltersCount, 1);
      });

      test('does not count empty searchQuery', () {
        const f = HistoryFilter(searchQuery: '');
        expect(f.activeFiltersCount, 0);
      });

      test('sums all filters', () {
        final f = HistoryFilter(
          types: {'expense'},
          isRecurring: true,
          searchQuery: 'test',
          from: DateTime(2024),
          accountIds: {'1'},
          categoryIds: {'2'},
          tagIds: {3},
        );
        // types=1 + date=1 + account=1 + category=1 + tag=1 + recurring=1 + search=1 = 7
        expect(f.activeFiltersCount, 7);
      });
    });

    test('copyWith creates new instance with overrides', () {
      const original = HistoryFilter(types: {'expense'});
      final copy = original.copyWith(types: {'income'});
      expect(copy.types, {'income'});
      expect(original.types, {'expense'});
    });

    test('copyWith with clear flags', () {
      final original = HistoryFilter(
        types: {'expense'},
        from: DateTime(2024),
        isRecurring: true,
        searchQuery: 'food',
      );
      final cleared = original.copyWith(
        clearTypes: true,
        clearFrom: true,
        clearRecurring: true,
        clearSearchQuery: true,
      );
      expect(cleared.types, isEmpty);
      expect(cleared.from, isNull);
      expect(cleared.isRecurring, isNull);
      expect(cleared.searchQuery, isNull);
    });

    test('equality', () {
      const a = HistoryFilter(types: {'expense'});
      const b = HistoryFilter(types: {'expense'});
      const c = HistoryFilter(types: {'income'});
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode consistency', () {
      const a = HistoryFilter(types: {'expense'});
      const b = HistoryFilter(types: {'expense'});
      expect(a.hashCode, b.hashCode);
    });
  });
}
