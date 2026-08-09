import '../../quick_add/services/quick_add_parser.dart';
import '../../quick_add/services/quick_add_resolver.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/viz_payload.dart';
import 'query_handler.dart';

/// Detects a "log a transaction" intent (e.g. "add 250 groceries", "I spent 300
/// on movies and 120 on tea") and returns an interactive preview — never an
/// auto-add. Uses the same offline parser + resolver as the Quick Add page so
/// both behave identically.
///
/// Runs after the conversational / knowledge / how-to handlers and before the
/// spending/data handlers. The guards are deliberately narrow: it requires an
/// explicit add cue, a detectable amount, and no data-query phrasing, so real
/// questions like "how much did I spend on food" still reach the data handlers.
class AddTransactionHandler extends QueryHandler {
  const AddTransactionHandler();

  /// Phrasings that mean the user is asking about data, not logging it.
  static const _queryCues = [
    'how much', 'how many', 'how often', 'what did', 'what have', 'what was',
    'what are', "what's", 'show ', 'list ', 'total', 'average', 'when did',
    'when was', 'where did', 'biggest', 'summary', 'breakdown', 'compare',
    'how are', 'how is',
  ];

  /// Phrasings that mean "log this".
  static const _addCues = [
    'add ', 'log ', 'record ', 'note down', 'jot down', 'i spent', 'i paid',
    'i bought', 'i received', 'i earned', 'i got', 'spent ', 'paid ',
    'bought ', 'received ', 'earned ', 'got paid',
  ];

  bool _looksLikeAdd(String lower) {
    if (_queryCues.any(lower.contains)) return false;
    return _addCues.any(lower.contains);
  }

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    if (!_looksLikeAdd(ctx.lower)) return null;

    final parsed = parseQuickAddMulti(ctx.raw);
    final withAmount = parsed.where((p) => p.isParsed).toList();
    if (withAmount.isEmpty) return null;

    final drafts = resolveDrafts(
      parsed,
      categories: ctx.categories,
      accounts: ctx.accounts,
      defaultAccountId: ctx.settings.defaultAccountId,
    );

    final n = withAmount.length;
    final lead = n <= 1
        ? "Here's what I'll add. Review and confirm."
        : "I found $n transactions. Confirm to add ${n == 2 ? 'both' : 'all'}.";

    return HandlerResult(
      text: lead,
      vizPayload: TransactionPreviewViz(
        originalMessage: ctx.raw,
        drafts: drafts,
      ),
    );
  }
}
