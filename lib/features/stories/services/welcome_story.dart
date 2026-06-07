import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/locale_font.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../l10n/app_localizations.dart';
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
  final l10n = lookupAppLocalizations(AppLocale.current);
  final slides = <StorySlide>[
    StorySlide(
      variant: SlideVariant.statement,
      background: StoryColorKey.plum,
      icon: 'sparkle',
      header: l10n.welcomeHeader,
      title: l10n.welcomeTitle,
      subtitle: l10n.welcomeSubtitle,
      emphasis: const [Emphasis('Kuber', EmphasisStyle.primary)],
    ),
    StorySlide(
      variant: SlideVariant.statement,
      background: StoryColorKey.blue,
      icon: 'wallet',
      header: l10n.basicsHeader,
      title: l10n.basicsTitle,
      subtitle: l10n.basicsSubtitle,
    ),
    StorySlide(
      variant: SlideVariant.statement,
      background: StoryColorKey.emerald,
      icon: 'savings',
      header: l10n.beyondBasicsHeader,
      title: l10n.beyondBasicsTitle,
      subtitle: l10n.beyondBasicsSubtitle,
    ),
    StorySlide(
      variant: SlideVariant.statement,
      background: StoryColorKey.amber,
      icon: 'chart',
      header: l10n.spaceIsYoursHeader,
      title: l10n.spaceIsYoursTitle,
      subtitle: l10n.spaceIsYoursSubtitle,
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
