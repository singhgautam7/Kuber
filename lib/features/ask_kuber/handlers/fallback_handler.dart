import '../models/chip_action.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';

/// Terminal handler - always matches. Mirrors the original `_processQuery`
/// fallback copy, with a few ask chips to nudge the user toward a valid query.
class FallbackHandler extends QueryHandler {
  const FallbackHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    return const HandlerResult(
      text: 'I can answer questions about your spending, income, balances, and categories.\n\n'
          'Try:\n'
          '• "How much have I spent this month?"\n'
          '• "How much did I spend in the past two weeks?"\n'
          '• "What\'s my net worth?"\n'
          '• "What\'s my top category?"\n'
          '• "How much do I owe on loans?"\n'
          '• "What\'s my portfolio value?"',
      thinking: ThinkingInfo(
        dateFilter: 'N/A',
        scanned: [],
        steps: [
          ThinkingStep(
              'No matching data query was found. Showing example questions you can ask.'),
        ],
      ),
      followUps: [
        AskChipAction('How much did I spend this month?'),
        AskChipAction('What\'s my net worth?'),
        AskChipAction('Top spending category'),
      ],
    );
  }
}
