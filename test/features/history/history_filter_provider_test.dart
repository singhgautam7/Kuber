import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuber/features/history/providers/history_filter_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('HistoryFilterNotifier', () {
    test('initial state is empty filter', () {
      final filter = container.read(historyFilterProvider);
      expect(filter.isEmpty, true);
    });

    test('toggleType adds type', () {
      container.read(historyFilterProvider.notifier).toggleType('expense');
      final filter = container.read(historyFilterProvider);
      expect(filter.types, {'expense'});
    });

    test('toggleType removes existing type', () {
      container.read(historyFilterProvider.notifier).toggleType('expense');
      container.read(historyFilterProvider.notifier).toggleType('expense');
      final filter = container.read(historyFilterProvider);
      expect(filter.types, isEmpty);
    });

    test('toggleType supports multiple types', () {
      final notifier = container.read(historyFilterProvider.notifier);
      notifier.toggleType('expense');
      notifier.toggleType('income');
      final filter = container.read(historyFilterProvider);
      expect(filter.types, {'expense', 'income'});
    });

    test('setType sets single type', () {
      container.read(historyFilterProvider.notifier).setType('expense');
      final filter = container.read(historyFilterProvider);
      expect(filter.types, {'expense'});
    });

    test('setType clears when toggling same single type', () {
      final notifier = container.read(historyFilterProvider.notifier);
      notifier.setType('expense');
      notifier.setType('expense');
      final filter = container.read(historyFilterProvider);
      expect(filter.types, isEmpty);
    });

    test('toggleRecurring toggles isRecurring', () {
      final notifier = container.read(historyFilterProvider.notifier);
      notifier.toggleRecurring();
      expect(container.read(historyFilterProvider).isRecurring, true);

      notifier.toggleRecurring();
      expect(container.read(historyFilterProvider).isRecurring, isNull);
    });

    test('setFilters applies multiple filters', () {
      container.read(historyFilterProvider.notifier).setFilters(
        types: {'expense'},
        accountIds: {'1', '2'},
        from: DateTime(2024, 1, 1),
      );
      final filter = container.read(historyFilterProvider);
      expect(filter.types, {'expense'});
      expect(filter.accountIds, {'1', '2'});
      expect(filter.from, DateTime(2024, 1, 1));
    });

    test('setFilters with clear flags', () {
      final notifier = container.read(historyFilterProvider.notifier);
      notifier.setFilters(types: {'expense'}, from: DateTime(2024));
      notifier.setFilters(clearTypes: true, clearFrom: true);
      final filter = container.read(historyFilterProvider);
      expect(filter.types, isEmpty);
      expect(filter.from, isNull);
    });

    test('setSearchQuery sets query', () {
      container.read(historyFilterProvider.notifier).setSearchQuery('food');
      expect(container.read(historyFilterProvider).searchQuery, 'food');
    });

    test('setSearchQuery clears with null', () {
      final notifier = container.read(historyFilterProvider.notifier);
      notifier.setSearchQuery('food');
      notifier.setSearchQuery(null);
      expect(container.read(historyFilterProvider).searchQuery, isNull);
    });

    test('setSearchQuery clears with empty string', () {
      final notifier = container.read(historyFilterProvider.notifier);
      notifier.setSearchQuery('food');
      notifier.setSearchQuery('');
      expect(container.read(historyFilterProvider).searchQuery, isNull);
    });

    test('clearAll resets to default', () {
      final notifier = container.read(historyFilterProvider.notifier);
      notifier.setFilters(
        types: {'expense'},
        isRecurring: true,
        accountIds: {'1'},
        categoryIds: {'2'},
        tagIds: {3},
        from: DateTime(2024),
      );
      notifier.setSearchQuery('test');
      notifier.clearAll();
      expect(container.read(historyFilterProvider).isEmpty, true);
    });
  });
}
