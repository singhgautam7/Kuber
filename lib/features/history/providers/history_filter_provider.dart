import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_filter.dart';

final historyFilterProvider = StateNotifierProvider<HistoryFilterNotifier, HistoryFilter>((ref) {
  return HistoryFilterNotifier();
});

class HistoryFilterNotifier extends StateNotifier<HistoryFilter> {
  HistoryFilterNotifier() : super(const HistoryFilter());

  void toggleType(String type) {
    final newTypes = Set<String>.from(state.types);
    if (newTypes.contains(type)) {
      newTypes.remove(type);
    } else {
      newTypes.add(type);
    }
    state = state.copyWith(types: newTypes);
  }

  void setType(String type) {
    if (state.types.contains(type) && state.types.length == 1) {
      state = state.copyWith(clearTypes: true);
    } else {
      state = state.copyWith(types: {type});
    }
  }

  void toggleRecurring() {
    state = state.copyWith(
      isRecurring: state.isRecurring == true ? null : true,
      clearRecurring: state.isRecurring == true,
    );
  }

  void setFilters({
    Set<String>? types,
    bool? isRecurring,
    DateTime? from,
    DateTime? to,
    Set<String>? accountIds,
    Set<String>? categoryIds,
    Set<int>? tagIds,
    bool clearTypes = false,
    bool clearRecurring = false,
    bool clearFrom = false,
    bool clearTo = false,
  }) {
    state = state.copyWith(
      types: types,
      isRecurring: isRecurring,
      from: from,
      to: to,
      accountIds: accountIds,
      categoryIds: categoryIds,
      tagIds: tagIds,
      clearTypes: clearTypes,
      clearRecurring: clearRecurring,
      clearFrom: clearFrom,
      clearTo: clearTo,
    );
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query, clearSearchQuery: query == null || query.isEmpty);
  }

  void clearAll() {
    state = const HistoryFilter();
  }
}
