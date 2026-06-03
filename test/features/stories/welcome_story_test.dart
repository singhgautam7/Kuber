import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/stories/data/insight_story.dart';
import 'package:kuber/features/stories/data/story_repository.dart';
import 'package:kuber/features/stories/services/story_keys.dart';
import 'package:kuber/features/stories/services/welcome_story.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Isar isar;

  setUpAll(initialiseIsarForTests);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    isar = await openTestIsar();
  });
  tearDown(() async => closeAndCleanIsar(isar));

  test('fresh install inserts the Welcome story and sets the flag', () async {
    await maybeSeedWelcomeStory(isar, now: DateTime(2026, 6, 3));

    final repo = StoryRepository(isar);
    final welcome = await repo.byKey(StoryKeys.welcome);
    expect(welcome, isNotNull);
    expect(welcome!.type, 'welcome');
    expect(welcome.expiresAt, welcome.generatedAt.add(const Duration(hours: 48)));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(PrefsKeys.welcomeStoryGenerated), isTrue);

    // Idempotent: a second call adds nothing.
    await maybeSeedWelcomeStory(isar, now: DateTime(2026, 6, 3));
    expect(await repo.count(), 1);
  });

  test('reseed force-inserts Welcome even when the flag is already set', () async {
    SharedPreferences.setMockInitialValues({
      PrefsKeys.welcomeStoryGenerated: true,
    });
    final repo = StoryRepository(isar);
    // Existing (stale) stories present, flag set — maybeSeed would do nothing.
    await repo.putAll([
      InsightStory()
        ..storyKey = 'recap_day_2026_06_02'
        ..type = 'recap_day'
        ..generatedAt = DateTime(2026, 6, 2)
        ..expiresAt = DateTime(2026, 6, 4)
        ..payloadJson = '[]',
    ]);

    await reseedWelcomeStory(isar, now: DateTime(2026, 6, 3));

    final welcome = await repo.byKey(StoryKeys.welcome);
    expect(welcome, isNotNull);
    expect(welcome!.type, 'welcome');

    // Reseeding again replaces in place — never duplicates.
    await reseedWelcomeStory(isar, now: DateTime(2026, 6, 4));
    expect(
      (await repo.all()).where((s) => s.storyKey == StoryKeys.welcome).length,
      1,
    );
  });

  test('upgrader with existing stories sets the flag, no Welcome', () async {
    final repo = StoryRepository(isar);
    await repo.putAll([
      InsightStory()
        ..storyKey = 'recap_day_2026_06_02'
        ..type = 'recap_day'
        ..generatedAt = DateTime(2026, 6, 2)
        ..expiresAt = DateTime(2026, 6, 4)
        ..payloadJson = '[]',
    ]);

    await maybeSeedWelcomeStory(isar, now: DateTime(2026, 6, 3));

    expect(await repo.byKey(StoryKeys.welcome), isNull);
    expect(await repo.count(), 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(PrefsKeys.welcomeStoryGenerated), isTrue);
  });
}
