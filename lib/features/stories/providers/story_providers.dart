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

/// Read-only view of the active stories for the ring/viewer. Generation is NOT
/// triggered here — it runs post-paint via [storyGenerationProvider] so the
/// home first frame is never blocked by it. As generation persists rows, the
/// debounced `watchLazy` listener invalidates this and bubbles appear
/// progressively.
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

    return _mapAndSort(await repo.listActive(DateTime.now()));
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

/// Drives story generation off the main thread, after the home first frame.
/// State is `true` while a generation pass is running so the ring can show a
/// skeleton instead of a blocking spinner. Failures are swallowed (logged) so
/// they never throw into the UI.
class StoryGenerationController extends Notifier<bool> {
  bool _ranThisSession = false;

  @override
  bool build() => false;

  /// Idempotent within a session and gated to once per calendar day. Called from
  /// the story ring's post-first-frame callback (the Welcome bubble is the only
  /// story inserted synchronously, in bootstrap).
  Future<void> ensureGenerated() async {
    if (_ranThisSession) return;
    _ranThisSession = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T').first;
      if (prefs.getString(PrefsKeys.lastStoryGenerationDate) == today) return;

      debugPrint('Kuber stories: generation start (post home first frame)');
      state = true;
      await StoryGenerationService(ref.read(isarProvider)).generateDue();
      await prefs.setString(PrefsKeys.lastStoryGenerationDate, today);
    } catch (e, st) {
      // Best-effort: the ring keeps whatever stories already exist.
      debugPrint('Kuber: story generation failed (non-fatal): $e\n$st');
    } finally {
      if (state) state = false;
    }
  }

  /// Forces a fresh generation pass now, bypassing the once-per-session and
  /// once-per-day gates. Used after data changes (mock data, clear, import) so
  /// stories reflect the new data without waiting for an app restart.
  Future<void> regenerate() async {
    try {
      state = true;
      await StoryGenerationService(ref.read(isarProvider)).generateDue();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        PrefsKeys.lastStoryGenerationDate,
        DateTime.now().toIso8601String().split('T').first,
      );
      _ranThisSession = true;
    } catch (e, st) {
      debugPrint('Kuber: story regeneration failed (non-fatal): $e\n$st');
    } finally {
      if (state) state = false;
    }
  }
}

final storyGenerationProvider =
    NotifierProvider<StoryGenerationController, bool>(
      StoryGenerationController.new,
    );

/// The active stories grouped into one bubble per type, in fixed ring order.
final storyBubblesProvider = Provider<AsyncValue<List<StoryBubble>>>((ref) {
  return ref.watch(storiesProvider).whenData(groupIntoBubbles);
});

/// Stable tiebreak order when two bubbles have the same read state and recency.
const _bubbleOrder = <String>[
  'welcome',
  'recap_day',
  'recap_week',
  'recap_month',
  'recap_year',
  'loans',
  'investments',
  'ledger',
  'insights',
];

/// Groups active stories by type into ring bubbles. Bubbles with any unread
/// story come first; within that, most recently generated first.
///
/// Within a bubble, stories stay in a STABLE chronological order (oldest first)
/// so positions don't shuffle as stories get read — the viewer opens the first
/// unread one (WhatsApp-style), then plays forward.
List<StoryBubble> groupIntoBubbles(List<StoryViewData> stories) {
  final byType = <String, List<StoryViewData>>{};
  for (final s in stories) {
    (byType[s.type] ??= []).add(s);
  }

  StoryBubble toBubble(String type, List<StoryViewData> group) {
    group.sort((a, b) {
      final byTime = a.generatedAt.compareTo(b.generatedAt); // oldest first
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
    final first = group.first;
    return StoryBubble(
      type: type,
      label: first.label,
      icon: first.icon,
      color: first.color,
      stories: group,
    );
  }

  DateTime latest(StoryBubble b) => b.stories
      .map((s) => s.generatedAt)
      .reduce((x, y) => x.isAfter(y) ? x : y);

  final bubbles = [for (final e in byType.entries) toBubble(e.key, e.value)];
  bubbles.sort((a, b) {
    // 1. Bubbles with any unread story first.
    if (a.seen != b.seen) return a.seen ? 1 : -1;
    // 2. Then most recently generated first.
    final byTime = latest(b).compareTo(latest(a));
    if (byTime != 0) return byTime;
    // 3. Deterministic tiebreak.
    return _bubbleOrder.indexOf(a.type).compareTo(_bubbleOrder.indexOf(b.type));
  });
  return bubbles;
}

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
  final meta = _metaForType(story.type);
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

/// Stable bubble meta per type. Labels are cadence-based (Daily/Weekly/...).
/// The bubble colour/icon is fixed per type so a bubble holding several stories
/// (e.g. several insights) reads consistently — individual slides keep their own
/// colours via their `background`.
({String label, String icon, StoryColorKey color}) _metaForType(String type) {
  switch (type) {
    case 'welcome':
      return (label: 'Welcome', icon: 'sparkle', color: StoryColorKey.plum);
    case 'recap_day':
      return (label: 'Daily', icon: 'calendar', color: StoryColorKey.blue);
    case 'recap_week':
      return (label: 'Weekly', icon: 'chart', color: StoryColorKey.violet);
    case 'recap_month':
      return (label: 'Monthly', icon: 'calendar', color: StoryColorKey.amber);
    case 'recap_year':
      return (label: 'Yearly', icon: 'trophy', color: StoryColorKey.gold);
    case 'loans':
      return (label: 'Loans', icon: 'loan', color: StoryColorKey.cyan);
    case 'investments':
      return (label: 'Investments', icon: 'investment', color: StoryColorKey.blue);
    case 'ledger':
      return (label: 'Ledger', icon: 'ledger', color: StoryColorKey.slate);
    default:
      return (label: 'Insights', icon: 'sparkle', color: StoryColorKey.violet);
  }
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.day}/${date.month}/${date.year}';
}
