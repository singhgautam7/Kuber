import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../categories/data/category.dart';
import '../data/budget.dart';
import '../providers/budget_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../core/utils/icon_mapper.dart';
import 'budget_history_sheet.dart';

class BudgetDetailsSheet extends ConsumerWidget {
  final int budgetId;
  final Category category;

  const BudgetDetailsSheet({
    super.key,
    required this.budgetId,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final budgetAsync = ref.watch(budgetByIdProvider(budgetId));

    return budgetAsync.when(
      data: (budget) {
        if (budget == null) return const SizedBox.shrink();

        final progressAsync = ref.watch(budgetProgressProvider(budget));
        final alerts = budget.alerts;

        return KuberBottomSheet(
          title: category.name,
          subtitle: 'MONTHLY BUDGET PLAN',
          leadingIcon: CategoryIcon.square(
            icon: IconMapper.fromString(category.icon),
            rawColor: Color(category.colorValue),
            size: 48,
          ),
          child: progressAsync.when(
            data: (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT SPENDING',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: ref
                                      .watch(formatterProvider)
                                      .formatCurrency(p.spent),
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' / ${ref.watch(formatterProvider).formatCurrency(p.limit)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'UTILIZATION',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ref
                                .watch(formatterProvider)
                                .formatPercentage(p.percentage),
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: _getUtilizationColor(p.percentage, cs),
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: (p.percentage / 100).clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: cs.outline.withValues(alpha: 0.1),
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ref.watch(formatterProvider).formatCurrency(0),
                        style: GoogleFonts.inter(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                    Text(
                        ref
                            .watch(formatterProvider)
                            .formatCompactCurrency(p.limit),
                        style: GoogleFonts.inter(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'BUDGET DETAILS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: KuberSpacing.xs),
                Row(
                  children: [
                    Expanded(
                        child: _DetailCell(
                      label: 'CREATED ON',
                      value:
                          DateFormat('MMM d, yyyy').format(budget.createdAt),
                    )),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                        child: _DetailCell(
                      label: budget.isRecurring ? 'RENEWS ON' : 'EXPIRES ON',
                      value: DateFormat('MMM d, yyyy').format(p.endDate),
                    )),
                  ],
                ),
                const SizedBox(height: KuberSpacing.sm),
                Row(
                  children: [
                    Expanded(
                        child: _DetailCell(
                      label: 'STARTED ON',
                      value: DateFormat('MMM d, yyyy').format(budget.startDate),
                    )),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                        child: _DetailCell(
                      label: 'STATUS',
                      value: budget.isActive ? 'Active' : 'Paused',
                    )),
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                Text(
                  'ACTIVE ALERTS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: KuberSpacing.xs),
                if (alerts.isEmpty)
                  Text('No alerts set',
                      style: GoogleFonts.inter(color: cs.onSurfaceVariant))
                else
                  Column(
                    children: alerts
                        .map((a) => _AlertRow(
                              alert: a,
                              currentSpent:
                                  progressAsync.valueOrNull?.spent ?? 0,
                              budgetAmount: budget.amount,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: KuberSpacing.lg),
                Text(
                  'ACTIONS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: KuberSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        type: AppButtonType.normal,
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/budgets/edit', extra: budget);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: budget.isActive ? 'Pause' : 'Resume',
                        icon: budget.isActive
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        type: AppButtonType.normal,
                        onPressed: () {
                          ref
                              .read(budgetListProvider.notifier)
                              .toggleActive(budget.id, !budget.isActive);
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'History',
                        icon: Icons.history_rounded,
                        type: AppButtonType.primary,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            useRootNavigator: true,
                            backgroundColor: cs.surfaceContainer,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(KuberRadius.lg),
                              ),
                            ),
                            builder: (_) => BudgetHistorySheet(budget: budget, category: category),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        type: AppButtonType.danger,
                        onPressed: () => _confirmDeleteBudget(
                            context, ref, budget.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xs),
              ],
            ),
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => Text('Error: $err'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          Center(child: Text('Error loading budget details: $err')),
    );

  }

  void _confirmDeleteBudget(BuildContext context, WidgetRef ref, int id) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.sm),
          side: BorderSide(color: cs.outline, width: 1),
        ),
        title: Text('Delete budget?',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            )),
        content: Text('The budget for "${category.name}" will be permanently deleted.',
            style: GoogleFonts.inter(
              color: cs.onSurfaceVariant,
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
            ),
            onPressed: () {
              ref.read(budgetListProvider.notifier).delete(id);
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(context).pop(); // close sheet
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getUtilizationColor(double percentage, ColorScheme cs) {
    if (percentage >= 100) return cs.error;
    if (percentage >= 66) return Colors.orangeAccent;
    if (percentage >= 33) return Colors.amber;
    return Colors.green;
  }
}

class _AlertRow extends ConsumerWidget {
  final BudgetAlert alert;
  final double currentSpent;
  final double budgetAmount;
  const _AlertRow({
    required this.alert,
    required this.currentSpent,
    required this.budgetAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final label = alert.type == BudgetAlertType.percentage
        ? 'At ${ref.watch(formatterProvider).formatPercentage(alert.value)}'
        : 'At ${ref.watch(formatterProvider).formatCurrency(alert.value)}';

    final threshold = alert.type == BudgetAlertType.percentage
        ? budgetAmount * (alert.value / 100)
        : alert.value;

    final isReached = currentSpent >= threshold;
    final status = isReached ? 'REACHED' : 'UPCOMING';
    final statusColor = isReached ? cs.primary : cs.onSurfaceVariant;

    // Notification Icon & Color
    final notificationIcon = alert.enableNotification
        ? Icons.notifications_active_outlined
        : Icons.notifications_off_outlined;
    final notificationColor =
        alert.enableNotification ? cs.primary : cs.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            notificationIcon,
            size: 20,
            color: notificationColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500, color: cs.onSurface),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final String label;
  final String value;

  const _DetailCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: KuberSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
