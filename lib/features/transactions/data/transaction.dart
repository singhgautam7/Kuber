import 'package:isar_community/isar.dart';

part 'transaction.g.dart';

/// What a transaction is for, beyond income / expense. Stored by its string
/// [value]. Null for normal transactions.
enum TxnSubType {
  // Expense side.
  loanRepayment('loan_repayment'),
  investment('investment'),
  savings('savings'),
  lent('lent'),
  // Income side.
  borrowed('borrowed'),
  investmentReturn('investment_return'),
  loanReceived('loan_received');

  const TxnSubType(this.value);
  final String value;

  static TxnSubType? fromValue(Object? v) =>
      TxnSubType.values.where((t) => t.value == v).firstOrNull;
}

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

  // SMS import provenance. null = entered manually; 'sms' = imported from a
  // bank SMS via the SMS import flow. Both nullable so existing rows migrate
  // safely with a null default.
  String? importSource;     // null | 'sms'
  String? importedFromSms;  // raw SMS body, stored only for SMS-imported txns

  // Kuber Notes provenance. Set only when the transaction was created via
  // the Notes tap-to-convert flow; stores KuberNote.id as a string. Nullable
  // so existing rows migrate safely with a null default.
  String? sourceNoteId;

  /// vNext: what the transaction is for (EMI, SIP, withdrawal...).
  @Enumerated(EnumType.value, 'value')
  TxnSubType? subType;

  /// vNext: the loan / investment / recurring rule that created it.
  /// 'recurring' | 'loan' | 'investment'; [sourceId] = rule id / loan uid /
  /// investment uid. linkedRuleType / linkedRuleId are still written too.
  @Index(composite: [CompositeIndex('sourceId')])
  String? sourceType;
  String? sourceId;

  /// EMI split, saved at the moment of payment and never recalculated.
  double? principalPart;
  double? interestPart;

  /// The loan's "count only interest as expense" was on for this EMI: only
  /// [interestPart] counts as spending (see `spendAmount`).
  bool spendInterestOnly = false;

  /// yyyymmdd of the schedule occurrence that created it.
  int? occurrenceDate;

  @ignore
  String? tempTags; // temporary storage for import

  /// The amount that counts as spending in Analytics, Budgets, Home, Stories,
  /// Ask Kuber and widgets. Balances and History always use [amount].
  /// Created by a recurring rule, a loan EMI or a SIP (not a manual top-up
  /// or extra payment). History's "Recurring" filter and Recurring > Recently
  /// processed use this.
  @ignore
  bool get isScheduled =>
      occurrenceDate != null ||
      linkedRuleType == 'recurring' ||
      (linkedRuleType == 'loan' && name.startsWith('EMI - ')) ||
      (linkedRuleType == 'investment' && name.startsWith('Contribution - '));

  @ignore
  double get spendAmount =>
      spendInterestOnly ? (interestPart ?? amount) : amount;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'amount': amount,
    'type': type,
    'categoryId': categoryId,
    'accountId': accountId,
    'notes': notes,
    'quickAddNote': quickAddNote,
    'linkedRuleId': linkedRuleId,
    'linkedRuleType': linkedRuleType,
    'isBalanceAdjustment': isBalanceAdjustment,
    'isTransfer': isTransfer,
    'transferId': transferId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'nameLower': nameLower,
    'attachmentPaths': attachmentPaths,
    'importSource': importSource,
    'importedFromSms': importedFromSms,
    'sourceNoteId': sourceNoteId,
    'subType': subType?.value,
    'sourceType': sourceType,
    'sourceId': sourceId,
    'principalPart': principalPart,
    'interestPart': interestPart,
    'spendInterestOnly': spendInterestOnly,
    'occurrenceDate': occurrenceDate,
  };
}
