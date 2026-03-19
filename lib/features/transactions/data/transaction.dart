import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late String name;
  late double amount;
  late String type; // 'income' | 'expense'

  @Index()
  late String categoryId;

  @Index()
  late String accountId;

  String? notes;

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;

  @Index(composite: [CompositeIndex('updatedAt')])
  late String nameLower; // store name.toLowerCase() for fast search
}
