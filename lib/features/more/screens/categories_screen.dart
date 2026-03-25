import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../categories/providers/category_provider.dart';
import 'add_edit_category_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoryListProvider);
    final groupsAsync = ref.watch(categoryGroupListProvider);

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
                child: KuberAppBar(showBack: true, title: 'Categories'),
              ),

              // Page header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage\nCategories',
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Organize your transactions with custom categories and group those categories.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddSelectionSheet(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (categories.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
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
                            onEdit: () => _showEditGroupDialog(context, ref, group),
                            onDelete: () => _confirmDeleteGroup(context, ref, group),
                          ),
                        ),
                      );
                      slivers.add(
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _CategoryGridItem(
                                category: groupCategories[index],
                                onTap: () => _showCategoryDetails(context, ref, groupCategories[index], group.name),
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
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _CategoryGridItem(
                              category: ungrouped[index],
                              onTap: () => _showCategoryDetails(context, ref, ungrouped[index], null),
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
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAddOption(
                context,
                icon: Icons.category_rounded,
                title: 'Add Category',
                description: 'Classify your transactions for better tracking',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/category/add', extra: const CategoryRouteArgs(returnToCategoryPicker: false));
                },
              ),
              const SizedBox(height: 16),
              _buildAddOption(
                context,
                icon: Icons.grid_view_rounded,
                title: 'Add Group',
                description: 'Organize categories into sections for better clarity',
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
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: cs.onSurface)),
                  Text(description, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
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

  void _showEditGroupDialog(BuildContext context, WidgetRef ref, CategoryGroup group) {
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
                if (editingGroupId != null && g.id == editingGroupId) return false;
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
                title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
                          color: raw.length >= 15 ? cs.error : cs.onSurfaceVariant,
                        ),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  FilledButton(
                    onPressed: canSave
                        ? () {
                            onSave(ref, normalized);
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, WidgetRef ref, CategoryGroup group) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        title: Text('Delete Group?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('Categories in "${group.name}" will be moved to "Ungrouped".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () {
              ref.read(categoryGroupListProvider.notifier).delete(group.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, WidgetRef ref, Category cat, String? groupName) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(cat.colorValue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(IconMapper.fromString(cat.icon), color: Color(cat.colorValue), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
                        Text(cat.effectiveType.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailItem(context, label: 'GROUP', value: groupName ?? 'None'),
              const SizedBox(height: 16),
              _buildDetailItem(
                context,
                label: 'TYPE',
                value: cat.effectiveType == 'both'
                    ? 'Income & Expense'
                    : cat.effectiveType[0].toUpperCase() + cat.effectiveType.substring(1),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/category/add', extra: CategoryRouteArgs(category: cat));
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: cs.errorContainer, foregroundColor: cs.onErrorContainer),
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(context, ref, cat);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
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

  Widget _buildDetailItem(BuildContext context, {required String label, required String value}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, letterSpacing: 1.1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 15, color: cs.onSurface, fontWeight: FontWeight.w500)),
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
          title: Text('Cannot delete category',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              )),
          content: Text(
            'This category has transactions linked to it. '
            'To delete this category, delete the linked transactions first.',
            style: GoogleFonts.inter(color: cs.onSurfaceVariant),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('OK',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
          title: Text('Delete category?',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              )),
          content: Text(
            '"${cat.name}" will be permanently deleted.',
            style: GoogleFonts.inter(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ref.read(categoryRepositoryProvider).delete(cat.id);
                ref.invalidate(categoryListProvider);
                Navigator.pop(context);
              },
              child: Text('Delete',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

  const _GroupHeader({
    required this.name,
    this.onEdit,
    this.onDelete,
  });

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
              icon: Icon(Icons.edit_outlined, size: 16, color: cs.onSurfaceVariant),
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: 16, color: cs.onSurfaceVariant),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryGridItem({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = Color(category.colorValue);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CategoryIcon.square(
              icon: IconMapper.fromString(category.icon),
              rawColor: color,
              size: 40,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5), width: 0.5),
              ),
              child: Text(
                category.effectiveType,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
