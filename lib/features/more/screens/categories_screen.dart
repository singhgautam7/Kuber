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

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoryListProvider);
    final groupsAsync = ref.watch(categoryGroupListProvider);

    // Auto-trigger info sheet
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoCategories), (prev, next) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.categories);
          ref.read(infoSeenProvider(PrefsKeys.seenInfoCategories).notifier).markSeen();
        });
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          final groups = groupsAsync.valueOrNull ?? [];

          return CustomScrollView(
            slivers: [
              // App bar
              const SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  title: 'Categories',
                  infoConfig: InfoConstants.categories,
                ),
              ),

              // Page header
              SliverToBoxAdapter(
                child: KuberPageHeader(
                  title: 'Manage\nCategories',
                  description:
                      'Organize your transactions with custom categories and group those categories.',
                  actionTooltip: 'Add Category/Group',
                  onAction: () => _showAddSelectionSheet(context),
                ),
              ),

              // KPI Grid
              const SliverToBoxAdapter(child: _CategoryKpisGrid()),

              if (categories.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.category_outlined,
                    title: 'No categories yet',
                    description: 'Create categories to organize your expenses',
                    actionLabel: 'Add Category',
                    onAction: () => _showAddSelectionSheet(context),
                  ),
                )
              else ...[
                ...() {
                  final Map<int?, List<Category>> grouped = {};
                  for (final cat in categories) {
                    grouped.putIfAbsent(cat.groupId, () => []).add(cat);
                  }

                  // Sort groups alphabetically
                  final sortedGroups = groups.toList()
                    ..sort((a, b) => a.name.compareTo(b.name));

                  final List<Widget> slivers = [];

                  // Render each group
                  for (final group in sortedGroups) {
                    final groupCategories = grouped[group.id] ?? [];
                    if (groupCategories.isNotEmpty) {
                      groupCategories.sort((a, b) => a.name.compareTo(b.name));
                      slivers.add(
                        SliverToBoxAdapter(
                          child: _GroupHeader(
                            name: group.name,
                            onEdit: () =>
                                _showEditGroupDialog(context, ref, group),
                            onDelete: () =>
                                _confirmDeleteGroup(context, ref, group),
                          ),
                        ),
                      );
                      slivers.add(
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _CategoryListItem(
                                  category: groupCategories[index],
                                  onTap: () => _showCategoryDetails(
                                    context,
                                    ref,
                                    groupCategories[index],
                                    group.name,
                                  ),
                                ),
                              ),
                              childCount: groupCategories.length,
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  // Render Ungrouped
                  final ungrouped = grouped[null] ?? [];
                  if (ungrouped.isNotEmpty) {
                    ungrouped.sort((a, b) => a.name.compareTo(b.name));
                    slivers.add(
                      const SliverToBoxAdapter(
                        child: _GroupHeader(name: 'Ungrouped'),
                      ),
                    );
                    slivers.add(
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CategoryListItem(
                                category: ungrouped[index],
                                onTap: () => _showCategoryDetails(
                                  context,
                                  ref,
                                  ungrouped[index],
                                  null,
                                ),
                              ),
                            ),
                            childCount: ungrouped.length,
                          ),
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
    );
  }

  void _showAddSelectionSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
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
                    'Add New',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
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
                title: 'Add Category',
                description: 'Classify your transactions for better tracking',
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/category/add',
                    extra: const CategoryRouteArgs(
                      returnToCategoryPicker: false,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildAddOption(
                context,
                icon: Icons.grid_view_rounded,
                title: 'Add Group',
                description:
                    'Organize categories into sections for better clarity',
                onTap: () {
                  Navigator.pop(context);
                  _showAddGroupDialog(context);
                },
              ),
            ],
          ),
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
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.inter(
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
    _showGroupDialog(context, controller, 'Add Group', (ref, name) {
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
    _showGroupDialog(context, controller, 'Edit Group', (ref, name) {
      group.name = name;
      ref.read(categoryGroupRepositoryProvider).save(group);
      ref.invalidate(categoryGroupListProvider);
    }, group.id);
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
                errorText = 'This group already exists';
              } else if (raw.isNotEmpty && normalized.isEmpty) {
                errorText = 'Group name cannot be empty';
              }

              return AlertDialog(
                backgroundColor: cs.surfaceContainer,
                title: Text(
                  title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
                        hintText: 'Group name (e.g. Food, Transport)',
                        errorText: errorText,
                        counterText: '${raw.length} / 15',
                        counterStyle: GoogleFonts.inter(
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
                    child: const Text('Cancel'),
                  ),
                  AppButton(
                    label: 'Save',
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
          'Delete Group?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Categories in "${group.name}" will be moved to "Ungrouped".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Delete',
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
        subtitle: 'Category Detail',
        leadingIcon: CategoryIcon.square(
          icon: IconMapper.fromString(cat.icon),
          rawColor: Color(cat.colorValue),
          size: 48,
        ),
        actions: AppButton(
          label: 'View Transactions',
          icon: Icons.receipt_long_rounded,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: () {
            ref.read(historyFilterProvider.notifier).clearAll();
            ref.read(historyFilterProvider.notifier).setFilters(
                  categoryIds: {cat.id.toString()},
                );
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
                            ? 'Last transaction ${DateFormatter.timeAgo(txn.createdAt)}'
                            : 'No transactions yet',
                        style: GoogleFonts.inter(
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
              label: 'GROUP',
              value: groupName ?? 'None',
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              context,
              label: 'TYPE',
              value: cat.effectiveType == 'both'
                  ? 'Income & Expense'
                  : cat.effectiveType[0].toUpperCase() +
                        cat.effectiveType.substring(1),
            ),
            const SizedBox(height: 24),
            _BudgetStatusSection(category: cat),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Edit',
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
                    label: 'Delete',
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
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
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
        builder: (_) => AlertDialog(
          backgroundColor: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: cs.outline, width: 1),
          ),
          title: Text(
            'Cannot delete category',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          content: Text(
            'This category has transactions linked to it. '
            'To delete this category, delete the linked transactions first.',
            style: GoogleFonts.inter(color: cs.onSurfaceVariant),
          ),
          actions: [
            AppButton(
              label: 'OK',
              type: AppButtonType.primary,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: cs.outline, width: 1),
          ),
          title: Text(
            'Delete category?',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          content: Text(
            '"${cat.name}" will be permanently deleted.',
            style: GoogleFonts.inter(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: cs.onSurfaceVariant),
              ),
            ),
            AppButton(
              label: 'Delete',
              type: AppButtonType.primary,
              onPressed: () {
                ref.read(categoryRepositoryProvider).delete(cat.id);
                ref.invalidate(categoryListProvider);
                Navigator.pop(context);
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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _GroupHeader({required this.name, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          if (onEdit != null) ...[
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

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
            style: GoogleFonts.inter(
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
            style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.effectiveType.toUpperCase(),
                        style: GoogleFonts.inter(
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
                  style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
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
                style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
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
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ref
                                .watch(formatterProvider)
                                .formatPercentage(p.percentage),
                            style: GoogleFonts.inter(
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
