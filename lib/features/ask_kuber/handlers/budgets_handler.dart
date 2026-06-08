import 'package:collection/collection.dart';

import '../../budgets/data/budget.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../models/chip_action.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import '../models/viz_payload.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// Budget queries. Aggregate questions ("show my budgets") return the original
/// text list. A query that names a category with an active budget ("am I
/// overspending on food") returns that budget's status plus a [BudgetStatusViz];
/// an over-budget result also gets a "View budget" navigate chip.
class BudgetsHandler extends QueryHandler {
  const BudgetsHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!(lower.contains('budget') ||
        lower.contains('spending limit') ||
        lower.contains('overspend'))) {
      return null;
    }

    final budgets = await ctx.read(budgetVsActualProvider.future);
    if (budgets.isEmpty) {
      return HandlerResult(
        text: 'No active budgets set up.',
        thinking: ThinkingInfo(
          dateFilter: 'Current period',
          scanned: const ['Budgets'],
          steps: [
            intentStep('budget status', 'current period'),
            const ThinkingStep('Scanned your **active budgets**.'),
            resultStep('No active budgets set up.'),
          ],
        ),
      );
    }

    final catMap = await ctx.read(categoryMapProvider.future);

    // Specific-budget query: the user named a category that has an active budget.
    final specific = budgets.firstWhereOrNull((b) {
      final cat = catMap[int.tryParse(b.budget.categoryId)];
      final name = cat?.name.trim().toLowerCase();
      return name != null && name.isNotEmpty && lower.contains(name);
    });

    if (specific != null) {
      return _specific(ctx, catMap, specific);
    }

    // Aggregate list (ported verbatim).
    final lines = budgets.take(5).map((b) {
      final catName = catMap[int.tryParse(b.budget.categoryId)]?.name ?? 'Budget';
      final pct = b.progress.percentage.toStringAsFixed(0);
      final over = b.progress.percentage > 100;
      return '• $catName: ${ctx.money(b.progress.spent)} / ${ctx.money(b.progress.limit)} ($pct%${over ? ' over!' : ''})';
    }).join('\n');
    return HandlerResult(
      text: 'Your budgets this period:\n$lines',
      thinking: ThinkingInfo(
        dateFilter: 'Current period',
        scanned: const ['Budgets', 'Transactions'],
        steps: [
          intentStep('budget status', 'current period'),
          scannedStep(budgets.length, 'budgets'),
          resultStep(
              'Compared spend against **${budgets.length} budget${budgets.length == 1 ? '' : 's'}** this period.'),
        ],
      ),
    );
  }

  HandlerResult _specific(
    QueryContext ctx,
    Map<int, Category> catMap,
    ({Budget budget, BudgetProgress progress}) item,
  ) {
    final catName = catMap[int.tryParse(item.budget.categoryId)]?.name ?? 'Budget';
    final spent = item.progress.spent;
    final limit = item.progress.limit;
    final pct = item.progress.percentage;
    final pctLabel = pct.round();

    final BudgetStatus status;
    final String closing;
    final String stateWord;
    if (pct > 100) {
      status = BudgetStatus.over;
      closing = "You're over by ${ctx.money(spent - limit)}.";
      stateWord = 'over budget';
    } else if (pct >= 80) {
      status = BudgetStatus.approaching;
      closing = "You're getting close to the limit.";
      stateWord = 'approaching the limit';
    } else {
      status = BudgetStatus.withinBudget;
      closing = "You're within budget.";
      stateWord = 'within budget';
    }

    return HandlerResult(
      text:
          "You've spent ${ctx.money(spent)} of your ${ctx.money(limit)} $catName budget this period ($pctLabel%). $closing",
      thinking: ThinkingInfo(
        dateFilter: 'Current period',
        scanned: const ['Budgets', 'Transactions'],
        steps: [
          intentStep('budget status for $catName', 'current period'),
          const ThinkingStep('Scanned your **active budgets** and matching spend.'),
          resultStep(
              '**$catName** is at **$pctLabel%** of its **${ctx.money(limit)}** budget, $stateWord.'),
        ],
      ),
      vizPayload: BudgetStatusViz(
        spent: spent,
        budgeted: limit,
        status: status,
        caption: '${ctx.money(spent)} of ${ctx.money(limit)} ($pctLabel%)',
      ),
      followUps: status == BudgetStatus.over
          ? const [NavChipAction(label: 'View budget', route: '/more/budgets')]
          : const [],
    );
  }
}
