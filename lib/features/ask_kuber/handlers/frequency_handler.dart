import '../../transactions/data/transaction.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'query_time_range.dart';
import 'thinking_steps.dart';

/// "How many times / how often / frequency" questions for a transaction name or
/// category. Answers with both a count and a total amount over the resolved
/// time range (all time by default). Runs before the spending and generic
/// counts handlers so entity-scoped frequency queries aren't swallowed by them,
/// but falls through (returns null) for generic "how many transactions"
/// questions that name no entity, leaving those to [CountsHandler].
class FrequencyHandler extends QueryHandler {
  const FrequencyHandler();

  bool _isFrequencyIntent(String lower) =>
      lower.contains('how many times') ||
      lower.contains('how often') ||
      lower.contains('frequency') ||
      lower.contains('number of times') ||
      (lower.contains('how many') && lower.contains('transaction'));

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!_isFrequencyIntent(lower)) return null;

    final match = ctx.extractor.matchEntity(lower, ctx.categories, ctx.txns);
    final range = resolveQueryRange(ctx);

    if (match == null) {
      // Only claim the query if the user clearly named a subject; otherwise let
      // the generic counts handler answer (e.g. "how many transactions today").
      final phrase = ctx.extractor.extractEntityPhrase(ctx.raw);
      if (phrase == null) return null;
      return HandlerResult(
        text:
            "I couldn't find any transactions matching '$phrase' in that period.",
        thinking: ThinkingInfo(
          dateFilter: range.thinkingDate,
          scanned: const ['Transactions'],
          steps: [
            intentStep('transaction frequency', range.label),
            scannedStep(ctx.txns.length, 'transactions'),
            resultStep("No transactions matched '**$phrase**'."),
          ],
        ),
      );
    }

    bool inRange(Transaction t) =>
        !t.createdAt.isBefore(range.from) && t.createdAt.isBefore(range.to);

    final matched = ctx.txns.validForCalculations.where((t) {
      if (!inRange(t)) return false;
      return match.isCategory
          ? t.categoryId == match.categoryId.toString()
          : t.name.toLowerCase().contains(match.nameKeyword!);
    }).toList();

    final count = matched.length;
    final total = matched.fold<double>(0, (sum, t) => sum + t.amount);

    if (count == 0) {
      return HandlerResult(
        text:
            "I couldn't find any transactions matching '${match.name}' in that period.",
        thinking: ThinkingInfo(
          dateFilter: range.thinkingDate,
          scanned: const ['Transactions'],
          steps: [
            intentStep('transaction frequency', range.label),
            scannedStep(ctx.txns.length, 'transactions'),
            resultStep("No transactions matched '**${match.name}**'."),
          ],
        ),
      );
    }

    final timePart = range.suffix.isEmpty ? '' : ' ${range.suffix}';
    final note = match.ambiguous ? ' (matched category: ${match.name})' : '';

    final String text;
    if (match.isCategory) {
      text =
          "You've made $count ${match.name} transaction${count == 1 ? '' : 's'}"
          '$timePart, totaling ${ctx.money(total)}.$note';
    } else {
      text =
          "You've spent on ${match.name} $count time${count == 1 ? '' : 's'}"
          '$timePart, totaling ${ctx.money(total)}.';
    }

    return HandlerResult(
      text: text,
      thinking: ThinkingInfo(
        dateFilter: range.thinkingDate,
        scanned: [
          'Transactions',
          if (match.isCategory) 'Categories (${match.name})',
        ],
        steps: [
          intentStep('transaction frequency', range.label),
          resultStep(
            'Matched **$count transactions** by name/category: **${match.name}**.',
          ),
          resultStep('Total across the period: **${ctx.money(total)}**.'),
        ],
      ),
    );
  }
}
