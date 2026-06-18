import 'package:isar_community/isar.dart';

part 'sms_account_mapping.g.dart';

/// Permanent learning data: remembers which Kuber account a given SMS sender
/// has been imported into. After [usageCount] >= 3 the review sheet
/// confidently auto-fills the account (the user can still override). These
/// rows are never auto-deleted.
@collection
class SmsAccountMapping {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String senderId;

  late String accountId;
  late int usageCount;
  late DateTime lastUsed;

  Map<String, dynamic> toMap() => {
    'id': id,
    'senderId': senderId,
    'accountId': accountId,
    'usageCount': usageCount,
    'lastUsed': lastUsed.toIso8601String(),
  };
}
