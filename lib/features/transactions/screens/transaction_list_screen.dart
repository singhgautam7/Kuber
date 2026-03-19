import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    var filtered = transactions;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) => t.name.toLowerCase().contains(query)).toList();
    }

    // Type filter
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

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: const KuberAppBar(),
      body: Column(
        children: [
          // Search bar
          Padding(
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

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.lg,
              vertical: KuberSpacing.xs,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                const SizedBox(width: KuberSpacing.sm),
                _FilterChip(
                  label: 'Expenses',
                  icon: Icons.arrow_downward,
                  isSelected: _selectedFilter == 'expense',
                  onTap: () => setState(() => _selectedFilter = 'expense'),
                ),
                const SizedBox(width: KuberSpacing.sm),
                _FilterChip(
                  label: 'Income',
                  icon: Icons.arrow_upward,
                  isSelected: _selectedFilter == 'income',
                  onTap: () => setState(() => _selectedFilter = 'income'),
                ),
                const SizedBox(width: KuberSpacing.sm),
                _FilterChip(
                  label: 'This Month',
                  isSelected: _selectedFilter == 'this_month',
                  onTap: () => setState(() => _selectedFilter = 'this_month'),
                ),
              ],
            ),
          ),

          const SizedBox(height: KuberSpacing.sm),

          // Transaction list
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (transactions) {
                final filtered = _applyFilters(transactions);

                if (filtered.isEmpty) {
                  return _EmptyState(
                    hasTransactions: transactions.isNotEmpty,
                    onAdd: () => context.push('/add-transaction'),
                  );
                }

                final groups = _groupByDate(filtered);

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 80,
                    left: KuberSpacing.lg,
                    right: KuberSpacing.lg,
                  ),
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
                        onTap: (t) =>
                            context.push('/add-transaction', extra: t),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Private widgets ---

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md,
          vertical: KuberSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? KuberColors.primary
              : KuberColors.surfaceElement,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : KuberColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : KuberColors.textSecondary,
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
