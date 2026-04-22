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
}
