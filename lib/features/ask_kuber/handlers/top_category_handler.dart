import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../transactions/helpers/transaction_filters.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import '../models/viz_payload.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// Top spending category over a period. Ports `_processQuery`'s ranked-category
/// branch verbatim and augments the answer with a [TopCategoriesViz] of the top
/// 3-5 categories.
class TopCategoryHandler extends QueryHandler {
  const TopCategoryHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    if (!((lower.contains('most') || lower.contains('top')) &&
        (lower.contains('spent') ||
            lower.contains('category') ||
            lower.contains('categor')))) {
      return null;
    }

    final catCustomRange = ctx.extractor.customRange(lower);
    final allTime =
        catCustomRange == null && !ctx.extractor.hasExplicitTimeContext(lower);

    final Map<String, double> byCat = {};
    for (final t in ctx.txns.validForCalculations) {
      if (t.type != 'expense') continue;
      if (catCustomRange != null) {
        if (t.createdAt.isBefore(catCustomRange.from) ||
            !t.createdAt.isBefore(catCustomRange.to)) {
          continue;
        }
      } else if (!allTime) {
        if (t.createdAt.isBefore(ctx.monthStart) ||
            !t.createdAt.isBefore(ctx.monthEnd)) {
          continue;
        }
      }
      byCat[t.categoryId] = (byCat[t.categoryId] ?? 0) + t.amount;
    }

    final String periodLabel;
    final String thinkingDateFilter;
    if (catCustomRange != null) {
      periodLabel = 'in the past ${catCustomRange.label}';
      thinkingDateFilter =
          '${ctx.fmtDate(catCustomRange.from)} – ${ctx.fmtDate(ctx.today)}';
    } else if (allTime) {
      periodLabel = 'overall';
      thinkingDateFilter = 'All time';
    } else {
      periodLabel = 'this month';
      thinkingDateFilter = '${ctx.fmtDate(ctx.monthStart)} – ${ctx.fmtDate(ctx.today)}';
    }

    if (byCat.isEmpty) {
      return HandlerResult(
        text: 'No expense data found for that period.',
        thinking: ThinkingInfo(
          dateFilter: thinkingDateFilter,
          scanned: const ['Transactions', 'Categories'],
          steps: [
            intentStep('top expense category', periodLabel),
            scannedStep(ctx.txns.length, 'transactions',
                groups: ctx.categories.length,
                groupType: 'categories',
                dimension: 'category'),
            resultStep('No expense data in this period.'),
          ],
        ),
      );
    }

    final topEntry = byCat.entries.reduce((a, b) => a.value > b.value ? a : b);
    final topCat =
        ctx.categories.where((c) => c.id.toString() == topEntry.key).firstOrNull;
    final topName = topCat?.name ?? 'Unknown';
    final total = byCat.values.fold(0.0, (s, v) => s + v);
    final pct = total > 0 ? (topEntry.value / total * 100).round() : 0;

    return HandlerResult(
      text:
          'Your top spending category $periodLabel is $topName at ${ctx.money(topEntry.value)}.',
      thinking: ThinkingInfo(
        dateFilter: thinkingDateFilter,
        scanned: const ['Transactions', 'Categories'],
        steps: [
          intentStep('top expense category', periodLabel),
          scannedStep(ctx.txns.length, 'transactions',
              groups: ctx.categories.length,
              groupType: 'categories',
              dimension: 'category'),
          resultStep(
              '**$topName** ranks first at **${ctx.money(topEntry.value)}**, **$pct%** of spend $periodLabel.'),
        ],
      ),
      vizPayload: _buildViz(ctx, byCat),
    );
  }

  TopCategoriesViz _buildViz(QueryContext ctx, Map<String, double> byCat) {
    final total = byCat.values.fold(0.0, (s, v) => s + v);
    final ranked = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final rows = <CategoryVizRow>[];
    for (final entry in ranked.take(5)) {
      final cat =
          ctx.categories.where((c) => c.id.toString() == entry.key).firstOrNull;
      rows.add(CategoryVizRow(
        name: cat?.name ?? 'Unknown',
        color: Color(cat?.colorValue ?? 0xFF888888),
        amount: entry.value,
        percentOfTotal: total > 0 ? entry.value / total : 0,
      ));
    }
    return TopCategoriesViz(rows);
  }
}
