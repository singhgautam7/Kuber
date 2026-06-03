import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';
import '../data/insight_story.dart';
import '../data/story_repository.dart';
import '../models/story_models.dart';
import 'story_keys.dart';
import 'story_ttl.dart';

/// Builds the one-shot Welcome story shown only to first-time users. Static
/// payload — no aggregation, no DB reads — so it is cheap enough to insert
/// synchronously before the first frame on a fresh install.
///
/// The bubble/ring colour is plum (`_metaForType`); the four slides cycle the
/// palette (plum -> blue -> emerald -> amber) for a refreshing intro. Welcome is
/// the only story allowed to vary `background` slide to slide.
InsightStory buildWelcomeStory(DateTime now) {
  const slides = <StorySlide>[
    StorySlide(
      variant: SlideVariant.statement,
      background: StoryColorKey.plum,
      icon: 'sparkle',
      header: 'Welcome',
      title: 'Welcome to Kuber',
      subtitle: 'Thanks for installing. Your money, beautifully tracked.',
      emphasis: [Emphasis('Kuber', EmphasisStyle.primary)],
    ),
    StorySlide(
      variant: SlideVariant.statement,
      background: StoryColorKey.blue,
      icon: 'wallet',
      header: 'The basics',
      title: 'Track every rupee',
      subtitle: 'Expenses, income, transfers, and budgets, all in one place.',
    ),
    StorySlide(
      variant: SlideVariant.statement,
      background: StoryColorKey.emerald,
      icon: 'savings',
      header: 'Beyond the basics',
      title: 'There is more in here',
      subtitle: 'Lend and borrow, EMIs, investments, and handy calculators.',
    ),
    StorySlide(
      variant: SlideVariant.statement,
      background: StoryColorKey.amber,
      icon: 'chart',
      header: 'This space is yours',
      title: 'Your money stories',
      subtitle:
          'Recaps and highlights about your spending will appear right here.',
    ),
  ];

  return InsightStory()
    ..storyKey = StoryKeys.welcome
    ..type = 'welcome'
    ..generatedAt = now
    ..expiresAt = now.add(kStoryTtl)
    ..payloadJson = jsonEncode(slides.map((s) => s.toJson()).toList());
}

/// Seeds the Welcome story for genuinely-new users, synchronously at bootstrap
/// so a fresh install sees something in the ring on the first frame.
///
/// - Fresh user (no stories AND flag unset): insert Welcome, then set the flag.
/// - Upgrader (already has stories, flag unset): set the flag silently so the
///   Welcome never appears for an existing user.
/// - Flag already set: no-op.
Future<void> maybeSeedWelcomeStory(Isar isar, {DateTime? now}) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(PrefsKeys.welcomeStoryGenerated) ?? false) return;

  final repo = StoryRepository(isar);
  final isFresh = await repo.count() == 0;
  if (isFresh) {
    await repo.putAll([buildWelcomeStory(now ?? DateTime.now())]);
  }
  await prefs.setBool(PrefsKeys.welcomeStoryGenerated, true);
  debugPrint('Kuber welcome: maybeSeed (fresh=$isFresh) -> seeded=$isFresh');
}

/// Unconditionally (re)seeds the Welcome story, replacing any existing one and
/// resetting the flag. Used on a full data reset (Clear All Data) so the Welcome
/// bubble reliably reappears regardless of the previous flag/state.
Future<void> reseedWelcomeStory(Isar isar, {DateTime? now}) async {
  final repo = StoryRepository(isar);
  final story = buildWelcomeStory(now ?? DateTime.now());
  final existing = await repo.byKey(StoryKeys.welcome);
  if (existing != null) story.id = existing.id; // overwrite in place
  await repo.putAll([story]);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(PrefsKeys.welcomeStoryGenerated, true);
  debugPrint('Kuber welcome: reseeded (force)');
}
