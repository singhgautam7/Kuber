import 'widgets/bs_squircle_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import 'data/bill.dart';
import 'providers/bill_net_provider.dart';
import 'providers/bills_provider.dart';
import 'view_bill_sheet.dart';
import 'widgets/bs_avatar.dart';

class BillSplitterScreen extends ConsumerWidget {
  const BillSplitterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final billsAsync = ref.watch(billsListProvider);
    final netSummaryAsync = ref.watch(netSummaryProvider);
    final personNetAsync = ref.watch(personNetListProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: KuberAppBar(
              title: '',
              showBack: true,
              showHome: true,
              infoConfig: InfoConstants.billSplitter,
            ),
          ),

          // ── Page Header with action button ─────────────────────────────
          SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Split &\nSettle Up',
              description: 'Track who owes whom across your shared bills.',
              onAction: () => context.push('/more/tools/bill-splitter/add'),
              actionTooltip: 'New Bill',
            ),
          ),

          // ── NET BALANCE card ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: netSummaryAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (summary) => _NetBalanceCard(summary: summary),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── BY PERSON section ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: personNetAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (netList) => netList.isEmpty
                  ? const SizedBox.shrink()
                  : _ByPersonSection(netList: netList),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── RECENT BILLS section ───────────────────────────────────────
          SliverToBoxAdapter(
            child: billsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (bills) => bills.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: KuberSpacing.xxl),
                      child: KuberEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No bills yet',
                        description: 'Tap + to split your first bill',
                        actionLabel: 'Add Bill',
                        onAction: () =>
                            context.push('/more/tools/bill-splitter/add'),
                      ),
                    )
                  : _RecentBillsSection(bills: bills),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── NET BALANCE CARD ─────────────────────────────────────────────────────────

class _NetBalanceCard extends StatelessWidget {
  final NetSummary summary;

