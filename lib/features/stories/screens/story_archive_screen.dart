import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../core/constants/info_constants.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
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
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => StoryViewer(
          stories: stories,
          initialIndex: index < 0 ? 0 : index,
          onSeen: (id, slideIndex) {
            ref.read(archiveStoriesProvider.notifier).markSeen(int.parse(id), slideIndex);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeOutCubic));
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
          final groups = _grouped(state.stories);
          return CustomScrollView(
            controller: _scroll,
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  showHome: true,
                  title: '',
                  infoConfig: InfoConstants.storiesArchive,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stories\nArchive',
                        style: AppTextStyles.inter.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Every recap Kuber has made for you, newest first.',
                        style: AppTextStyles.inter.copyWith(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.stories.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 120),
                    child: Center(
                      child: KuberEmptyState(
                        title: 'No stories yet',
                        description: 'Keep using Kuber to see your recaps here.',
                        icon: Icons.auto_awesome_outlined,
                      ),
                    ),
                  ),
                )
              else ...[
                for (final entry in groups.entries) ...[
                  SliverToBoxAdapter(child: _DateHeader(label: entry.key)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 3 / 4.4,
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

  Map<String, List<StoryViewData>> _grouped(List<StoryViewData> stories) {
    final out = <String, List<StoryViewData>>{};
    for (final story in stories) {
      (out[_bucketLabel(story.generatedAt)] ??= []).add(story);
    }
    return out;
  }

  String _bucketLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff <= 6) return 'Earlier this week';
    if (diff <= 30) return 'Earlier this month';
    return 'Older';
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.inter.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(height: 1, color: cs.outline)),
        ],
      ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  final StoryViewData story;
  final VoidCallback onTap;

  const _ArchiveCard({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = StoryPalette.background[story.color]!;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: story.seen ? 0.82 : 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          child: Container(
            color: bg,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.28),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                        stops: const [0, 0.38, 1],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          storyIcon(story.icon),
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.inter.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            story.timeLabel,
                            style: AppTextStyles.inter.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 11,
                  right: 11,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: story.seen ? Colors.transparent : Colors.white,
                      border: story.seen
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 1.5,
                            )
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 9,
                  right: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(KuberRadius.full),
                    ),
                    child: Text(
                      '${story.slides.length}',
                      style: AppTextStyles.inter.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          'Loading older stories',
          style: AppTextStyles.inter.copyWith(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
