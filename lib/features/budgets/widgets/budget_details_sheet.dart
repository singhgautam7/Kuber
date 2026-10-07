import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/info_table.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../categories/data/category.dart';
import '../data/budget.dart';
import '../providers/budget_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/sheet_button_section.dart';
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
          subtitle: context.l10n.monthlyBudgetPlan,
          leadingIcon: CategoryIcon.square(
            icon: IconMapper.fromString(category.icon),
            rawColor: Color(category.colorValue),
            size: 48,
          ),
          // Edit + Pause / Resume in the row; History and Delete fall into the
          // overflow (⋯) menu, like the account view sheet.
          actions: SheetButtonSection(
            padding: EdgeInsets.zero,
            actions: [
              SheetAction(
                label: context.l10n.editLabel,
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/budgets/edit', extra: budget);
                },
              ),
              SheetAction(
                label: budget.isActive
                    ? context.l10n.pauseLabel
                    : context.l10n.resumeLabel,
                icon: budget.isActive
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                onPressed: () {
                  ref
                      .read(budgetListProvider.notifier)
                      .toggleActive(budget.id, !budget.isActive);
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              SheetAction(
                label: context.l10n.historyLabel,
                icon: Icons.history_rounded,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    useRootNavigator: true,
                    backgroundColor: cs.surfaceContainer,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(KuberShape.extraLarge),
                      ),
                    ),
                    builder: (_) =>
                        BudgetHistorySheet(budget: budget, category: category),
                  );
                },
              ),
              SheetAction(
                label: context.l10n.deleteLabel,
                icon: Icons.delete_outline_rounded,
                destructive: true,
                onPressed: () => _confirmDeleteBudget(context, ref, budget.id),
              ),
            ],
          ),
          child: progressAsync.when(
            data: (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Board 3.18 view sheet: amount of limit + status pill, wavy
                // bar, the reset / expiry line, then the details table.
                Builder(
                  builder: (context) {
                    final fmt = ref.watch(formatterProvider);
                    final tt = Theme.of(context).textTheme;
                    final pct = p.percentage;
                    final (state, tone, label) = pct >= 100
                        ? (
                            KuberProgressState.overLimit,
                            KuberTone.expense,
                            'Over budget',
                          )
                        : pct >= 80
                        ? (
                            KuberProgressState.nearLimit,
                            KuberTone.warning,
                            'Near limit',
                          )
                        : (
                            KuberProgressState.normal,
                            KuberTone.secondary,
                            'On track',
                          );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              fmt.formatCurrency(p.spent),
                              style: tt.headlineMedium!.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'of ${fmt.formatCurrency(p.limit)}',
                                style: tt.bodyMedium!.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                            KuberPill(label: label, tone: tone),
                          ],
                        ),
                        const SizedBox(height: KuberSpace.md),
                        KuberLinearProgress(
                          value: (pct / 100).clamp(0.0, 1.0),
                          state: state,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (budget.isRecurring
                                  ? context.l10n.budgetResetsIn(p.daysRemaining)
                                  : context.l10n.budgetExpiresIn(
                                      p.daysRemaining,
                                    ))
                              .toUpperCase(),
                          style: tt.labelSmall!.copyWith(
                            letterSpacing: 0.6,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: KuberSpace.lg),
                InfoTable(
                  rows: [
                    InfoTableDataRow(
                      label: context.l10n.createdOn,
                      value: DateFormat('MMM d, yyyy').format(budget.createdAt),
                    ),
                    InfoTableDataRow(
                      label: budget.isRecurring
                          ? context.l10n.renewsOn
                          : context.l10n.expiresOn,
                      value: DateFormat('MMM d, yyyy').format(p.endDate),
                    ),
                    InfoTableDataRow(
                      label: context.l10n.startedOn,
                      value: DateFormat('MMM d, yyyy').format(budget.startDate),
                    ),
                    InfoTableDataRow(
                      label: sentenceCase(context.l10n.statusUpper),
                      value: budget.isActive
                          ? context.l10n.activeLabel
                          : context.l10n.pausedLabel,
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpace.lg),
                KuberSectionHeader(title: context.l10n.activeAlerts),
                if (alerts.isEmpty)
                  Text(
                    context.l10n.noAlertsSet,
                    style: localeFont(color: cs.onSurfaceVariant),
                  )
                else
                  Column(
                    children: alerts
                        .map(
                          (a) => _AlertRow(
                            alert: a,
                            currentSpent: progressAsync.valueOrNull?.spent ?? 0,
                            budgetAmount: budget.amount,
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: KuberSpace.xs),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberShape.extraLarge),
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        title: Text(
          context.l10n.deleteBudgetConfirm,
          style: localeFont(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        content: Text(
          context.l10n.deleteBudgetBody(category.name),
          style: localeFont(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancelLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberShape.small),
              ),
            ),
            onPressed: () {
              ref.read(budgetListProvider.notifier).delete(id);
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(context).pop(); // close sheet
            },
            child: Text(context.l10n.deleteLabel),
          ),
        ],
      ),
    );
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

    // Notification Icon & Color
    final notificationIcon = alert.enableNotification
        ? Icons.notifications_active_outlined
        : Icons.notifications_off_outlined;
    final notificationColor = alert.enableNotification
        ? cs.primary
        : cs.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(notificationIcon, size: 20, color: notificationColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: cs.onSurface),
            ),
          ),
          KuberPill(
            label: sentenceCase(status),
            tone: isReached ? KuberTone.secondary : KuberTone.neutral,
          ),
        ],
      ),
    );
  }
}
