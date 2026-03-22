import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import 'add_edit_category_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: KuberColors.background,
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) => CustomScrollView(
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
                              color: KuberColors.textPrimary,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Organize your transactions with custom categories.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: KuberColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(
                        '/category/add',
                        extra: const CategoryRouteArgs(
                            returnToCategoryPicker: false),
                      ),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: KuberColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
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

            // Category list
            if (categories.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No categories yet',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: KuberColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                ),
                sliver: SliverList.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: KuberSpacing.sm),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final color = Color(cat.colorValue);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.md,
                        vertical: KuberSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: KuberColors.surfaceCard,
                        borderRadius:
                            BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: KuberColors.border),
                      ),
                      child: Row(
                        children: [
                          CategoryIcon.square(
                            icon: IconMapper.fromString(cat.icon),
                            rawColor: color,
                            size: 40,
                          ),
                          const SizedBox(width: KuberSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: KuberColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  cat.effectiveType.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: KuberColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Edit — all categories
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: KuberColors.textSecondary,
                                size: 18),
                            onPressed: () => context.push(
                              '/category/add',
                              extra: CategoryRouteArgs(category: cat),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: KuberColors.textSecondary,
                                size: 18),
                            onPressed: () =>
                                _confirmDelete(context, ref, cat),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: navBarBottomPadding(context)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Category cat) async {
    final repo = ref.read(categoryRepositoryProvider);
    final hasTxns = await repo.hasTransactions(cat.id);

    if (!context.mounted) return;

    if (hasTxns) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: KuberColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: KuberColors.border, width: 1),
          ),
          title: Text('Cannot delete category',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: KuberColors.textPrimary,
              )),
          content: Text(
            'This category has transactions linked to it. '
            'To delete this category, delete the linked transactions first.',
            style: GoogleFonts.inter(color: KuberColors.textSecondary),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: KuberColors.primary,
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
          backgroundColor: KuberColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: KuberColors.border, width: 1),
          ),
          title: Text('Delete category?',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: KuberColors.textPrimary,
              )),
          content: Text(
            '"${cat.name}" will be permanently deleted.',
            style: GoogleFonts.inter(color: KuberColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: KuberColors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: KuberColors.expense,
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
