import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show
        formatterProvider,
        privacyModeProvider,
        navBarStyleProvider,
        NavBarStyle;
import '../data/transaction.dart';
import '../providers/transaction_provider.dart';
import '../../export/widgets/export_bottom_sheet.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../history/providers/history_view_provider.dart';
import '../../history/widgets/history_filter_widget.dart';
import '../../history/providers/selection_provider.dart';
import '../../tutorial/models/tutorial_step_keys.dart';
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
    final viewAsync = ref.watch(historyViewProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              key: TutorialStepKeys.historyList,
              controller: _scrollController,
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: KuberSpacing.xl),
                ),

                // Page header
                SliverToBoxAdapter(
                  child: KuberPageHeader(
                    title: context.l10n.historyTitle,
                    description: context.l10n.historyDescription,
                    actionIcon: Icons.file_download_outlined,
                    actionTooltip: context.l10n.exportLabel,
                    onAction: () => showExportBottomSheet(
                      context: context,
                      exportType: ExportType.transactions,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: HistoryFilterWidget(
                    key: TutorialStepKeys.historyQuickFilters,
                    onAdvancedTap: () => context.push('/history/filter'),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: KuberSpacing.sm),
                ),

                // Transaction list
                ...viewAsync.when(
                  // Skeleton (summary bar + a few rows) so the first open of
                  // the History tab doesn't stutter behind a blank spinner.
                  loading: () => const [
                    SliverToBoxAdapter(child: _HistorySkeleton()),
                  ],
                  error: (e, _) => [
                    SliverFillRemaining(
                      child: Center(child: Text('${context.l10n.errorLabel}: $e')),
                    ),
                  ],
                  data: (view) {
                    // All heavy derivation (filter → group → tag map → totals)
                    // lives in `historyViewProvider`, memoized so this rebuilds
                    // cheaply and the tab no longer stutters on entry.
                    final fmt = ref.watch(formatterProvider);
                    final isPrivate = ref.watch(privacyModeProvider);
                    final totalExp = view.totalExpense;
                    final totalInc = view.totalIncome;
                    final totalNet = view.totalNet;
                    final groups = view.groups;
                    final transferPairs = view.transferPairAccountId;
                    final tagNamesMap = view.tagNamesMap;
                    final filteredCount = view.filteredCount;
                    final sourceEmpty = view.sourceEmpty;

                    return [
                      // EXP / INC / NET summary
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KuberSpacing.lg,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${context.l10n.expLabel} ',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: cs.onSurfaceVariant,
                                      ),
                                ),
                                Text(
                                  maskAmount(
                                    '-${fmt.formatCurrency(totalExp.round())}',
                                    isPrivate,
                                  ),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: cs.error,
                                      ),
                                ),
                                const SizedBox(width: KuberSpacing.lg),
                                Text(
                                  '${context.l10n.incLabel} ',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: cs.onSurfaceVariant,
                                      ),
                                ),
                                Text(
                                  maskAmount(
                                    '+${fmt.formatCurrency(totalInc.round())}',
                                    isPrivate,
                                  ),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: cs.tertiary,
                                      ),
                                ),
                                const SizedBox(width: KuberSpacing.lg),
                                Text(
                                  '${context.l10n.netLabel} ',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: cs.onSurfaceVariant,
                                      ),
                                ),
                                Text(
                                  maskAmount(
                                    totalNet == 0
                                        ? fmt.formatCurrency(0)
                                        : '${totalNet > 0 ? '+' : '-'}${fmt.formatCurrency(totalNet.abs().round())}',
                                    isPrivate,
                                  ),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
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
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: cs.onSurfaceVariant,
                                  ),
                              children: [
                                TextSpan(text: '${context.l10n.showingLabel} '),
                                TextSpan(
                                  text: '$filteredCount ',
                                  style: TextStyle(color: cs.primary),
                                ),
                                TextSpan(text: context.l10n.transactionsLabel),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if (filteredCount == 0)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: KuberEmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: sourceEmpty
                                ? context.l10n.noTransactionsYet
                                : context.l10n.noTransactionsFound,
                            description: sourceEmpty
                                ? context.l10n.startTrackingExpenses
                                : context.l10n.adjustSearchFilters,
                            actionLabel: sourceEmpty
                                ? context.l10n.addTransaction
                                : null,
                            onAction: sourceEmpty
                                ? () => context.push('/add-transaction')
                                : null,
                          ),
                        )
                      else ...[
                        () {
                          final displayedGroups = groups
                              .take(_displayedGroupCount)
                              .toList();
                          final hasMore =
                              displayedGroups.length < groups.length;

                          return SliverPadding(
                            padding: EdgeInsets.only(
                              bottom: hasMore
                                  ? 0
                                  : navBarBottomPadding(context),
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
                                    key: groupIndex == 0
                                        ? TutorialStepKeys.historyFirstItem
                                        : null,
                                    transactions: group.transactions,
                                    onDelete: _deleteWithUndo,
                                    onTap: (t) => _showTransactionDetail(t),
                                    onEdit: (t) => context.push(
                                      '/add-transaction',
                                      extra: t,
                                    ),
                                    formatter: fmt,
                                    categoryMap:
                                        ref
                                            .watch(categoryMapProvider)
                                            .valueOrNull ??
                                        {},
                                    accountMap:
                                        ref
                                            .watch(accountMapProvider)
                                            .valueOrNull ??
                                        {},
                                    transferPairAccountId: transferPairs,
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                offset: ref.watch(isSelectionModeProvider)
                    ? Offset.zero
                    : const Offset(0, 1.2),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: const _SelectionActionBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionActionBar extends ConsumerWidget {
  const _SelectionActionBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selectedIds = ref.watch(transactionSelectionProvider);
    final allTransactions =
        ref.watch(transactionListProvider).valueOrNull ?? [];

    final selectedTransactions = allTransactions
        .where((t) => selectedIds.contains(t.id))
        .toList();

    double totalExp = 0;
    double totalInc = 0;
    for (final t in selectedTransactions) {
      if (!t.isBalanceAdjustment && !t.isTransfer) {
        if (t.type == 'income') {
          totalInc += t.amount;
        } else {
          totalExp += t.amount;
        }
      }
    }
    final totalNet = totalInc - totalExp;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);

    final isModern = ref.watch(navBarStyleProvider) == NavBarStyle.modern;
    // Root-view inset: the shell body has a bottomNavigationBar, so Flutter
    // zeroes viewPadding.bottom here — viewPaddingOf would return 0 and the bar
    // would slide under the system nav bar (the app nav bar is hidden during
    // selection, so nothing else clears it).
    final bottomInset = systemNavBarInset(context);
    // On modern nav bar, add generous bottom clearance so curved-screen edges
    // don't clip the action buttons (the floating nav bar normally fills this space).
    final bottomPad = isModern ? bottomInset + KuberSpacing.xl : bottomInset;

    return Material(
      elevation: 8,
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPad),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.sm,
            vertical: KuberSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.outline)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>
                    ref.read(transactionSelectionProvider.notifier).clear(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.selectedCount('${selectedIds.length}'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${context.l10n.expLabel} ${maskAmount('-${fmt.formatCurrency(totalExp)}', isPrivate)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        Text(
                          '${context.l10n.incLabel} ${maskAmount('+${fmt.formatCurrency(totalInc)}', isPrivate)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        Text(
                          '${context.l10n.netLabel} ${maskAmount('${totalNet > 0
                              ? "+"
                              : totalNet < 0
                              ? "-"
                              : ""}${fmt.formatCurrency(totalNet.abs())}', isPrivate)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: totalNet > 0
                                ? cs.tertiary
                                : totalNet < 0
                                ? cs.error
                                : cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(context, ref, selectedIds),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.error.withValues(alpha: 0.5)),
                  ),
                  child: Icon(Icons.delete_outline, size: 16, color: cs.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Set<int> selectedIds,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.l10n.deleteTransactionsConfirm('${selectedIds.length}'),
        ),
        content: Text(context.l10n.actionCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancelLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final notifier = ref.read(transactionListProvider.notifier);
              await notifier.deleteMany(selectedIds);
              ref.read(transactionSelectionProvider.notifier).clear();
              if (context.mounted) {
                showKuberSnackBar(
                  context,
                  context.l10n.transactionsDeleted('${selectedIds.length}'),
                  isError: true,
                );
              }
            },
            child: Text(context.l10n.deleteLabel),
          ),
        ],
      ),
    );
  }
}

/// Skeleton shown while [historyViewProvider] first loads: a summary bar
/// followed by a handful of transaction-row placeholders.
class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary bar (count / EXP / INC / NET).
          Row(
            children: const [
              SkeletonBlock(width: 90, height: 20, borderRadius: 6),
              SizedBox(width: 10),
              SkeletonBlock(width: 70, height: 20, borderRadius: 6),
              SizedBox(width: 10),
              SkeletonBlock(width: 70, height: 20, borderRadius: 6),
            ],
          ),
          const SizedBox(height: KuberSpacing.lg),
          for (var i = 0; i < 7; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: KuberSpacing.md),
              child: Row(
                children: const [
                  SkeletonBlock(width: 40, height: 40, borderRadius: 10),
                  SizedBox(width: KuberSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBlock(
                            width: 140, height: 13, borderRadius: 5),
                        SizedBox(height: 7),
                        SkeletonBlock(
                            width: 90, height: 11, borderRadius: 5),
                      ],
                    ),
                  ),
                  SizedBox(width: KuberSpacing.md),
                  SkeletonBlock(width: 64, height: 14, borderRadius: 5),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
