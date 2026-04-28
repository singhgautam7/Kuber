import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../tags/data/tag.dart';
import '../../tags/providers/tag_providers.dart';
import '../../tags/widgets/tag_bottom_sheets.dart';
import '../../../core/constants/info_constants.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../settings/providers/info_provider.dart';

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

    // Auto-trigger info sheet
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoTags), (prev, next) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.tags);
          ref.read(infoSeenProvider(PrefsKeys.seenInfoTags).notifier).markSeen();
        });
      }
    });

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

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: KuberAppBar(
            showBack: true,
            showHome: true,
            title: '',
            infoConfig: InfoConstants.tags,
          ),
        ),
        SliverToBoxAdapter(
          child: KuberPageHeader(
            title: 'Manage\nTags',
            description: 'Organize transactions with custom labels.',
            actionTooltip: 'Add Tag',
            onAction: onAdd,
          ),
        ),
        if (tags.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: KuberEmptyState(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, _) {
                final countAsync = ref.watch(tagTransactionCountProvider(tag.id));
                return countAsync.when(
                  data: (count) => Text(
                    count == 0 ? 'No transactions' : '$count transactions',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

