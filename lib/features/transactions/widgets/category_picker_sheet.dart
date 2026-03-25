import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/add_new_button.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../more/screens/add_edit_category_screen.dart';

class CategoryPickerSheet extends ConsumerStatefulWidget {
  final int? selectedCategoryId;
  final ValueChanged<int> onSelected;
  final String? defaultType;

  const CategoryPickerSheet({
    super.key,
    required this.selectedCategoryId,
    required this.onSelected,
    this.defaultType,
  });

  @override
  ConsumerState<CategoryPickerSheet> createState() =>
      _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categories = ref.watch(categoryListProvider);
    final groups = ref.watch(categoryGroupListProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KuberSpacing.lg,
            KuberSpacing.sm,
            KuberSpacing.lg,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),

              // Title row
              Row(
                children: [
                  Text(
                    'Select Category',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.md),

              // Search field
              TextField(
                controller: _searchController,
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search categories',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: cs.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHigh,
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              ),
              const SizedBox(height: KuberSpacing.lg),
            ],
          ),
        ),

        Flexible(
          child: categories.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (cats) {
              final groupsData = groups.valueOrNull ?? [];

              // 1. Initial Filtering (Search + Type)
              var filtered = cats;
              if (_query.isNotEmpty) {
                filtered = filtered
                    .where((c) => c.name.toLowerCase().contains(_query))
                    .toList();
              }

              if (widget.defaultType == 'expense') {
                filtered = filtered
                    .where((c) =>
                        c.effectiveType == 'expense' ||
                        c.effectiveType == 'both')
                    .toList();
              } else if (widget.defaultType == 'income') {
                filtered = filtered
                    .where((c) =>
                        c.effectiveType == 'income' ||
                        c.effectiveType == 'both')
                    .toList();
              }

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(KuberSpacing.lg),
                    child: Text(
                      'No categories found',
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              // 2. Rendering based on Query
              if (_query.isNotEmpty) {
                // Flat grid for search results
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: KuberSpacing.md,
                    crossAxisSpacing: KuberSpacing.md,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _CategoryItem(cat: filtered[index], selectedCategoryId: widget.selectedCategoryId, onSelected: widget.onSelected),
                );
              }

              // 3. Grouping & Sorting logic
              final Map<int?, List<Category>> grouped = {};
              for (final cat in filtered) {
                grouped.putIfAbsent(cat.groupId, () => []).add(cat);
              }

              // Sort categories within each group
              for (final groupCats in grouped.values) {
                groupCats.sort((a, b) => a.name.compareTo(b.name));
              }

              // Sort groups alphabetically
              final sortedGroups = groupsData.toList()
                ..sort((a, b) => a.name.compareTo(b.name));

              return CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  // Grouped categories
                  for (final group in sortedGroups) ...[
                    if (grouped.containsKey(group.id) && grouped[group.id]!.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _GroupHeader(name: group.name),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: KuberSpacing.md,
                            crossAxisSpacing: KuberSpacing.md,
                            childAspectRatio: 0.8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _CategoryItem(
                              cat: grouped[group.id]![index],
                              selectedCategoryId: widget.selectedCategoryId,
                              onSelected: widget.onSelected,
                            ),
                            childCount: grouped[group.id]!.length,
                          ),
                        ),
                      ),
                    ],
                  ],

                  // Ungrouped categories
                  if (grouped.containsKey(null) && grouped[null]!.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: _GroupHeader(name: 'Ungrouped'),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: KuberSpacing.md,
                          crossAxisSpacing: KuberSpacing.md,
                          childAspectRatio: 0.8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _CategoryItem(
                            cat: grouped[null]![index],
                            selectedCategoryId: widget.selectedCategoryId,
                            onSelected: widget.onSelected,
                          ),
                          childCount: grouped[null]!.length,
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: KuberSpacing.lg)),
                ],
              );
            },
          ),
        ),

        // Add new category button
        AddNewButton(
          label: 'Add new category',
          onTap: () {
            // Close the picker sheet first
            Navigator.pop(context);
            // Then push to add category screen
            context.push(
              '/category/add',
              extra: CategoryRouteArgs(
                defaultType: widget.defaultType,
                returnToCategoryPicker: true,
              ),
            );
          },
        ),
      ],
    );
  }
}
class _GroupHeader extends StatelessWidget {
  final String name;

  const _GroupHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpacing.lg,
        KuberSpacing.lg,
        KuberSpacing.lg,
        KuberSpacing.sm,
      ),
      child: Text(
        name.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category cat;
  final int? selectedCategoryId;
  final ValueChanged<int> onSelected;

  const _CategoryItem({
    required this.cat,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selected = cat.id == selectedCategoryId;
    final harmonized = harmonizeCategory(context, Color(cat.colorValue));

    return GestureDetector(
      onTap: () => onSelected(cat.id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: harmonized.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: selected
                  ? Border.all(
                      color: harmonized,
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              IconMapper.fromString(cat.icon),
              color: harmonized,
              size: 28,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            cat.name,
            style: textTheme.labelSmall?.copyWith(
              color: selected ? cs.onSurface : cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
