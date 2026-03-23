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
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
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
  Set<String> _selectedTypes = {};
  Set<int> _selectedAccountIds = {};
  Set<int> _selectedCategoryIds = {};

  bool get _hasAdvancedFilters =>
      _dateRange != null ||
      _selectedTypes.isNotEmpty ||
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
      _selectedTypes = {};
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
      case 'transfer':
        filtered = filtered.where((t) => t.type == 'transfer').toList();
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

    if (_selectedTypes.isNotEmpty) {
      filtered = filtered.where((t) => _selectedTypes.contains(t.type)).toList();
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
        if (t.type == 'transfer') continue;
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
    showTransactionDetailSheet(context, ref, t);
  }

  void _deleteWithUndo(Transaction t) {
    deleteTransactionWithUndo(context, ref, t);
  }

  void _openAdvancedFilters() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => _AdvancedFilterSheet(
        dateRange: _dateRange,
        selectedTypes: _selectedTypes,
        selectedAccountIds: _selectedAccountIds,
        selectedCategoryIds: _selectedCategoryIds,
        searchQuery: _searchQuery,
        onApply: (dateRange, types, accountIds, categoryIds, searchQuery) {
          setState(() {
            _dateRange = dateRange;
            _selectedTypes = types;
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
    final cs = Theme.of(context).colorScheme;
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
                style: GoogleFonts.inter(
                  color: cs.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: GoogleFonts.inter(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: Icon(
                    Icons.mic_outlined,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                    vertical: KuberSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide:
                        BorderSide(color: cs.primary, width: 1.5),
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
                        backgroundColor: cs.error.withValues(alpha: 0.15),
                        labelStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.error,
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
                        onEdit: (t) => context.push('/add-transaction', extra: t),
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
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md,
          vertical: KuberSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: hasFilters
              ? cs.primary.withValues(alpha: 0.15)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: hasFilters
              ? Border.all(color: cs.primary, width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 14,
              color: hasFilters ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Advanced',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: hasFilters ? FontWeight.w600 : FontWeight.w400,
                color: hasFilters ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateGroupHeader extends ConsumerWidget {
  final String label;
  final double dayTotal;

  const _DateGroupHeader({required this.label, required this.dayTotal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final isPositive = dayTotal >= 0;
    final totalText = isPositive
        ? '+$symbol${dayTotal.toStringAsFixed(2)}'
        : '-$symbol${dayTotal.abs().toStringAsFixed(2)}';
    final totalColor =
        isPositive ? cs.tertiary : cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(
        top: KuberSpacing.lg,
        bottom: KuberSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Container(
              height: 0.5,
              color: cs.outline,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Text(
            totalText,
            style: GoogleFonts.inter(
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
  final void Function(Transaction) onEdit;

  const _DayCard({
    required this.transactions,
    required this.onDelete,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < transactions.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _TransactionRow(
            transaction: transactions[i],
            onDelete: () => onDelete(transactions[i]),
            onTap: () => onTap(transactions[i]),
            onEdit: () => onEdit(transactions[i]),
          ),
        ],
      ],
    );
  }
}

class _TransactionRow extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _TransactionRow({
    required this.transaction,
    required this.onDelete,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoryListProvider);
    final accountsAsync = ref.watch(accountListProvider);
    final isTransfer = transaction.type == 'transfer';

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

    // Transfer-specific: look up FROM and TO accounts
    String? fromName;
    String? toName;
    if (isTransfer) {
      final accs = accountsAsync.valueOrNull ?? [];
      fromName = accs
          .where((a) => a.id.toString() == transaction.fromAccountId)
          .firstOrNull
          ?.name;
      toName = accs
          .where((a) => a.id.toString() == transaction.toAccountId)
          .firstOrNull
          ?.name;
    }

    final isIncome = transaction.type == 'income';
    final amountColor = isTransfer
        ? cs.onSurface
        : (isIncome ? cs.tertiary : cs.onSurface);
    final amountPrefix = isTransfer ? '' : (isIncome ? '+' : '-');
    final iconData = isTransfer
        ? Icons.swap_horiz_rounded
        : (category != null
            ? IconMapper.fromString(category.icon)
            : Icons.category);
    final iconColor = isTransfer
        ? const Color(0xFF78909C)
        : (category != null ? Color(category.colorValue) : cs.primary);

    final displayName = isTransfer
        ? '${fromName ?? "Unknown"} → ${toName ?? "Unknown"}'
        : transaction.name;
    final subtitle = isTransfer
        ? 'Transfer · ${toName ?? "Unknown"}'
        : '${category?.name ?? "Unknown"} · ${account?.name ?? "Unknown"}';

    final swipeMode = ref.watch(settingsProvider).valueOrNull?.swipeMode ?? SwipeMode.changeTabs;

    final content = Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg,
            vertical: KuberSpacing.md,
          ),
          child: Row(
            children: [
              CategoryIcon.square(
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
                      displayName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: cs.onSurfaceVariant,
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
                    '$amountPrefix${ref.watch(currencyProvider).symbol}${transaction.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.time(transaction.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (swipeMode == SwipeMode.performActions) {
      return Dismissible(
        key: ValueKey(transaction.id),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: KuberSpacing.xl),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Icon(Icons.edit_outlined, color: cs.primary),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: KuberSpacing.xl),
          decoration: BoxDecoration(
            color: cs.error.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Icon(Icons.delete_outline, color: cs.error),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            onDelete();
            return true;
          } else {
            onEdit();
            return false;
          }
        },
        child: content,
      );
    }

    return content;
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasTransactions;
  final VoidCallback onAdd;

  const _EmptyState({required this.hasTransactions, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: cs.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          Text(
            'No transactions found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            hasTransactions
                ? 'Try adjusting your search or filters'
                : 'Start tracking your expenses',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: cs.onSurfaceVariant,
            ),
          ),
          if (!hasTransactions) ...[
            const SizedBox(height: KuberSpacing.xl),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Transaction'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.xl,
                  vertical: KuberSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
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
  final Set<String> selectedTypes;
  final Set<int> selectedAccountIds;
  final Set<int> selectedCategoryIds;
  final String searchQuery;
  final void Function(
    DateTimeRange? dateRange,
    Set<String> types,
    Set<int> accountIds,
    Set<int> categoryIds,
    String searchQuery,
  ) onApply;

  const _AdvancedFilterSheet({
    required this.dateRange,
    required this.selectedTypes,
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
  late Set<String> _selectedTypes;
  late Set<int> _accountIds;
  late Set<int> _categoryIds;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _dateRange = widget.dateRange;
    _selectedTypes = Set.from(widget.selectedTypes);
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
      _selectedTypes = {};
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
    final cs = Theme.of(context).colorScheme;
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
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
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
                    style: GoogleFonts.inter(
                      color: cs.primary,
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
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: _dateRange != null
                      ? Border.all(color: cs.primary, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range,
                        size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: KuberSpacing.sm),
                    Text(
                      _dateRange != null
                          ? '${DateFormat('MMM d, y').format(_dateRange!.start)} - ${DateFormat('MMM d, y').format(_dateRange!.end)}'
                          : 'Select date range',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _dateRange != null
                            ? cs.onSurface
                            : cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (_dateRange != null)
                      GestureDetector(
                        onTap: () => setState(() => _dateRange = null),
                        child: Icon(Icons.close,
                            size: 16, color: cs.onSurfaceVariant),
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
                  label: 'Income',
                  isSelected: _selectedTypes.contains('income'),
                  onTap: () {
                    setState(() {
                      if (_selectedTypes.contains('income')) {
                        _selectedTypes.remove('income');
                      } else {
                        _selectedTypes.add('income');
                      }
                    });
                  },
                ),
                const SizedBox(width: KuberSpacing.sm),
                _SheetChip(
                  label: 'Expense',
                  isSelected: _selectedTypes.contains('expense'),
                  onTap: () {
                    setState(() {
                      if (_selectedTypes.contains('expense')) {
                        _selectedTypes.remove('expense');
                      } else {
                        _selectedTypes.add('expense');
                      }
                    });
                  },
                ),
                const SizedBox(width: KuberSpacing.sm),
                _SheetChip(
                  label: 'Transfer',
                  isSelected: _selectedTypes.contains('transfer'),
                  onTap: () {
                    setState(() {
                      if (_selectedTypes.contains('transfer')) {
                        _selectedTypes.remove('transfer');
                      } else {
                        _selectedTypes.add('transfer');
                      }
                    });
                  },
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
              style: GoogleFonts.inter(
                color: cs.onSurface,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                hintStyle: GoogleFonts.inter(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                  vertical: KuberSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
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
                    _selectedTypes,
                    _accountIds,
                    _categoryIds,
                    _searchController.text,
                  );
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.inter(
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
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.18)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
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
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md,
          vertical: KuberSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.15)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: cs.primary, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