  const _NetBalanceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPositive = summary.net >= 0;
    final netColor = isPositive ? KuberColors.income : KuberColors.expense;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: ShapeDecoration(
          color: cs.surfaceContainer,
          shape: bsSquircle(16, side: BorderSide(color: cs.outline),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NET BALANCE label
            Text(
              'NET BALANCE',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),

            // Big number
            Text(
              '${isPositive ? '+' : ''}${formatter.format(summary.net)}',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.4,
                color: netColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),

            // Sub-line
            Text(
              'across ${summary.activePeople} ${summary.activePeople == 1 ? 'person' : 'people'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),

            // Two side-by-side mini cards
            Row(
              children: [
                Expanded(
                  child: _NetMiniCard(
                    label: "YOU'LL RECEIVE",
                    amount: summary.youReceive,
                    color: KuberColors.income,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _NetMiniCard(
                    label: 'YOU OWE',
                    amount: summary.youOwe,
                    color: KuberColors.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NetMiniCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _NetMiniCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: cs.surfaceContainerHigh,
        shape: bsSquircle(14, side: BorderSide(color: cs.outline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(amount),
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── BY PERSON SECTION ─────────────────────────────────────────────────────────

class _ByPersonSection extends StatelessWidget {
  final List<PersonNet> netList;

  const _ByPersonSection({required this.netList});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BY PERSON',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                'VIEW ALL',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),

        // Card with rows
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
          child: Container(
            decoration: ShapeDecoration(
              color: cs.surfaceContainer,
              shape: bsSquircle(14, side: BorderSide(color: cs.outline),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: netList
                  .asMap()
                  .entries
                  .map((entry) => _PersonRow(
                        person: entry.value,
                        isLast: entry.key == netList.length - 1,
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonRow extends StatelessWidget {
  final PersonNet person;
  final bool isLast;

  const _PersonRow({required this.person, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final owesYou = person.amount > 0.01;
    final settled = person.isSettled;
    final color = settled
        ? cs.onSurfaceVariant
        : (owesYou ? KuberColors.income : KuberColors.expense);
    final verb = settled
        ? 'all settled up'
        : (owesYou ? 'owes you' : 'you owe');
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: cs.outline, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: KuberSpacing.lg,
      ),
      child: Row(
        children: [
          BsAvatar(name: person.name, size: 40),
          const SizedBox(width: 12),

          // Name + sub-line
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$verb · ${person.bills} bill${person.bills == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Amount + label
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                settled ? '—' : formatter.format(person.amount.abs()),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (!settled) ...[
                const SizedBox(height: 1),
                Text(
                  owesYou ? 'TO YOU' : 'TO PAY',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── RECENT BILLS SECTION ──────────────────────────────────────────────────────

class _RecentBillsSection extends ConsumerWidget {
  final List<Bill> bills;

  const _RecentBillsSection({required this.bills});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT BILLS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                '${bills.length} TOTAL',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Bill cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: bills
                .map((bill) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BillRow(
                        bill: bill,
                        formattedAmount: formatter.formatCurrency(
                          bill.totalAmount,
                          symbol: currency.symbol,
                        ),
                        onTap: () => _showViewSheet(context, bill),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  void _showViewSheet(BuildContext context, Bill bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ViewBillSheet(bill: bill),
    );
  }
}

class _BillRow extends StatelessWidget {
  final Bill bill;
  final String formattedAmount;
  final VoidCallback onTap;

  const _BillRow({
    required this.bill,
    required this.formattedAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final status = billStatusForYou(bill);
    final yourShare = yourShareInBill(bill);
    final youInBill = bill.participants.any((p) => p.personName == kYouName);

    final Color statusColor;
    final String statusLabel;
    switch (status) {
      case BillStatus.youLent:
        statusColor = KuberColors.income;
        statusLabel = 'YOU LENT';
      case BillStatus.youOwe:
        statusColor = KuberColors.expense;
        statusLabel = 'YOU OWE';
      case BillStatus.settled:
        statusColor = cs.onSurfaceVariant;
        statusLabel = 'SETTLED';
      case BillStatus.notInvolved:
        statusColor = cs.onSurfaceVariant;
        statusLabel = '';
    }

    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: ShapeDecoration(
          color: cs.surfaceContainer,
          shape: bsSquircle(14, side: BorderSide(color: cs.outline),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: icon tile + name + amount
              Row(
                children: [
                  // 42×42 squircle icon tile
                  Container(
                    width: 42,
                    height: 42,
                    decoration: ShapeDecoration(
                      color: cs.surfaceContainerHigh,
                      shape: bsSquircle(12, side: BorderSide(color: cs.outline)),
                    ),
                    alignment: Alignment.center,
                    child:
                        Icon(Icons.receipt_long_rounded, color: cs.primary, size: 18),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Paid by ${bill.paidByPersonName} · ${bill.participants.length} people · ${DateFormat('d MMM').format(bill.createdAt)}',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  Text(
                    formattedAmount,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: cs.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),

              // Bottom strip: avatar stack + split badge + your share
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: cs.outline, width: 1)),
                  ),
                  child: Row(
                    children: [
                      // Avatar stack
                      _AvatarStack(
                          names: bill.participants
                              .map((p) => p.personName)
                              .toList()),
                      const SizedBox(width: 4),

                      // Split type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cs.outline),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _splitIcon(bill.splitType),
                              size: 10,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _splitLabel(bill.splitType),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Your share
                      if (youInBill) ...[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              statusLabel,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              status == BillStatus.settled
                                  ? '—'
                                  : formatter.format(yourShare),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: statusColor,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _splitIcon(String splitType) {
    return switch (splitType) {
      'equal' => Icons.drag_handle_rounded,
      'unequal' => Icons.edit_rounded,
      'percentage' => Icons.percent_rounded,
      'fraction' => Icons.call_split_rounded,
      _ => Icons.drag_handle_rounded,
    };
  }

  String _splitLabel(String splitType) {
    return switch (splitType) {
      'equal' => 'EQUAL',
      'unequal' => 'CUSTOM',
      'percentage' => 'PERCENT',
      'fraction' => 'FRACTION',
      _ => splitType.toUpperCase(),
    };
  }
}

class _AvatarStack extends StatelessWidget {
  final List<String> names;

  const _AvatarStack({required this.names});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shown = names.take(4).toList();
    final overflow = names.length - shown.length;
    final totalCount = shown.length + (overflow > 0 ? 1 : 0);
    // Each avatar is 24px wide, offset 16px from previous; last one has full 24px width.
    final stackWidth = totalCount == 0 ? 0.0 : (totalCount - 1) * 16.0 + 24.0;

    return SizedBox(
      width: stackWidth,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...shown.asMap().entries.map((entry) {
            return Positioned(
              left: entry.key * 16.0,
              child: BsAvatar(name: entry.value, size: 24),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: shown.length * 16.0,
              child: Container(
                width: 24,
                height: 24,
                decoration: ShapeDecoration(
                  color: cs.surfaceContainerHigh,
                  shape: bsSquircle(8, side: BorderSide(color: cs.outline)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$overflow',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
