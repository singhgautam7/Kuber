import 'package:collection/collection.dart';

import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../../core/utils/fuzzy_category_matcher.dart';
import 'quick_add_parser.dart';

/// Lifecycle of one preview line.
enum QuickAddDraftStatus {
  /// Resolved category + account; counts toward the confirm total.
  ready,

  /// Amount detected but the named category doesn't exist yet (Create / Pick).
  newCategory,

  /// No account could be resolved and no default is set (blocks confirm).
  missingAccount,

  /// No amount detected on this line (excluded from the count).
  unparseable,

  /// Written to the store (Ask Kuber confirmed state).
  confirmed,

  /// Dismissed without writing (Ask Kuber cancelled state).
  cancelled,
}

/// A single preview line with everything the card needs to render, denormalized
/// so the card is a pure widget (no provider lookups per row — matters for the
/// Ask Kuber chat ListView). Re-resolved whenever the user edits the category.
class QuickAddDraft {
  final String rawText;
  final double? amount;
  final String type; // 'income' | 'expense'
  final QuickAddDraftStatus status;

  final String? categoryHint; // original phrase, used to prefill "create"
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon; // icon name string
  final int? categoryColor; // raw color int (harmonized at render time)

  final int? accountId;
  final String? accountName;

  const QuickAddDraft({
    required this.rawText,
    required this.amount,
    required this.type,
    required this.status,
    this.categoryHint,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.accountId,
    this.accountName,
  });

  /// Whether this line is included in the confirm count / write. New-category
  /// lines DO count: the category is created at confirm time (not when the card
  /// appears), so a valid amount + account is enough to add.
  bool get counts =>
      status == QuickAddDraftStatus.ready ||
      status == QuickAddDraftStatus.newCategory;

  Map<String, dynamic> toJson() => {
        'rawText': rawText,
        'amount': amount,
        'type': type,
        'status': status.index,
        'categoryHint': categoryHint,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'categoryIcon': categoryIcon,
        'categoryColor': categoryColor,
        'accountId': accountId,
        'accountName': accountName,
      };

  factory QuickAddDraft.fromJson(Map<String, dynamic> j) => QuickAddDraft(
        rawText: j['rawText'] as String? ?? '',
        amount: (j['amount'] as num?)?.toDouble(),
        type: j['type'] as String? ?? 'expense',
        status: QuickAddDraftStatus.values[((j['status'] as num?)?.toInt() ?? 0)
            .clamp(0, QuickAddDraftStatus.values.length - 1)],
        categoryHint: j['categoryHint'] as String?,
        categoryId: (j['categoryId'] as num?)?.toInt(),
        categoryName: j['categoryName'] as String?,
        categoryIcon: j['categoryIcon'] as String?,
        categoryColor: (j['categoryColor'] as num?)?.toInt(),
        accountId: (j['accountId'] as num?)?.toInt(),
        accountName: j['accountName'] as String?,
      );

  QuickAddDraft copyWith({
    QuickAddDraftStatus? status,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? categoryColor,
    int? accountId,
    String? accountName,
  }) {
    return QuickAddDraft(
      rawText: rawText,
      amount: amount,
      type: type,
      status: status ?? this.status,
      categoryHint: categoryHint,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
    );
  }
}

/// Category names treated as a catch-all when a line names no category.
const _fallbackCategoryNames = <String>{
  'general', 'other', 'others', 'miscellaneous', 'misc', 'uncategorized',
};

/// Resolves parsed lines into display-ready drafts against the user's real
/// [categories] and [accounts]. Pure — creates nothing, writes nothing. Shared
/// by the Quick Add page and the Ask Kuber handler so both resolve identically.
List<QuickAddDraft> resolveDrafts(
  List<ParsedQuickAddTxn> parsed, {
  required List<Category> categories,
  required List<Account> accounts,
  required String? defaultAccountId,
}) {
  return parsed
      .map((p) => resolveDraft(
            p,
            categories: categories,
            accounts: accounts,
            defaultAccountId: defaultAccountId,
          ))
      .toList(growable: false);
}

QuickAddDraft resolveDraft(
  ParsedQuickAddTxn p, {
  required List<Category> categories,
  required List<Account> accounts,
  required String? defaultAccountId,
}) {
  if (!p.isParsed) {
    return QuickAddDraft(
      rawText: p.rawText,
      amount: p.amount,
      type: p.type,
      status: QuickAddDraftStatus.unparseable,
      categoryHint: p.categoryHint,
    );
  }

  // Account: hint match first, else default.
  Account? account;
  if (p.accountHint != null && p.accountHint!.trim().isNotEmpty) {
    final hint = p.accountHint!.toLowerCase();
    account = accounts
        .where((a) => a.name.toLowerCase().contains(hint))
        .firstOrNull;
  }
  account ??= defaultAccountId == null
      ? null
      : accounts.where((a) => a.id.toString() == defaultAccountId).firstOrNull;

  // Category: fuzzy match on the hint, else a catch-all fallback.
  Category? category;
  if (p.categoryHint != null && p.categoryHint!.trim().isNotEmpty) {
    category = matchCategory(p.categoryHint!, categories, type: p.type);
  } else {
    category = categories
        .where((c) =>
            (c.type == 'both' || c.type == p.type) &&
            _fallbackCategoryNames.contains(c.name.toLowerCase()))
        .firstOrNull;
  }

  final missingAccount = account == null;
  final newCategory = category == null;

  final status = missingAccount
      ? QuickAddDraftStatus.missingAccount
      : (newCategory ? QuickAddDraftStatus.newCategory : QuickAddDraftStatus.ready);

  return QuickAddDraft(
    rawText: p.rawText,
    amount: p.amount,
    type: p.type,
    status: status,
    categoryHint: p.categoryHint,
    categoryId: category?.id,
    categoryName: category?.name,
    categoryIcon: category?.icon,
    categoryColor: category?.colorValue,
    accountId: account?.id,
    accountName: account?.name,
  );
}
