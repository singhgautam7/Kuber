import 'package:isar/isar.dart';

part 'transaction_tag.g.dart';

@collection
class TransactionTag {
  Id id = Isar.autoIncrement;

  @Index()
  late int transactionId;

  @Index()
  late int tagId;
}
