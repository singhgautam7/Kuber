import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../data/recurring_repository.dart';
import '../data/recurring_rule.dart';
import '../providers/recurring_provider.dart';

/// Shows the recurring rule detail bottom sheet.
void showRecurringDetailSheet(
  BuildContext context,
  WidgetRef ref,
  RecurringRule rule,
) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: KuberColors.surfaceCard,
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
    ) ?? 'Unknown';

    final iconData = cat != null
        ? IconMapper.fromString(cat.icon)
        : Icons.category_outlined;
    final iconColor = cat != null
        ? harmonizeCategory(context, Color(cat.colorValue))
        : KuberColors.textSecondary;
    final categoryName = cat?.name ?? 'Unknown';

    final isIncome = rule.type == 'income';
    final amountColor = isIncome ? KuberColors.income : KuberColors.expense;

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
        ? KuberColors.textSecondary
        : isExpired
            ? KuberColors.expense
            : KuberColors.income;

    final frequencyLabel = rule.frequency == 'custom'
        ? 'Every ${rule.customDays ?? 1} days'
        : rule.frequency[0].toUpperCase() + rule.frequency.substring(1);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KuberColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Header row: icon + name + close
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
                          color: KuberColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'TRANSACTION DETAIL',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: KuberColors.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: KuberColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: KuberColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Recurring amount label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RECURRING AMOUNT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: KuberColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xs),

            // Amount
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.format(rule.amount),
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // 2×2 detail grid
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

            // Status row
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.lg,
                vertical: KuberSpacing.md,
              ),
              decoration: BoxDecoration(
                color: KuberColors.surfaceMuted,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Row(
                children: [
                  Text(
                    'CURRENT STATUS',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: KuberColors.textSecondary,
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

            // Edit button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  context.push('/recurring/edit', extra: rule);
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  'Edit Transaction',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KuberColors.textPrimary,
                  side: BorderSide(color: KuberColors.border),
                  padding:
                      const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),

            // Pause/Resume button
            if (!isExpired)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(recurringListProvider.notifier)
                        .togglePause(rule);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  icon: Icon(
                    isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isPaused ? 'Resume Automation' : 'Pause Automation',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KuberColors.textPrimary,
                    side: BorderSide(color: KuberColors.border),
                    padding:
                        const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: KuberSpacing.sm),

            // Delete button
            TextButton.icon(
              onPressed: () {
                ref.read(recurringListProvider.notifier).delete(rule.id);
                Navigator.of(context, rootNavigator: true).pop();
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(
                'Delete Transaction',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: KuberColors.expense,
              ),
            ),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: KuberSpacing.md,
      ),
      decoration: BoxDecoration(
        color: KuberColors.surfaceMuted,
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
              color: KuberColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KuberColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
