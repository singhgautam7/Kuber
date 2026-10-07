import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KuberShape.extraLarge),
        ),
      ),
      builder: (_) => const AddEditTagBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tagsAsync = ref.watch(tagListProvider);

    // Auto-trigger info sheet
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoTags), (
      prev,
      next,
    ) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.tags);
          ref
              .read(infoSeenProvider(PrefsKeys.seenInfoTags).notifier)
              .markSeen();
        });
      }
    });

    return Scaffold(
      floatingActionButton: KuberExtendedFab(
        icon: Icons.add_rounded,
        label: context.l10n.addTag,
        onPressed: () => _openAddTagSheet(context),
      ),
      floatingActionButtonLocation: kuberFabLocation,
      backgroundColor: cs.surface,
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            context.l10n.errorWithDetails(e.toString()),
            style: localeFont(color: cs.onSurfaceVariant),
          ),
        ),
        data: (tags) =>
            _TagsBody(tags: tags, onAdd: () => _openAddTagSheet(context)),
      ),
    );
  }
}

class _TagsBody extends StatefulWidget {
  final List<Tag> allTags;
  final VoidCallback onAdd;

  const _TagsBody({required List<Tag> tags, required this.onAdd})
    : allTags = tags;

  @override
  State<_TagsBody> createState() => _TagsBodyState();
}

class _TagsBodyState extends State<_TagsBody> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final tags = q.isEmpty
        ? widget.allTags
        : [
            for (final t in widget.allTags)
              if (t.name.toLowerCase().contains(q)) t,
          ];
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: KuberAppBar(
            showBack: true,
            title: context.l10n.menuTags,
            infoConfig: InfoConstants.tags,
            search: widget.allTags.isEmpty
                ? null
                : KuberHeaderSearch(
                    controller: _searchController,
                    hint: context.l10n.searchTags,
                    onChanged: (v) => setState(() => _query = v),
                  ),
          ),
        ),

        if (tags.isEmpty && q.isNotEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: KuberEmptyState(
              icon: Icons.search_off_rounded,
              title: context.l10n.noMatches,
              description: context.l10n.noTagsMatch(_query.trim()),
            ),
          )
        else if (tags.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: KuberEmptyState(
              icon: Icons.sell_outlined,
              title: context.l10n.noTags,
              description: context.l10n.tagsEmptyDesc,
            ),
          )
        else
          // Board 3.17: count in the section header, one grouped list.
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpace.screenMargin,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KuberSectionHeader(
                    title: context.l10n.menuTags,
                    trailing: Text(
                      '${tags.length}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  KuberGroup(
                    children: [for (final t in tags) _TagListItem(tag: t)],
                  ),
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: KuberExtendedFab.clearance),
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
      backgroundColor: Colors.transparent,
      builder: (_) => ViewTagBottomSheet(tag: tag),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tags carry no colour of their own: tint from the categorical palette
    // by id (open decision 6), re-toned like a category tile.
    final palette = context.kuberChart.categorical;
    final tones = categoryTones(context, palette[tag.id % palette.length]);
    final countAsync = ref.watch(tagTransactionCountProvider(tag.id));
    final count = countAsync.valueOrNull;

    final row = KuberListRow(
      onTap: () => _openTagDetail(context),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tones.container,
          borderRadius: KuberShape.mediumR,
        ),
        child: Icon(Icons.sell_rounded, size: 20, color: tones.fg),
      ),
      title: '#${tag.name}',
      subtitle: count == null
          ? null
          : (count == 0
                ? context.l10n.noTransactions
                : context.l10n.nTransactions(count)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!tag.isEnabled) ...[
            KuberPill(
              label: context.l10n.disabledLabel,
              tone: KuberTone.neutral,
            ),
            const SizedBox(width: KuberSpace.sm),
          ],
          const KuberChevron(),
        ],
      ),
    );
    return tag.isEnabled ? row : Opacity(opacity: 0.38, child: row);
  }
}
