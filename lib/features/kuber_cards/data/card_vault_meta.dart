import 'package:isar_community/isar.dart';

part 'card_vault_meta.g.dart';

/// Singleton (id == 0) holding the Kuber Cards vault's encryption metadata,
/// biometric preference, failed-attempt lockout state, and any locked payload
/// that arrived via a backup import. See `specs/plans/kuber-cards.md` §1.2.
///
/// `hasVault` is simply "this row exists".
@collection
class CardVaultMeta {
  /// Fixed singleton id.
  Id id = 0;

  // ── Encryption metadata (portable inside a backup) ─────────────────────────

  /// 16 random bytes, generated once at setup. Included in backups so the same
  /// PIN unlocks on any device.
  List<int> salt = [];

  /// 'argon2id' | 'pbkdf2'.
  String kdf = 'argon2id';

  int kdfMemoryKb = 19456;
  int kdfIterations = 2;
  int kdfParallelism = 1;
  int encVersion = 1;

  /// 4 or 6.
  int pinLength = 6;

  /// Ciphertext over a fixed sentinel, used to accept/reject a PIN WITHOUT
  /// decrypting any card. `EncryptedField` JSON: {v, iv, ct}.
  String? verifierEnc;

  // ── Biometric convenience ──────────────────────────────────────────────────
  bool biometricEnabled = false;

  // ── Failed-attempt lockout (survives restart) ──────────────────────────────

  /// Consecutive wrong attempts; 5 → 5-minute cooldown. Reset on success.
  int failedStreak = 0;

  /// End of the current 5-minute cooldown, or null.
  DateTime? cooldownUntil;

  /// End of a full-day lock after 10 wrong attempts in a rolling 24h window.
  /// Access is blocked, data is never wiped.
  DateTime? dayLockedUntil;

  /// Timestamps of wrong attempts within the rolling 24h window.
  List<DateTime> failedTimestamps = [];

  // ── Locked import payload (backup import; see §6.3) ─────────────────────────

  /// True when a backup restored encrypted cards that still need the old
  /// device's PIN before they can be shown.
  bool hasLockedImport = false;

  /// The restored vault's metadata (its salt/params/verifier) used to unlock the
  /// imported cards. Once unlocked, this becomes the active metadata above.
  List<int>? importSalt;
  String? importKdf;
  int? importMemoryKb;
  int? importIterations;
  int? importParallelism;
  int? importEncVersion;
  int? importPinLength;
  String? importVerifierEnc;

  /// User dismissed the "cards from your backup are locked" banner. The cards
  /// stay locked and reachable; only the banner is hidden.
  bool importBannerDismissed = false;

  Map<String, dynamic> toMap() => {
    'id': id,
    'salt': salt,
    'kdf': kdf,
    'kdfMemoryKb': kdfMemoryKb,
    'kdfIterations': kdfIterations,
    'kdfParallelism': kdfParallelism,
    'encVersion': encVersion,
    'pinLength': pinLength,
    'verifierEnc': verifierEnc,
    'biometricEnabled': biometricEnabled,
    // Lockout state is intentionally NOT exported (device-local, not portable).
  };

  /// Builds the metadata a backup import needs. Lockout/biometric/import fields
  /// are reset to a clean local state; the imported salt/params land in the
  /// `import*` fields via the caller when a local vault already exists.
  static CardVaultMeta fromMap(Map<String, dynamic> m) => CardVaultMeta()
    ..id = 0
    ..salt = (m['salt'] as List?)?.cast<int>() ?? <int>[]
    ..kdf = (m['kdf'] as String?) ?? 'argon2id'
    ..kdfMemoryKb = (m['kdfMemoryKb'] as int?) ?? 19456
    ..kdfIterations = (m['kdfIterations'] as int?) ?? 2
    ..kdfParallelism = (m['kdfParallelism'] as int?) ?? 1
    ..encVersion = (m['encVersion'] as int?) ?? 1
    ..pinLength = (m['pinLength'] as int?) ?? 6
    ..verifierEnc = m['verifierEnc'] as String?;
}
