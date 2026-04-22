import 'package:isar_community/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late String name;
  late double amount;
  late String type; // 'income' | 'expense' ONLY — never 'transfer'

  @Index(composite: [CompositeIndex('createdAt')])
  late String categoryId;

  @Index()
  late String accountId;

  String? notes;

  String? quickAddNote;

  String? linkedRuleId; // UUID string — works for all linked collections

  @Index()
  String? linkedRuleType; // 'recurring' | 'lent' | 'borrowed' | 'loan' | 'investment'

  bool isBalanceAdjustment = false;

  // Transfer fields
  bool isTransfer = false;          // true for both legs of a transfer
  String? transferId;               // same value on both legs (timestamp-based)

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;

  @Index(composite: [CompositeIndex('updatedAt')])
  late String nameLower; // store name.toLowerCase() for fast search

  List<String> attachmentPaths = []; // file paths on disk

  @ignore
  String? tempTags; // temporary storage for import
}
