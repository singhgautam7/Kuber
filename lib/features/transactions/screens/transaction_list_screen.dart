import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;
import '../data/transaction.dart';
import '../providers/transaction_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../../export/widgets/export_bottom_sheet.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../history/models/history_filter.dart';
import '../../history/utils/filter_utils.dart';
import '../../history/widgets/history_filter_widget.dart';
import '../../history/utils/history_utils.dart';
import '../widgets/transaction_row.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const _groupsPerPage = 10;
  int _displayedGroupCount = _groupsPerPage;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300) {
      _loadMoreGroups();
    }
  }

  void _loadMoreGroups() {
    // The actual check against groups.length happens in build —
    // here we just bump the count and let build() clamp it.
    setState(() => _displayedGroupCount += _groupsPerPage);
  }

  List<Transaction> _applyFilters(List<Transaction> transactions, HistoryFilter filter) {
    final txnTagsMap = ref.watch(transactionTagsMapProvider).valueOrNull ?? {};
    return applyHistoryFilters(transactions, filter, txnTagsMap: txnTagsMap);
  }

  void _showTransactionDetail(Transaction t) {
    showTransactionDetailSheet(context, ref, t);
  }

  void _deleteWithUndo(Transaction t) {
    deleteTransactionWithUndo(context, ref, t);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reset pagination when filters change
    ref.listen(historyFilterProvider, (_, __) {
      _displayedGroupCount = _groupsPerPage;
    });

    final cs = Theme.of(context).colorScheme;
    final transactionsAsync = ref.watch(transactionListProvider);
    final filter = ref.watch(historyFilterProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go('/');
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
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
                  onAction: () => showExportBottomSheet(
                    context: context,
                    exportType: ExportType.transactions,
                  ),
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

                  // Compute EXP / INC / NET from filtered list
                  double totalExp = 0;
                  double totalInc = 0;
                  for (final t in filtered) {
                    if (t.isTransfer || t.isBalanceAdjustment) continue;
                    if (t.type == 'income') {
                      totalInc += t.amount;
                    } else {
                      totalExp += t.amount;
                    }
                  }
                  final totalNet = totalInc - totalExp;
                  final fmt = ref.watch(formatterProvider);
                  final groups = groupTransactionsByDate(filtered);

                  // Build tag names map for indicator line
                  final allTags = ref.watch(tagListProvider).valueOrNull ?? [];
                  final tagNameById = {for (final t in allTags) t.id: t.name};
                  final txnTagsMapData = ref.watch(transactionTagsMapProvider).valueOrNull ?? {};
                  final tagNamesMap = <int, List<String>>{};
                  for (final entry in txnTagsMapData.entries) {
                    final names = entry.value
                        .map((tagId) => tagNameById[tagId])
                        .whereType<String>()
                        .toList();
                    if (names.isNotEmpty) tagNamesMap[entry.key] = names;
                  }

                  return [
                    // EXP / INC / NET summary
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.lg,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'EXP ',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '-${fmt.formatCurrency(totalExp)}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: cs.error,
                              ),
                            ),
                            const SizedBox(width: KuberSpacing.lg),
                            Text(
                              'INC ',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '+${fmt.formatCurrency(totalInc)}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: cs.tertiary,
                              ),
                            ),
                            const SizedBox(width: KuberSpacing.lg),
                            Text(
                              'NET ',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              totalNet == 0
                                  ? fmt.formatCurrency(0)
                                  : '${totalNet > 0 ? '+' : '-'}${fmt.formatCurrency(totalNet.abs())}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: totalNet > 0
                                    ? cs.tertiary
                                    : totalNet < 0
                                        ? cs.error
                                        : cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SHOWING N TRANSACTIONS row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.lg,
                          vertical: KuberSpacing.sm,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                    else ...[
                      () {
                        final displayedGroups = groups.take(_displayedGroupCount).toList();
                        final hasMore = displayedGroups.length < groups.length;

                        return SliverPadding(
                          padding: EdgeInsets.only(
                            bottom: hasMore ? 0 : navBarBottomPadding(context),
                            left: KuberSpacing.lg,
                            right: KuberSpacing.lg,
                          ),
                          sliver: SliverList.builder(
                            itemCount: displayedGroups.length * 2,
                            itemBuilder: (context, index) {
                              final groupIndex = index ~/ 2;
                              final group = displayedGroups[groupIndex];

                              if (index.isEven) {
                                return DateGroupHeader(
                                  label: group.label,
                                  dayTotal: group.dayTotal,
                                );
                              } else {
                                return TransactionDayCard(
                                  transactions: group.transactions,
                                  onDelete: _deleteWithUndo,
                                  onTap: (t) => _showTransactionDetail(t),
                                  onEdit: (t) =>
                                      context.push('/add-transaction', extra: t),
                                  formatter: fmt,
                                  categoryMap: ref.watch(categoryMapProvider).valueOrNull ?? {},
                                  accountMap: ref.watch(accountMapProvider).valueOrNull ?? {},
                                  transactionList: transactions, // For transfer lookup
                                  tagNamesMap: tagNamesMap,
                                );
                              }
                            },
                          ),
                        );
                      }(),
                      if (groups.length > _displayedGroupCount)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: KuberSpacing.lg,
                              bottom: navBarBottomPadding(context),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
