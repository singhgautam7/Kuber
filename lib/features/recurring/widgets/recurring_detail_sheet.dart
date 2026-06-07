import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../data/recurring_rule.dart';
import '../providers/recurring_provider.dart';
import '../data/recurring_repository.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/app_button.dart';
import '../widgets/recurring_history_sheet.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';

/// Shows the recurring rule detail bottom sheet.
void showRecurringDetailSheet(
  BuildContext context,
  WidgetRef ref,
  RecurringRule rule,
) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => RecurringDetailSheet(rule: rule),
  );
}

class RecurringDetailSheet extends ConsumerWidget {
  final RecurringRule rule;

  const RecurringDetailSheet({super.key, required this.rule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categoryMap = ref.watch(categoryMapProvider);
    final accountsAsync = ref.watch(accountListProvider);

    final cat = categoryMap.whenOrNull(
      data: (map) {
        final catId = int.tryParse(rule.categoryId);
        return catId != null ? map[catId] : null;
      },
    );

    final accountName = accountsAsync.whenOrNull(
          data: (accs) {
            try {
              return accs
                  .firstWhere((a) => a.id.toString() == rule.accountId)
                  .name;
            } catch (_) {
              return null;
            }
          },
        ) ??
        context.l10n.unknownLabel;

    final iconData = cat != null
        ? IconMapper.fromString(cat.icon)
        : Icons.category_outlined;
    final iconColor = cat != null
        ? Color(cat.colorValue)
        : cs.onSurfaceVariant;

    final isIncome = rule.type == 'income';
    final amountColor = isIncome ? cs.tertiary : cs.error;

    final isPaused = rule.isPaused;
    final isExpired = RecurringRepository.isExpired(rule);

    final statusLabel = isPaused
        ? context.l10n.pausedUpper
        : isExpired
            ? context.l10n.expiredUpper
            : rule.frequency == 'custom'
                ? context.l10n.activeCustomUpper
                : context.l10n.activeUpper;
    final statusColor = isPaused
        ? cs.onSurfaceVariant
        : isExpired
            ? cs.error
            : cs.tertiary;

    final frequencyLabel = rule.frequency == 'custom'
        ? context.l10n.freqEveryNDays('${rule.customDays ?? 1}')
        : _freqTitle(context, rule.frequency);

    final createdDateStr =
        DateFormat('MMM d, yyyy').format(rule.createdAt).toUpperCase();

    return KuberBottomSheet(
      title: rule.name,
      subtitle: context.l10n.createdOnUpper(createdDateStr),
      leadingIcon: CategoryIcon.square(
        icon: iconData,
        rawColor: iconColor,
        size: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Recurring amount label ────────────────────────────────────
          Text(
            context.l10n.recurringAmountLabel(
                (rule.type == 'income' ? context.l10n.incomeLabel : context.l10n.expenseLabel)
                    .toUpperCase()),
            style: localeFont(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            '${isIncome ? '+' : '−'}₹${rule.amount.toStringAsFixed(0)}',
            style: localeFont(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: amountColor,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),

          // ── Details Grid ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _DetailCell(
                  label: context.l10n.frequencyUpper,
                  value: frequencyLabel.toUpperCase(),
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: _DetailCell(
                  label: context.l10n.statusUpper,
                  value: statusLabel,
                  valueColor: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _DetailCell(
                  label: context.l10n.accountUpper,
                  value: accountName.toUpperCase(),
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: _DetailCell(
                  label: context.l10n.nextDue.toUpperCase(),
                  value: DateFormat('MMM d').format(rule.nextDueAt).toUpperCase(),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.lg),

          // ── Actions ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: context.l10n.editLabel,
                  icon: Icons.edit_outlined,
                  type: AppButtonType.normal,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: AppButton(
                  label: isPaused ? context.l10n.resumeLabel : context.l10n.pauseLabel,
                  icon: isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  type: AppButtonType.normal,
                  onPressed: () {
                    ref
                        .read(recurringListProvider.notifier)
                        .togglePause(rule);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: context.l10n.historyLabel,
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
                      builder: (_) => RecurringHistorySheet(rule: rule),
                    );
                  },
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: AppButton(
                  label: context.l10n.deleteLabel,
                  icon: Icons.delete_outline_rounded,
                  type: AppButtonType.danger,
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.xs),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.sm),
          side: BorderSide(color: cs.outline, width: 1),
        ),
        title: Text(
          context.l10n.deleteAutomationConfirm,
          style: localeFont(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          context.l10n.deleteAutomationBody(rule.name),
          style: localeFont(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancelLabel, style: localeFont()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
            ),
            onPressed: () {
              ref.read(recurringListProvider.notifier).delete(rule.id);
              Navigator.pop(ctx);
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(context.l10n.deleteLabel),
          ),
        ],
      ),
    );
  }
}

String _freqTitle(BuildContext context, String value) {
  final l = context.l10n;
  return switch (value) {
    'daily' => l.freqDaily,
    'weekly' => l.freqWeekly,
    'biweekly' => l.freqBiweekly,
    'yearly' => l.freqYearly,
    'quarterly' => l.freqQuarterly,
    'custom' => l.freqCustom,
    _ => l.freqMonthly,
  };
}

class _DetailCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailCell({required this.label, required this.value, this.valueColor});

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
            style: localeFont(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            value,
            style: localeFont(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? cs.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}