import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/locale_font.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/add_new_button.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../more/screens/add_edit_category_screen.dart';

class CategoryPickerSheet extends ConsumerStatefulWidget {
  final int? selectedCategoryId;
  final ValueChanged<int> onSelected;
  final String? defaultType;
  final List<int>? disabledCategoryIds;

  const CategoryPickerSheet({
    super.key,
    required this.selectedCategoryId,
    required this.onSelected,
    this.defaultType,
    this.disabledCategoryIds,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final categories = ref.watch(categoryListProvider);
    final groups = ref.watch(categoryGroupListProvider);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: KuberShape.sheetR,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KuberSpace.screenMargin,
              KuberSpace.sm,
              KuberSpace.sm,
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
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: KuberShape.fullR,
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpace.lg),

                // Title row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.selectCategoryTitle,
                        style: textTheme.titleLarge?.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.close_rounded,
                      semanticLabel: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpace.md),

                // Search field
                Padding(
                  padding: const EdgeInsets.only(right: KuberSpace.md),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    style: textTheme.bodyMedium?.copyWith(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: context.l10n.searchCategories,
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: cs.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHigh,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: const OutlineInputBorder(
                        borderRadius: KuberShape.fullR,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: KuberShape.fullR,
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: KuberShape.fullR,
                        borderSide: BorderSide(color: cs.primary, width: 2),
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  ),
                ),
                const SizedBox(height: KuberSpace.lg),
              ],
            ),
          ),

          Flexible(
            child: categories.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('${context.l10n.errorLabel}: $e')),
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
                      .where(
                        (c) =>
                            c.effectiveType == 'expense' ||
                            c.effectiveType == 'both',
                      )
                      .toList();
                } else if (widget.defaultType == 'income') {
                  filtered = filtered
                      .where(
                        (c) =>
                            c.effectiveType == 'income' ||
                            c.effectiveType == 'both',
                      )
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(KuberSpace.lg),
                      child: Text(
                        context.l10n.noCategoriesFound,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: KuberSpace.screenMargin,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: KuberSpace.md,
                          crossAxisSpacing: KuberSpace.sm,
                          mainAxisExtent: 112,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _CategoryItem(
                      cat: filtered[index],
                      selectedCategoryId: widget.selectedCategoryId,
                      onSelected: widget.onSelected,
                    ),
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
                      if (grouped.containsKey(group.id) &&
                          grouped[group.id]!.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _GroupHeader(name: group.name),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: KuberSpace.screenMargin,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: KuberSpace.md,
                                  crossAxisSpacing: KuberSpace.sm,
                                  mainAxisExtent: 112,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _CategoryItem(
                                cat: grouped[group.id]![index],
                                selectedCategoryId: widget.selectedCategoryId,
                                onSelected: widget.onSelected,
                                hasBudget:
                                    widget.disabledCategoryIds?.contains(
                                      grouped[group.id]![index].id,
                                    ) ??
                                    false,
                              ),
                              childCount: grouped[group.id]!.length,
                            ),
                          ),
                        ),
                      ],
                    ],

                    // Ungrouped categories
                    if (grouped.containsKey(null) &&
                        grouped[null]!.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _GroupHeader(name: context.l10n.ungrouped),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpace.screenMargin,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: KuberSpace.md,
                                crossAxisSpacing: KuberSpace.sm,
                                mainAxisExtent: 112,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _CategoryItem(
                              cat: grouped[null]![index],
                              selectedCategoryId: widget.selectedCategoryId,
                              onSelected: widget.onSelected,
                              hasBudget:
                                  widget.disabledCategoryIds?.contains(
                                    grouped[null]![index].id,
                                  ) ??
                                  false,
                            ),
                            childCount: grouped[null]!.length,
                          ),
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(
                      child: SizedBox(height: KuberSpace.lg),
                    ),
                  ],
                );
              },
            ),
          ),

          // Add new category button
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 16,
            ),
            child: AddNewButton(
              label: context.l10n.addNewCategory,
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
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String name;

  const _GroupHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpace.screenMargin,
        KuberSpace.lg,
        KuberSpace.screenMargin,
        KuberSpace.sm,
      ),
      child: Text(name.toUpperCase(), style: sectionHeaderStyle(context)),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category cat;
  final int? selectedCategoryId;
  final ValueChanged<int> onSelected;
  final bool hasBudget;

  const _CategoryItem({
    required this.cat,
    required this.selectedCategoryId,
    required this.onSelected,
    this.hasBudget = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final selected = cat.id == selectedCategoryId;
    final tones = categoryTones(context, Color(cat.colorValue));

    return InkWell(
      onTap: () => onSelected(cat.id),
      borderRadius: KuberShape.mediumR,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: KuberSpace.xs),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: tones.container,
              borderRadius: BorderRadius.circular(KuberShape.large),
              border: selected ? Border.all(color: cs.primary, width: 2) : null,
            ),
            child: Icon(
              IconMapper.fromString(cat.icon),
              color: tones.fg,
              size: 24,
            ),
          ),
          const SizedBox(height: KuberSpace.xs),
          Text(
            cat.name,
            style: textTheme.labelMedium?.copyWith(
              color: selected ? cs.onSurface : cs.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasBudget)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: KuberPill(label: context.l10n.budgetLabel),
            ),
        ],
      ),
    );
  }
}
