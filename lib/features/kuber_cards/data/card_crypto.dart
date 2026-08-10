import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart' show compute;

/// Low-level crypto primitives for the Kuber Cards vault: key derivation
/// (Argon2id / PBKDF2), AES-GCM-256 field encryption, and the `EncryptedField`
/// wire format. No Isar, no UI, no key retention.
///
/// Nothing here logs a PIN, key, or plaintext. See `specs/plans/kuber-cards.md` §2.

/// KDF parameters, stored per-vault in `CardVaultMeta` and carried in backups so
/// a field encrypted on one device decrypts on another.
class KdfSpec {
  final String algorithm; // 'argon2id' | 'pbkdf2'
  final int memoryKb; // Argon2 only (1 kB blocks)
  final int iterations;
  final int parallelism; // Argon2 only

  const KdfSpec({
    required this.algorithm,
    required this.memoryKb,
    required this.iterations,
    required this.parallelism,
  });

  /// Defaults: Argon2id at the OWASP ~19 MiB tier. One-time cost at unlock,
  /// always run off the UI isolate.
  static const argon2Default = KdfSpec(
    algorithm: 'argon2id',
    memoryKb: 19456,
    iterations: 2,
    parallelism: 1,
  );

  /// Fallback for platforms/devices that can't run Argon2id.
  static const pbkdf2Default = KdfSpec(
    algorithm: 'pbkdf2',
    memoryKb: 0,
    iterations: 210000,
    parallelism: 1,
  );
}

/// A single encrypted value: version + 12-byte GCM IV + ciphertext + 16-byte tag,
/// all base64. Serialized to a compact JSON string for storage.
class EncryptedField {
  final int v;
  final String iv;
  final String ct;
  final String tag;

  const EncryptedField({
    required this.v,
    required this.iv,
    required this.ct,
    required this.tag,
  });

  String toJsonString() => jsonEncode({'v': v, 'iv': iv, 'ct': ct, 'tag': tag});

  factory EncryptedField.fromJsonString(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return EncryptedField(
      v: (m['v'] as int?) ?? 1,
      iv: m['iv'] as String,
      ct: m['ct'] as String,
      tag: m['tag'] as String,
    );
  }
}

class CardCrypto {
  const CardCrypto._();

  static final _rng = Random.secure();

  static List<int> randomBytes(int n) =>
      List<int>.generate(n, (_) => _rng.nextInt(256));

  /// 16-byte per-device salt.
  static List<int> newSalt() => randomBytes(16);

  /// Derives the 32-byte key from [pin] + [salt] using [spec]. Runs on a
  /// background isolate (`compute`) so the heavy Argon2 pass never janks the UI.
  static Future<List<int>> deriveKey({
    required String pin,
    required List<int> salt,
    required KdfSpec spec,
  }) {
    return compute(_deriveKeyEntry, <String, dynamic>{
      'pin': pin,
      'salt': salt,
      'algorithm': spec.algorithm,
      'memoryKb': spec.memoryKb,
      'iterations': spec.iterations,
      'parallelism': spec.parallelism,
    });
  }

  /// Encrypts [plaintext] under [key] with a fresh random IV.
  static Future<EncryptedField> encrypt({
    required List<int> key,
    required String plaintext,
    int version = 1,
  }) async {
    final algo = AesGcm.with256bits();
    final iv = randomBytes(12);
    final box = await algo.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(key),
      nonce: iv,
    );
    return EncryptedField(
      v: version,
      iv: base64.encode(iv),
      ct: base64.encode(box.cipherText),
      tag: base64.encode(box.mac.bytes),
    );
  }

  /// Decrypts [field] under [key]. Throws [SecretBoxAuthenticationError] when the
  /// key is wrong or the ciphertext was tampered with.
  static Future<String> decrypt({
    required List<int> key,
    required EncryptedField field,
  }) async {
    final algo = AesGcm.with256bits();
    final box = SecretBox(
      base64.decode(field.ct),
      nonce: base64.decode(field.iv),
      mac: Mac(base64.decode(field.tag)),
    );
    final clear = await algo.decrypt(box, secretKey: SecretKey(key));
    return utf8.decode(clear);
  }

  /// Returns true if [key] correctly decrypts [verifier]. Cheap, touches no card.
  static Future<bool> verify({
    required List<int> key,
    required String verifierJson,
  }) async {
    try {
      final plain = await decrypt(
        key: key,
        field: EncryptedField.fromJsonString(verifierJson),
      );
      return plain == verifierSentinel;
    } on SecretBoxAuthenticationError {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fixed sentinel encrypted at setup so a PIN can be checked without a card.
  static const verifierSentinel = 'kuber-cards-v1';
}

/// Isolate entry point for [CardCrypto.deriveKey]. Top-level so `compute` can
/// spawn it.
Future<List<int>> _deriveKeyEntry(Map<String, dynamic> a) async {
  final pin = a['pin'] as String;
  final salt = (a['salt'] as List).cast<int>();
  final algorithm = a['algorithm'] as String;

  final KdfAlgorithm kdf;
  if (algorithm == 'pbkdf2') {
    kdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: a['iterations'] as int,
      bits: 256,
    );
  } else {
    kdf = Argon2id(
      parallelism: a['parallelism'] as int,
      memory: a['memoryKb'] as int,
      iterations: a['iterations'] as int,
      hashLength: 32,
    );
  }

  final key = await kdf.deriveKey(
    secretKey: SecretKey(utf8.encode(pin)),
    nonce: salt,
  );
  return key.extractBytes();
}
