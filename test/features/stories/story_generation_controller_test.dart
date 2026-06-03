import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/stories/providers/story_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(initialiseIsarForTests);

  test('generation failure is swallowed and isGenerating resets', () async {
    SharedPreferences.setMockInitialValues({});
    final isar = await openTestIsar();
    final container = ProviderContainer(
      overrides: [isarProvider.overrideWithValue(isar)],
    );
    addTearDown(container.dispose);

    // Closing the DB makes the generation pass throw on its first query, which
    // must be caught so the home/ring never sees the error.
    await isar.close(deleteFromDisk: true);

    await container.read(storyGenerationProvider.notifier).ensureGenerated();

    expect(container.read(storyGenerationProvider), isFalse);
  });
}
