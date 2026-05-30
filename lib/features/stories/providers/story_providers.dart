import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/utils/prefs_keys.dart';
import '../data/insight_story.dart';
import '../data/story_repository.dart';
import '../models/story_models.dart';
import '../services/story_generation_service.dart';

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository(ref.watch(isarProvider));
});

class StoriesNotifier extends AsyncNotifier<List<StoryViewData>> {
  StreamSubscription<void>? _sub;

  @override
  Future<List<StoryViewData>> build() async {
    final repo = ref.watch(storyRepositoryProvider);
    _sub?.cancel();
    _sub = repo.watchLazy().listen((_) => ref.invalidateSelf());
    ref.onDispose(() => _sub?.cancel());

    _generateStoriesInBackground();

    final stories = await repo.listActive(DateTime.now());
    return _mapAndSort(stories);
  }

  void _generateStoriesInBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final lastGen = prefs.getString(PrefsKeys.lastStoryGenerationDate);
    final today = DateTime.now().toIso8601String().split('T').first;
    
    if (lastGen != today) {
      final isar = ref.read(isarProvider);
      final service = StoryGenerationService(isar);
      await service.generateMissingNow();
      
      final repo = ref.read(storyRepositoryProvider);
      final allStories = await repo.listActive(DateTime.now());
      if (allStories.isNotEmpty) {
        await prefs.setString(PrefsKeys.lastStoryGenerationDate, today);
      }
    }
  }

  Future<void> markSeen(int id, int slideIndex) async {
    await ref.read(storyRepositoryProvider).markSeen(id, slideIndex);
    ref.invalidateSelf();
  }
}

final storiesProvider =
    AsyncNotifierProvider<StoriesNotifier, List<StoryViewData>>(
      StoriesNotifier.new,
    );

class ArchiveStoriesState {
  final List<StoryViewData> stories;
  final bool hasMore;
  final bool loadingMore;

  const ArchiveStoriesState({
    this.stories = const [],
    this.hasMore = true,
    this.loadingMore = false,
  });

  ArchiveStoriesState copyWith({
    List<StoryViewData>? stories,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return ArchiveStoriesState(
      stories: stories ?? this.stories,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class ArchiveStoriesNotifier extends AsyncNotifier<ArchiveStoriesState> {
  static const _pageSize = 30;

  @override
  Future<ArchiveStoriesState> build() async {
    final rows = await ref
        .watch(storyRepositoryProvider)
        .listArchive(offset: 0, limit: _pageSize);
    return ArchiveStoriesState(
      stories: rows.map(_toViewData).toList(),
      hasMore: rows.length == _pageSize,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    final rows = await ref
        .read(storyRepositoryProvider)
        .listArchive(offset: current.stories.length, limit: _pageSize);
    state = AsyncData(
      ArchiveStoriesState(
        stories: [...current.stories, ...rows.map(_toViewData)],
        hasMore: rows.length == _pageSize,
      ),
    );
  }

  Future<void> markSeen(int id, int slideIndex) async {
    await ref.read(storyRepositoryProvider).markSeen(id, slideIndex);
    ref.invalidateSelf();
  }
}

final archiveStoriesProvider =
    AsyncNotifierProvider<ArchiveStoriesNotifier, ArchiveStoriesState>(
      ArchiveStoriesNotifier.new,
    );

List<StoryViewData> _mapAndSort(List<InsightStory> rows) {
  final stories = rows.map(_toViewData).toList();
  stories.sort((a, b) {
    final aDay = DateTime(
      a.generatedAt.year,
      a.generatedAt.month,
      a.generatedAt.day,
    );
    final bDay = DateTime(
      b.generatedAt.year,
      b.generatedAt.month,
      b.generatedAt.day,
    );
    final dayCompare = bDay.compareTo(aDay);
    if (dayCompare != 0) return dayCompare;
    if (a.seen != b.seen) return a.seen ? 1 : -1;
    return b.generatedAt.compareTo(a.generatedAt);
  });
  return stories;
}

StoryViewData _toViewData(InsightStory story) {
  final slides = ((jsonDecode(story.payloadJson) as List?) ?? [])
      .map((e) => StorySlide.fromJson(e as Map<String, dynamic>))
      .toList();
  final meta = _metaForType(story.type, slides);
  return StoryViewData(
    id: story.id,
    storyKey: story.storyKey,
    type: story.type,
    label: meta.label,
    icon: meta.icon,
    color: meta.color,
    timeLabel: _timeAgo(story.generatedAt),
    generatedAt: story.generatedAt,
    expiresAt: story.expiresAt,
    seenAt: story.seenAt,
    seenSlides: List<int>.from(story.seenSlides),
    slides: slides,
  );
}

({String label, String icon, StoryColorKey color}) _metaForType(
  String type,
  List<StorySlide> slides,
) {
  if (type == 'recap_day') {
    return (label: 'Yesterday', icon: 'calendar', color: StoryColorKey.blue);
  }
  if (type == 'recap_week') {
    return (label: 'This Week', icon: 'chart', color: StoryColorKey.violet);
  }
  if (type == 'recap_month') {
    return (label: 'This Month', icon: 'calendar', color: StoryColorKey.amber);
  }
  if (type == 'recap_year') {
    return (label: 'This Year', icon: 'trophy', color: StoryColorKey.gold);
  }
  if (type == 'loans') {
    return (label: 'Loans', icon: 'loan', color: StoryColorKey.cyan);
  }
  if (type == 'investments') {
    return (
      label: 'Investments',
      icon: 'investment',
      color: StoryColorKey.blue,
    );
  }
  if (type == 'ledger') {
    return (label: 'Ledger', icon: 'ledger', color: StoryColorKey.slate);
  }
  final slide = slides.isEmpty ? null : slides.first;
  return (
    label: 'Insights',
    icon: slide?.icon ?? 'sparkle',
    color: slide?.background ?? StoryColorKey.violet,
  );
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.day}/${date.month}/${date.year}';
}
