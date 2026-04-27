import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import 'data/bill.dart';
import 'providers/bills_provider.dart';
import 'view_bill_sheet.dart';

class BillSplitterScreen extends ConsumerWidget {
  const BillSplitterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final billsAsync = ref.watch(billsListProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/more/tools/bill-splitter/add'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      body: billsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        ),
        data: (bills) => CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KuberAppBar(
                title: 'Bill Splitter',
                showBack: true,
                infoConfig: InfoConstants.billSplitter,
              ),
            ),
            const SliverToBoxAdapter(
              child: KuberPageHeader(
                title: 'Bill Splitter',
                description: 'Split bills fairly among friends',
              ),
            ),
            if (bills.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: KuberSpacing.lg),
                      Text(
                        'No bills yet',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      Text(
                        'Tap + to split your first bill',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  KuberSpacing.lg,
                  0,
                  KuberSpacing.lg,
                  KuberSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (i.isOdd) return const SizedBox(height: KuberSpacing.sm);
                      final bill = bills[i ~/ 2];
                      return _BillCard(
                        bill: bill,
                        formattedAmount: formatter.formatCurrency(
                          bill.totalAmount,
                          symbol: currency.symbol,
                        ),
                        onTap: () => _showViewSheet(context, bill),
                      );
                    },
                    childCount: bills.length * 2 - 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showViewSheet(BuildContext context, Bill bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, ctrl) => ViewBillSheet(bill: bill),
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill;
  final String formattedAmount;
  final VoidCallback onTap;

  const _BillCard({
    required this.bill,
    required this.formattedAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.receipt_long_rounded,
                  color: cs.primary, size: 22),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Paid by ${bill.paidByPersonName} · ${bill.participants.length} people · ${DateFormat('d MMM').format(bill.createdAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Text(
              formattedAmount,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
