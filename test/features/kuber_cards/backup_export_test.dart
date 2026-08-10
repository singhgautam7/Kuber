import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/kuber_cards/data/card_crypto.dart';
import 'package:kuber/features/kuber_cards/data/card_vault_service.dart';

import '../../helpers/isar_test_helper.dart';

const _fastSpec = KdfSpec(
  algorithm: 'pbkdf2',
  memoryKb: 0,
  iterations: 500,
  parallelism: 1,
);

void main() {
  late Isar isar;

  setUpAll(initialiseIsarForTests);
  setUp(() async => isar = await openTestIsar());
  tearDown(() async => closeAndCleanIsar(isar));

  test('exportJson completes with a vault + card', () async {
    final service = CardVaultService(isar);
    final key = await service.setupVault(pin: '1234', pinLength: 4, spec: _fastSpec);
    await service.saveCard(
        key: key, input: CardInput(nickname: 'X', number: '4111111111111234'));

    final json = await JsonBackupService()
        .exportJson(isar)
        .timeout(const Duration(seconds: 15));
    expect(json, contains('storedCards'));
    expect(json, contains('cardVaultMeta'));
  });

  test('exportJson completes with no vault', () async {
    final json = await JsonBackupService()
        .exportJson(isar)
        .timeout(const Duration(seconds: 15));
    expect(json, contains('storedCards'));
  });
}
