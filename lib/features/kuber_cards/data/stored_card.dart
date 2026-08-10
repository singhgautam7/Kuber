import 'package:isar_community/isar.dart';

part 'stored_card.g.dart';

/// One stored payment card in the Kuber Cards vault.
///
/// Sensitive fields (cardholder name, full card number, expiry, custom-field
/// values) are stored ONLY as ciphertext blobs (`*Enc`) so a copied database
/// file is unreadable without the user's PIN. Everything the home list needs to
/// render (nickname, last 4, colour, icon, type, network) stays plaintext, so
/// the list paints without ever deriving a key or touching the vault session.
/// See `specs/plans/kuber-cards.md` §1.
@collection
class StoredCard {
  Id id = Isar.autoIncrement;

  // ── Plaintext (list-render safe, never sensitive) ──────────────────────────

  /// User label, e.g. "HDFC Regalia". Required.
  late String nickname;

  /// Last 4 digits, derived from the full number on save (or entered directly).
  /// Plaintext so list/blur views never decrypt. Shown masked as `•••• 1234`.
  String? last4;

  /// Icon key: an `IconMapper` key (incl. `bank/*`) OR `gallery:<relative-path>`
  /// for a user-picked image.
  String? bankIcon;

  /// 'debit' | 'credit' | 'prepaid' | 'forex' | 'gift' | 'travel' | 'fuel' |
  /// 'meal' | 'corporate' | 'other'.
  String? cardType;

  /// 'visa' | 'mastercard' | 'rupay' | 'amex' | 'discover' | 'other'.
  String? network;

  /// When [isGradient] is false, a solid ARGB colour int. When true, an index
  /// into `CardPalette.gradients`. This is content data (like `Account.colorValue`),
  /// the one sanctioned exception to "colorScheme only".
  int colorValue = 0;

  bool isGradient = false;

  /// Optional foreign key to an `Account` (`Account.id.toString()`). Plaintext.
  String? linkedAccountId;

  @Index()
  DateTime createdAt = DateTime.now();

  @Index()
  DateTime updatedAt = DateTime.now();

  // ── Encrypted (JSON strings from CardVaultService; null when unset) ─────────

  /// Encrypted cardholder name. `EncryptedField` JSON: {v, iv, ct}.
  String? cardholderEnc;

  /// Encrypted full card number (PAN).
  String? numberEnc;

  /// Encrypted expiry "MM/YY".
  String? expiryEnc;

  /// Each element is an `EncryptedCustomField` JSON string:
  /// `{"label": plaintext, "value": {v, iv, ct}}`.
  List<String> customFieldsEnc = [];

  Map<String, dynamic> toMap() => {
    'id': id,
    'nickname': nickname,
    'last4': last4,
    'bankIcon': bankIcon,
    'cardType': cardType,
    'network': network,
    'colorValue': colorValue,
    'isGradient': isGradient,
    'linkedAccountId': linkedAccountId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'cardholderEnc': cardholderEnc,
    'numberEnc': numberEnc,
    'expiryEnc': expiryEnc,
    'customFieldsEnc': customFieldsEnc,
  };

  static StoredCard fromMap(Map<String, dynamic> m) => StoredCard()
    ..id = m['id'] as int
    ..nickname = m['nickname'] as String
    ..last4 = m['last4'] as String?
    ..bankIcon = m['bankIcon'] as String?
    ..cardType = m['cardType'] as String?
    ..network = m['network'] as String?
    ..colorValue = (m['colorValue'] as int?) ?? 0
    ..isGradient = (m['isGradient'] as bool?) ?? false
    ..linkedAccountId = m['linkedAccountId'] as String?
    ..createdAt = DateTime.parse(m['createdAt'] as String)
    ..updatedAt = DateTime.parse(m['updatedAt'] as String)
    ..cardholderEnc = m['cardholderEnc'] as String?
    ..numberEnc = m['numberEnc'] as String?
    ..expiryEnc = m['expiryEnc'] as String?
    ..customFieldsEnc =
        (m['customFieldsEnc'] as List?)?.cast<String>() ?? <String>[];
}
