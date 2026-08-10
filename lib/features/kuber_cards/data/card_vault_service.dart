import 'dart:convert';

import 'package:isar_community/isar.dart';

import 'card_crypto.dart';
import 'card_vault_meta.dart';
import 'stored_card.dart';

/// A card's editable fields (add/edit form) in plaintext. Sensitive values are
/// encrypted by [CardVaultService] before they touch Isar.
class CardInput {
  String nickname;
  String? number; // full PAN
  String? cardholder;
  String? expiry; // MM/YY
  String? cardType;
  String? network;
  String? bankIcon;
  int colorValue;
  bool isGradient;
  String? linkedAccountId;
  List<CardCustomField> customFields;

  CardInput({
    required this.nickname,
    this.number,
    this.cardholder,
    this.expiry,
    this.cardType,
    this.network,
    this.bankIcon,
    this.colorValue = 0,
    this.isGradient = false,
    this.linkedAccountId,
    List<CardCustomField>? customFields,
  }) : customFields = customFields ?? [];
}

/// A single custom field, plaintext. Used both for input and decrypted output.
class CardCustomField {
  String label;
  String value;
  CardCustomField({required this.label, required this.value});
}

/// A fully decrypted card for the detail sheet / edit screen.
class DecryptedCard {
  final int id;
  final String nickname;
  final String? last4;
  final String? bankIcon;
  final String? cardType;
  final String? network;
  final int colorValue;
  final bool isGradient;
  final String? linkedAccountId;
  final String? cardholder;
  final String? number;
  final String? expiry;
  final List<CardCustomField> customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DecryptedCard({
    required this.id,
    required this.nickname,
    required this.last4,
    required this.bankIcon,
    required this.cardType,
    required this.network,
    required this.colorValue,
    required this.isGradient,
    required this.linkedAccountId,
    required this.cardholder,
    required this.number,
    required this.expiry,
    required this.customFields,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum UnlockStatus { success, wrongPin, cooldown, dayLocked, noVault }

/// Result of an unlock attempt, carrying just enough for the UI to react.
class UnlockOutcome {
  final UnlockStatus status;
  final List<int>? key; // present only on success
  final int attemptsLeft; // for wrongPin
  final DateTime? until; // for cooldown / dayLocked

  const UnlockOutcome._(this.status,
      {this.key, this.attemptsLeft = 0, this.until});

  factory UnlockOutcome.success(List<int> key) =>
      UnlockOutcome._(UnlockStatus.success, key: key);
  factory UnlockOutcome.wrongPin(int attemptsLeft) =>
      UnlockOutcome._(UnlockStatus.wrongPin, attemptsLeft: attemptsLeft);
  factory UnlockOutcome.cooldown(DateTime until) =>
      UnlockOutcome._(UnlockStatus.cooldown, until: until);
  factory UnlockOutcome.dayLocked(DateTime until) =>
      UnlockOutcome._(UnlockStatus.dayLocked, until: until);
  factory UnlockOutcome.noVault() =>
      const UnlockOutcome._(UnlockStatus.noVault);
}

/// The Kuber Cards vault: crypto + repository. Never holds a key or PIN between
/// calls (the session provider owns the in-memory key). The one exception is the
/// derived key it returns to the caller on setup/unlock. See
/// `specs/plans/kuber-cards.md` §2, §3.
///
/// SECURITY: no method here logs a PIN, key, or decrypted field.
class CardVaultService {
  final Isar _isar;
  CardVaultService(this._isar);

  static const _maxStreak = 5; // wrong-in-a-row -> 5 min cooldown
  static const _cooldown = Duration(minutes: 5);
  static const _maxPerDay = 10; // wrong-in-24h -> day lock
  static const _dayWindow = Duration(hours: 24);

  // ── Metadata ────────────────────────────────────────────────────────────

  Future<CardVaultMeta?> readMeta() => _isar.cardVaultMetas.get(0);

  Future<bool> hasVault() async => (await readMeta()) != null;

  KdfSpec _specOf(CardVaultMeta m) => KdfSpec(
        algorithm: m.kdf,
        memoryKb: m.kdfMemoryKb,
        iterations: m.kdfIterations,
        parallelism: m.kdfParallelism,
      );

  // ── Setup ───────────────────────────────────────────────────────────────

  /// Creates the vault for a first-time PIN. Returns the derived key so the
  /// caller can open the session immediately (setup counts as unlocked).
  Future<List<int>> setupVault({
    required String pin,
    required int pinLength,
    KdfSpec spec = KdfSpec.argon2Default,
  }) async {
    final salt = CardCrypto.newSalt();
    final key = await CardCrypto.deriveKey(pin: pin, salt: salt, spec: spec);
    final verifier = await CardCrypto.encrypt(
      key: key,
      plaintext: CardCrypto.verifierSentinel,
    );

    final meta = CardVaultMeta()
      ..id = 0
      ..salt = salt
      ..kdf = spec.algorithm
      ..kdfMemoryKb = spec.memoryKb
      ..kdfIterations = spec.iterations
      ..kdfParallelism = spec.parallelism
      ..encVersion = 1
      ..pinLength = pinLength
      ..verifierEnc = verifier.toJsonString();

    await _isar.writeTxn(() => _isar.cardVaultMetas.put(meta));
    return key;
  }

  /// Flips the biometric-convenience preference on the vault metadata. The
  /// actual PIN store/clear in the Keystore is handled by the caller (UI layer),
  /// gated behind a `local_auth` check.
  Future<void> setBiometricEnabled(bool enabled) async {
    final meta = await readMeta();
    if (meta == null) return;
    meta.biometricEnabled = enabled;
    await _isar.writeTxn(() => _isar.cardVaultMetas.put(meta));
  }

  // ── Unlock + lockout ──────────────────────────────────────────────────────

  Future<UnlockOutcome> attemptUnlock(String pin) async {
    final meta = await readMeta();
    if (meta == null || meta.verifierEnc == null) {
      return UnlockOutcome.noVault();
    }
    final now = DateTime.now();

    if (meta.dayLockedUntil != null && now.isBefore(meta.dayLockedUntil!)) {
      return UnlockOutcome.dayLocked(meta.dayLockedUntil!);
    }
    if (meta.cooldownUntil != null && now.isBefore(meta.cooldownUntil!)) {
      return UnlockOutcome.cooldown(meta.cooldownUntil!);
    }

    final key =
        await CardCrypto.deriveKey(pin: pin, salt: meta.salt, spec: _specOf(meta));
    final ok = await CardCrypto.verify(key: key, verifierJson: meta.verifierEnc!);

    if (ok) {
      meta
        ..failedStreak = 0
        ..cooldownUntil = null
        ..dayLockedUntil = null
        ..failedTimestamps = []
        // A successful unlock clears any "imported and locked" state: the
        // imported cards are now decryptable and become this device's vault.
        ..hasLockedImport = false
        ..importBannerDismissed = false;
      await _isar.writeTxn(() => _isar.cardVaultMetas.put(meta));
      return UnlockOutcome.success(key);
    }
    return _recordFailure(meta, now);
  }

  /// Biometric path: unlock directly with a key retrieved from the Keystore.
  /// Verifies it against the vault verifier (guards against corruption) and
  /// clears lockout on success. Returns true if the key is valid.
  Future<bool> unlockWithKey(List<int> key) async {
    final meta = await readMeta();
    if (meta == null || meta.verifierEnc == null) return false;
    if (!await CardCrypto.verify(key: key, verifierJson: meta.verifierEnc!)) {
      return false;
    }
    meta
      ..failedStreak = 0
      ..cooldownUntil = null
      ..dayLockedUntil = null
      ..failedTimestamps = []
      ..hasLockedImport = false
      ..importBannerDismissed = false;
    await _isar.writeTxn(() => _isar.cardVaultMetas.put(meta));
    return true;
  }

  Future<UnlockOutcome> _recordFailure(CardVaultMeta meta, DateTime now) async {
    // Prune the rolling 24h window, then record this failure.
    final cutoff = now.subtract(_dayWindow);
    meta.failedTimestamps = [
      ...meta.failedTimestamps.where((t) => t.isAfter(cutoff)),
      now,
    ];
    meta.failedStreak += 1;

    UnlockOutcome outcome;
    if (meta.failedTimestamps.length >= _maxPerDay) {
      // Locked until enough of the oldest failures age out of the window.
      final until = meta.failedTimestamps.first.add(_dayWindow);
      meta.dayLockedUntil = until;
      outcome = UnlockOutcome.dayLocked(until);
    } else if (meta.failedStreak >= _maxStreak) {
      final until = now.add(_cooldown);
      meta
        ..cooldownUntil = until
        ..failedStreak = 0;
      outcome = UnlockOutcome.cooldown(until);
    } else {
      outcome = UnlockOutcome.wrongPin(_maxStreak - meta.failedStreak);
    }

    await _isar.writeTxn(() => _isar.cardVaultMetas.put(meta));
    return outcome;
  }

  // ── Export / import bundle ─────────────────────────────────────────────────

  /// A self-contained, already-encrypted `.kcards` bundle: card records plus the
  /// vault metadata (salt + KDF params + verifier) needed to unlock them with the
  /// same PIN on any device. Field values are ciphertext, so no extra wrapping.
  Future<String> exportCardsBundle() async {
    final cards = await _isar.storedCards.where().findAll();
    final meta = await readMeta();
    return jsonEncode({
      'version': 1,
      'kind': 'kuber-cards',
      'exportedAt': DateTime.now().toIso8601String(),
      'storedCards': cards.map((c) => c.toMap()).toList(),
      'cardVaultMeta': meta?.toMap(),
    });
  }

  // ── Card CRUD (repository) ────────────────────────────────────────────────

  /// Ordered most-recently-updated first (same convention as accounts). This is
  /// what the home list watches; it needs no key.
  Future<List<StoredCard>> allCards() =>
      _isar.storedCards.where().sortByUpdatedAtDesc().findAll();

  Future<StoredCard?> cardById(int id) => _isar.storedCards.get(id);

  Future<int> saveCard({
    required List<int> key,
    required CardInput input,
    StoredCard? existing,
  }) async {
    final card = existing ?? StoredCard();
    final now = DateTime.now();

    card
      ..nickname = input.nickname.trim()
      ..last4 = _deriveLast4(input.number)
      ..bankIcon = input.bankIcon
      ..cardType = input.cardType
      ..network = input.network
      ..colorValue = input.colorValue
      ..isGradient = input.isGradient
      ..linkedAccountId = input.linkedAccountId
      ..updatedAt = now;
    if (existing == null) card.createdAt = now;

    card.cardholderEnc = await _encOrNull(key, input.cardholder);
    card.numberEnc = await _encOrNull(key, input.number);
    card.expiryEnc = await _encOrNull(key, input.expiry);
    card.customFieldsEnc = await _encryptCustomFields(key, input.customFields);

    return _isar.writeTxn(() => _isar.storedCards.put(card));
  }

  Future<void> deleteCard(int id) =>
      _isar.writeTxn(() => _isar.storedCards.delete(id));

  /// Drops an imported-but-locked vault: deletes every restored card and the
  /// imported metadata. Used when the user declines to unlock backup cards on
  /// import (the rest of the imported data is kept). See `import-flow.md`.
  Future<void> discardImportedVault() async {
    await _isar.writeTxn(() async {
      await _isar.storedCards.clear();
      await _isar.cardVaultMetas.clear();
    });
  }

  Future<DecryptedCard> decryptCard({
    required List<int> key,
    required StoredCard card,
  }) async {
    return DecryptedCard(
      id: card.id,
      nickname: card.nickname,
      last4: card.last4,
      bankIcon: card.bankIcon,
      cardType: card.cardType,
      network: card.network,
      colorValue: card.colorValue,
      isGradient: card.isGradient,
      linkedAccountId: card.linkedAccountId,
      cardholder: await _decOrNull(key, card.cardholderEnc),
      number: await _decOrNull(key, card.numberEnc),
      expiry: await _decOrNull(key, card.expiryEnc),
      customFields: await _decryptCustomFields(key, card.customFieldsEnc),
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
    );
  }

  // ── Change PIN (re-encrypt everything under the new key) ────────────────────

  /// Verifies [currentPin], then re-encrypts every card + verifier under a key
  /// derived from [newPin]. Keeps the same salt for cross-device portability.
  /// Returns the new key on success, or null if the current PIN is wrong.
  Future<List<int>?> changePin({
    required String currentPin,
    required String newPin,
    required int newPinLength,
  }) async {
    final meta = await readMeta();
    if (meta == null || meta.verifierEnc == null) return null;

    final oldKey = await CardCrypto.deriveKey(
        pin: currentPin, salt: meta.salt, spec: _specOf(meta));
    if (!await CardCrypto.verify(key: oldKey, verifierJson: meta.verifierEnc!)) {
      return null;
    }

    // Same salt; keep Argon2 defaults for the new key.
    const spec = KdfSpec.argon2Default;
    final newKey =
        await CardCrypto.deriveKey(pin: newPin, salt: meta.salt, spec: spec);

    // Re-encrypt every card off-transaction (crypto is async), then write once.
    final cards = await _isar.storedCards.where().findAll();
    for (final c in cards) {
      final dec = await decryptCard(key: oldKey, card: c);
      c
        ..cardholderEnc = await _encOrNull(newKey, dec.cardholder)
        ..numberEnc = await _encOrNull(newKey, dec.number)
        ..expiryEnc = await _encOrNull(newKey, dec.expiry)
        ..customFieldsEnc = await _encryptCustomFields(newKey, dec.customFields);
    }
    final newVerifier = await CardCrypto.encrypt(
        key: newKey, plaintext: CardCrypto.verifierSentinel);

    meta
      ..kdf = spec.algorithm
      ..kdfMemoryKb = spec.memoryKb
      ..kdfIterations = spec.iterations
      ..kdfParallelism = spec.parallelism
      ..pinLength = newPinLength
      ..verifierEnc = newVerifier.toJsonString();

    await _isar.writeTxn(() async {
      await _isar.storedCards.putAll(cards);
      await _isar.cardVaultMetas.put(meta);
    });
    return newKey;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String? _deriveLast4(String? number) {
    if (number == null) return null;
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return digits.isEmpty ? null : digits;
    return digits.substring(digits.length - 4);
  }

  Future<String?> _encOrNull(List<int> key, String? plaintext) async {
    final v = plaintext?.trim();
    if (v == null || v.isEmpty) return null;
    return (await CardCrypto.encrypt(key: key, plaintext: v)).toJsonString();
  }

  Future<String?> _decOrNull(List<int> key, String? json) async {
    if (json == null) return null;
    return CardCrypto.decrypt(
        key: key, field: EncryptedField.fromJsonString(json));
  }

  Future<List<String>> _encryptCustomFields(
      List<int> key, List<CardCustomField> fields) async {
    final out = <String>[];
    for (final f in fields) {
      final label = f.label.trim();
      final value = f.value.trim();
      if (label.isEmpty && value.isEmpty) continue;
      final enc = await CardCrypto.encrypt(key: key, plaintext: value);
      out.add(jsonEncode({'label': label, 'value': enc.toJsonString()}));
    }
    return out;
  }

  Future<List<CardCustomField>> _decryptCustomFields(
      List<int> key, List<String> encoded) async {
    final out = <CardCustomField>[];
    for (final s in encoded) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      final value = await CardCrypto.decrypt(
        key: key,
        field: EncryptedField.fromJsonString(m['value'] as String),
      );
      out.add(CardCustomField(label: m['label'] as String, value: value));
    }
    return out;
  }
}
