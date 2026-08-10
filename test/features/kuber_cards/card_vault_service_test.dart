import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/kuber_cards/data/card_crypto.dart';
import 'package:kuber/features/kuber_cards/data/card_vault_meta.dart';
import 'package:kuber/features/kuber_cards/data/card_vault_service.dart';
import 'package:kuber/features/kuber_cards/data/stored_card.dart';

import '../../helpers/isar_test_helper.dart';

// PBKDF2 with a low iteration count keeps these tests fast while exercising the
// exact same code paths as the production Argon2id default.
const _fastSpec = KdfSpec(
  algorithm: 'pbkdf2',
  memoryKb: 0,
  iterations: 1000,
  parallelism: 1,
);

void main() {
  late Isar isar;
  late CardVaultService service;

  setUpAll(initialiseIsarForTests);
  setUp(() async {
    isar = await openTestIsar();
    service = CardVaultService(isar);
  });
  tearDown(() async => closeAndCleanIsar(isar));

  group('CardCrypto', () {
    test('same pin + salt yields the same key (portability)', () async {
      final salt = CardCrypto.newSalt();
      final k1 = await CardCrypto.deriveKey(pin: '1234', salt: salt, spec: _fastSpec);
      final k2 = await CardCrypto.deriveKey(pin: '1234', salt: salt, spec: _fastSpec);
      expect(k1, equals(k2));
    });

    test('different salt yields a different key', () async {
      final k1 = await CardCrypto.deriveKey(
          pin: '1234', salt: CardCrypto.newSalt(), spec: _fastSpec);
      final k2 = await CardCrypto.deriveKey(
          pin: '1234', salt: CardCrypto.newSalt(), spec: _fastSpec);
      expect(k1, isNot(equals(k2)));
    });

    test('encrypt -> decrypt round-trips with a fresh IV each time', () async {
      final key = CardCrypto.randomBytes(32);
      final a = await CardCrypto.encrypt(key: key, plaintext: 'hello');
      final b = await CardCrypto.encrypt(key: key, plaintext: 'hello');
      expect(a.iv, isNot(equals(b.iv))); // unique IV per encryption
      expect(await CardCrypto.decrypt(key: key, field: a), 'hello');
      expect(await CardCrypto.decrypt(key: key, field: b), 'hello');
    });

    test('wrong key fails verification, correct key passes', () async {
      final salt = CardCrypto.newSalt();
      final key = await CardCrypto.deriveKey(pin: '1234', salt: salt, spec: _fastSpec);
      final verifier =
          (await CardCrypto.encrypt(key: key, plaintext: CardCrypto.verifierSentinel))
              .toJsonString();
      final wrong = await CardCrypto.deriveKey(pin: '9999', salt: salt, spec: _fastSpec);
      expect(await CardCrypto.verify(key: key, verifierJson: verifier), isTrue);
      expect(await CardCrypto.verify(key: wrong, verifierJson: verifier), isFalse);
    });
  });

  group('setup + unlock', () {
    test('setup creates a vault; correct PIN unlocks', () async {
      expect(await service.hasVault(), isFalse);
      await service.setupVault(pin: '4321', pinLength: 4, spec: _fastSpec);
      expect(await service.hasVault(), isTrue);

      final outcome = await service.attemptUnlock('4321');
      expect(outcome.status, UnlockStatus.success);
      expect(outcome.key, isNotNull);
    });

    test('wrong PIN reports attempts left', () async {
      await service.setupVault(pin: '4321', pinLength: 4, spec: _fastSpec);
      final o1 = await service.attemptUnlock('0000');
      expect(o1.status, UnlockStatus.wrongPin);
      expect(o1.attemptsLeft, 4);
      final o2 = await service.attemptUnlock('0000');
      expect(o2.attemptsLeft, 3);
    });

    test('5 wrong attempts triggers a 5-minute cooldown', () async {
      await service.setupVault(pin: '4321', pinLength: 4, spec: _fastSpec);
      UnlockOutcome? last;
      for (var i = 0; i < 5; i++) {
        last = await service.attemptUnlock('0000');
      }
      expect(last!.status, UnlockStatus.cooldown);
      expect(last.until, isNotNull);
      // Further attempts stay blocked by the cooldown without deriving.
      final blocked = await service.attemptUnlock('4321');
      expect(blocked.status, UnlockStatus.cooldown);
    });

    test('successful unlock resets the failed streak', () async {
      await service.setupVault(pin: '4321', pinLength: 4, spec: _fastSpec);
      await service.attemptUnlock('0000');
      await service.attemptUnlock('0000');
      await service.attemptUnlock('4321'); // success resets
      final o = await service.attemptUnlock('0000');
      expect(o.attemptsLeft, 4); // streak restarted
    });
  });

  group('card CRUD + decryption', () {
    Future<List<int>> setup() =>
        service.setupVault(pin: '4321', pinLength: 4, spec: _fastSpec);

    test('save stores ciphertext, derives last4, decrypts back', () async {
      final key = await setup();
      final id = await service.saveCard(
        key: key,
        input: CardInput(
          nickname: 'HDFC Regalia',
          number: '4111 1111 1111 1234',
          cardholder: 'Asha Mehta',
          expiry: '08/28',
          cardType: 'credit',
          network: 'visa',
          customFields: [CardCustomField(label: 'Reward tier', value: 'Diamond')],
        ),
      );

      final stored = await service.cardById(id);
      expect(stored!.last4, '1234');
      expect(stored.nickname, 'HDFC Regalia');
      // Sensitive fields are NOT plaintext on disk.
      expect(stored.numberEnc, isNotNull);
      expect(stored.numberEnc, isNot(contains('4111')));
      expect(stored.cardholderEnc, isNot(contains('Asha')));

      final dec = await service.decryptCard(key: key, card: stored);
      expect(dec.number, '4111 1111 1111 1234');
      expect(dec.cardholder, 'Asha Mehta');
      expect(dec.expiry, '08/28');
      expect(dec.customFields.single.label, 'Reward tier');
      expect(dec.customFields.single.value, 'Diamond');
    });

    test('delete removes the card', () async {
      final key = await setup();
      final id = await service.saveCard(
          key: key, input: CardInput(nickname: 'X', number: '4111111111119999'));
      await service.deleteCard(id);
      expect(await service.cardById(id), isNull);
    });
  });

  group('change PIN', () {
    test('re-encrypts cards; new PIN unlocks, old PIN fails', () async {
      final key = await service.setupVault(pin: '1111', pinLength: 4, spec: _fastSpec);
      final id = await service.saveCard(
        key: key,
        input: CardInput(nickname: 'Card', number: '4111111111110000', cardholder: 'Me'),
      );

      // Force the fast spec on change too by reusing PBKDF2? changePin uses
      // Argon2 defaults, so this exercises the real KDF once (kept minimal).
      final newKey = await service.changePin(
          currentPin: '1111', newPin: '2222', newPinLength: 4);
      expect(newKey, isNotNull);

      final stored = await service.cardById(id);
      final dec = await service.decryptCard(key: newKey!, card: stored!);
      expect(dec.cardholder, 'Me');

      final ok = await service.attemptUnlock('2222');
      expect(ok.status, UnlockStatus.success);
      final bad = await service.attemptUnlock('1111');
      expect(bad.status, UnlockStatus.wrongPin);
    });

    test('wrong current PIN aborts the change', () async {
      await service.setupVault(pin: '1111', pinLength: 4, spec: _fastSpec);
      final result = await service.changePin(
          currentPin: '9999', newPin: '2222', newPinLength: 4);
      expect(result, isNull);
    });
  });

  group('backup portability', () {
    test('exported bundle carries cards + metadata', () async {
      final key =
          await service.setupVault(pin: '4321', pinLength: 4, spec: _fastSpec);
      await service.saveCard(
          key: key, input: CardInput(nickname: 'B', number: '4111111111113333'));
      final bundle =
          jsonDecode(await service.exportCardsBundle()) as Map<String, dynamic>;
      expect((bundle['storedCards'] as List).length, 1);
      expect(bundle['cardVaultMeta'], isNotNull);
      expect((bundle['cardVaultMeta'] as Map)['salt'], isNotEmpty);
    });

    test('same PIN unlocks an imported vault on another device', () async {
      // Device A: create + export.
      final key =
          await service.setupVault(pin: '4321', pinLength: 4, spec: _fastSpec);
      final id = await service.saveCard(
        key: key,
        input: CardInput(
            nickname: 'Portable', number: '4111111111114444', cardholder: 'Y'),
      );
      final bundle =
          jsonDecode(await service.exportCardsBundle()) as Map<String, dynamic>;

      // Device B: restore into a fresh database.
      final isarB = await openTestIsar();
      final serviceB = CardVaultService(isarB);
      final meta =
          CardVaultMeta.fromMap(bundle['cardVaultMeta'] as Map<String, dynamic>);
      await isarB.writeTxn(() => isarB.cardVaultMetas.put(meta));
      for (final c in bundle['storedCards'] as List) {
        await isarB.writeTxn(
            () => isarB.storedCards.put(StoredCard.fromMap(c as Map<String, dynamic>)));
      }

      // The same PIN unlocks and decrypts on device B.
      final outcome = await serviceB.attemptUnlock('4321');
      expect(outcome.status, UnlockStatus.success);
      final storedB = await serviceB.cardById(id);
      final decB = await serviceB.decryptCard(key: outcome.key!, card: storedB!);
      expect(decB.cardholder, 'Y');
      expect(decB.number, '4111111111114444');

      // A different PIN fails on device B.
      final bad = await serviceB.attemptUnlock('0000');
      expect(bad.status, UnlockStatus.wrongPin);

      await closeAndCleanIsar(isarB);
    });
  });
}
