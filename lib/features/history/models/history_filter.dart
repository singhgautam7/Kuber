
class HistoryFilter {
  final Set<String> types; // 'expense', 'income', 'transfer'
  final bool? isRecurring;
  final String? searchQuery;
  final DateTime? from;
  final DateTime? to;
  final Set<String> accountIds;
  final Set<String> categoryIds;
  final Set<int> tagIds;

  const HistoryFilter({
    this.types = const {},
    this.isRecurring,
    this.searchQuery,
    this.from,
    this.to,
    this.accountIds = const {},
    this.categoryIds = const {},
    this.tagIds = const {},
  });

  bool get isEmpty =>
      types.isEmpty &&
      isRecurring == null &&
      searchQuery == null &&
      from == null &&
      to == null &&
      accountIds.isEmpty &&
      categoryIds.isEmpty &&
      tagIds.isEmpty;

  bool get isAdvanced =>
      from != null ||
      to != null ||
      accountIds.isNotEmpty ||
      categoryIds.isNotEmpty ||
      tagIds.isNotEmpty ||
      types.length > 1;

  int get activeFiltersCount {
    int count = 0;
    if (types.isNotEmpty) count++;
    if (from != null || to != null) count++;
    if (accountIds.isNotEmpty) count += accountIds.length;
    if (categoryIds.isNotEmpty) count += categoryIds.length;
    if (tagIds.isNotEmpty) count += tagIds.length;
    if (isRecurring != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    return count;
  }

  HistoryFilter copyWith({
    Set<String>? types,
    bool? isRecurring,
    String? searchQuery,
    DateTime? from,
    DateTime? to,
    Set<String>? accountIds,
    Set<String>? categoryIds,
    Set<int>? tagIds,
    bool clearTypes = false,
    bool clearRecurring = false,
    bool clearSearchQuery = false,
    bool clearFrom = false,
    bool clearTo = false,
  }) {
    return HistoryFilter(
      types: clearTypes ? const {} : (types ?? this.types),
      isRecurring: clearRecurring ? null : (isRecurring ?? this.isRecurring),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      accountIds: accountIds ?? this.accountIds,
      categoryIds: categoryIds ?? this.categoryIds,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryFilter &&
          runtimeType == other.runtimeType &&
          types == other.types &&
          isRecurring == other.isRecurring &&
          searchQuery == other.searchQuery &&
          from == other.from &&
          to == other.to &&
          accountIds == other.accountIds &&
          categoryIds == other.categoryIds &&
          tagIds == other.tagIds;

  @override
  int get hashCode =>
      types.hashCode ^
      isRecurring.hashCode ^
      searchQuery.hashCode ^
      from.hashCode ^
      to.hashCode ^
      accountIds.hashCode ^
      categoryIds.hashCode ^
      tagIds.hashCode;
}
