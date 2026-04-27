import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../settings/providers/settings_provider.dart';
import 'data/bill.dart';
import 'providers/bills_provider.dart';

class ViewBillSheet extends ConsumerWidget {
  final Bill bill;

  const ViewBillSheet({super.key, required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);

    return KuberBottomSheet(
      title: bill.name,
      subtitle: DateFormat('d MMM yyyy').format(bill.createdAt),
      actions: Column(
        children: [
          AppButton(
            label: 'Add to Lent / Borrow',
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Edit',
                  type: AppButtonType.outline,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    context.push('/more/tools/bill-splitter/edit', extra: bill);
                  },
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Delete',
                  type: AppButtonType.danger,
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  label: 'Total',
                  value: formatter.formatCurrency(bill.totalAmount, symbol: currency.symbol),
                  valueColor: cs.primary,
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: _InfoChip(label: 'Paid by', value: bill.paidByPersonName),
              ),
              const SizedBox(width: KuberSpacing.sm),
              _SplitTypeBadge(splitType: bill.splitType),
            ],
          ),
          const SizedBox(height: KuberSpacing.xl),
          Text(
            'BREAKDOWN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: KuberSpacing.md),
          ...bill.participants.map((p) {
            final isPayer = p.personName == bill.paidByPersonName;
            return Padding(
              padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
              child: Row(
                children: [
                  PersonAvatar(name: p.personName, size: PersonAvatarSize.medium),
                  const SizedBox(width: KuberSpacing.md),
                  Expanded(
                    child: Text(
                      p.personName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  if (isPayer)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(KuberRadius.sm),
                      ),
                      child: Text(
                        'Paid ✓',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.tertiary,
                        ),
                      ),
                    )
                  else
                    Text(
                      formatter.formatCurrency(p.share, symbol: currency.symbol),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bill?'),
        content: Text('Delete "${bill.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        ref.read(billsListProvider.notifier).delete(bill.id);
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? cs.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SplitTypeBadge extends StatelessWidget {
  final String splitType;

  const _SplitTypeBadge({required this.splitType});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.sm,
        vertical: KuberSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Text(
        splitType[0].toUpperCase() + splitType.substring(1),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
    );
  }
}
