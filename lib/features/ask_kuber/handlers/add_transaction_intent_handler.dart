import '../../dashboard/utils/quick_add_parser.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/transaction_preview_payload.dart';
import 'query_handler.dart';

class AddTransactionIntentHandler extends QueryHandler {
  const AddTransactionIntentHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final raw = ctx.raw.trim();
    final lower = ctx.lower;

    // Check if the query is an add-transaction prompt
    final isExplicitAdd = lower.startsWith('add ') ||
        lower.startsWith('create ') ||
        lower.startsWith('record ') ||
        lower.startsWith('log ') ||
        lower.startsWith('spent ') ||
        lower.startsWith('paid ') ||
        lower.startsWith('bought ');

    // Check for number + category pattern (e.g. "300 movies", "500 dinner and 200 tea")
    final hasNumber = RegExp(r'\d+').hasMatch(lower);
    final isMultiPattern = lower.contains(' and ') || lower.contains(' then ');

    if (!isExplicitAdd && !(hasNumber && (lower.contains(' on ') || lower.contains(' for ') || lower.contains(' in ') || isMultiPattern))) {
      return null;
    }

    final categories = ctx.categories;
    final accounts = ctx.accounts;

    if (accounts.isEmpty) {
      return HandlerResult(
        text: "You don't have any accounts set up yet.",
        previewPayload: TransactionPreviewPayload(
          items: const [],
          missingAccounts: true,
          rawPrompt: raw,
        ),
      );
    }

    if (categories.isEmpty) {
      return HandlerResult(
        text: "You don't have any categories set up yet.",
        previewPayload: TransactionPreviewPayload(
          items: const [],
          missingCategories: true,
          rawPrompt: raw,
        ),
      );
    }

    final parsedItems = parseMultiQuickAdd(raw, categories);
    if (parsedItems.isEmpty || parsedItems.every((i) => i.amount == null || i.amount! <= 0)) {
      return null;
    }

    final defaultAccId = ctx.settings.defaultAccountId;
    final hasDefaultAccount = defaultAccId != null && accounts.any((a) => a.id.toString() == defaultAccId);

    bool missingDefaultAccount = false;
    for (final item in parsedItems) {
      if (item.accountHint != null) {
        final match = accounts.where((a) => a.name.toLowerCase().contains(item.accountHint!.toLowerCase())).firstOrNull;
        if (match == null && !hasDefaultAccount) {
          missingDefaultAccount = true;
          break;
        }
      } else if (!hasDefaultAccount) {
        missingDefaultAccount = true;
        break;
      }
    }

    double total = 0.0;
    for (final item in parsedItems) {
      total += (item.amount ?? 0.0);
    }

    final totalFormatted = total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(2);
    final leadText = parsedItems.length == 1
        ? "Here's what I'll add:"
        : "I found ${parsedItems.length} transactions totalling ₹$totalFormatted:";

    return HandlerResult(
      text: leadText,
      previewPayload: TransactionPreviewPayload(
        items: parsedItems,
        missingDefaultAccount: missingDefaultAccount,
        rawPrompt: raw,
      ),
    );
  }
}
