import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/migrations.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  setUpAll(() async => initialiseIsarForTests());
  setUp(() async => isar = await openTestIsar());
  tearDown(() async => closeAndCleanIsar(isar));

  test('installed users move to the classic More layout once', () async {
    SharedPreferences.setMockInitialValues({
      PrefsKeys.moreTabLayout: MoreTabLayout.modern.index,
    });
    await MigrationService.runAll(isar);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(PrefsKeys.moreTabLayout), MoreTabLayout.simple.index);

    // A later choice survives the next launch.
    await prefs.setInt(PrefsKeys.moreTabLayout, MoreTabLayout.modern.index);
    await MigrationService.runAll(isar);
    expect(prefs.getInt(PrefsKeys.moreTabLayout), MoreTabLayout.modern.index);
  });
}
