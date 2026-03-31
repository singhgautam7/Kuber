import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;
import '../data/recurring_repository.dart';
import '../data/recurring_rule.dart';
import '../providers/recurring_provider.dart';
import 'recurring_history_sheet.dart';

/// Shows the recurring rule detail bottom sheet.
void showRecurringDetailSheet(
  BuildContext context,
  WidgetRef ref,
  RecurringRule rule,
) {
  final cs = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: cs.surfaceContainer,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
    ),
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
        ? harmonizeCategory(context, Color(cat.colorValue))
        : cs.onSurfaceVariant;
    final categoryName = cat?.name ?? 'Unknown';

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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // ── Header row: icon + name + close ──────────────────────────
            Row(
              children: [
                CategoryIcon.square(
                  icon: iconData,
                  rawColor: iconColor,
                  size: 48,
                ),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'CREATED ON $createdDateStr',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.surfaceContainerHigh,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.xl),

            // ── Recurring amount label ────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RECURRING AMOUNT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xs),

            // ── Amount ───────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ref.watch(formatterProvider).formatCurrency(rule.amount),
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // ── 2×2 detail grid ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _DetailCell(
                    label: 'FREQUENCY',
                    value: frequencyLabel,
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
                Expanded(
                  child: _DetailCell(
                    label: 'NEXT PAYMENT',
                    value: DateFormat('MMM d, yyyy').format(rule.nextDueAt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _DetailCell(
                    label: 'CATEGORY',
                    value: categoryName,
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
                Expanded(
                  child: _DetailCell(
                    label: 'PAY FROM',
                    value: accountName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.sm),

            // ── Status row ───────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.lg,
                vertical: KuberSpacing.md,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Row(
                children: [
                  Text(
                    'CURRENT STATUS',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(KuberRadius.sm),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // ── Row 1: Edit + Pause/Resume ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    type: AppButtonType.normal,
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      context.push('/recurring/edit', extra: rule);
                    },
                  ),
                ),
                const SizedBox(width: KuberSpacing.md),
                if (!isExpired)
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
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: KuberSpacing.md),

            // ── Row 2: History + Delete ──────────────────────────────────
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
            const SizedBox(height: KuberSpacing.lg),
          ],
        ),
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
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
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
