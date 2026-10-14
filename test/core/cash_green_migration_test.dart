import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/migrations.dart';
import 'package:kuber/core/database/seed_service.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  setUpAll(() async => initialiseIsarForTests());
  setUp(() async {
    isar = await openTestIsar();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async => closeAndCleanIsar(isar));

  test('default-grey Cash goes green once; picked colours stay', () async {
    Account a(String name, String type, int color) => Account()
      ..name = name
      ..type = type
      ..colorValue = color;
    final ids = await isar.writeTxn(() => isar.accounts.putAll([
      a('Cash', 'cash', 0xFF9E9E9E),
      a('Wallet', 'cash', 0xFFE91E63), // user picked pink
      a('Bank', 'bank', 0xFF9E9E9E), // not cash
    ]));
    await MigrationService.runAll(isar);
    final got = await isar.accounts.getAll(ids);
    expect(got[0]!.colorValue, SeedService.cashGreen);
    expect(got[1]!.colorValue, 0xFFE91E63);
    expect(got[2]!.colorValue, 0xFF9E9E9E);

    // Runs once: a user who later picks grey keeps it.
    await isar.writeTxn(() => isar.accounts.put(got[0]!..colorValue = 0xFF9E9E9E));
    await MigrationService.runAll(isar);
    expect((await isar.accounts.get(ids[0]))!.colorValue, 0xFF9E9E9E);
  });
}
