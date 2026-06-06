import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../categories/data/category.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/budget.dart';
import '../providers/budget_provider.dart';

class BudgetHistorySheet extends ConsumerWidget {
  final Budget budget;
  final Category category;

  const BudgetHistorySheet({
    super.key,
    required this.budget,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(budgetHistoryProvider(budget));

    return KuberBottomSheet(
      title: context.l10n.budgetHistory,
      subtitle: category.name,
      child: historyAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Center(
            child: Text(
              '${context.l10n.errorLabel}: $err',
              style: localeFont(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
        data: (history) {
          // Filter out months with zero spent to avoid noise, but keep
          // all months so the user can see every period.
          if (history.isEmpty) {
            return KuberEmptyState(
              icon: Icons.history_rounded,
              title: context.l10n.noHistoryYet,
              description: context.l10n.budgetHistoryEmptyDesc,
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < history.length; i++) ...[
                _MonthHistoryCard(entry: history[i]),
                if (i < history.length - 1)
                  const SizedBox(height: KuberSpacing.md),
              ],
              const SizedBox(height: KuberSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}

// ── Month card ────────────────────────────────────────────────────────────────

class _MonthHistoryCard extends ConsumerWidget {
  final BudgetMonthHistory entry;

  const _MonthHistoryCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);

    final isOver = entry.isOverBudget;
    final progress = (entry.percentage / 100).clamp(0.0, 1.0);

    // Colors
    final statusColor = isOver ? cs.error : cs.primary;
    final amountColor = isOver ? cs.error : cs.primary;

    // Status label
    final statusLabel = isOver ? context.l10n.overBudget : context.l10n.underBudget;

    // Right detail: "₹X EXTRA" if over, "X% LEFT" if under
    final String rightDetail;
    if (isOver) {
      final extra = entry.spent - entry.budgetAmount;
      rightDetail = '${formatter.formatCurrency(extra)} EXTRA';
    } else {
      final pctLeft = 100 - entry.percentage;
      rightDetail = '${pctLeft.toStringAsFixed(0)}% LEFT';
    }

    // Date range: "01 MMM YYYY – DD MMM YYYY"
    final startFmt = DateFormat('dd MMM yyyy').format(entry.startDate).toUpperCase();
    final endFmt = DateFormat('dd MMM yyyy').format(entry.endDate).toUpperCase();
    final dateRange = '$startFmt – $endFmt';

    // Month header: "Sep 2025"
    final monthLabel = DateFormat('MMM yyyy').format(entry.startDate);

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: month name + spent amount ────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthLabel,
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateRange,
                      style: localeFont(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatter.formatCurrency(entry.spent),
                    style: localeFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ALLOCATED: ${formatter.formatCurrency(entry.budgetAmount)}',
                    style: localeFont(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: KuberSpacing.md),

          // ── Progress bar ───────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(KuberRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.outline.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),

          const SizedBox(height: KuberSpacing.sm),

          // ── Bottom row: status label + right detail ────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusLabel,
                style: localeFont(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                rightDetail,
                style: localeFont(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}