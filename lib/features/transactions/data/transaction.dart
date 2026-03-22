import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late String name;
  late double amount;
  late String type; // 'income' | 'expense' | 'transfer'

  @Index()
  late String categoryId;

  @Index()
  late String accountId;

  String? notes;

  String? fromAccountId; // only set when type == 'transfer'
  String? toAccountId;   // only set when type == 'transfer'

  int? recurringRuleId; // set when created by recurring processor

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;

  @Index(composite: [CompositeIndex('updatedAt')])
  late String nameLower; // store name.toLowerCase() for fast search
}
