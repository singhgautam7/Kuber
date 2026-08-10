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

/// A backup made on "device 1" with PIN 1234, carrying one encrypted card.
Future<String> _makeBackupWithCard(Isar isar) async {
  final service = CardVaultService(isar);
  final key =
      await service.setupVault(pin: '1234', pinLength: 4, spec: _fastSpec);
  await service.saveCard(
    key: key,
    input: CardInput(nickname: 'HDFC', number: '4111111111111234'),
  );
  return JsonBackupService().exportJson(isar);
}

void main() {
  late Isar device1;
  late Isar device2;

  setUpAll(initialiseIsarForTests);
  setUp(() async {
    device1 = await openTestIsar();
    device2 = await openTestIsar();
  });
  tearDown(() async {
    await closeAndCleanIsar(device1);
    await closeAndCleanIsar(device2);
  });

  test('import restores cards in a locked state and unlocks with the old PIN',
      () async {
    final backup = await _makeBackupWithCard(device1);

    // Restore onto a fresh device.
    await JsonBackupService().importJson(device2, backup);

    final service2 = CardVaultService(device2);
    final meta = await service2.readMeta();
    expect(meta, isNotNull);
    expect(meta!.hasLockedImport, isTrue,
        reason: 'imported cards must arrive locked');

    final cards = await service2.allCards();
    expect(cards, hasLength(1));
    expect(cards.first.last4, '1234'); // plaintext column survives

    // Wrong PIN keeps them locked.
    final wrong = await service2.attemptUnlock('0000');
    expect(wrong.status, UnlockStatus.wrongPin);
    expect((await service2.readMeta())!.hasLockedImport, isTrue);

    // Correct old PIN unlocks, clears the locked flag, and decrypts the number.
    final ok = await service2.attemptUnlock('1234');
    expect(ok.status, UnlockStatus.success);
    expect((await service2.readMeta())!.hasLockedImport, isFalse);

    final dec = await service2.decryptCard(key: ok.key!, card: cards.first);
    expect(dec.number, '4111111111111234');
  });

  test('discardImportedVault removes the imported cards and metadata', () async {
    final backup = await _makeBackupWithCard(device1);
    await JsonBackupService().importJson(device2, backup);

    final service2 = CardVaultService(device2);
    expect(await service2.allCards(), hasLength(1));
    expect(await service2.readMeta(), isNotNull);

    await service2.discardImportedVault();

    expect(await service2.allCards(), isEmpty);
    expect(await service2.readMeta(), isNull);
  });
}
