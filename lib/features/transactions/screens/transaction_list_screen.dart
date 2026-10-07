import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../core/models/overflow_config.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
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

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  static const _groupsPerPage = 10;
  int _displayedGroupCount = _groupsPerPage;
  final _scrollController = ScrollController();

  /// True from a filter change until the re-filtered view arrives. Set in a
  /// listener, so the progress bar paints on the frame before the (6000+
  /// row) filter pass runs.
  bool _filtering = false;

  /// Fades the rows in after a filter change (review round 3).
  late final AnimationController _listFade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

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
    _listFade.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reset pagination when filters change, and show the filtering bar.
    ref.listen(historyFilterProvider, (_, __) {
      _displayedGroupCount = _groupsPerPage;
      if (!_filtering) setState(() => _filtering = true);
    });
    ref.listen(historyViewProvider, (prev, next) {
      if (_filtering && !next.isLoading && (next.hasValue || next.hasError)) {
        setState(() => _filtering = false);
        _listFade.forward(from: 0);
      }
    });

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final viewAsync = ref.watch(historyViewProvider);
    final isSelecting = ref.watch(isSelectionModeProvider);

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
                // Header (feedback round 1): "Transactions", no description,
                // Export in the overflow.
                SliverToBoxAdapter(
                  child: KuberAppBar(
                    title: sentenceCase(context.l10n.transactionsLabel),
                    overflowConfig: KuberOverflowConfig(
                      items: [
                        KuberOverflowItem(
                          icon: Icons.file_download_outlined,
                          label: context.l10n.exportLabel,
                          onTap: () => showExportBottomSheet(
                            context: context,
                            exportType: ExportType.transactions,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: HistoryFilterWidget(
                    key: TutorialStepKeys.historyQuickFilters,
                    onAdvancedTap: () => context.push('/history/filter'),
                  ),
                ),

                // Thin progress bar while a filter is being applied; the
                // previous rows stay on screen underneath.
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: KuberSpace.sm,
                    child: AnimatedOpacity(
                      opacity: _filtering ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: KuberSpace.screenMargin,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            borderRadius: KuberShape.fullR,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Transaction list
                ...viewAsync.when(
                  // Re-filtering keeps the current rows (the bar above shows
                  // progress); only the very first load uses the skeleton.
                  skipLoadingOnReload: true,
                  // Skeleton (summary bar + a few rows) so the first open of
                  // the History tab doesn't stutter behind a blank spinner.
                  loading: () => const [
                    SliverToBoxAdapter(child: _HistorySkeleton()),
                  ],
                  error: (e, _) => [
                    SliverFillRemaining(
                      child: Center(
                        child: Text('${context.l10n.errorLabel}: $e'),
                      ),
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
                      // EXP / INC / NET summary + "Showing N" (board 3.5).
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            KuberSpace.screenMargin,
                            KuberSpace.sm,
                            KuberSpace.screenMargin,
                            KuberSpace.md,
                          ),
                          // One scale-down box for both lines, so "Showing N"
                          // always renders at the totals' size.
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: textTheme.labelMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${context.l10n.expLabel} ',
                                      ),
                                      TextSpan(
                                        text: maskAmount(
                                          '-${fmt.formatCurrency(totalExp.round())}',
                                          isPrivate,
                                        ),
                                        style: TextStyle(
                                          color: context.kuberMoney.expense,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '   ${context.l10n.incLabel} ',
                                      ),
                                      TextSpan(
                                        text: maskAmount(
                                          '+${fmt.formatCurrency(totalInc.round())}',
                                          isPrivate,
                                        ),
                                        style: TextStyle(
                                          color: context.kuberMoney.income,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '   ${context.l10n.netLabel} ',
                                      ),
                                      TextSpan(
                                        text: maskAmount(
                                          totalNet == 0
                                              ? fmt.formatCurrency(0)
                                              : '${totalNet > 0 ? '+' : '-'}${fmt.formatCurrency(totalNet.abs().round())}',
                                          isPrivate,
                                        ),
                                        style: TextStyle(
                                          color: totalNet > 0
                                              ? context.kuberMoney.income
                                              : totalNet < 0
                                              ? context.kuberMoney.expense
                                              : cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: KuberSpace.xs),
                                Text.rich(
                                  TextSpan(
                                    style: textTheme.labelMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '${context.l10n.showingLabel.toUpperCase()} ',
                                      ),
                                      TextSpan(
                                        text: '$filteredCount',
                                        style: TextStyle(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' ${context.l10n.transactionsLabel.toUpperCase()}',
                                      ),
                                    ],
                                  ),
                                ),
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

                          return SliverFadeTransition(
                            opacity: _listFade,
                            sliver: SliverPadding(
                              padding: EdgeInsets.only(
                                bottom: hasMore
                                    ? 0
                                    : navBarBottomPadding(context),
                                left: KuberSpace.screenMargin,
                                right: KuberSpace.screenMargin,
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
                            ),
                          );
                        }(),
                        if (groups.length > _displayedGroupCount)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: KuberSpace.lg,
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
            // Selection mode (board 3.5 / open decision 8): a one-line
            // contextual header at the top, the totals pill where the nav was.
            if (isSelecting)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _SelectionHeader(),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                offset: isSelecting ? Offset.zero : const Offset(0, 1.2),
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

    final bottomInset = systemNavBarInset(context);
    final bottom = bottomInset > 22 ? bottomInset : 22.0;
    final money = context.kuberMoney;
    final style = Theme.of(
      context,
    ).textTheme.labelMedium!.copyWith(color: cs.onInverseSurface);
    final strong = style.copyWith(fontWeight: FontWeight.w700);

    // Totals pill (board 3.5): inverseSurface, h48, EXP / INC / NET of the
    // selection in the inverse-safe money tones.
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Center(
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: cs.inverseSurface,
            borderRadius: KuberShape.fullR,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                style: style,
                children: [
                  TextSpan(text: '${context.l10n.expLabel} '),
                  TextSpan(
                    text: maskAmount(
                      '-${fmt.formatCurrency(totalExp)}',
                      isPrivate,
                    ),
                    style: strong.copyWith(color: money.inverseExpense),
                  ),
                  TextSpan(text: '    ${context.l10n.incLabel} '),
                  TextSpan(
                    text: maskAmount(
                      '+${fmt.formatCurrency(totalInc)}',
                      isPrivate,
                    ),
                    style: strong.copyWith(color: money.inverseIncome),
                  ),
                  TextSpan(text: '    ${context.l10n.netLabel} '),
                  TextSpan(
                    text: maskAmount(
                      '${totalNet > 0
                          ? "+"
                          : totalNet < 0
                          ? "-"
                          : ""}${fmt.formatCurrency(totalNet.abs())}',
                      isPrivate,
                    ),
                    style: strong.copyWith(
                      color: totalNet > 0
                          ? money.inverseIncome
                          : totalNet < 0
                          ? money.inverseExpense
                          : cs.onInverseSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Contextual header while selecting (components/contextual-header.md):
/// surfaceContainer, close, "{n} selected", Delete (danger tonal).
class _SelectionHeader extends ConsumerWidget {
  const _SelectionHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(transactionSelectionProvider);
    return KuberAppBar(
      background: Theme.of(context).colorScheme.surfaceContainer,
      showBack: true,
      closeIcon: true,
      onBack: () => ref.read(transactionSelectionProvider.notifier).clear(),
      title: context.l10n.selectedCount('${selectedIds.length}'),
      actions: [
        AppIconButton(
          icon: Icons.delete_outline_rounded,
          kind: AppIconButtonKind.danger,
          semanticLabel: context.l10n.deleteLabel,
          onPressed: () => _confirmDeleteSelection(context, ref, selectedIds),
        ),
      ],
    );
  }
}

void _confirmDeleteSelection(
  BuildContext context,
  WidgetRef ref,
  Set<int> selectedIds,
) {
  {
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
    Widget row() => const SizedBox(
      height: KuberSpace.listItem2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SkeletonBlock(width: 40, height: 40, borderRadius: 12),
            SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 140, height: 12, borderRadius: 999),
                  SizedBox(height: 8),
                  SkeletonBlock(width: 90, height: 10, borderRadius: 999),
                ],
              ),
            ),
            SizedBox(width: KuberSpace.md),
            SkeletonBlock(width: 56, height: 12, borderRadius: 999),
          ],
        ),
      ),
    );
    // Loading skeleton (board 3.5): summary pill, then grouped day blocks.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpace.screenMargin,
        KuberSpace.sm,
        KuberSpace.screenMargin,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBlock(width: 240, height: 16, borderRadius: 999),
          const SizedBox(height: KuberSpace.xl),
          for (var g = 0; g < 2; g++) ...[
            const SkeletonBlock(width: 80, height: 12, borderRadius: 999),
            const SizedBox(height: KuberSpace.md),
            KuberGroup(children: [row(), row(), row()]),
            const SizedBox(height: KuberSpace.xl),
          ],
        ],
      ),
    );
  }
}
