
class HistoryFilter {
  final Set<String> types; // 'expense', 'income', 'transfer'
  final bool? isRecurring;
  final String? searchQuery;
  final DateTime? from;
  final DateTime? to;
  final Set<String> accountIds;
  final Set<String> categoryIds;
  final Set<int> tagIds;
  final double? minAmount;
  final double? maxAmount;

  const HistoryFilter({
    this.types = const {},
    this.isRecurring,
    this.searchQuery,
    this.from,
    this.to,
    this.accountIds = const {},
    this.categoryIds = const {},
    this.tagIds = const {},
    this.minAmount,
    this.maxAmount,
  });

  bool get isEmpty =>
      types.isEmpty &&
      isRecurring == null &&
      searchQuery == null &&
      from == null &&
      to == null &&
      accountIds.isEmpty &&
      categoryIds.isEmpty &&
      tagIds.isEmpty &&
      minAmount == null &&
      maxAmount == null;

  bool get isAdvanced =>
      from != null ||
      to != null ||
      accountIds.isNotEmpty ||
      categoryIds.isNotEmpty ||
      tagIds.isNotEmpty ||
      minAmount != null ||
      maxAmount != null ||
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
    if (minAmount != null || maxAmount != null) count++;
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
    double? minAmount,
    double? maxAmount,
    bool clearTypes = false,
    bool clearRecurring = false,
    bool clearSearchQuery = false,
    bool clearFrom = false,
    bool clearTo = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
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
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
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
          tagIds == other.tagIds &&
          minAmount == other.minAmount &&
          maxAmount == other.maxAmount;

  @override
  int get hashCode =>
      types.hashCode ^
      isRecurring.hashCode ^
      searchQuery.hashCode ^
      from.hashCode ^
      to.hashCode ^
      accountIds.hashCode ^
      categoryIds.hashCode ^
      tagIds.hashCode ^
      minAmount.hashCode ^
      maxAmount.hashCode;
}
