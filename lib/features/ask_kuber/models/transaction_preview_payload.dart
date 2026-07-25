import '../../dashboard/utils/quick_add_parser.dart';

class TransactionPreviewPayload {
  final List<QuickAddParsedItem> items;
  final bool missingDefaultAccount;
  final bool missingCategories;
  final bool missingAccounts;
  final String rawPrompt;
  bool isCommitted;

  TransactionPreviewPayload({
    required this.items,
    this.missingDefaultAccount = false,
    this.missingCategories = false,
    this.missingAccounts = false,
    required this.rawPrompt,
    this.isCommitted = false,
  });
}
