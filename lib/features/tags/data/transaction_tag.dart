import 'package:isar_community/isar.dart';

part 'transaction_tag.g.dart';

@collection
class TransactionTag {
  Id id = Isar.autoIncrement;

  @Index()
  late int transactionId;

  @Index()
  late int tagId;

  Map<String, dynamic> toMap() => {
    'id': id,
    'transactionId': transactionId,
    'tagId': tagId,
  };
}
