import '../../transactions/data/transaction.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../models/chip_action.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'query_time_range.dart';

/// "When did I last …" / "most recent …" lookups. Returns the date and amount
/// of the most recent transaction matching a transaction name or category.
/// Searches all time by default; respects an explicit period when given. Runs
/// before the spending handler so "when did I last spend on Netflix this month"
/// isn't captured as a period total.
class LastSpentHandler extends QueryHandler {
  const LastSpentHandler();

  bool _isLastIntent(String lower) =>
      lower.contains('most recent') ||
      lower.contains('last transaction') ||
      (lower.contains('last') &&
          (lower.contains('when') ||
              lower.contains('time') ||
              lower.contains('transaction') ||
              lower.contains('recent')));

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!_isLastIntent(lower)) return null;

    final match = ctx.extractor.matchEntity(lower, ctx.categories, ctx.txns);
    final range = resolveQueryRange(ctx);
    final scope = range.isAllTime ? 'all time' : range.label;

    if (match == null) {
      final phrase = ctx.extractor.extractEntityPhrase(ctx.raw);
      if (phrase == null) return null;
      return HandlerResult(
        text: "I couldn't find any transactions matching '$phrase'.",
        thinking: ThinkingInfo(
          dateFilter: range.thinkingDate,
          scanned: const ['Transactions'],
          steps: [
            ThinkingStep(
              'Detected intent: **last transaction lookup**. '
              'Search scope: **$scope**.',
            ),
            ThinkingStep(
              'Searched **${ctx.txns.length} transactions** for '
              'name/category: **$phrase**.',
            ),
            const ThinkingStep('No matching transaction found.'),
          ],
        ),
      );
    }

    bool inRange(Transaction t) =>
        !t.createdAt.isBefore(range.from) && t.createdAt.isBefore(range.to);

    final matched =
        ctx.txns.validForCalculations.where((t) {
            if (!inRange(t)) return false;
            return match.isCategory
                ? t.categoryId == match.categoryId.toString()
                : t.name.toLowerCase().contains(match.nameKeyword!);
          }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (matched.isEmpty) {
      // No match in an explicitly named period: suggest dropping the filter.
      if (!range.isAllTime) {
        return HandlerResult(
          text: 'No ${match.name} transactions found ${range.suffix}.',
          followUps: [
            AskChipAction('When did I last spend on ${match.name}?'),
          ],
          thinking: ThinkingInfo(
            dateFilter: range.thinkingDate,
            scanned: const ['Transactions'],
            steps: [
              ThinkingStep(
                'Detected intent: **last transaction lookup**. '
                'Search scope: **$scope**.',
              ),
              ThinkingStep(
                'Searched **${ctx.txns.length} transactions** for '
                'name/category: **${match.name}**.',
              ),
              const ThinkingStep('No match in the requested period.'),
            ],
          ),
        );
      }
      return HandlerResult(
        text: "I couldn't find any transactions matching '${match.name}'.",
        thinking: ThinkingInfo(
          dateFilter: range.thinkingDate,
          scanned: const ['Transactions'],
          steps: [
            ThinkingStep(
              'Detected intent: **last transaction lookup**. '
              'Search scope: **$scope**.',
            ),
            ThinkingStep(
              'Searched **${ctx.txns.length} transactions** for '
              'name/category: **${match.name}**.',
            ),
            const ThinkingStep('No matching transaction found.'),
          ],
        ),
      );
    }

    final last = matched.first;
    final date = ctx.fmtDate(last.createdAt);
    final amount = ctx.money(last.amount);

    final String text;
    if (match.isCategory) {
      final txName = last.name.trim();
      final clause = txName.isEmpty ? '' : ' at $txName';
      text =
          'Your last ${match.name} transaction was on $date for '
          '$amount$clause.';
    } else {
      text =
          'Your last ${match.name} transaction was on $date for $amount.';
    }

    return HandlerResult(
      text: text,
      followUps: [
        AskChipAction('How many times did I spend on ${match.name}?'),
        AskChipAction('Total spent on ${match.name} this month?'),
      ],
      thinking: ThinkingInfo(
        dateFilter: range.thinkingDate,
        scanned: [
          'Transactions',
          if (match.isCategory) 'Categories (${match.name})',
        ],
        steps: [
          ThinkingStep(
            'Detected intent: **last transaction lookup**. '
            'Search scope: **$scope**.',
          ),
          ThinkingStep(
            'Searched **${ctx.txns.length} transactions** for '
            'name/category: **${match.name}**.',
          ),
          ThinkingStep('Most recent match: **$date**, **$amount**.'),
        ],
      ),
    );
  }
}
