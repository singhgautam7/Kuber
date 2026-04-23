import 'package:isar_community/isar.dart';

part 'transaction_suggestion.g.dart';

@collection
class TransactionSuggestion {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String nameLower;

  late String displayName;
  String? categoryId;
  String? accountId;
  double? amount;
  late DateTime createdAt;
  late DateTime updatedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'nameLower': nameLower,
    'displayName': displayName,
    'categoryId': categoryId,
    'accountId': accountId,
    'amount': amount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
