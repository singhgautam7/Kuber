import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show settingsProvider, formatterProvider, SwipeMode;
import '../data/transaction.dart';
import '../providers/transaction_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../../../shared/widgets/wip_bottom_sheet.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../history/models/history_filter.dart';
import '../../history/widgets/history_filter_widget.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // No local search state, moved to HistoryFilterProvider

  List<Transaction> _applyFilters(List<Transaction> transactions, HistoryFilter filter) {
    var filtered = transactions;

    // Search filter
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      filtered = filtered.where((t) => t.name.toLowerCase().contains(query)).toList();
    }

    // Type filter
    if (filter.types.isNotEmpty) {
      filtered = filtered.where((t) => filter.types.contains(t.type)).toList();
    }

    // Recurring filter
    if (filter.isRecurring != null) {
      filtered = filtered.where((t) => t.isRecurring == filter.isRecurring).toList();
    }

    // Date Range
    if (filter.from != null && filter.to != null) {
      filtered = filtered.where((t) =>
          !t.createdAt.isBefore(filter.from!) &&
          t.createdAt.isBefore(filter.to!.add(const Duration(days: 1)))).toList();
    }

    // Accounts
    if (filter.accountIds.isNotEmpty) {
      filtered = filtered.where((t) =>
          filter.accountIds.contains(t.accountId)).toList();
    }

    // Categories
    if (filter.categoryIds.isNotEmpty) {
      filtered = filtered.where((t) =>
          filter.categoryIds.contains(t.categoryId)).toList();
    }

    // Tags
    if (filter.tagIds.isNotEmpty) {
      final txnTagsMap = ref.watch(transactionTagsMapProvider).valueOrNull ?? {};
      filtered = filtered.where((t) {
        final txnTags = txnTagsMap[t.id] ?? {};
        // AND logic: transaction must have ALL selected tags
        return filter.tagIds.every((tagId) => txnTags.contains(tagId));
      }).toList();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final transactionsAsync = ref.watch(transactionListProvider);
    final filter = ref.watch(historyFilterProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          const SliverToBoxAdapter(
            child: KuberAppBar(title: 'History'),
          ),

          // Page header
          SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Transaction\nHistory',
              description: 'Your past expenses, incomes and transfers',
              actionIcon: Icons.file_download_outlined,
              actionTooltip: 'Export',
              onAction: () {
                final cs = Theme.of(context).colorScheme;
                showWIPBottomSheet(
                  context: context,
                  icon: Icons.rocket_launch_rounded,
                  title: 'Export Report',
                  content: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.6,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: "We are currently building this feature to help you export your financial reports in "),
                        TextSpan(
                          text: "PDF",
                          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "CSV",
                          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: " formats. Stay tuned!"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),


          SliverToBoxAdapter(
            child: HistoryFilterWidget(
              onAdvancedTap: () => context.push('/history/filter'),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: KuberSpacing.sm),
          ),

          // Transaction list
          ...transactionsAsync.when(
            loading: () => [
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (e, _) => [
              SliverFillRemaining(
                child: Center(child: Text('Error: $e')),
              ),
            ],
            data: (transactions) {
              final filtered = _applyFilters(transactions, filter);

              return [
                // SHOWING N TRANSACTIONS row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KuberSpacing.lg,
                      vertical: KuberSpacing.sm,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: cs.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: 'SHOWING '),
                          TextSpan(
                            text: '${filtered.length} ',
                            style: TextStyle(color: cs.primary),
                          ),
                          const TextSpan(text: 'TRANSACTIONS'),
                        ],
                      ),
                    ),
                  ),
                ),

                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: KuberEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: transactions.isEmpty
                          ? 'No transactions yet'
                          : 'No transactions found',
                      description: transactions.isEmpty
                          ? 'Start tracking your expenses'
                          : 'Try adjusting your search or filters',
                      actionLabel:
                          transactions.isEmpty ? 'Add Transaction' : null,
                      onAction: transactions.isEmpty
                          ? () => context.push('/add-transaction')
                          : null,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: navBarBottomPadding(context),
                      left: KuberSpacing.lg,
                      right: KuberSpacing.lg,
                    ),
                    sliver: SliverList.builder(
                      itemCount: _groupByDate(filtered).length * 2,
                      itemBuilder: (context, index) {
                        final groups = _groupByDate(filtered);
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
                            onEdit: (t) =>
                                context.push('/add-transaction', extra: t),
                          );
                        }
                      },
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

// --- Private widgets ---

class _DateGroupHeader extends ConsumerWidget {
  final String label;
  final double dayTotal;

  const _DateGroupHeader({required this.label, required this.dayTotal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final isPositive = dayTotal >= 0;
    final totalText = isPositive
        ? '+${formatter.formatCurrency(dayTotal)}'
        : '−${formatter.formatCurrency(dayTotal.abs())}';
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
                    '$amountPrefix${ref.watch(formatterProvider).formatCurrency(transaction.amount)}',
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
