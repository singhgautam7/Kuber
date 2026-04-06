import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
        'Unknown';

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
        ? 'PAUSED'
        : isExpired
            ? 'EXPIRED'
            : rule.frequency == 'custom'
                ? 'ACTIVE \u2022 CUSTOM'
                : 'ACTIVE';
    final statusColor = isPaused
        ? cs.onSurfaceVariant
        : isExpired
            ? cs.error
            : cs.tertiary;

    final frequencyLabel = rule.frequency == 'custom'
        ? 'Every ${rule.customDays ?? 1} days'
        : rule.frequency[0].toUpperCase() + rule.frequency.substring(1);

    final createdDateStr =
        DateFormat('MMM d, yyyy').format(rule.createdAt).toUpperCase();

    return KuberBottomSheet(
      title: rule.name,
      subtitle: 'CREATED ON $createdDateStr',
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
            'RECURRING ${rule.type.toUpperCase()} AMOUNT',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            '${isIncome ? '+' : '−'}₹${rule.amount.toStringAsFixed(0)}',
            style: GoogleFonts.inter(
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
                  label: 'FREQUENCY',
                  value: frequencyLabel.toUpperCase(),
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: _DetailCell(
                  label: 'STATUS',
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
                  label: 'ACCOUNT',
                  value: accountName.toUpperCase(),
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: _DetailCell(
                  label: 'NEXT DUE',
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
                  label: 'Edit',
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
                  label: isPaused ? 'Resume' : 'Pause',
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
                      builder: (_) => RecurringHistorySheet(rule: rule),
                    );
                  },
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Delete',
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
          'Delete automation?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'The recurring rule for "${rule.name}" will be permanently deleted.',
          style: GoogleFonts.inter(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
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
              color: valueColor ?? cs.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
