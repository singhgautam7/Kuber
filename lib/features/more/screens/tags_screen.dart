import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../tags/data/tag.dart';
import '../../tags/providers/tag_providers.dart';
import '../../tags/widgets/tag_bottom_sheets.dart';

class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  void _openAddTagSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => const AddEditTagBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        ),
        data: (tags) => _TagsBody(tags: tags, onAdd: () => _openAddTagSheet(context)),
      ),
    );
  }
}

class _TagsBody extends StatelessWidget {
  final List<Tag> tags;
  final VoidCallback onAdd;

  const _TagsBody({required this.tags, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: KuberAppBar(showBack: true, title: 'Tags'),
        ),
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
                        'Manage\nTags',
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
                        'Organize transactions with custom labels.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: cs.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (tags.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.sell_outlined,
              title: 'No tags yet',
              description: 'Create hashtags to track specific expenses.',
              actionLabel: 'Add Tag',
              onAction: onAdd,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: tags.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _TagListItem(tag: tags[index]);
              },
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(height: navBarBottomPadding(context) + 24),
        ),
      ],
    );
  }
}

class _TagListItem extends ConsumerWidget {
  final Tag tag;
  const _TagListItem({required this.tag});

  void _openTagDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => ViewTagBottomSheet(tag: tag),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _openTagDetail(context),
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: tag.isEnabled ? cs.outline : cs.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Text(
              "#",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: tag.isEnabled ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: tag.isEnabled ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  if (!tag.isEnabled)
                    Text(
                      "Disabled",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: cs.error.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

