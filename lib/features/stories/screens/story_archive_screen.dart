import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../core/constants/info_constants.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../models/story_icons.dart';
import '../models/story_models.dart';
import '../providers/story_providers.dart';
import '../widgets/story_viewer.dart';

class StoryArchiveScreen extends ConsumerStatefulWidget {
  const StoryArchiveScreen({super.key});

  @override
  ConsumerState<StoryArchiveScreen> createState() => _StoryArchiveScreenState();
}

class _StoryArchiveScreenState extends ConsumerState<StoryArchiveScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      ref.read(archiveStoriesProvider.notifier).loadMore();
    }
  }

  void _open(List<StoryViewData> stories, StoryViewData story) {
    final index = stories.indexOf(story);
    // The archive is a flat history, so each story is its own single-story
    // bubble; the viewer then advances sequentially through them.
    final bubbles = [
      for (final s in stories)
        StoryBubble(
          type: s.type,
          label: s.label,
          icon: s.icon,
          color: s.color,
          stories: [s],
        ),
    ];
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewer(
          bubbles: bubbles,
          initialBubbleIndex: index < 0 ? 0 : index,
          onSeen: (id, slideIndex) {
            ref
                .read(archiveStoriesProvider.notifier)
                .markSeen(int.parse(id), slideIndex);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final archive = ref.watch(archiveStoriesProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: archive.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (state) {
          final groups = _grouped(context, state.stories);
          return CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  title: context.l10n.storiesArchiveTitle,
                  infoConfig: InfoConstants.storiesArchive,
                ),
              ),
              if (state.stories.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Center(
                      child: KuberEmptyState(
                        title: context.l10n.noStoriesYet,
                        description: context.l10n.keepUsingToSeeRecaps,
                        icon: Icons.auto_awesome_outlined,
                      ),
                    ),
                  ),
                )
              else ...[
                for (final entry in groups.entries) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KuberSpace.screenMargin,
                        KuberSpace.md,
                        KuberSpace.screenMargin,
                        0,
                      ),
                      child: KuberSectionHeader(title: entry.key),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KuberSpace.screenMargin,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: KuberSpace.sm,
                            crossAxisSpacing: KuberSpace.sm,
                            mainAxisExtent: 136,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ArchiveCard(
                          story: entry.value[index],
                          onTap: () => _open(state.stories, entry.value[index]),
                        ),
                        childCount: entry.value.length,
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    child: state.hasMore
                        ? _LoadingFooter(cs: cs)
                        : const SizedBox(height: 8),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Map<String, List<StoryViewData>> _grouped(
    BuildContext context,
    List<StoryViewData> stories,
  ) {
    final out = <String, List<StoryViewData>>{};
    for (final story in stories) {
      (out[_bucketLabel(context, story.generatedAt)] ??= []).add(story);
    }
    return out;
  }

  String _bucketLabel(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return context.l10n.todayLabel;
    if (diff == 1) return context.l10n.yesterdayLabel;
    if (diff <= 6) return context.l10n.earlierThisWeek;
    if (diff <= 30) return context.l10n.earlierThisMonth;
    return context.l10n.olderLabel;
  }
}

/// Story card (board 3.27): tinted cover with the story glyph, then kind
/// (caps), title and date. Unseen stories carry the primary dot.
class _ArchiveCard extends StatelessWidget {
  final StoryViewData story;
  final VoidCallback onTap;

  const _ArchiveCard({required this.story, required this.onTap});

  static String _kind(String type) => switch (type) {
    'recap_day' => 'DAILY',
    'recap_week' => 'WEEKLY',
    'recap_month' => 'MONTHLY',
    'recap_year' => 'YEARLY',
    _ => type.replaceAll('_', ' ').toUpperCase(),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tones = categoryTones(context, StoryPalette.ring[story.color]!);
    return Material(
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.cardR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ColoredBox(
                color: tones.container,
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        storyIcon(story.icon),
                        size: 28,
                        color: tones.fg,
                      ),
                    ),
                    if (!story.seen)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: tones.container,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _kind(story.type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.labelSmall!.copyWith(
                      letterSpacing: 0.8,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    story.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall!.copyWith(color: cs.onSurface),
                  ),
                  Text(
                    story.timeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingFooter extends StatelessWidget {
  final ColorScheme cs;
  const _LoadingFooter({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
        ),
        const SizedBox(width: 8),
        Text(
          context.l10n.loadingOlderStories,
          style: AppTextStyles.inter.copyWith(
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
