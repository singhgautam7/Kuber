import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
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
  Timer? _debounce;

  @override
  Future<List<StoryViewData>> build() async {
    final repo = ref.watch(storyRepositoryProvider);
    _sub?.cancel();
    // Coalesce bursts of collection writes (a generation pass writes several
    // rows; marking slides seen writes one per slide) into a single rebuild,
    // so we don't re-query and re-decode every active payload on each write.
    _sub = repo.watchLazy().listen((_) {
      _debounce?.cancel();
      _debounce = Timer(
        const Duration(milliseconds: 300),
        ref.invalidateSelf,
      );
    });
    ref.onDispose(() {
      _sub?.cancel();
      _debounce?.cancel();
    });

    final existing = await repo.listActive(DateTime.now());
    if (existing.isNotEmpty) {
      // Stories already exist: show them immediately and refresh in the
      // background. Deterministic keys mean nothing is duplicated.
      unawaited(_generateIfNeeded());
      return _mapAndSort(existing);
    }

    // Nothing to show yet (first-ever generation, or every story expired).
    // Await generation so the ring keeps its skeleton instead of flashing the
    // empty-state and then popping to content once generation finishes. If the
    // user genuinely has nothing to recap, this still resolves to an empty list
    // and the ring shows its empty-state.
    await _generateIfNeeded();
    final stories = await repo.listActive(DateTime.now());
    return _mapAndSort(stories);
  }

  Future<void> _generateIfNeeded() async {
    // Best-effort: a generation failure (including an error on the background
    // isolate) must never break the ring or the home. On failure we simply
    // fall back to whatever stories already exist.
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastGen = prefs.getString(PrefsKeys.lastStoryGenerationDate);
      final today = DateTime.now().toIso8601String().split('T').first;
      if (lastGen == today) return;

      final service = StoryGenerationService(ref.read(isarProvider));
      await service.generateMissingNow();

      final allStories = await ref
          .read(storyRepositoryProvider)
          .listActive(DateTime.now());
      if (allStories.isNotEmpty) {
        await prefs.setString(PrefsKeys.lastStoryGenerationDate, today);
      }
    } catch (e, st) {
      debugPrint('Kuber: story generation failed (non-fatal): $e\n$st');
    }
  }

  Future<void> markSeen(int id, int slideIndex) async {
    await ref.read(storyRepositoryProvider).markSeen(id, slideIndex);
    // Reflect the change in place instead of invalidating (which would re-query
    // and re-decode every active payload). The debounced watchLazy listener
    // still reconciles against the database shortly after.
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData([
      for (final s in current) s.id == id ? _markSlideSeen(s, slideIndex) : s,
    ]);
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
    // Update in place so already-loaded pages are not dropped and we avoid
    // re-decoding the whole list.
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        stories: [
          for (final s in current.stories)
            s.id == id ? _markSlideSeen(s, slideIndex) : s,
        ],
      ),
    );
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

StoryViewData _markSlideSeen(StoryViewData s, int slideIndex) {
  if (s.seenSlides.contains(slideIndex)) return s;
  return StoryViewData(
    id: s.id,
    storyKey: s.storyKey,
    type: s.type,
    label: s.label,
    icon: s.icon,
    color: s.color,
    timeLabel: s.timeLabel,
    generatedAt: s.generatedAt,
    expiresAt: s.expiresAt,
    seenAt: DateTime.now(),
    seenSlides: [...s.seenSlides, slideIndex],
    slides: s.slides,
  );
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
