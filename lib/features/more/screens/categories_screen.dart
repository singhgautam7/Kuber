import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;
import '../../budgets/providers/budget_provider.dart';
import '../../budgets/data/budget.dart';
import '../../budgets/widgets/budget_details_sheet.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import 'add_edit_category_screen.dart';
import '../../../core/constants/info_constants.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../settings/providers/info_provider.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../categories/widgets/category_widgets.dart';

final categorySpendBreakdownProvider =
    FutureProvider<
      ({
        double total,
        double? trendPct,
        int categoryCount,
        List<CategorySpendSlice> topSlices,
        Map<String, double> perCategoryTotals,
        Map<String, int> perCategoryTxnCounts,
      })
    >((ref) async {
      final categories = await ref.watch(categoryListProvider.future);
      final txns = await ref.watch(transactionListProvider.future);
      final categoryById = {for (final c in categories) c.id: c};
      final now = DateTime.now();

      // Three windows via the shared `aggregate(filter)` helper:
      //   1. Full current month → drives hero total, slices, category count.
      //   2. Current month to date (1..today, same-day cutoff).
      //   3. Last month, same 1..today cutoff.
      // The trend % compares #2 vs #3 — apples-to-apples — while #1 keeps
      // the headline number consistent with Home's monthlySummaryProvider
      // (no linkedRuleType exclusion; EMI / SIP / recurring count as spend).
      final monthStart = DateTime(now.year, now.month);
      final nextMonth = DateTime(now.year, now.month + 1);
      final todayExclusive = DateTime(now.year, now.month, now.day + 1);
      final lastMonthStart = DateTime(now.year, now.month - 1);
      final lastMonthSameDayExclusive = DateTime(
        now.year,
        now.month - 1,
        now.day + 1,
      );

      final fullMonth = txns.aggregate(
        TxnPeriodFilter(from: monthStart, to: nextMonth),
      );
      final currentToDate = txns.aggregate(
        TxnPeriodFilter(from: monthStart, to: todayExclusive),
      );
      final lastMonthSameWindow = txns.aggregate(
        TxnPeriodFilter(from: lastMonthStart, to: lastMonthSameDayExclusive),
      );

      final slices = <CategorySpendSlice>[];
      fullMonth.spendingByCategory.forEach((catIdStr, amount) {
        final catId = int.tryParse(catIdStr);
        if (catId == null) return;
        final category = categoryById[catId];
        if (category == null) return;
        slices.add(
          CategorySpendSlice(
            categoryId: catId,
            name: category.name,
            color: Color(category.colorValue),
            amount: amount,
          ),
        );
      });
      slices.sort((a, b) => b.amount.compareTo(a.amount));

      final trendPct = lastMonthSameWindow.expense > 0
          ? ((currentToDate.expense - lastMonthSameWindow.expense) /
                    lastMonthSameWindow.expense) *
                100
          : null;

      return (
        total: fullMonth.expense,
        trendPct: trendPct,
        categoryCount: slices.length,
        topSlices: slices.take(5).toList(),
        perCategoryTotals: fullMonth.spendingByCategory,
        perCategoryTxnCounts: fullMonth.txnCountByCategory,
      );
    });

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  /// Search query — when non-empty the list flips from grouped → flat
  /// matches. A match is "name contains query OR the parent group's name
  /// contains query" (case-insensitive).
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoryListProvider);
    final groupsAsync = ref.watch(categoryGroupListProvider);

    // Auto-trigger info sheet
    ref.listen<AsyncValue<bool>>(
      infoSeenProvider(PrefsKeys.seenInfoCategories),
      (prev, next) {
        if (next.hasValue && next.value == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            KuberInfoBottomSheet.show(context, InfoConstants.categories);
            ref
                .read(infoSeenProvider(PrefsKeys.seenInfoCategories).notifier)
                .markSeen();
          });
        }
      },
    );

    return Scaffold(
      backgroundColor: cs.surface,
      // Tap anywhere outside the search field to dismiss the keyboard.
      // `behavior: opaque` so the detector also catches taps on empty
      // space inside the scroll view, not just on widgets that themselves
      // absorb hits.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(context.l10n.errorWithDetails(e.toString()))),
          data: (categories) {
            final groups = groupsAsync.valueOrNull ?? [];

            return CustomScrollView(
              slivers: [
                // App bar
                const SliverToBoxAdapter(
                  child: KuberAppBar(
                    showBack: true,
                    showHome: true,
                    title: '',
                    infoConfig: InfoConstants.categories,
                  ),
                ),

                // Page header
                SliverToBoxAdapter(
                  child: KuberPageHeader(
                    title: context.l10n.categoriesTitle,
                    description: '',
                    actionTooltip: context.l10n.addCategoryGroup,
                    onAction: () => _showAddSelectionSheet(context),
                  ),
                ),

                // Spend hero — hidden when there is no expense activity this
                // month so we don't render an empty ₹0 / 0 categories card.
                SliverToBoxAdapter(
                  child: ref
                      .watch(categorySpendBreakdownProvider)
                      .when(
                        data: (breakdown) {
                          if (breakdown.total <= 0 ||
                              breakdown.topSlices.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              KuberSpacing.lg,
                              0,
                              KuberSpacing.lg,
                              KuberSpacing.lg,
                            ),
                            child: CategorySpendHero(
                              total: breakdown.total,
                              trendPct: breakdown.trendPct,
                              categoryCount: breakdown.categoryCount,
                              topSlices: breakdown.topSlices,
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.fromLTRB(
                            KuberSpacing.lg,
                            0,
                            KuberSpacing.lg,
                            KuberSpacing.lg,
                          ),
                          child: SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                ),

                if (categories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: KuberEmptyState(
                      icon: Icons.category_outlined,
                      title: context.l10n.noCategories,
                      description: context.l10n.categoriesEmptyDesc,
                      actionLabel: context.l10n.addCategory,
                      onAction: () => _showAddSelectionSheet(context),
                    ),
                  )
                else ...[
                  // Search field — matches the tools_hub_screen treatment.
                  // Filters by category name OR parent group name (case-
                  // insensitive); when matches occur, the list flips from
                  // grouped to a flat sorted result list.
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KuberSpacing.lg,
                        0,
                        KuberSpacing.lg,
                        KuberSpacing.md,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        style: localeFont(
                          fontSize: 14,
                          color: cs.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: context.l10n.searchCategoriesHint,
                          hintStyle: localeFont(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: cs.onSurfaceVariant,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                          filled: true,
                          fillColor: cs.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: KuberSpacing.md,
                            horizontal: KuberSpacing.lg,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(KuberRadius.md),
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(KuberRadius.md),
                            borderSide: BorderSide(color: cs.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(KuberRadius.md),
                            borderSide: BorderSide(color: cs.primary),
                          ),
                        ),
                      ),
                    ),
                  ),

                  ...() {
                    // Per-category this-month aggregates — same source the
                    // hero uses, so per-row amount + txn count stay in
                    // lockstep with the hero total.
                    final breakdownValue = ref
                        .watch(categorySpendBreakdownProvider)
                        .valueOrNull;
                    final perCategoryThisMonth =
                        breakdownValue?.perCategoryTotals ??
                        const <String, double>{};
                    final perCategoryThisMonthCount =
                        breakdownValue?.perCategoryTxnCounts ??
                        const <String, int>{};

                    // Group lookups (id -> name) so search can match by
                    // parent group name.
                    final groupNameById = <int, String>{
                      for (final g in groups) g.id: g.name,
                    };

                    final q = _query.trim().toLowerCase();
                    final isSearching = q.isNotEmpty;

                    // ── Searching: flat list of matches ───────────────────
                    if (isSearching) {
                      bool matches(Category c) {
                        if (c.name.toLowerCase().contains(q)) return true;
                        final gid = c.groupId;
                        if (gid != null) {
                          final gname = groupNameById[gid];
                          if (gname != null &&
                              gname.toLowerCase().contains(q)) {
                            return true;
                          }
                        }
                        return false;
                      }

                      final matched = categories.where(matches).toList()
                        ..sort((a, b) => a.name.compareTo(b.name));

                      if (matched.isEmpty) {
                        return <Widget>[
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: KuberSpacing.lg,
                              vertical: KuberSpacing.xl,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: KuberEmptyState(
                                icon: Icons.search_off_rounded,
                                title: context.l10n.noMatches,
                                description: context.l10n.noCategoryMatches(_query.trim()),
                              ),
                            ),
                          ),
                        ];
                      }

                      return <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final cat = matched[index];
                              final catIdStr = cat.id.toString();
                              final realGname = cat.groupId != null
                                  ? groupNameById[cat.groupId!]
                                  : null;
                              // Always surface a group tag in search
                              // results: real group name if set, else
                              // "Ungrouped". Otherwise an orphan category
                              // looks identical to a grouped one and the
                              // user can't tell why it matched.
                              final searchTag = realGname ?? context.l10n.ungroupedLabel;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: CategoryListItem(
                                  category: cat,
                                  thisMonthSpent:
                                      perCategoryThisMonth[catIdStr] ?? 0,
                                  thisMonthTxnCount:
                                      perCategoryThisMonthCount[catIdStr] ?? 0,
                                  groupName: searchTag,
                                  onTap: () => _showCategoryDetails(
                                    context,
                                    ref,
                                    cat,
                                    realGname,
                                  ),
                                ),
                              );
                            }, childCount: matched.length),
                          ),
                        ),
                      ];
                    }

                    // ── Not searching: existing grouped view ──────────────
                    final Map<int?, List<Category>> grouped = {};
                    for (final cat in categories) {
                      grouped.putIfAbsent(cat.groupId, () => []).add(cat);
                    }

                    // Sort groups alphabetically
                    final sortedGroups = groups.toList()
                      ..sort((a, b) => a.name.compareTo(b.name));

                    final List<Widget> slivers = [];
                    int groupSerial = 0;

                    // Render each group
                    for (final group in sortedGroups) {
                      final groupCategories = grouped[group.id] ?? [];
                      if (groupCategories.isNotEmpty) {
                        groupCategories.sort(
                          (a, b) => a.name.compareTo(b.name),
                        );
                        groupSerial += 1;
                        slivers.add(
                          SliverToBoxAdapter(
                            child: _GroupHeader(
                              name: group.name,
                              serial: groupSerial.toString().padLeft(2, '0'),
                              count: groupCategories.length,
                              onTap: () =>
                                  _showGroupActionsSheet(context, ref, group),
                            ),
                          ),
                        );
                        slivers.add(
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final cat = groupCategories[index];
                                final catIdStr = cat.id.toString();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: CategoryListItem(
                                    category: cat,
                                    thisMonthSpent:
                                        perCategoryThisMonth[catIdStr] ?? 0,
                                    thisMonthTxnCount:
                                        perCategoryThisMonthCount[catIdStr] ??
                                        0,
                                    groupName: group.name,
                                    onTap: () => _showCategoryDetails(
                                      context,
                                      ref,
                                      cat,
                                      group.name,
                                    ),
                                  ),
                                );
                              }, childCount: groupCategories.length),
                            ),
                          ),
                        );
                      }
                    }

                    // Render Ungrouped
                    final ungrouped = grouped[null] ?? [];
                    if (ungrouped.isNotEmpty) {
                      ungrouped.sort((a, b) => a.name.compareTo(b.name));
                      groupSerial += 1;
                      slivers.add(
                        SliverToBoxAdapter(
                          child: _GroupHeader(
                            name: 'Ungrouped',
                            serial: groupSerial.toString().padLeft(2, '0'),
                            count: ungrouped.length,
                          ),
                        ),
                      );
                      slivers.add(
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final cat = ungrouped[index];
                              final catIdStr = cat.id.toString();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: CategoryListItem(
                                  category: cat,
                                  thisMonthSpent:
                                      perCategoryThisMonth[catIdStr] ?? 0,
                                  thisMonthTxnCount:
                                      perCategoryThisMonthCount[catIdStr] ?? 0,
                                  onTap: () => _showCategoryDetails(
                                    context,
                                    ref,
                                    cat,
                                    null,
                                  ),
                                ),
                              );
                            }, childCount: ungrouped.length),
                          ),
                        ),
                      );
                    }

                    return slivers;
                  }(),
                ],

                // Bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(height: navBarBottomPadding(context) + 40),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddSelectionSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KuberRadius.lg),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpacing.xl,
          0,
          KuberSpacing.xl,
          KuberSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Header with Title + Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.addNew,
                  style: localeFont(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAddOption(
              context,
              icon: Icons.category_rounded,
              title: context.l10n.addCategory,
              description: context.l10n.addCategoryDesc,
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/category/add',
                  extra: const CategoryRouteArgs(returnToCategoryPicker: false),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildAddOption(
              context,
              icon: Icons.grid_view_rounded,
              title: context.l10n.addGroup,
              description: context.l10n.addGroupDesc,
              onTap: () {
                Navigator.pop(context);
                _showAddGroupDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: cs.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: localeFont(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: localeFont(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context) {
    final controller = TextEditingController();
    _showGroupDialog(context, controller, context.l10n.addGroup, (ref, name) {
      final group = CategoryGroup()..name = name;
      ref.read(categoryGroupListProvider.notifier).add(group);
    }, null);
  }

  void _showEditGroupDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryGroup group,
  ) {
    final controller = TextEditingController(text: group.name);
    _showGroupDialog(context, controller, context.l10n.editGroup, (ref, name) {
      group.name = name;
      ref.read(categoryGroupRepositoryProvider).save(group);
      ref.invalidate(categoryGroupListProvider);
    }, group.id);
  }

  /// Bottom sheet shown on tap of a group row in the Categories list.
  /// Contains Edit and Delete actions. Dismisses before delegating so the
  /// downstream dialog has a clean stack.
  void _showGroupActionsSheet(
    BuildContext context,
    WidgetRef ref,
    CategoryGroup group,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => KuberBottomSheet(
        title: group.name,
        subtitle: context.l10n.categoryGroupSubtitle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: context.l10n.editGroupLabel,
              icon: Icons.edit_outlined,
              type: AppButtonType.normal,
              fullWidth: true,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _showEditGroupDialog(context, ref, group);
              },
            ),
            const SizedBox(height: KuberSpacing.sm),
            AppButton(
              label: context.l10n.deleteGroupLabel,
              icon: Icons.delete_outline_rounded,
              type: AppButtonType.danger,
              fullWidth: true,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _confirmDeleteGroup(context, ref, group);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupDialog(
    BuildContext context,
    TextEditingController controller,
    String title,
    void Function(WidgetRef ref, String name) onSave,
    int? editingGroupId,
  ) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final cs = Theme.of(context).colorScheme;
          final groups = ref.watch(categoryGroupListProvider).valueOrNull ?? [];

          return StatefulBuilder(
            builder: (context, setDialogState) {
              // Normalize: trim and replace multiple spaces with one
              final raw = controller.text;
              final normalized = raw.trim().replaceAll(RegExp(r'\s+'), ' ');

              final isDuplicate = groups.any((g) {
                if (editingGroupId != null && g.id == editingGroupId) {
                  return false;
                }
                return g.name.toLowerCase() == normalized.toLowerCase();
              });

              final canSave = normalized.isNotEmpty && !isDuplicate;

              String? errorText;
              if (raw.trim().isNotEmpty && isDuplicate) {
                errorText = context.l10n.groupAlreadyExists;
              } else if (raw.isNotEmpty && normalized.isEmpty) {
                errorText = context.l10n.groupNameEmpty;
              }

              return AlertDialog(
                backgroundColor: cs.surfaceContainer,
                title: Text(
                  title,
                  style: localeFont(fontWeight: FontWeight.w600),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLength: 15,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: context.l10n.groupNameHint,
                        errorText: errorText,
                        counterText: '${raw.length} / 15',
                        counterStyle: localeFont(
                          fontSize: 10,
                          color: raw.length >= 15
                              ? cs.error
                              : cs.onSurfaceVariant,
                        ),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.cancelLabel),
                  ),
                  AppButton(
                    label: context.l10n.saveLabel,
                    type: AppButtonType.primary,
                    onPressed: canSave
                        ? () {
                            onSave(ref, normalized);
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDeleteGroup(
    BuildContext context,
    WidgetRef ref,
    CategoryGroup group,
  ) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        title: Text(
          context.l10n.deleteGroupConfirm,
          style: localeFont(fontWeight: FontWeight.w600),
        ),
        content: Text(
          context.l10n.deleteGroupBody(group.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelLabel),
          ),
          AppButton(
            label: context.l10n.deleteLabel,
            type: AppButtonType.primary,
            onPressed: () {
              ref.read(categoryGroupListProvider.notifier).delete(group.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showCategoryDetails(
    BuildContext context,
    WidgetRef ref,
    Category cat,
    String? groupName,
  ) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KuberBottomSheet(
        title: cat.name,
        subtitle: context.l10n.categoryDetail,
        leadingIcon: CategoryIcon.square(
          icon: IconMapper.fromString(cat.icon),
          rawColor: Color(cat.colorValue),
          size: 48,
        ),
        actions: AppButton(
          label: context.l10n.viewTransactions,
          icon: Icons.receipt_long_rounded,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: () {
            ref.read(historyFilterProvider.notifier).clearAll();
            ref
                .read(historyFilterProvider.notifier)
                .setFilters(categoryIds: {cat.id.toString()});
            context.go('/history');
          },
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Last Transaction Activity
            Consumer(
              builder: (context, ref, _) {
                final latestTxnAsync = ref.watch(
                  categoryRecentTransactionProvider(cat.id),
                );

                return latestTxnAsync.when(
                  data: (txn) => Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        txn != null
                            ? context.l10n.lastTransaction(DateFormatter.timeAgo(txn.createdAt))
                            : context.l10n.noTransactionsYet,
                        style: localeFont(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 32),
            _buildDetailItem(
              context,
              label: context.l10n.groupUpper,
              value: groupName ?? context.l10n.noneLabel,
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              context,
              label: context.l10n.typeUpper,
              value: cat.effectiveType == 'both'
                  ? context.l10n.incomeAndExpense
                  : cat.effectiveType == 'income'
                      ? context.l10n.incomeLabel
                      : context.l10n.expenseLabel,
            ),
            const SizedBox(height: 24),
            _BudgetStatusSection(category: cat),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: context.l10n.editLabel,
                    icon: Icons.edit_outlined,
                    type: AppButtonType.normal,
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(
                        '/category/add',
                        extra: CategoryRouteArgs(category: cat),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: context.l10n.deleteLabel,
                    icon: Icons.delete_outline_rounded,
                    type: AppButtonType.danger,
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(context, ref, cat);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: localeFont(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: localeFont(
            fontSize: 15,
            color: cs.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Category cat) async {
    final cs = Theme.of(context).colorScheme;
    final repo = ref.read(categoryRepositoryProvider);
    final hasTxns = await repo.hasTransactions(cat.id);

    if (!context.mounted) return;

    if (hasTxns) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: cs.outline, width: 1),
          ),
          title: Text(
            context.l10n.cannotDeleteCategory,
            style: localeFont(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          content: Text(
            context.l10n.cannotDeleteCategoryBody,
            style: localeFont(color: cs.onSurfaceVariant),
          ),
          actions: [
            AppButton(
              label: context.l10n.okLabel,
              type: AppButtonType.primary,
              onPressed: () => Navigator.of(dialogCtx).pop(),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: cs.outline, width: 1),
          ),
          title: Text(
            context.l10n.deleteCategoryConfirm,
            style: localeFont(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          content: Text(
            context.l10n.deleteCategoryBody(cat.name),
            style: localeFont(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                context.l10n.cancelLabel,
                style: localeFont(color: cs.onSurfaceVariant),
              ),
            ),
            AppButton(
              label: context.l10n.deleteLabel,
              type: AppButtonType.danger,
              onPressed: () async {
                await ref.read(categoryRepositoryProvider).delete(cat.id);
                ref.invalidate(categoryListProvider);
                if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
              },
            ),
          ],
        ),
      );
    }
  }
}

class _GroupHeader extends StatelessWidget {
  final String name;
  final String? serial;
  final int? count;

  /// When non-null, the entire header row is tappable. Use to open a
  /// bottom sheet with group actions (edit / delete). Pass null for
  /// non-actionable groups (e.g. "Ungrouped").
  final VoidCallback? onTap;

  const _GroupHeader({required this.name, this.serial, this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (serial != null) ...[
            Text(
              serial!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
          ],
          Text(
            name.toUpperCase(),
            style: localeFont(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.primary,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          if (count != null)
            Text(
              count == 1 ? '1 category' : '$count categories',
              style: localeFont(
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}

// ignore: unused_element
class _CategoryKpisGrid extends ConsumerWidget {
  const _CategoryKpisGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiAsync = ref.watch(categoryKpiProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: kpiAsync.when(
        data: (kpis) => Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildKpiCard(
                    context,
                    'TOTAL CATEGORIES',
                    kpis.totalCategories.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildKpiCard(
                    context,
                    'UNUSED CATEGORIES',
                    kpis.unusedCategories.toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _buildKpiCard(
                    context,
                    'TOTAL GROUPS',
                    kpis.totalGroups.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildKpiCard(
                    context,
                    'TOP EXPENSE',
                    kpis.topExpenseCategory,
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, st) => const Text('Error loading KPIs'),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: localeFont(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: localeFont(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _CategoryListItem extends ConsumerWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryListItem({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final color = Color(category.colorValue);

    final statsAsync = ref.watch(categoryStatsProvider);
    final stats =
        statsAsync.valueOrNull?[category.id] ??
        CategoryStats.empty(category.id);

    final budgetAsync = ref.watch(
      budgetByCategoryProvider(category.id.toString()),
    );
    final budget = budgetAsync.valueOrNull;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Top Row
            Row(
              children: [
                CategoryIcon.square(
                  icon: IconMapper.fromString(category.icon),
                  rawColor: color,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: localeFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.effectiveType.toUpperCase(),
                        style: localeFont(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  stats.transactionCount == 1
                      ? '1 transaction'
                      : '${stats.transactionCount} transactions',
                  style: localeFont(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom Row (Budget)
            if (budget == null || !budget.isActive)
              _buildNoBudget(context)
            else
              _buildBudgetProgress(context, ref, budget, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBudget(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cs.onSurfaceVariant.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_circle_outline,
                size: 12,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                'NO BUDGET',
                style: localeFont(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Empty percentage placeholder for alignment if needed
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildBudgetProgress(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
    CategoryStats stats,
  ) {
    final cs = Theme.of(context).colorScheme;
    final progressAsync = ref.watch(budgetProgressProvider(budget));

    return progressAsync.when(
      data: (p) {
        final progressNum = p.percentage / 100.0;
        final isOverBudget = progressNum >= 1.0;

        final trackColor = cs.outlineVariant.withValues(alpha: 0.3);
        final barColor = isOverBudget ? cs.error : cs.primary;
        final iconData = isOverBudget
            ? Icons.warning_amber_rounded
            : Icons.check_circle_outline_rounded;

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: barColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: barColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconData, size: 12, color: barColor),
                  const SizedBox(width: 4),
                  Text(
                    'BUDGET',
                    style: localeFont(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: barColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  return Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: trackColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0.0,
                          end: progressNum.clamp(0.0, 1.0),
                        ),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          // very small values minimally visible (~6px)
                          final width = value == 0
                              ? 0.0
                              : (maxWidth * value).clamp(6.0, maxWidth);
                          return Container(
                            width: width,
                            height: 6,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 40,
              child: Text(
                '${p.percentage.round()}%',
                textAlign: TextAlign.right,
                style: localeFont(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 24,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (_, __) => const Text('Error'),
    );
  }
}

class _BudgetStatusSection extends ConsumerWidget {
  final Category category;
  const _BudgetStatusSection({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(
      budgetByCategoryProvider(category.id.toString()),
    );
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUDGET STATUS',
          style: localeFont(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        budgetAsync.when(
          data: (budget) {
            if (budget == null || !budget.isActive) {
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/budgets/add', extra: category);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 20,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Set a budget for this category',
                        style: localeFont(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final progressAsync = ref.watch(budgetProgressProvider(budget));
            return progressAsync.when(
              data: (p) => InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BudgetDetailsSheet(
                      budgetId: budget.id,
                      category: category,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${ref.watch(formatterProvider).formatCurrency(p.spent)} / ${ref.watch(formatterProvider).formatCurrency(p.limit)}',
                            style: localeFont(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ref
                                .watch(formatterProvider)
                                .formatPercentage(p.percentage),
                            style: localeFont(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: p.percentage >= 100
                                  ? cs.error
                                  : cs.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (p.percentage / 100).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: cs.outline.withValues(alpha: 0.1),
                          color: p.percentage >= 100 ? cs.error : cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error calculating progress: $err'),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text('Error: $err'),
        ),
      ],
    );
  }
}