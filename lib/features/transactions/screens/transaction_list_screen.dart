import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../data/transaction.dart';
import '../providers/transaction_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  // Advanced filter state
  DateTimeRange? _dateRange;
  String? _typeFilter;
  Set<int> _selectedAccountIds = {};
  Set<int> _selectedCategoryIds = {};

  bool get _hasAdvancedFilters =>
      _dateRange != null ||
      _typeFilter != null ||
      _selectedAccountIds.isNotEmpty ||
      _selectedCategoryIds.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAdvancedFilters() {
    setState(() {
      _dateRange = null;
      _typeFilter = null;
      _selectedAccountIds = {};
      _selectedCategoryIds = {};
    });
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    var filtered = transactions;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) => t.name.toLowerCase().contains(query)).toList();
    }

    // Simple type filter (from chips)
    switch (_selectedFilter) {
      case 'expense':
        filtered = filtered.where((t) => t.type == 'expense').toList();
        break;
      case 'income':
        filtered = filtered.where((t) => t.type == 'income').toList();
        break;
      case 'this_month':
        final now = DateTime.now();
        filtered = filtered
            .where((t) =>
                t.createdAt.year == now.year && t.createdAt.month == now.month)
            .toList();
        break;
    }

    // Advanced filters
    if (_dateRange != null) {
      filtered = filtered.where((t) =>
          !t.createdAt.isBefore(_dateRange!.start) &&
          t.createdAt.isBefore(_dateRange!.end.add(const Duration(days: 1)))).toList();
    }

    if (_typeFilter != null) {
      filtered = filtered.where((t) => t.type == _typeFilter).toList();
    }

    if (_selectedAccountIds.isNotEmpty) {
      filtered = filtered.where((t) =>
          _selectedAccountIds.contains(int.tryParse(t.accountId))).toList();
    }

    if (_selectedCategoryIds.isNotEmpty) {
      filtered = filtered.where((t) =>
          _selectedCategoryIds.contains(int.tryParse(t.categoryId))).toList();
    }

    return filtered;
  }

  List<_DateGroup> _groupByDate(List<Transaction> transactions) {
    final groups = <String, List<Transaction>>{};
    for (final t in transactions) {
      final key =
          DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day)
              .toIso8601String();
      groups.putIfAbsent(key, () => []).add(t);
    }

    final result = groups.entries.map((e) {
      final date = DateTime.parse(e.key);
      final txns = e.value
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      double dayTotal = 0;
      for (final t in txns) {
        dayTotal += t.type == 'income' ? t.amount : -t.amount;
      }

      final label = DateFormatter.groupHeader(date).toUpperCase();

      return _DateGroup(
        label: label,
        date: date,
        dayTotal: dayTotal,
        transactions: txns,
      );
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  void _showTransactionDetail(Transaction t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KuberColors.surfaceCard,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _TransactionDetailSheet(
        transaction: t,
        onEdit: () {
          Navigator.pop(context);
          context.push('/add-transaction', extra: t);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteWithUndo(t);
        },
      ),
    );
  }

  void _deleteWithUndo(Transaction t) {
    ref.read(transactionListProvider.notifier).delete(t.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${t.name}"'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            final restored = Transaction()
              ..name = t.name
              ..amount = t.amount
              ..type = t.type
              ..categoryId = t.categoryId
              ..accountId = t.accountId
              ..notes = t.notes
              ..createdAt = t.createdAt
              ..updatedAt = t.updatedAt
              ..nameLower = t.nameLower;
            ref.read(transactionListProvider.notifier).add(restored);
          },
        ),
      ),
    );
  }

  void _openAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: KuberColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AdvancedFilterSheet(
        dateRange: _dateRange,
        typeFilter: _typeFilter,
        selectedAccountIds: _selectedAccountIds,
        selectedCategoryIds: _selectedCategoryIds,
        searchQuery: _searchQuery,
        onApply: (dateRange, typeFilter, accountIds, categoryIds, searchQuery) {
          setState(() {
            _dateRange = dateRange;
            _typeFilter = typeFilter;
            _selectedAccountIds = accountIds;
            _selectedCategoryIds = categoryIds;
            if (searchQuery != _searchQuery) {
              _searchQuery = searchQuery;
              _searchController.text = searchQuery;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          const SliverToBoxAdapter(
            child: KuberAppBar(title: 'Transactions'),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.lg,
                vertical: KuberSpacing.sm,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.plusJakartaSans(
                  color: KuberColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: KuberColors.textMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: KuberColors.textMuted,
                    size: 20,
                  ),
                  suffixIcon: const Icon(
                    Icons.mic_outlined,
                    color: KuberColors.textMuted,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: KuberColors.surfaceElement,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                    vertical: KuberSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: KuberColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.lg,
                vertical: KuberSpacing.xs,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_hasAdvancedFilters) ...[
                      FilterChip(
                        avatar: const Icon(Icons.close, size: 14),
                        label: const Text('Clear Filters'),
                        selected: false,
                        onSelected: (_) => _clearAdvancedFilters(),
                        backgroundColor: KuberColors.expense.withValues(alpha: 0.15),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: KuberColors.expense,
                        ),
                      ),
                      const SizedBox(width: KuberSpacing.sm),
                    ],
                    _KuberFilterChip(
                      label: 'All',
                      selected: _selectedFilter == 'all',
                      onTap: () {
                        if (_selectedFilter == 'all') return;
                        setState(() => _selectedFilter = 'all');
                      },
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    _KuberFilterChip(
                      label: 'Expenses',
                      selected: _selectedFilter == 'expense',
                      onTap: () {
                        if (_selectedFilter == 'expense') return;
                        setState(() => _selectedFilter = 'expense');
                      },
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    _KuberFilterChip(
                      label: 'Income',
                      selected: _selectedFilter == 'income',
                      onTap: () {
                        if (_selectedFilter == 'income') return;
                        setState(() => _selectedFilter = 'income');
                      },
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    _KuberFilterChip(
                      label: 'This Month',
                      selected: _selectedFilter == 'this_month',
                      onTap: () {
                        if (_selectedFilter == 'this_month') return;
                        setState(() => _selectedFilter = 'this_month');
                      },
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    _AdvancedFilterButton(
                      hasFilters: _hasAdvancedFilters,
                      onTap: _openAdvancedFilters,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: KuberSpacing.sm),
          ),

          // Transaction list
          transactionsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (transactions) {
              final filtered = _applyFilters(transactions);

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    hasTransactions: transactions.isNotEmpty,
                    onAdd: () => context.push('/add-transaction'),
                  ),
                );
              }

              final groups = _groupByDate(filtered);

              return SliverPadding(
                padding: EdgeInsets.only(
                  bottom: navBarBottomPadding(context),
                  left: KuberSpacing.lg,
                  right: KuberSpacing.lg,
                ),
                sliver: SliverList.builder(
                  itemCount: groups.length * 2,
                  itemBuilder: (context, index) {
                    final groupIndex = index ~/ 2;
                    final group = groups[groupIndex];

                    if (index.isEven) {
                      return _DateGroupHeader(
                        label: group.label,
                        dayTotal: group.dayTotal,
                      );
                    } else {
                      return _DayCard(
                        transactions: group.transactions,
                        onDelete: _deleteWithUndo,
                        onTap: (t) => _showTransactionDetail(t),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- Private widgets ---

class _AdvancedFilterButton extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onTap;

  const _AdvancedFilterButton({
    required this.hasFilters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md,
          vertical: KuberSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: hasFilters
              ? KuberColors.primary.withValues(alpha: 0.15)
              : KuberColors.surfaceElement,
          borderRadius: BorderRadius.circular(10),
          border: hasFilters
              ? Border.all(color: KuberColors.primary, width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 14,
              color: hasFilters ? KuberColors.primary : KuberColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Advanced',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: hasFilters ? FontWeight.w600 : FontWeight.w400,
                color: hasFilters ? KuberColors.primary : KuberColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateGroupHeader extends StatelessWidget {
  final String label;
  final double dayTotal;

  const _DateGroupHeader({required this.label, required this.dayTotal});

  @override
  Widget build(BuildContext context) {
    final isPositive = dayTotal >= 0;
    final totalText = isPositive
        ? '+₹${dayTotal.toStringAsFixed(2)}'
        : '-₹${dayTotal.abs().toStringAsFixed(2)}';
    final totalColor =
        isPositive ? KuberColors.income : KuberColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(
        top: KuberSpacing.lg,
        bottom: KuberSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: KuberColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Container(
              height: 0.5,
              color: KuberColors.surfaceDivider,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Text(
            totalText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: totalColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final List<Transaction> transactions;
  final void Function(Transaction) onDelete;
  final void Function(Transaction) onTap;

  const _DayCard({
    required this.transactions,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KuberColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          for (int i = 0; i < transactions.length; i++) ...[
            if (i > 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
                child: Container(
                  height: 0.5,
                  color: KuberColors.surfaceDivider,
                ),
              ),
            _TransactionRow(
              transaction: transactions[i],
              onDelete: () => onDelete(transactions[i]),
              onTap: () => onTap(transactions[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _TransactionRow({
    required this.transaction,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final accountsAsync = ref.watch(accountListProvider);

    final category = categoriesAsync.whenOrNull(
      data: (cats) {
        try {
          return cats.firstWhere(
            (c) => c.id.toString() == transaction.categoryId,
          );
        } catch (_) {
          return null;
        }
      },
    );

    final account = accountsAsync.whenOrNull(
      data: (accs) {
        try {
          return accs.firstWhere(
            (a) => a.id.toString() == transaction.accountId,
          );
        } catch (_) {
          return null;
        }
      },
    );

    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? KuberColors.income : KuberColors.expense;
    final amountPrefix = isIncome ? '+' : '-';
    final iconData = category != null
        ? IconMapper.fromString(category.icon)
        : Icons.category;
    final iconColor =
        category != null ? Color(category.colorValue) : KuberColors.primary;

    final categoryName = category?.name ?? 'Unknown';
    final accountName = account?.name ?? 'Unknown';

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: KuberSpacing.xl),
        decoration: BoxDecoration(
          color: KuberColors.expense.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: KuberColors.expense,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg,
            vertical: KuberSpacing.md,
          ),
          child: Row(
            children: [
              CategoryIcon.circle(
                icon: iconData,
                rawColor: iconColor,
                size: 42,
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KuberColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$categoryName · $accountName',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: KuberColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix₹${transaction.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.time(transaction.createdAt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: KuberColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasTransactions;
  final VoidCallback onAdd;

  const _EmptyState({required this.hasTransactions, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: KuberColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: KuberColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          Text(
            'No transactions found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: KuberColors.textPrimary,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            hasTransactions
                ? 'Try adjusting your search or filters'
                : 'Start tracking your expenses',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: KuberColors.textSecondary,
            ),
          ),
          if (!hasTransactions) ...[
            const SizedBox(height: KuberSpacing.xl),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Transaction'),
              style: FilledButton.styleFrom(
                backgroundColor: KuberColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.xl,
                  vertical: KuberSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateGroup {
  final String label;
  final DateTime date;
  final double dayTotal;
  final List<Transaction> transactions;

  _DateGroup({
    required this.label,
    required this.date,
    required this.dayTotal,
    required this.transactions,
  });
}

// ---------------------------------------------------------------------------
// Advanced Filter Bottom Sheet
// ---------------------------------------------------------------------------

class _AdvancedFilterSheet extends ConsumerStatefulWidget {
  final DateTimeRange? dateRange;
  final String? typeFilter;
  final Set<int> selectedAccountIds;
  final Set<int> selectedCategoryIds;
  final String searchQuery;
  final void Function(
    DateTimeRange? dateRange,
    String? typeFilter,
    Set<int> accountIds,
    Set<int> categoryIds,
    String searchQuery,
  ) onApply;

  const _AdvancedFilterSheet({
    required this.dateRange,
    required this.typeFilter,
    required this.selectedAccountIds,
    required this.selectedCategoryIds,
    required this.searchQuery,
    required this.onApply,
  });

  @override
  ConsumerState<_AdvancedFilterSheet> createState() =>
      _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends ConsumerState<_AdvancedFilterSheet> {
  late DateTimeRange? _dateRange;
  late String? _typeFilter;
  late Set<int> _accountIds;
  late Set<int> _categoryIds;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _dateRange = widget.dateRange;
    _typeFilter = widget.typeFilter;
    _accountIds = Set.from(widget.selectedAccountIds);
    _categoryIds = Set.from(widget.selectedCategoryIds);
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _dateRange = null;
      _typeFilter = null;
      _accountIds = {};
      _categoryIds = {};
      _searchController.clear();
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountListProvider).valueOrNull ?? [];
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: KuberColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),

            // Title + Reset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Filters',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    'Reset',
                    style: GoogleFonts.plusJakartaSans(
                      color: KuberColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.lg),

            // Date Range
            Text('Date Range', style: textTheme.labelLarge),
            const SizedBox(height: KuberSpacing.sm),
            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                  vertical: KuberSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: KuberColors.surfaceElement,
                  borderRadius: BorderRadius.circular(12),
                  border: _dateRange != null
                      ? Border.all(color: KuberColors.primary, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range,
                        size: 18, color: KuberColors.textSecondary),
                    const SizedBox(width: KuberSpacing.sm),
                    Text(
                      _dateRange != null
                          ? '${DateFormat('MMM d, y').format(_dateRange!.start)} - ${DateFormat('MMM d, y').format(_dateRange!.end)}'
                          : 'Select date range',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: _dateRange != null
                            ? KuberColors.textPrimary
                            : KuberColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    if (_dateRange != null)
                      GestureDetector(
                        onTap: () => setState(() => _dateRange = null),
                        child: const Icon(Icons.close,
                            size: 16, color: KuberColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),

            // Type
            Text('Type', style: textTheme.labelLarge),
            const SizedBox(height: KuberSpacing.sm),
            Row(
              children: [
                _SheetChip(
                  label: 'All',
                  isSelected: _typeFilter == null,
                  onTap: () => setState(() => _typeFilter = null),
                ),
                const SizedBox(width: KuberSpacing.sm),
                _SheetChip(
                  label: 'Income',
                  isSelected: _typeFilter == 'income',
                  onTap: () => setState(() => _typeFilter = 'income'),
                ),
                const SizedBox(width: KuberSpacing.sm),
                _SheetChip(
                  label: 'Expense',
                  isSelected: _typeFilter == 'expense',
                  onTap: () => setState(() => _typeFilter = 'expense'),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.lg),

            // Accounts
            if (accounts.isNotEmpty) ...[
              Text('Accounts', style: textTheme.labelLarge),
              const SizedBox(height: KuberSpacing.sm),
              Wrap(
                spacing: KuberSpacing.sm,
                runSpacing: KuberSpacing.sm,
                children: accounts.map((a) {
                  final selected = _accountIds.contains(a.id);
                  return _SheetChip(
                    label: a.name,
                    isSelected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _accountIds.remove(a.id);
                        } else {
                          _accountIds.add(a.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: KuberSpacing.lg),
            ],

            // Categories
            if (categories.isNotEmpty) ...[
              Text('Categories', style: textTheme.labelLarge),
              const SizedBox(height: KuberSpacing.sm),
              Wrap(
                spacing: KuberSpacing.sm,
                runSpacing: KuberSpacing.sm,
                children: categories.map((c) {
                  final selected = _categoryIds.contains(c.id);
                  return _SheetChip(
                    label: c.name,
                    isSelected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _categoryIds.remove(c.id);
                        } else {
                          _categoryIds.add(c.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: KuberSpacing.lg),
            ],

            // Search
            Text('Search', style: textTheme.labelLarge),
            const SizedBox(height: KuberSpacing.sm),
            TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(
                color: KuberColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: KuberColors.textMuted,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: KuberColors.surfaceElement,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                  vertical: KuberSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Apply button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(
                    _dateRange,
                    _typeFilter,
                    _accountIds,
                    _categoryIds,
                    _searchController.text,
                  );
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: KuberColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _KuberFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _KuberFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? KuberColors.primary.withValues(alpha: 0.18)
              : KuberColors.surfaceElement,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? KuberColors.primary : KuberColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction Detail Bottom Sheet
// ---------------------------------------------------------------------------

class _TransactionDetailSheet extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionDetailSheet({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final accountsAsync = ref.watch(accountListProvider);

    final category = categoriesAsync.whenOrNull(
      data: (cats) {
        try {
          return cats.firstWhere(
            (c) => c.id.toString() == transaction.categoryId,
          );
        } catch (_) {
          return null;
        }
      },
    );

    final account = accountsAsync.whenOrNull(
      data: (accs) {
        try {
          return accs.firstWhere(
            (a) => a.id.toString() == transaction.accountId,
          );
        } catch (_) {
          return null;
        }
      },
    );

    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? KuberColors.income : KuberColors.expense;
    final amountPrefix = isIncome ? '+₹' : '−₹';
    final iconData = category != null
        ? IconMapper.fromString(category.icon)
        : Icons.category;
    final iconColor =
        category != null ? Color(category.colorValue) : KuberColors.primary;
    final categoryName = category?.name ?? 'Unknown';
    final accountName = account?.name ?? 'Unknown';

    final dateLabel =
        '${DateFormatter.groupHeader(transaction.createdAt)}, ${DateFormat('d MMM').format(transaction.createdAt)} • ${DateFormatter.time(transaction.createdAt)}';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KuberColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Category icon
            CategoryIcon.circle(
              icon: iconData,
              rawColor: iconColor,
              size: 64,
            ),
            const SizedBox(height: KuberSpacing.lg),

            // Transaction name
            Text(
              transaction.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: KuberColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KuberSpacing.sm),

            // Amount
            Text(
              '$amountPrefix${transaction.amount.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: amountColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KuberSpacing.xs),

            // Date & time
            Text(
              dateLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: KuberColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Detail rows
            // Category
            _DetailRow(
              icon: Icons.category_rounded,
              label: 'Category',
              trailing: Text(
                categoryName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KuberColors.primary,
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),

            // Account
            _DetailRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Account',
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    accountName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KuberColors.textPrimary,
                    ),
                  ),
                  if (account?.last4Digits != null &&
                      account!.last4Digits!.isNotEmpty)
                    Text(
                      'ENDING IN ${account.last4Digits}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: KuberColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),

            // Notes
            if (transaction.notes != null &&
                transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: KuberSpacing.sm),
              _DetailRow(
                icon: Icons.notes_rounded,
                label: 'Notes',
                trailing: const SizedBox.shrink(),
                subtitle: Text(
                  transaction.notes!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: KuberColors.textSecondary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: KuberSpacing.xl),

            // Edit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  'Edit Transaction',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: KuberColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),

            // Delete button
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(
                'Delete Transaction',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: KuberColors.expense,
              ),
            ),
            SizedBox(height: navBarBottomPadding(context)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final Widget? subtitle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: KuberSpacing.md,
      ),
      decoration: BoxDecoration(
        color: KuberColors.surfaceElement,
        borderRadius: BorderRadius.circular(16),
      ),
      child: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: KuberColors.textSecondary),
                    const SizedBox(width: KuberSpacing.sm),
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: KuberColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.sm),
                subtitle!,
              ],
            )
          : Row(
              children: [
                Icon(icon, size: 18, color: KuberColors.textSecondary),
                const SizedBox(width: KuberSpacing.sm),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: KuberColors.textSecondary,
                  ),
                ),
                const Spacer(),
                trailing,
              ],
            ),
    );
  }
}

class _SheetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SheetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md,
          vertical: KuberSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? KuberColors.primary.withValues(alpha: 0.15)
              : KuberColors.surfaceElement,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: KuberColors.primary, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? KuberColors.primary : KuberColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
