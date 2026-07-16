import '../handlers/average_expense_handler.dart';
import '../handlers/balance_handler.dart';
import '../handlers/biggest_expense_handler.dart';
import '../handlers/budgets_handler.dart';
import '../handlers/conversational_handler.dart';
import '../handlers/counts_handler.dart';
import '../handlers/easter_egg_handler.dart';
import '../handlers/fallback_handler.dart';
import '../handlers/frequency_handler.dart';
import '../handlers/how_to_handler.dart';
import '../handlers/knowledge_handler.dart';
import '../handlers/last_spent_handler.dart';
import '../handlers/income_handler.dart';
import '../handlers/investments_handler.dart';
import '../handlers/language_handler.dart';
import '../handlers/ledger_handler.dart';
import '../handlers/loans_handler.dart';
import '../handlers/notes_handler.dart';
import '../handlers/query_handler.dart';
import '../handlers/recent_transactions_handler.dart';
import '../handlers/savings_handler.dart';
import '../handlers/spending_handler.dart';
import '../handlers/top_category_handler.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';

/// Walks the handler chain in priority order and returns the first non-null
/// result. The non-terminal order is:
///
///   conversational -> easter egg -> how-to -> data handlers (in the original
///   `_processQuery` precedence) -> fallback.
///
/// When nothing but the fallback matches, [onUnhandled] fires so the caller can
/// log the query.
class QueryOrchestrator {
  final List<QueryHandler> handlers;
  final QueryHandler fallback;

  const QueryOrchestrator({
    required this.handlers,
    this.fallback = const FallbackHandler(),
  });

  /// The production chain.
  factory QueryOrchestrator.standard() => const QueryOrchestrator(
        handlers: [
          // Conversational layer.
          ConversationalHandler(),
          EasterEggHandler(),
          // Knowledge base: informational "help" / "how does X work" answers.
          // Runs before how-to so informational phrasing wins; how-to keeps the
          // functional "how do I do X" navigation.
          KnowledgeHandler(),
          // Functional help.
          HowToHandler(),
          LanguageHandler(),
          // Kuber Notes lookups run before spending/counts so "what did I
          // note this month" isn't swallowed by the data handlers.
          NotesHandler(),
          // Entity-scoped lookups run before the spending/counts handlers so
          // "how many times…" and "when did I last…" aren't swallowed by them.
          FrequencyHandler(),
          LastSpentHandler(),
          // Data handlers - same precedence as the original monolith.
          SpendingHandler(),
          TopCategoryHandler(),
          IncomeHandler(),
          SavingsHandler(),
          BiggestExpenseHandler(),
          CountsHandler(),
          AverageExpenseHandler(),
          RecentTransactionsHandler(),
          BalanceHandler(),
          LoansHandler(),
          LedgerHandler(),
          InvestmentsHandler(),
          BudgetsHandler(),
        ],
      );

  Future<HandlerResult> process(
    QueryContext ctx, {
    void Function(String raw)? onUnhandled,
  }) async {
    for (final handler in handlers) {
      final result = await handler.tryHandle(ctx);
      if (result != null) return result;
    }
    onUnhandled?.call(ctx.raw);
    return (await fallback.tryHandle(ctx))!;
  }
}
