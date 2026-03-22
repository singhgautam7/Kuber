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
    final textTheme = Theme.of(context).textTheme;
    final categories = ref.watch(categoryListProvider);

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
                    color: KuberColors.textSecondary,
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
                      color: KuberColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: KuberColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.md),

              // Search field
              TextField(
                controller: _searchController,
                style: textTheme.bodyMedium?.copyWith(
                  color: KuberColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search categories',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: KuberColors.textSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: KuberColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: KuberColors.surfaceMuted,
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              ),
              const SizedBox(height: KuberSpacing.lg),
            ],
          ),
        ),

        // Category grid
        Flexible(
          child: categories.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Center(
              child: Text('Error: $e'),
            ),
            data: (cats) {
              // Filter by search query
              var filtered = _query.isEmpty
                  ? cats
                  : cats
                      .where(
                        (c) => c.name.toLowerCase().contains(_query),
                      )
                      .toList();

              // Filter by transaction type
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
                        color: KuberColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: KuberSpacing.md,
                  crossAxisSpacing: KuberSpacing.md,
                  childAspectRatio: 0.8,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final cat = filtered[index];
                  final selected =
                      cat.id == widget.selectedCategoryId;
                  final harmonized =
                      harmonizeCategory(context, Color(cat.colorValue));

                  return GestureDetector(
                    onTap: () => widget.onSelected(cat.id),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: harmonized.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(KuberRadius.md),
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
                            color: selected
                                ? KuberColors.textPrimary
                                : KuberColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
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
