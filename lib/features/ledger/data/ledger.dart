import 'package:isar/isar.dart';

part 'ledger.g.dart';

@collection
class Ledger {
  Id id = Isar.autoIncrement;

  late String uid; // UUID — used as linkedRuleId on transactions

  late String personName; // Title-cased, trimmed

  @Index()
  late String personNameLower; // personName.toLowerCase() for autocomplete

  late String type; // 'lent' | 'borrowed'

  late double originalAmount; // Always positive

  late String accountId;

  late String categoryId; // Auto-selected 'Lent/Borrowed' system category

  String? notes;

  DateTime? expectedDate; // Optional due date

  bool isSettled = false;

  late DateTime createdAt;

  late DateTime updatedAt;
}
