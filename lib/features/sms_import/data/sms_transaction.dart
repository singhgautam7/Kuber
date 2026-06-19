import 'package:isar_community/isar.dart';

part 'sms_transaction.g.dart';

/// Staging row for a single parsed bank SMS. These live temporarily until the
/// user imports or dismisses them; a cleanup job prunes reviewed rows older
/// than 90 days (unreviewed rows are kept regardless of age).
@collection
class SmsTransaction {
  Id id = Isar.autoIncrement;

  late String rawSms;
  late String senderId;

  /// Hash of [rawSms] used as the upsert key so re-scanning the inbox does not
  /// create duplicate staging rows (and does not reset review status).
  @Index(unique: true, replace: true)
  late String rawSmsHash;

  late DateTime parsedDate;
  late double parsedAmount;
  late String parsedType; // 'expense' | 'income'

  String? parsedMerchant;
  String? parsedAccountSuffix; // last 4 digits if found
  String? suggestedAccountId; // matched Kuber account id (as string)
  String? suggestedCategoryId;

  /// 'unreviewed' | 'imported' | 'dismissed'
  @Index()
  late String reviewStatus;

  late DateTime smsDate; // original SMS timestamp
  DateTime? importedAt;
  String? importedTransactionId; // linked Transaction id after import

  /// Name of the parser pattern that matched, e.g. 'HDFC debit (UPI)'. Shown
  /// in the review sheet as the "matched … pattern" credit.
  String? patternMatched;

  Map<String, dynamic> toMap() => {
    'id': id,
    'rawSms': rawSms,
    'senderId': senderId,
    'rawSmsHash': rawSmsHash,
    'parsedDate': parsedDate.toIso8601String(),
    'parsedAmount': parsedAmount,
    'parsedType': parsedType,
    'parsedMerchant': parsedMerchant,
    'parsedAccountSuffix': parsedAccountSuffix,
    'suggestedAccountId': suggestedAccountId,
    'suggestedCategoryId': suggestedCategoryId,
    'reviewStatus': reviewStatus,
    'smsDate': smsDate.toIso8601String(),
    'importedAt': importedAt?.toIso8601String(),
    'importedTransactionId': importedTransactionId,
    'patternMatched': patternMatched,
  };
}
