import 'widgets/bs_squircle_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../settings/providers/settings_provider.dart';
import 'data/bill.dart';
import 'providers/bills_provider.dart';
import 'providers/bill_net_provider.dart';
import 'widgets/bs_avatar.dart';

class ViewBillSheet extends ConsumerWidget {
  final Bill bill;
  const ViewBillSheet({super.key, required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final splitLabel = _splitLabel(bill.splitType);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: cs.outline), left: BorderSide(color: cs.outline), right: BorderSide(color: cs.outline)),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),

            // Hero header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormat('d MMM yyyy').format(bill.createdAt).toUpperCase()} · $splitLabel SPLIT',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: cs.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bill.name,
                              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: cs.onSurface),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      BsSquircleButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                        icon: Icons.close_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Total + paid-by row
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: ShapeDecoration(
                      color: cs.surfaceContainerHigh,
                      shape: bsSquircle(12, side: BorderSide(color: cs.outline),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOTAL', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: cs.onSurfaceVariant)),
                              const SizedBox(height: 2),
                              Text(
                                formatter.formatCurrency(bill.totalAmount, symbol: currency.symbol),
                                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.7, color: cs.onSurface, fontFeatures: const [FontFeature.tabularFigures()]),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 48, color: cs.outline),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PAID BY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: cs.onSurfaceVariant)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  BsAvatar(name: bill.paidByPersonName, size: 28),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      bill.paidByPersonName,
                                      style: GoogleFonts.inter(
                                        fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.1,
                                        color: bill.paidByPersonName == kYouName ? cs.primary : cs.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: cs.outline),

            // Breakdown scroll area
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BREAKDOWN · ${bill.participants.length} PEOPLE',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: ShapeDecoration(
                        color: cs.surfaceContainerHigh,
                        shape: bsSquircle(12, side: BorderSide(color: cs.outline),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: bill.participants.asMap().entries.map((entry) {
                          final i = entry.key;
                          final p = entry.value;
                          final isLast = i == bill.participants.length - 1;
                          final isPayer = p.personName == bill.paidByPersonName;

                          String statusLabel;
                          Color statusColor;
                          if (isPayer) {
                            statusLabel = 'PAID THE BILL';
                            statusColor = cs.primary;
                          } else if (bill.paidByPersonName == kYouName) {
                            statusLabel = 'OWES YOU';
                            statusColor = KuberColors.income;
                          } else if (p.personName == kYouName) {
                            statusLabel = 'YOU OWE';
                            statusColor = KuberColors.expense;
                          } else {
                            statusLabel = 'OWES';
                            statusColor = cs.onSurfaceVariant;
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: isPayer ? cs.primary.withValues(alpha: 0.08) : null,
                              border: isLast ? null : Border(bottom: BorderSide(color: cs.outline)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                BsAvatar(name: p.personName, size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.personName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.1)),
                                      const SizedBox(height: 2),
                                      Text(statusLabel, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.7, color: statusColor)),
                                    ],
                                  ),
                                ),
                                if (!isPayer)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        formatter.formatCurrency(p.share, symbol: currency.symbol),
                                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: statusColor, fontFeatures: const [FontFeature.tabularFigures()]),
                                      ),
                                      if (bill.splitType == 'percentage' && p.rawInput != null)
                                        Text('${p.rawInput!.toStringAsFixed(0)}% of total', style: GoogleFonts.inter(fontSize: 10.5, color: cs.onSurfaceVariant)),
                                      if (bill.splitType == 'fraction' && p.rawInput != null)
                                        Text('${p.rawInput!.toStringAsFixed(0)} parts', style: GoogleFonts.inter(fontSize: 10.5, color: cs.onSurfaceVariant)),
                                    ],
                                  )
                                else
                                  Text(
                                    formatter.formatCurrency(bill.totalAmount, symbol: currency.symbol),
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: cs.primary, fontFeatures: const [FontFeature.tabularFigures()]),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Action footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outline))),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Edit',
                      type: AppButtonType.outline,
                      icon: Icons.edit_rounded,
                      height: 48,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        context.push('/more/tools/bill-splitter/edit', extra: bill);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Trash button
                  GestureDetector(
                    onTap: () => _confirmDelete(context, ref),
                    child: Container(
                      width: 48, height: 48,
                      decoration: ShapeDecoration(
                        color: KuberColors.expenseSubtle,
                        shape: bsSquircle(10, side: const BorderSide(color: Color(0x59EF4444)),
                        ),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: KuberColors.expense, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        ref.read(billsListProvider.notifier).delete(bill.id);
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  String _splitLabel(String type) => switch (type) {
    'equal' => 'EQUAL',
    'unequal' => 'CUSTOM',
    'percentage' => 'PERCENT',
    'fraction' => 'FRACTION',
    _ => type.toUpperCase(),
  };
}
